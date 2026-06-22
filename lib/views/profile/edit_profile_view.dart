import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sar_track/controllers/auth_controller.dart';
import 'package:sar_track/services/database_service.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = authController.currentUser.value;
    if (user != null) {
      nameController.text = user.username;
      urlController.text = user.profileImageUrl;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    urlController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    final user = authController.currentUser.value;
    if (user == null) return;

    final newName = nameController.text.trim();
    final newUrl = urlController.text.trim();

    if (newName.isEmpty) {
      Get.snackbar('Gagal', 'Nama tidak boleh kosong', 
          backgroundColor: Colors.red.withValues(alpha: 0.1), colorText: Colors.red);
      return;
    }

    setState(() => isLoading = true);

    try {
      await DatabaseService().updateUser(user.uid, {
        'username': newName,
        'profileImageUrl': newUrl,
      });

      // Update local state
      authController.currentUser.value = user.copyWith(
        username: newName,
        profileImageUrl: newUrl,
      );

      Get.back();
      Get.snackbar('Sukses', 'Profil berhasil diperbarui', 
          backgroundColor: Colors.green.withValues(alpha: 0.1), colorText: Colors.green);
    } catch (e) {
      Get.snackbar('Gagal', 'Terjadi kesalahan saat memperbarui profil', 
          backgroundColor: Colors.red.withValues(alpha: 0.1), colorText: Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF131A26)),
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: Color(0xFF131A26),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview Gambar
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFF6600), width: 3),
                    color: Colors.grey.shade200,
                  ),
                  child: ClipOval(
                    child: urlController.text.isNotEmpty
                        ? Image.network(
                            urlController.text,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                                const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                          )
                        : const Icon(Icons.person, color: Colors.grey, size: 50),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Form Nama
              const Text(
                "Nama Lengkap",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF495057),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: "Nama Anda",
                  hintStyle: const TextStyle(color: Color(0xFFAEB5BC), fontSize: 14),
                  prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF6C757D), size: 20),
                  filled: true,
                  fillColor: Colors.white,
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
              const SizedBox(height: 24),

              // Form URL Foto
              const Text(
                "URL Foto Profil",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF495057),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: urlController,
                onChanged: (val) {
                  // Memicu rebuild untuk preview gambar
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: "https://example.com/foto.jpg",
                  hintStyle: const TextStyle(color: Color(0xFFAEB5BC), fontSize: 14),
                  prefixIcon: const Icon(Icons.link, color: Color(0xFF6C757D), size: 20),
                  filled: true,
                  fillColor: Colors.white,
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
              const SizedBox(height: 8),
              const Text(
                "Masukkan tautan langsung gambar dari internet (URL berakhiran .jpg atau .png).",
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
              const SizedBox(height: 48),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6600),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          "Simpan Perubahan",
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
      ),
    );
  }
}
