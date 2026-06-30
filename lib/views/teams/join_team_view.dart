import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sar_track/controllers/team_controller.dart';

class JoinTeamView extends StatelessWidget {
  const JoinTeamView({super.key});

  @override
  Widget build(BuildContext context) {
    // Pakai instance yang sudah ada kalau sudah teregistrasi, jangan buat baru —
    // mencegah TeamController lama (dengan activeTeam terisi) ke-overwrite.
    final teamController = Get.isRegistered<TeamController>()
        ? Get.find<TeamController>()
        : Get.put(TeamController(), permanent: true);

    final codeController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF131A26)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Gabung Tim",
          style: TextStyle(
            color: Color(0xFF131A26),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Kode Tim",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF495057),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: codeController,
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) => teamController.clearError(),
              decoration: InputDecoration(
                hintText: "Masukkan kode unik tim (mis. SAR-AB12CD)",
                filled: true,
                fillColor: Colors.white,
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
                  borderSide: const BorderSide(
                    color: Color(0xFF131A26),
                    width: 2,
                  ),
                ),
              ),
            ),

            // Pesan error reaktif dari TeamController
            Obx(() {
              if (teamController.errorMessage.value.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  teamController.errorMessage.value,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              );
            }),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF90CAF9)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF1976D2)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Minta kode tim dari Komandan atau pembuat tim agar kamu bisa bergabung.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF0D47A1),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Obx(
                () => ElevatedButton(
                  onPressed: teamController.isLoading.value
                      ? null
                      : () async {
                          await teamController.joinTeam(codeController.text);

                          // joinTeam() sudah otomatis navigasi ke /tracking kalau
                          // sukses. Snackbar di sini hanya untuk konfirmasi visual.
                          if (teamController.errorMessage.value.isEmpty &&
                              teamController.activeTeam.value != null) {
                            Get.snackbar(
                              "Berhasil Bergabung",
                              "Kamu sekarang tergabung di tim '${teamController.activeTeam.value!.teamName}'",
                              backgroundColor: Colors.blue.shade700,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                              margin: const EdgeInsets.all(16),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF131A26),
                    disabledBackgroundColor: const Color(
                      0xFF131A26,
                    ).withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: teamController.isLoading.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Gabung",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
