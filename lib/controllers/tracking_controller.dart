import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sar_track/models/tracker_model.dart';
import 'package:sar_track/models/team_model.dart';
import 'package:sar_track/services/database_service.dart';
import 'package:sar_track/services/location_service.dart';
import 'package:sar_track/controllers/auth_controller.dart';
import 'package:sar_track/controllers/team_controller.dart';

class TrackingController extends GetxController {
  final DatabaseService _dbService = Get.find();
  final LocationService _locationService = LocationService();
  final AuthController _authController = Get.find();
  final TeamController _teamController = Get.find();

  // State
  final RxBool isTracking = RxBool(false);
  final RxList<TrackerModel> teamTrackers = RxList<TrackerModel>([]);
  final Rx<TrackerModel?> myTracker = Rx<TrackerModel?>(null);

  // Subscription & worker — nullable supaya onClose() aman meski belum diinit
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<List<TrackerModel>>? _teamTrackersSubscription;
  Worker? _gpsIntervalWorker;

  double _currentGpsInterval = 3.5;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void onClose() {
    _positionSubscription?.cancel();
    _teamTrackersSubscription?.cancel();
    _gpsIntervalWorker?.dispose();
    super.onClose();
  }

  // ── Start Tracking ─────────────────────────────────────────────────────────

  /// Mulai tracking untuk tim dengan teamId.
  /// Guard: tidak restart jika sudah tracking.
  Future<void> startTracking(String teamId) async {
    if (isTracking.value) return;

    try {
      final uid = _authController.currentUser.value?.uid;
      if (uid == null) throw 'User tidak terautentikasi';

      isTracking.value = true;

      // Ambil data tim untuk dapat GPS interval awal
      final team = await _dbService.getTeam(teamId);
      if (team == null) throw 'Tim tidak ditemukan';

      _currentGpsInterval = team.gpsDistanceFilter;

      // Minta permission GPS
      await _locationService.requestPermission();

      // Ambil posisi awal dengan akurasi rendah tapi CEPAT (< 2 detik)
      // supaya peta langsung ada titik, tidak kosong menunggu GPS lock.
      // Stream akurat tetap berjalan di background untuk update presisi.
      _getInitialPositionFast(teamId, uid);

      // Stream tracker semua anggota tim dari Firebase
      _teamTrackersSubscription = _dbService.streamTeamTrackers(teamId).listen((
        trackers,
      ) {
        teamTrackers.value = trackers;
        myTracker.value = trackers.firstWhereOrNull((t) => t.uid == uid);
      });

      // Listen perubahan GPS interval dari leader
      _setupGpsIntervalListener(teamId);

      // Mulai GPS stream dengan interval dari tim
      _startPositionStream(teamId, uid, _currentGpsInterval);
    } catch (e) {
      isTracking.value = false;
      rethrow;
    }
  }

  // ── Fast Initial Position ─────────────────────────────────────────────────

