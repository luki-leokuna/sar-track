import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

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
                    color: const Color(0xFF131A26),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4A5568),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on, 
                        color: Color(0xFFFF6B00),
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
                    color: Color(0xFF131A26),
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

                // 3. Card Form Register
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
                      // Tombol Daftar dengan Google
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: _buildGoogleIcon(),
                          label: const Text(
                            "Daftar dengan Google",
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

                      // Input Username
                      const Text(
                        "Username",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF495057),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        hintText: "Username Anda",
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),

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
                      _buildTextField(
                        hintText: "nama@instansi.go.id",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

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
                      _buildTextField(
                        hintText: "••••••••",
                        icon: Icons.lock_outline,
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),

                      // Input Konfirmasi Kata Sandi
                      const Text(
                        "Konfirmasi Kata Sandi",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF495057),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        hintText: "••••••••",
                        icon: Icons.history, // Icon yang mirip di referensi gambar
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),

                      // Tombol Daftar Sekarang
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6600), // Oranye
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Daftar Sekarang",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Link Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Sudah punya akun? ",
                      style: TextStyle(color: Color(0xFF495057), fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.back(); // Kembali ke halaman Login
                      },
                      child: const Text(
                        "Masuk",
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

  // Method helper untuk textfield agar kode lebih rapi dan reusable
  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFAEB5BC), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF6C757D), size: 20),
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
    );
  }

  // Widget sementara untuk icon Google
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
