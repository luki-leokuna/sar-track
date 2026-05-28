// ignore_for_file: dangling_library_doc_comments

/// [BACKEND] tracking_controller.dart
/// Jantung fitur pelacakan — kalkulasi jarak Haversine, manajemen SOS,
/// dan sinkronisasi GPS real-time ke Firebase.

import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sar_track/models/tracker_model.dart';
import 'package:sar_track/controllers/auth_controller.dart';
import 'package:sar_track/services/database_service.dart';
import 'package:sar_track/services/location_service.dart';

class TrackingController extends GetxController {
  final DatabaseService _dbService = DatabaseService();
  final LocationService _locationService = LocationService();

  AuthController get _authController => Get.find<AuthController>();

  // ─── State Reaktif ────────────────────────────────────────────────────────

  /// Daftar semua tracker anggota tim yang aktif
  final RxList<TrackerModel> teamTrackers = <TrackerModel>[].obs;

  /// Posisi GPS user sendiri saat ini
  final Rx<TrackerModel?> myTracker = Rx<TrackerModel?>(null);

  /// Status tracking sedang berjalan atau tidak
  final RxBool isTracking = false.obs;

  /// Status loading untuk operasi async
  final RxBool isLoading = false.obs;

  /// Pesan error
  final RxString errorMessage = ''.obs;

  // ─── Internal ─────────────────────────────────────────────────────────────

  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<List<TrackerModel>>? _teamSubscription;
  String? _activeTeamId;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onClose() {
    stopTracking();
    super.onClose();
  }

  // ─── Mulai Tracking ───────────────────────────────────────────────────────

  /// Mulai sesi tracking — minta izin GPS, stream posisi, dan dengarkan
  /// posisi seluruh anggota tim dari Firebase.
  Future<void> startTracking(String teamId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      _activeTeamId = teamId;

      // Minta izin GPS
      await _locationService.requestPermission();

      // Set status user menjadi Online di Firebase
      await _setMyStatus(teamId, MemberStatus.online);

      // Mulai stream posisi GPS dari perangkat
      _positionSubscription = _locationService.getPositionStream().listen(
        (position) => _onPositionUpdate(teamId, position),
      );

      // Mulai dengarkan posisi semua anggota tim dari Firebase
      _teamSubscription = _dbService
          .streamTeamTrackers(teamId)
          .listen((trackers) => teamTrackers.value = trackers);

      isTracking.value = true;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Stop Tracking ────────────────────────────────────────────────────────

  /// Hentikan tracking — batalkan semua stream dan set status Offline.
  Future<void> stopTracking() async {
    await _positionSubscription?.cancel();
    await _teamSubscription?.cancel();
    _positionSubscription = null;
    _teamSubscription = null;

    if (_activeTeamId != null) {
      final uid = _authController.currentUser.value?.uid;
      if (uid != null) {
        await _dbService.updateMemberStatus(
          _activeTeamId!,
          uid,
          MemberStatus.offline.value,
        );
      }
    }

    isTracking.value = false;
    _activeTeamId = null;
  }

  // ─── SOS ──────────────────────────────────────────────────────────────────

  /// Aktifkan sinyal SOS — update status di Firebase agar semua anggota
  /// tim menerima notifikasi darurat.
  Future<void> activateSOS() async {
    if (_activeTeamId == null) return;
    await _setMyStatus(_activeTeamId!, MemberStatus.sos);

    // Update state lokal segera tanpa tunggu stream
    if (myTracker.value != null) {
      myTracker.value = myTracker.value!.copyWith(status: MemberStatus.sos);
    }
  }

  /// Nonaktifkan SOS — kembali ke status Online
  Future<void> deactivateSOS() async {
    if (_activeTeamId == null) return;
    await _setMyStatus(_activeTeamId!, MemberStatus.online);

    if (myTracker.value != null) {
      myTracker.value = myTracker.value!.copyWith(status: MemberStatus.online);
    }
  }

  // ─── Kalkulasi Jarak ──────────────────────────────────────────────────────

  /// Hitung jarak antara user dan anggota lain dalam meter.
  /// Menggunakan Geolocator.distanceBetween() yang berbasis formula Haversine.
  double? distanceTo(TrackerModel target) {
    final me = myTracker.value;
    if (me == null) return null;

    return _locationService.distanceBetween(
      startLatitude: me.latitude,
      startLongitude: me.longitude,
      endLatitude: target.latitude,
      endLongitude: target.longitude,
    );
  }

  /// Daftar anggota tim diurutkan dari yang terdekat ke terjauh dari posisi user.
  List<TrackerModel> get sortedByProximity {
    final me = myTracker.value;
    if (me == null) return teamTrackers;

    final others = teamTrackers.where((t) => t.uid != me.uid).toList();

    others.sort((a, b) {
      final distA = distanceTo(a) ?? double.maxFinite;
      final distB = distanceTo(b) ?? double.maxFinite;
      return distA.compareTo(distB);
    });

    return others;
  }

  /// Anggota dalam kondisi SOS — digunakan UI untuk tampilkan peringatan
  List<TrackerModel> get sosMembers =>
      teamTrackers.where((t) => t.isSOS).toList();

  /// Anggota dengan status Delayed (tidak update > 2 menit)
  List<TrackerModel> get delayedMembers => teamTrackers
      .where((t) => t.isDelayed && t.uid != myTracker.value?.uid)
      .toList();

  // ─── Internal Helpers ─────────────────────────────────────────────────────

  /// Dipanggil setiap kali GPS device emit posisi baru.
  /// Update tracker data user ke Firebase.
  Future<void> _onPositionUpdate(String teamId, Position position) async {
    final user = _authController.currentUser.value;
    if (user == null) return;

    final currentStatus = myTracker.value?.status ?? MemberStatus.online;

    final tracker = TrackerModel(
      uid: user.uid,
      username: user.username,
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      status: currentStatus,
    );

    myTracker.value = tracker;
    await _dbService.updateTrackerData(teamId, tracker);
  }

  /// Update status anggota di Firebase
  Future<void> _setMyStatus(String teamId, MemberStatus status) async {
    final uid = _authController.currentUser.value?.uid;
    if (uid == null) return;
    await _dbService.updateMemberStatus(teamId, uid, status.value);
  }

  void clearError() => errorMessage.value = '';
}
