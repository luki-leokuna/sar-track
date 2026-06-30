// ignore_for_file: dangling_library_doc_comments

/// [BACKEND] auth_controller.dart
/// Manajemen session login dan routing halaman awal.
/// Menggabungkan AuthService + DatabaseService untuk alur register/login lengkap.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sar_track/models/user_model.dart';
import 'package:sar_track/services/auth_service.dart';
import 'package:sar_track/services/database_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  // ─── State Reaktif ────────────────────────────────────────────────────────

  /// Data user yang sedang login (null = belum login)
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  /// Status loading untuk disable tombol saat proses berlangsung
  final RxBool isLoading = false.obs;

  /// Pesan error untuk ditampilkan di UI
  final RxString errorMessage = ''.obs;

  /// Status loading khusus untuk proses kirim email reset password
  final RxBool isResetLoading = false.obs;

  /// Pesan error khusus untuk popup lupa kata sandi
  final RxString resetErrorMessage = ''.obs;

  /// Pesan sukses khusus untuk popup lupa kata sandi
  final RxString resetSuccessMessage = ''.obs;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    // Dengarkan perubahan status auth Firebase secara real-time.
    // Setiap kali user login/logout, routing otomatis dijalankan.
    ever(_bindAuthState(), _handleAuthStateChange);
  }

  /// Bind Firebase authStateChanges ke `Rx<User?>` untuk didengarkan ever()
  Rx<User?> _bindAuthState() {
    final rxUser = Rx<User?>(null);
    _authService.authStateChanges.listen((user) {
      rxUser.value = user;
    });
    return rxUser;
  }

  /// Handler utama perubahan status login.
  /// Dipanggil otomatis setiap kali authStateChanges emit nilai baru.
  void _handleAuthStateChange(User? firebaseUser) async {
    if (firebaseUser == null) {
      // User logout → bersihkan data lokal dan ke halaman Login
      currentUser.value = null;
      await _navigateSafely('/login');
    } else {
      // User login → ambil profil dari database lalu ke Dashboard
      try {
        final user = await _dbService.getUser(firebaseUser.uid);
        currentUser.value = user;
      } catch (e) {
        // Gagal ambil profil (misal permission-denied di Database Rules).
        // Tetap lanjut ke dashboard agar user tidak "tersangkut" di halaman login;
        // tampilkan pesan agar masalah Rules tetap kelihatan saat development.
        errorMessage.value = 'Login berhasil, tetapi gagal memuat profil: $e';
        currentUser.value = UserModel(
          uid: firebaseUser.uid,
          username: firebaseUser.email?.split('@').first ?? 'User',
          email: firebaseUser.email ?? '',
        );
      }
      await _navigateSafely('/dashboard');
    }
  }

  /// Navigasi aman — menunda satu microtask supaya GetMaterialApp
  /// sudah selesai mount sebelum Get.offAllNamed() dipanggil.
  /// Tanpa ini, AuthController yang di-put SEBELUM runApp() bisa
  /// memicu navigasi sebelum widget tree siap ("contextless navigation").
  Future<void> _navigateSafely(String route) async {
    await Future.delayed(Duration.zero);
    Get.offAllNamed(route);
  }

  // ─── Register ─────────────────────────────────────────────────────────────

  /// Daftar akun baru dengan email, password, dan username.
  /// Otomatis simpan profil ke database setelah akun dibuat.
  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {
    if (!_validateInputs(
      email: email,
      password: password,
      username: username,
    )) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final credential = await _authService.registerWithEmail(
        email: email,
        password: password,
      );

      if (credential?.user != null) {
        final newUser = UserModel(
          uid: credential!.user!.uid,
          username: username.trim(),
          email: email.trim(),
        );
        // Simpan profil ke Firebase Realtime Database
        await _dbService.saveUser(newUser);
        currentUser.value = newUser;
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Login Email ──────────────────────────────────────────────────────────

  /// Login dengan email dan password.
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      errorMessage.value = 'Email dan password tidak boleh kosong.';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.loginWithEmail(email: email, password: password);
      // Routing ditangani otomatis oleh _handleAuthStateChange
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Login Google ─────────────────────────────────────────────────────────

  /// Login dengan Google — jika akun baru, profil otomatis dibuat di database.
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final credential = await _authService.loginWithGoogle();

      if (credential?.user != null) {
        final firebaseUser = credential!.user!;

        // Cek apakah profil sudah ada di database (akun lama)
        final existingUser = await _dbService.getUser(firebaseUser.uid);

        if (existingUser == null) {
          // Akun baru via Google → buat profil baru
          final newUser = UserModel(
            uid: firebaseUser.uid,
            username: firebaseUser.displayName ?? 'Anggota SAR',
            email: firebaseUser.email ?? '',
            profileImageUrl: firebaseUser.photoURL ?? '',
          );
          await _dbService.saveUser(newUser);
          currentUser.value = newUser;
        } else {
          currentUser.value = existingUser;
        }
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Ganti Kata Sandi ─────────────────────────────────────────────────────

  /// Mengganti kata sandi pengguna dengan memverifikasi kata sandi lama terlebih dahulu.
  Future<void> changePassword({required String oldPassword, required String newPassword}) async {
    try {
      isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        Get.snackbar('Gagal', 'Sesi login tidak valid.', 
            backgroundColor: Colors.red.shade50, colorText: Colors.red.shade800, margin: const EdgeInsets.all(16));
        return;
      }

      // Re-authenticate first
      final credential = EmailAuthProvider.credential(email: user.email!, password: oldPassword);
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      Get.back();
      Get.snackbar('Sukses', 'Kata sandi berhasil diperbarui.', 
          backgroundColor: Colors.green.shade50, colorText: Colors.green.shade800, margin: const EdgeInsets.all(16));
    } on FirebaseAuthException catch (e) {
      String message = 'Terjadi kesalahan.';
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Kata sandi saat ini salah.';
      } else if (e.code == 'weak-password') {
        message = 'Kata sandi baru terlalu lemah.';
      } else if (e.code == 'requires-recent-login') {
        message = 'Sesi telah kedaluwarsa. Silakan login ulang untuk mengganti kata sandi.';
      } else {
        message = e.message ?? e.toString();
      }
      Get.snackbar('Gagal', message, 
          backgroundColor: Colors.red.shade50, colorText: Colors.red.shade800, margin: const EdgeInsets.all(16));
    } catch (e) {
      Get.snackbar('Gagal', 'Terjadi kesalahan: $e', 
          backgroundColor: Colors.red.shade50, colorText: Colors.red.shade800, margin: const EdgeInsets.all(16));
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  /// Logout dari aplikasi — routing ke Login ditangani oleh authStateChanges.
  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _authService.logout();
      currentUser.value = null;
    } catch (e) {
      errorMessage.value = 'Gagal logout: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Lupa Kata Sandi ──────────────────────────────────────────────────────

  /// Kirim email reset password. Mengembalikan true jika berhasil dikirim,
  /// sehingga UI (popup) tahu kapan harus menampilkan pesan sukses.
  Future<bool> resetPassword({required String email}) async {
    resetErrorMessage.value = '';
    resetSuccessMessage.value = '';

    if (email.trim().isEmpty) {
      resetErrorMessage.value = 'Masukkan email terlebih dahulu.';
      return false;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email.trim())) {
      resetErrorMessage.value = 'Format email tidak valid.';
      return false;
    }

    try {
      isResetLoading.value = true;
      await _authService.sendPasswordResetEmail(email: email);
      resetSuccessMessage.value =
          'Tautan reset password telah dikirim ke $email. Periksa kotak masuk (atau folder spam) email kamu.';
      return true;
    } catch (e) {
      resetErrorMessage.value = e.toString();
      return false;
    } finally {
      isResetLoading.value = false;
    }
  }

  /// Bersihkan pesan-pesan terkait popup lupa kata sandi (dipanggil saat popup dibuka/ditutup)
  void clearResetMessages() {
    resetErrorMessage.value = '';
    resetSuccessMessage.value = '';
  }

  // ─── Helper ───────────────────────────────────────────────────────────────

  /// Validasi input form register
  bool _validateInputs({
    required String email,
    required String password,
    required String username,
  }) {
    if (username.trim().isEmpty) {
      errorMessage.value = 'Nama tidak boleh kosong.';
      return false;
    }
    if (email.trim().isEmpty) {
      errorMessage.value = 'Email tidak boleh kosong.';
      return false;
    }
    if (password.length < 6) {
      errorMessage.value = 'Password minimal 6 karakter.';
      return false;
    }
    return true;
  }

  /// Bersihkan pesan error (dipanggil saat user mulai mengetik lagi)
  void clearError() => errorMessage.value = '';
}