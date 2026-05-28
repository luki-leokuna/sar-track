// ignore_for_file: dangling_library_doc_comments

/// [BACKEND] team_controller.dart
/// Logika pembentukan tim dan validasi kode masuk.
/// Mengelola state tim aktif yang sedang diikuti user.

import 'dart:math';
import 'package:get/get.dart';
import 'package:sar_track/models/team_model.dart';
import 'package:sar_track/controllers/auth_controller.dart';
import 'package:sar_track/services/database_service.dart';

class TeamController extends GetxController {
  final DatabaseService _dbService = DatabaseService();

  // AuthController diakses via GetX — tidak perlu inject manual
  AuthController get _authController => Get.find<AuthController>();

  // ─── State Reaktif ────────────────────────────────────────────────────────

  /// Tim yang sedang aktif diikuti user
  final Rx<TeamModel?> activeTeam = Rx<TeamModel?>(null);

  /// Status loading
  final RxBool isLoading = false.obs;

  /// Pesan error untuk UI
  final RxString errorMessage = ''.obs;

  // ─── Buat Tim ─────────────────────────────────────────────────────────────

  /// Buat tim baru dengan nama yang diberikan.
  /// TeamId di-generate otomatis dengan format SAR-XXXXXX (6 karakter acak).
  Future<void> createTeam(String teamName) async {
    if (teamName.trim().isEmpty) {
      errorMessage.value = 'Nama tim tidak boleh kosong.';
      return;
    }

    final uid = _authController.currentUser.value?.uid;
    if (uid == null) {
      errorMessage.value = 'Sesi login tidak valid. Silakan login ulang.';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final teamId = _generateTeamId();
      final now = DateTime.now().millisecondsSinceEpoch;

      final newTeam = TeamModel(
        teamId: teamId,
        teamName: teamName.trim(),
        createdAt: now,
        members: [uid], // Pembuat tim otomatis jadi anggota pertama
      );

      await _dbService.createTeam(newTeam);
      activeTeam.value = newTeam;

      // Mulai dengarkan perubahan tim secara real-time
      _listenToTeam(teamId);

      // Navigasi ke halaman tracking
      Get.offAllNamed('/tracking', arguments: {'teamId': teamId});
    } catch (e) {
      errorMessage.value = 'Gagal membuat tim: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Gabung Tim ───────────────────────────────────────────────────────────

  /// Gabung ke tim yang sudah ada menggunakan kode teamId.
  /// Validasi: tim harus ada, user belum tergabung.
  Future<void> joinTeam(String teamId) async {
    final cleanId = teamId.trim().toUpperCase();

    if (cleanId.isEmpty) {
      errorMessage.value = 'Kode tim tidak boleh kosong.';
      return;
    }

    // Validasi format kode — harus SAR-XXXXXX
    if (!RegExp(r'^SAR-[A-Z0-9]{6}$').hasMatch(cleanId)) {
      errorMessage.value = 'Format kode tim tidak valid. Contoh: SAR-AB12CD';
      return;
    }

    final uid = _authController.currentUser.value?.uid;
    if (uid == null) {
      errorMessage.value = 'Sesi login tidak valid. Silakan login ulang.';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Cek apakah tim dengan kode ini ada
      final team = await _dbService.getTeam(cleanId);
      if (team == null) {
        errorMessage.value = 'Tim dengan kode "$cleanId" tidak ditemukan.';
        return;
      }

      // Cek apakah user sudah tergabung
      if (team.hasMember(uid)) {
        errorMessage.value = 'Kamu sudah tergabung di tim ini.';
        return;
      }

      // Tambahkan uid ke daftar members
      await _dbService.addMemberToTeam(cleanId, uid);
      activeTeam.value = team;

      // Mulai dengarkan perubahan tim secara real-time
      _listenToTeam(cleanId);

      // Navigasi ke halaman tracking
      Get.offAllNamed('/tracking', arguments: {'teamId': cleanId});
    } catch (e) {
      errorMessage.value = 'Gagal bergabung: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Real-Time Listener ───────────────────────────────────────────────────

  /// Dengarkan perubahan data tim dari Firebase secara real-time.
  /// Dipanggil setelah berhasil buat atau gabung tim.
  void _listenToTeam(String teamId) {
    _dbService.streamTeam(teamId).listen((team) {
      if (team != null) {
        activeTeam.value = team;
      }
    });
  }

  // ─── Helper ───────────────────────────────────────────────────────────────

  /// Generate kode tim unik format SAR-XXXXXX (6 karakter alfanumerik kapital)
  String _generateTeamId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    final code = List.generate(
      6,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
    return 'SAR-$code';
  }

  /// Bersihkan state tim saat user keluar dari sesi tracking
  void clearTeam() {
    activeTeam.value = null;
    errorMessage.value = '';
  }

  void clearError() => errorMessage.value = '';
}
