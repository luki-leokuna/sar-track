import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sar_track/controllers/team_controller.dart';

class CreateTeamView extends StatefulWidget {
  const CreateTeamView({super.key});

  @override
  State<CreateTeamView> createState() => _CreateTeamViewState();
}

class _CreateTeamViewState extends State<CreateTeamView> {
  final teamNameController = TextEditingController();
  final teamController = Get.find<TeamController>();

  double selectedGpsInterval = 3.5; // Default: balanced

  final List<Map<String, dynamic>> gpsOptions = [
    {
      'value': 1.0,
      'label': '1m',
      'battery': '2.5%/hour',
      'type': 'Ultra-responsive',
    },
    {
      'value': 1.5,
      'label': '1.5m',
      'battery': '2.3%/hour',
      'type': 'High responsive',
    },
    {
      'value': 2.0,
      'label': '2m',
      'battery': '2.1%/hour',
      'type': 'High responsive',
    },
    {'value': 2.5, 'label': '2.5m', 'battery': '2%/hour', 'type': 'Responsive'},
    {'value': 3.0, 'label': '3m', 'battery': '2%/hour', 'type': 'Responsive'},
    {
      'value': 3.5,
      'label': '3.5m',
      'battery': '2%/hour',
      'type': 'Balanced',
    }, // Default
    {'value': 4.0, 'label': '4m', 'battery': '1.8%/hour', 'type': 'Balanced'},
    {'value': 4.5, 'label': '4.5m', 'battery': '1.7%/hour', 'type': 'Moderate'},
    {'value': 5.0, 'label': '5m', 'battery': '1.5%/hour', 'type': 'Moderate'},
    {'value': 7.5, 'label': '7.5m', 'battery': '1.1%/hour', 'type': 'Saving'},
    {
      'value': 10.0,
      'label': '10m',
      'battery': '0.8%/hour',
      'type': 'Ultra-saving',
    },
  ];

  @override
  void dispose() {
    teamNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          "Buat Tim Baru",
          style: TextStyle(
            color: Color(0xFF131A26),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Nama Tim ───────────────────────────────────────────────────
            const Text(
              "Nama Tim",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF495057),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: teamNameController,
              onChanged: (_) => teamController.clearError(),
              decoration: InputDecoration(
                hintText: "Contoh: Tim SAR Alpha",
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

            // ── Error Message ──────────────────────────────────────────────
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

            const SizedBox(height: 32),

            // ── GPS Interval Selection ─────────────────────────────────────
            const Text(
              "GPS Update Interval",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF495057),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Pilih seberapa sering posisi diperbarui. Interval lebih kecil = update lebih sering = lebih akurat tapi baterei lebih cepat habis.",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6C757D),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Slider untuk GPS interval
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  // Display current value
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${selectedGpsInterval.toStringAsFixed(1)}m',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6600),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getIntervalType(selectedGpsInterval),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6C757D),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _getBatteryInfo(selectedGpsInterval),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF495057),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '🔋 Battery impact',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6C757D),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Slider
                  Slider(
                    value: selectedGpsInterval,
                    min: 1.0,
                    max: 10.0,
                    divisions: 18, // (10 - 1) * 2 = 18 untuk 0.5 step
                    label: '${selectedGpsInterval.toStringAsFixed(1)}m',
                    onChanged: (value) {
                      setState(() {
                        selectedGpsInterval = double.parse(
                          value.toStringAsFixed(1),
                        );
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  // Tick labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '1m',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6C757D),
                        ),
                      ),
                      Text(
                        '5m',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6C757D),
                        ),
                      ),
                      const Text(
                        '10m',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6C757D),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Info box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF90CAF9)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF1976D2),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Setting ini bisa diubah kapan saja saat operasi berjalan. Hanya leader tim yang bisa mengubahnya.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0D47A1),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Tombol Buat Tim
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Obx(
                () => ElevatedButton(
                  onPressed: teamController.isLoading.value
                      ? null
                      : () async {
                          if (teamNameController.text.isEmpty) {
                            Get.snackbar(
                              'Validasi',
                              'Nama tim tidak boleh kosong',
                              backgroundColor: Colors.red.shade700,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          try {
                            await teamController.createTeam(
                              teamNameController.text,
                              gpsDistanceFilter: selectedGpsInterval,
                            );

                            if (!mounted) return;

                            Get.snackbar(
                              'Berhasil',
                              'Tim "${teamNameController.text}" telah dibuat dengan GPS interval ${selectedGpsInterval.toStringAsFixed(1)}m',
                              backgroundColor: Colors.blue.shade700,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                              margin: const EdgeInsets.all(16),
                            );

                            // Navigate to map
                            await Future.delayed(
                              const Duration(milliseconds: 500),
                            );
                            // Get.offAllNamed('/tracking');
                          } catch (e) {
                            Get.snackbar(
                              'Error',
                              e.toString(),
                              backgroundColor: Colors.red.shade700,
                              colorText: Colors.white,
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
                          "Buat Tim",
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

  String _getIntervalType(double interval) {
    for (var option in gpsOptions) {
      if (option['value'] == interval) {
        return option['type'];
      }
    }
    return '';
  }

  String _getBatteryInfo(double interval) {
    for (var option in gpsOptions) {
      if (option['value'] == interval) {
        return option['battery'];
      }
    }
    return '';
  }
}
