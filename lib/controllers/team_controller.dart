import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sar_track/services/database_service.dart';
import 'package:sar_track/controllers/auth_controller.dart';
import 'package:sar_track/models/team_model.dart';
import 'package:sar_track/models/user_model.dart';

class TeamController extends GetxController {
  final DatabaseService _dbService = Get.find();
  final AuthController _authController = Get.find();

  final Rx<TeamModel?> activeTeam = Rx<TeamModel?>(null);
  final RxBool isLoading = RxBool(false);
  final RxString errorMessage = RxString('');

  // Dua subscription terpisah: satu untuk user stream, satu untuk team stream
  StreamSubscription<UserModel?>? _userSubscription;
  StreamSubscription<TeamModel?>? _teamSubscription;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();

    // Saat user login/logout, update tim aktif
    ever(_authController.currentUser, (user) {
      if (user != null) {
        _listenToActiveTeam(user.uid);
      } else {
        _userSubscription?.cancel();
        _teamSubscription?.cancel();
        activeTeam.value = null;
      }
    });

    // Kalau user sudah login saat controller dibuat, langsung load
    final uid = _authController.currentUser.value?.uid;
    if (uid != null) _listenToActiveTeam(uid);
  }

  @override
  void onClose() {
    _userSubscription?.cancel();
    _teamSubscription?.cancel();
    super.onClose();
  }

  // ── Active Team Listener ───────────────────────────────────────────────────

  /// Stream user profil → baca activeTeamId → stream tim secara real-time.
  /// Ini yang memastikan tim aktif ter-restore saat app dibuka kembali.
  void _listenToActiveTeam(String uid) {
    _userSubscription?.cancel();
    _teamSubscription?.cancel();

    // Stream 1: listen ke profil user untuk dapat activeTeamId
    _userSubscription = _dbService
        .streamUser(uid)
        .listen(
          (user) {
            if (user == null) return;

            final teamId = user.activeTeamId;
            if (teamId == null || teamId.isEmpty) {
              activeTeam.value = null;
              _teamSubscription?.cancel();
              return;
            }

            // Stream 2: listen ke data tim secara real-time
            _teamSubscription?.cancel();
            _teamSubscription = _dbService
                .streamTeam(teamId)
                .listen(
                  (team) {
                    activeTeam.value = team;
                  },
                  onError: (e) {
                    debugPrint('[TeamController] Stream team error: $e');
                  },
                );
          },
          onError: (e) {
            debugPrint('[TeamController] Stream user error: $e');
          },
        );
  }

  // ── Create Team ───────────────────────────────────────────────────────────

  Future<void> createTeam(
    String teamName, {
    double gpsDistanceFilter = 3.5,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final uid = _authController.currentUser.value?.uid;
      if (uid == null) throw 'User tidak terautentikasi';
      if (teamName.trim().isEmpty) throw 'Nama tim tidak boleh kosong';

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final teamId =
          'SAR-${timestamp.toString().substring(7, 13).toUpperCase()}';

      final newTeam = TeamModel(
        teamId: teamId,
        teamName: teamName.trim(),
        createdAt: timestamp,
        members: [uid],
        gpsDistanceFilter: gpsDistanceFilter,
      );

      await _dbService.createTeam(newTeam);
      await _dbService.updateUser(uid, {'activeTeamId': teamId});
      activeTeam.value = newTeam;

      await Future.delayed(Duration.zero);
      Get.offAllNamed('/tracking', arguments: {'teamId': teamId});
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Join Team ─────────────────────────────────────────────────────────────

  Future<void> joinTeam(String teamCode) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final uid = _authController.currentUser.value?.uid;
      if (uid == null) throw 'User tidak terautentikasi';

      final code = teamCode.trim().toUpperCase();
      if (!code.startsWith('SAR-') || code.length < 8) {
        throw 'Format kode tim tidak valid. Contoh: SAR-AB12CD';
      }

      final team = await _dbService.getTeam(code);
      if (team == null) throw 'Tim dengan kode $code tidak ditemukan';
      if (team.hasMember(uid)) throw 'Anda sudah tergabung di tim ini';

      await _dbService.addMemberToTeam(code, uid);
      await _dbService.updateUser(uid, {'activeTeamId': code});

      final updatedTeam = await _dbService.getTeam(code);
      activeTeam.value = updatedTeam;

      await Future.delayed(Duration.zero);
      Get.offAllNamed('/tracking', arguments: {'teamId': code});
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Update GPS Interval ───────────────────────────────────────────────────

  Future<void> updateGpsInterval(double newInterval) async {
    try {
      final team = activeTeam.value;
      if (team == null) throw 'Tidak ada tim aktif';

      final uid = _authController.currentUser.value?.uid;
      if (uid == null) throw 'User tidak terautentikasi';
      if (!team.isCreator(uid)) {
        throw 'Hanya leader tim yang bisa mengubah GPS interval';
      }

      await _dbService.updateGpsDistanceFilter(team.teamId, newInterval);
      activeTeam.value = team.copyWith(gpsDistanceFilter: newInterval);

      await _dbService.broadcastTeamAction(team.teamId, {
        'type': 'GPS_INTERVAL_CHANGED',
        'by': uid,
        'from': team.gpsDistanceFilter,
        'to': newInterval,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool isTeamLeader(String? uid) {
    if (uid == null || activeTeam.value == null) return false;
    return activeTeam.value!.isCreator(uid);
  }

  void clearError() => errorMessage.value = '';
}
