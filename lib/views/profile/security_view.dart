import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sar_track/controllers/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SecurityView extends StatefulWidget {
  const SecurityView({super.key});

  @override
  State<SecurityView> createState() => _SecurityViewState();
}

class _SecurityViewState extends State<SecurityView> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isOldPassObscured = true;
  bool isNewPassObscured = true;
  bool isConfirmPassObscured = true;

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitChangePassword() async {
    final oldPass = oldPasswordController.text;
    final newPass = newPasswordController.text;
    final confirmPass = confirmPasswordController.text;

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Semua kolom harus diisi.',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
        margin: const EdgeInsets.all(16),
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (newPass != confirmPass) {
      Get.snackbar(
        'Gagal',
        'Kata sandi baru tidak cocok.',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
        margin: const EdgeInsets.all(16),
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (newPass.length < 6) {
      Get.snackbar(
        'Gagal',
        'Kata sandi baru minimal 6 karakter.',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
        margin: const EdgeInsets.all(16),
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    await authController.changePassword(
      oldPassword: oldPass,
      newPassword: newPass,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mengecek apakah user login menggunakan provider selain password (misal Google)
    // Jika provider utamanya google.com, fitur ganti password disembunyikan
    final currentUser = FirebaseAuth.instance.currentUser;
    final isGoogleSignIn =
        currentUser?.providerData.any(
          (userInfo) => userInfo.providerId == 'google.com',
        ) ??
        false;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF131A26)),
        title: const Text(
          "Security",
          style: TextStyle(
            color: Color(0xFF131A26),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: isGoogleSignIn
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    "Akun ini masuk menggunakan Google. Pengaturan kata sandi dikelola langsung oleh akun Google Anda.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ganti Kata Sandi",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF131A26),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Pastikan kata sandi baru Anda kuat dan mudah diingat.",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 32),

                    _buildPasswordField(
                      "Kata Sandi Saat Ini",
                      oldPasswordController,
                      isOldPassObscured,
                      () {
                        setState(() => isOldPassObscured = !isOldPassObscured);
                      },
                    ),
                    const SizedBox(height: 20),

                    _buildPasswordField(
                      "Kata Sandi Baru",
                      newPasswordController,
                      isNewPassObscured,
                      () {
                        setState(() => isNewPassObscured = !isNewPassObscured);
                      },
                    ),
                    const SizedBox(height: 20),

                    _buildPasswordField(
                      "Konfirmasi Kata Sandi Baru",
                      confirmPasswordController,
                      isConfirmPassObscured,
                      () {
                        setState(
                          () => isConfirmPassObscured = !isConfirmPassObscured,
                        );
                      },
                    ),
                    const SizedBox(height: 48),

                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: authController.isLoading.value
                              ? null
                              : _submitChangePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6600),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: authController.isLoading.value
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Perbarui Kata Sandi",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool isObscured,
    VoidCallback onToggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF495057),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscured,
          decoration: InputDecoration(
            hintText: "••••••••",
            hintStyle: const TextStyle(color: Color(0xFFAEB5BC)),
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: Color(0xFF6C757D),
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isObscured ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF6C757D),
                size: 20,
              ),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF6600), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
