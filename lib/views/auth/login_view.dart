import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sar_track/views/auth/register_view.dart';
import 'package:sar_track/controllers/auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordObscured = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Latar belakang putih keabu-abuan
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // 1. Logo Aplikasi
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF131A26), // Warna kotak logo gelap
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4A5568), // Lingkaran di belakang icon
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on, 
                        color: Color(0xFFFF6B00), // Warna oranye pin
                        size: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // 2. Judul & Subjudul
                const Text(
                  "SAR-TRACK",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF131A26), // Biru gelap/hitam
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Sistem Koordinasi Lapangan Terintegrasi",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6C757D),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // 3. Card Form Login
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tombol Login dengan Google
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            authController.loginWithGoogle();
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: _buildGoogleIcon(),
                          label: const Text(
                            "Login dengan Google",
                            style: TextStyle(
                              color: Color(0xFF212529),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Divider "ATAU"
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              "ATAU",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Input Email
                      const Text(
                        "Email",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF495057),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) => authController.clearError(),
                        decoration: InputDecoration(
                          hintText: "nama@instansi.go.id",
                          hintStyle: const TextStyle(color: Color(0xFFAEB5BC), fontSize: 14),
                          prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF6C757D), size: 20),
                          filled: true,
                          fillColor: const Color(0xFFF1F3F5),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFFF6600)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Input Kata Sandi
                      const Text(
                        "Kata Sandi",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF495057),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passwordController,
                        obscureText: isPasswordObscured,
                        onChanged: (_) => authController.clearError(),
                        decoration: InputDecoration(
                          hintText: "••••••••",
                          hintStyle: const TextStyle(color: Color(0xFFAEB5BC), fontSize: 14),
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6C757D), size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                              color: const Color(0xFF6C757D),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordObscured = !isPasswordObscured;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF1F3F5),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFFF6600)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Lupa kata sandi?
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _showForgotPasswordDialog(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            "Lupa kata sandi?",
                            style: TextStyle(
                              color: Color(0xFFB54504), // Warna oranye tua
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tombol Masuk via Email
                      Obx(() => authController.errorMessage.value.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                authController.errorMessage.value,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          : const SizedBox.shrink()),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: Obx(() => ElevatedButton(
                          onPressed: authController.isLoading.value
                              ? null
                              : () {
                                  authController.loginWithEmail(
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6600), // Oranye
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: authController.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Masuk",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Link Pendaftaran
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Belum punya akun? ",
                      style: TextStyle(color: Color(0xFF495057), fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => const RegisterView());
                      },
                      child: const Text(
                        "Daftar",
                        style: TextStyle(
                          color: Color(0xFFB54504),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Footer (3 Icons)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFooterFeature(Icons.verified_user_outlined, "AMAN"),
                    const SizedBox(width: 32),
                    _buildFooterFeature(Icons.track_changes_outlined, "REAL-TIME"),
                    const SizedBox(width: 32),
                    _buildFooterFeature(Icons.gpp_good_outlined, "ENKRIPSI"),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget sementara untuk icon Google karena kita tidak menggunakan asset gambar
  Widget _buildGoogleIcon() {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: Color(0xFFF1F3F5),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          "G",
          style: TextStyle(
            color: Color(0xFF4285F4),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ─── Popup Lupa Kata Sandi ────────────────────────────────────────────────

  /// Menampilkan popup untuk mengirim email reset password.
  /// Mengisi email otomatis dari field login jika sudah diketik.
  void _showForgotPasswordDialog(BuildContext context) {
    authController.clearResetMessages();
    final TextEditingController resetEmailController =
        TextEditingController(text: emailController.text.trim());

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Builder(
                builder: (context) {
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon + Judul
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1E6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.lock_reset,
                                color: Color(0xFFFF6600),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Text(
                                "Lupa Kata Sandi",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF131A26),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(dialogContext),
                              child: const Icon(Icons.close, color: Color(0xFF6C757D), size: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Masukkan email akunmu. Kami akan mengirimkan tautan untuk mengatur ulang kata sandi.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6C757D),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Pesan sukses (jika email berhasil dikirim)
                        Obx(() {
                          final success = authController.resetSuccessMessage.value;
                          if (success.isEmpty) return const SizedBox.shrink();
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9F7EF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFB7E4C7)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    success,
                                    style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 12.5, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        // Form input email — disembunyikan setelah sukses
                        Obx(() {
                          if (authController.resetSuccessMessage.value.isNotEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Email",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF495057),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: resetEmailController,
                                keyboardType: TextInputType.emailAddress,
                                autofocus: true,
                                onChanged: (_) => authController.resetErrorMessage.value = '',
                                decoration: InputDecoration(
                                  hintText: "nama@instansi.go.id",
                                  hintStyle: const TextStyle(color: Color(0xFFAEB5BC), fontSize: 14),
                                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF6C757D), size: 20),
                                  filled: true,
                                  fillColor: const Color(0xFFF1F3F5),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFFFF6600)),
                                  ),
                                ),
                              ),
                              // Pesan error
                              Obx(() {
                                final error = authController.resetErrorMessage.value;
                                if (error.isEmpty) return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    error,
                                    style: const TextStyle(color: Colors.red, fontSize: 12),
                                  ),
                                );
                              }),
                              const SizedBox(height: 20),
                            ],
                          );
                        }),

                        // Tombol Aksi
                        Obx(() {
                          final sudahSukses = authController.resetSuccessMessage.value.isNotEmpty;

                          if (sudahSukses) {
                            return SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6600),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "Tutup",
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          }

                          return Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 46,
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pop(dialogContext),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.grey.shade300),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      "Batal",
                                      style: TextStyle(color: Color(0xFF495057), fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 46,
                                  child: ElevatedButton(
                                    onPressed: authController.isResetLoading.value
                                        ? null
                                        : () async {
                                            await authController.resetPassword(
                                              email: resetEmailController.text,
                                            );
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF6600),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: authController.isResetLoading.value
                                        ? const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            "Kirim Tautan",
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    ).then((_) {
      // Bersihkan pesan saat popup ditutup agar tidak muncul lagi di pembukaan berikutnya
      authController.clearResetMessages();
    });
  }

  Widget _buildFooterFeature(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFAEB5BC), size: 22),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFAEB5BC),
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}