  /// Ambil posisi awal dengan akurasi rendah supaya peta langsung ada titik.
  /// Tidak di-await — berjalan di background parallel dengan stream.
  /// Setelah dapat posisi pertama, stream akurat akan override nilainya.
  void _getInitialPositionFast(String teamId, String uid) async {
    try {
      // Timeout 5 detik — kalau lewat, biarkan stream yang handle
      final position =
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.lowest, // Cepat, pakai WiFi/cell tower
            ),
          ).timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw 'GPS timeout — menunggu stream',
          );

      // Upload posisi awal ke Firebase — tidak ada filter akurasi di sini
      // karena tujuannya memang cepat, bukan presisi.
      // Stream akurat akan override ini begitu GPS lock.
      await _dbService.setTrackerData(teamId, uid, {
        'uid': uid,
        'username': _authController.currentUser.value?.username ?? 'Unknown',
        'latitude': position.latitude,
        'longitude': position.longitude,
        'status': MemberStatus.online.name,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'accuracy': position.accuracy,
        'isSOS': false,
      });

      // Update local state supaya peta langsung pindah ke posisi user
      myTracker.value = TrackerModel(
        uid: uid,
        username: _authController.currentUser.value?.username ?? 'Unknown',
        latitude: position.latitude,
        longitude: position.longitude,
        status: MemberStatus.online,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      // Tidak perlu handle — stream akurat akan dapat posisi sendiri
      debugPrint('[GPS Fast Init] $e');
    }
  }

  // ── GPS Interval Listener ──────────────────────────────────────────────────

  /// Dengarkan perubahan `gpsDistanceFilter` di `activeTeam`.
  /// Jika berubah, restart position stream dengan filter baru.
  void _setupGpsIntervalListener(String teamId) {
    // Fix error 1: import TeamModel + ever<TeamModel?> sekarang valid
    _gpsIntervalWorker = ever<TeamModel?>(_teamController.activeTeam, (team) {
      if (team == null) return;

      final newInterval = team.gpsDistanceFilter;
      if (newInterval != _currentGpsInterval) {
        _currentGpsInterval = newInterval;
        final uid = _authController.currentUser.value?.uid;
        if (uid != null) {
          _restartPositionStream(teamId, uid, newInterval);
        }
      }
    });
  }

  // ── Position Stream ────────────────────────────────────────────────────────

  void _startPositionStream(String teamId, String uid, double distanceFilter) {
    _positionSubscription?.cancel();
    _positionSubscription = _createPositionStream(distanceFilter).listen(
      (position) => _onPositionUpdate(teamId, uid, position),
      onError: (e) => debugPrint('[GPS Error] $e'),
    );
  }

  void _restartPositionStream(String teamId, String uid, double newInterval) {
    _positionSubscription?.cancel();
    _startPositionStream(teamId, uid, newInterval);
  }

  /// Buat GPS stream dengan distanceFilter dinamis.
  /// Fix error 2: distanceFilter di LocationSettings adalah int,
  /// jadi kita round double ke int terdekat.
  Stream<Position> _createPositionStream(double distanceFilter) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter.round(), // double → int
      ),
    );
  }

  // ── Position Update ────────────────────────────────────────────────────────

  Future<void> _onPositionUpdate(
    String teamId,
    String uid,
    Position position,
  ) async {
    try {
      // Toleransi akurasi dinaikkan ke 100m supaya posisi dari
      // WiFi/cell tower (50-100m) tetap diterima.
      // Untuk SAR, lebih baik posisi kasar daripada tidak ada sama sekali.
      if (position.accuracy > 100) {
        debugPrint('[GPS] Accuracy too poor (${position.accuracy}m), skip');
        return;
      }

      // Fix error 3: TrackerModel tidak punya field `accuracy`,
      // jadi dihapus dari konstruktor. Accuracy tetap dikirim ke Firebase.
      final tracker = TrackerModel(
        uid: uid,
        username: _authController.currentUser.value?.username ?? 'Unknown',
        latitude: position.latitude,
        longitude: position.longitude,
        status: MemberStatus.online,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      // Upload posisi + accuracy ke Firebase
      await _dbService.setTrackerData(teamId, uid, {
        'uid': uid,
        'username': tracker.username,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'status': tracker.status.name,
        'timestamp': tracker.timestamp,
        'accuracy': position.accuracy, // disimpan di Firebase, bukan di model
        'isSOS': false,
      });

      myTracker.value = tracker;
    } catch (e) {
      debugPrint('[GPS Update Error] $e');
    }
  }

  // ── Stop Tracking ──────────────────────────────────────────────────────────

  Future<void> stopTracking() async {
    if (!isTracking.value) return;

    try {
      final uid = _authController.currentUser.value?.uid;
      final teamId = _teamController.activeTeam.value?.teamId;

      if (uid != null && teamId != null) {
        await _dbService.removeTracker(teamId, uid);
      }

      _positionSubscription?.cancel();
      _teamTrackersSubscription?.cancel();
      _gpsIntervalWorker?.dispose();

      isTracking.value = false;
      myTracker.value = null;
    } catch (e) {
      debugPrint('[Stop Tracking Error] $e');
    }
  }

  // ── SOS ───────────────────────────────────────────────────────────────────

  Future<void> activateSOS() async {
    try {
      final uid = _authController.currentUser.value?.uid;
      final teamId = _teamController.activeTeam.value?.teamId;
      if (uid == null || teamId == null) throw 'User atau tim tidak valid';

      await _dbService.updateTrackerData(teamId, uid, {
        'status': MemberStatus.sos.name,
        'isSOS': true,
      });

      if (myTracker.value != null) {
        myTracker.value = myTracker.value!.copyWith(status: MemberStatus.sos);
      }
    } catch (e) {
      debugPrint('[SOS Error] $e');
    }
  }

  Future<void> deactivateSOS() async {
    try {
      final uid = _authController.currentUser.value?.uid;
      final teamId = _teamController.activeTeam.value?.teamId;
      if (uid == null || teamId == null) throw 'User atau tim tidak valid';

      await _dbService.updateTrackerData(teamId, uid, {
        'status': MemberStatus.online.name,
        'isSOS': false,
      });

      if (myTracker.value != null) {
        myTracker.value = myTracker.value!.copyWith(
          status: MemberStatus.online,
        );
      }
    } catch (e) {
      debugPrint('[Deactivate SOS Error] $e');
    }
  }

  // ── Distance ──────────────────────────────────────────────────────────────

  /// Hitung jarak ke tracker lain dalam meter.
  /// Return null jika posisi sendiri belum diketahui.
  double? distanceTo(TrackerModel tracker) {
    final myPos = myTracker.value;
    if (myPos == null) return null;

    return _locationService.distanceBetween(
      startLatitude: myPos.latitude,
      startLongitude: myPos.longitude,
      endLatitude: tracker.latitude,
      endLongitude: tracker.longitude,
    );
  }
}
