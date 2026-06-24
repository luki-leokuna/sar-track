import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sar_track/views/profile/profile_view.dart' as sar_track_profile;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sar_track/controllers/auth_controller.dart';
import 'package:sar_track/services/database_service.dart';
import 'package:sar_track/services/imgbb_service.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emergencyController = TextEditingController();
  
  String? selectedRole;
  final List<String> roleOptions = [
    'Komandan Lapangan',
    'Relawan',
    'Tim Medis',
    'Tim Logistik',
    'Basarnas'
  ];
  
  String profileImageUrl = '';
  bool isLoading = false;
  bool isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    final user = authController.currentUser.value;
    if (user != null) {
      nameController.text = user.username;
      emergencyController.text = user.emergencyContact;
      selectedRole = roleOptions.contains(user.role) ? user.role : 'Relawan';
      profileImageUrl = user.profileImageUrl;
    } else {
      selectedRole = 'Relawan';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emergencyController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 70, // Kompresi untuk menghemat bandwidth
    );

    if (pickedFile != null) {
      setState(() => isUploadingImage = true);
      
      // Menggunakan readAsBytes dari XFile agar mendukung Flutter Web (localhost/Chrome)
      final Uint8List imageBytes = await pickedFile.readAsBytes();
      final uploadedUrl = await ImgbbService.uploadImage(imageBytes);
      
      setState(() => isUploadingImage = false);

      if (uploadedUrl != null && !uploadedUrl.startsWith('ERROR:')) {
        setState(() {
          profileImageUrl = uploadedUrl;
        });
        Get.snackbar('Sukses', 'Foto profil berhasil diunggah. Jangan lupa klik "Simpan Perubahan".', 
            backgroundColor: Colors.green.shade50, colorText: Colors.green.shade800,
            margin: const EdgeInsets.all(16), snackPosition: SnackPosition.TOP);
      } else {
        Get.defaultDialog(
          title: "Gagal Mengunggah",
          titleStyle: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          middleText: uploadedUrl ?? "Terjadi kesalahan yang tidak diketahui.",
          textConfirm: "Tutup",
          confirmTextColor: Colors.white,
          buttonColor: Colors.red,
          onConfirm: () => Get.back(),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      Get.snackbar('Gagal', 'Sesi login tidak ditemukan. Silakan login ulang.', 
          backgroundColor: Colors.red.shade50, colorText: Colors.red.shade800);
      return;
    }

    final newName = nameController.text.trim();
    final newEmergency = emergencyController.text.trim();

    if (newName.isEmpty) {
      Get.snackbar('Gagal', 'Nama tidak boleh kosong', 
          backgroundColor: Colors.red.shade50, colorText: Colors.red.shade800,
          margin: const EdgeInsets.all(16));
      return;
    }

    setState(() => isLoading = true);

    try {
      await DatabaseService().updateUser(firebaseUser.uid, {
        'username': newName,
        'profileImageUrl': profileImageUrl,
        'emergencyContact': newEmergency,
        'role': selectedRole,
      });

      // Update local state secara manual agar akurat
      final updatedUser = await DatabaseService().getUser(firebaseUser.uid);
      if (updatedUser != null) {
        authController.currentUser.value = updatedUser;
      }

      Get.off(() => const sar_track_profile.ProfileView());
      Get.snackbar('Sukses', 'Profil berhasil diperbarui', 
          backgroundColor: Colors.green.shade50, colorText: Colors.green.shade800,
          margin: const EdgeInsets.all(16));
    } catch (e) {
      Get.snackbar('Gagal', 'Terjadi kesalahan: $e', 
          backgroundColor: Colors.red.shade50, colorText: Colors.red.shade800,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 5));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
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
          "Edit Profil",
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
                child: GestureDetector(
                  onTap: isUploadingImage ? null : _pickAndUploadImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFF6600), width: 3),
                          color: Colors.grey.shade200,
                        ),
                        child: ClipOval(
                          child: isUploadingImage
                            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6600)))
                            : profileImageUrl.isNotEmpty
                              ? Image.network(
                                  profileImageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => 
                                      const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                                )
                              : const Icon(Icons.person, color: Colors.grey, size: 60),
                        ),
                      ),
                      if (!isUploadingImage)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF6600),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  "Ketuk foto untuk mengubah",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              const SizedBox(height: 32),

              // Form Nama
              const Text(
                "Nama Lengkap",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF495057)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: _inputDecoration(hint: "Nama Anda", icon: Icons.person_outline),
              ),
              const SizedBox(height: 20),

              // Form Jabatan / Peran
              const Text(
                "Peran / Jabatan di Tim SAR",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF495057)),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: roleOptions.map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedRole = val;
                  });
                },
                decoration: _inputDecoration(hint: "Pilih peran", icon: Icons.badge_outlined),
                dropdownColor: Colors.white,
              ),
              const SizedBox(height: 20),

              // Form Kontak Darurat
              const Text(
                "Nomor Telepon Darurat",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF495057)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emergencyController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration(hint: "Contoh: 08123456789", icon: Icons.phone_in_talk_outlined),
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
                      borderRadius: BorderRadius.circular(12),
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
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFAEB5BC), fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF6C757D), size: 20),
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
    );
  }
}
