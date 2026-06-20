// ignore_for_file: dangling_library_doc_comments

/// [BACKEND] auth_service.dart
/// Layanan autentikasi — komunikasi langsung ke Firebase Auth.
/// Mendukung Email/Password dan Google Sign-In.
/// Controller TIDAK boleh panggil Firebase Auth langsung, harus lewat file ini.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  // ─── Stream ────────────────────────────────────────────────────────────────

  /// Stream status login — didengarkan oleh AuthController
  /// untuk auto-redirect halaman awal.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// User yang sedang login saat ini (null jika belum login)
  User? get currentUser => _auth.currentUser;

  // ─── Email / Password ──────────────────────────────────────────────────────

  /// Daftar akun baru dengan email & password.
  Future<UserCredential?> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _parseAuthException(e);
    }
  }

  /// Login dengan email & password.
  Future<UserCredential?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _parseAuthException(e);
    }
  }

  /// Kirim email reset password ke alamat email yang diberikan.
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _parseAuthException(e);
    }
  }

  // ─── Google Sign-In ────────────────────────────────────────────────────────

  /// Login menggunakan akun Google.
  Future<UserCredential?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleAccount = await _googleSignIn.signIn();

      // User membatalkan dialog
      if (googleAccount == null) return null;

      // Ambil token — tidak pakai await karena bukan Future di versi ini
      final GoogleSignInAuthentication googleAuth =
          await googleAccount.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _parseAuthException(e);
    } catch (e) {
      throw 'Gagal login dengan Google. Coba lagi.';
    }
  }

  // ─── Logout ────────────────────────────────────────────────────────────────

  /// Logout dari semua metode (Email/Password maupun Google).
  Future<void> logout() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  // ─── Helper ────────────────────────────────────────────────────────────────

  /// Konversi kode error Firebase → pesan ramah pengguna (Bahasa Indonesia)
  String _parseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Akun dengan email ini tidak ditemukan.';
      case 'wrong-password':
        return 'Password yang kamu masukkan salah.';
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar. Silakan login.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah. Minimal 6 karakter.';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan.';
      default:
        return 'Terjadi kesalahan: ${e.message}';
    }
  }
}