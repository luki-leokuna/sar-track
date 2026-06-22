import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sar_track/views/dashboard/dashboard_view.dart';
import 'package:sar_track/views/auth/login_view.dart';
import 'package:sar_track/views/teams/team_view.dart';
import 'package:sar_track/views/tracking/map_view.dart';
import 'package:sar_track/controllers/auth_controller.dart';
import 'package:sar_track/views/profile/edit_profile_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Profile Picture & Name
                Center(
                  child: Obx(() {
                    final user = authController.currentUser.value;
                    final String imageUrl = user?.profileImageUrl ?? '';
                    final String name = user?.username ?? 'Sobat SAR';

                    return Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                                color: Colors.grey.shade200,
                                image: imageUrl.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(imageUrl),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: imageUrl.isEmpty
                                  ? Icon(
                                      Icons.person,
                                      color: Colors.grey,
                                      size: 64,
                                    )
                                  : null,
                            ),
                            // Badge
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF6600),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.verified,
                                    color: Color(0xFF131A26),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF131A26),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 32),

                // 2. Settings Menu Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.settings_outlined,
                              color: Color(0xFFB54504),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Account Settings",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(
                                  0xFF131A26,
                                ).withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: Colors.grey.shade300),

                      // List Items
                      _buildMenuItem(
                        Icons.person_outline,
                        "Edit Profile",
                        onTap: () {
                          Get.to(() => const EditProfileView());
                        },
                      ),
                      Divider(height: 1, color: Colors.grey.shade300),
                      _buildMenuItem(
                        Icons.lock_outline,
                        "Security",
                        onTap: () {
                          Get.snackbar(
                            'Segera Hadir',
                            'Fitur keamanan sedang dalam pengembangan.',
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                          );
                        },
                      ),
                      Divider(height: 1, color: Colors.grey.shade300),
                      _buildMenuItem(
                        Icons.notifications_none,
                        "Notifications",
                        onTap: () {
                          Get.snackbar(
                            'Segera Hadir',
                            'Fitur notifikasi sedang dalam pengembangan.',
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Sign Out Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      authController.logout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF131A26), // Biru gelap
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.logout, size: 20),
                    label: const Text(
                      "Sign Out",
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
      ),

      // 4. Bottom Navigation Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F5),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                Icons.assignment_outlined,
                "Missions",
                false,
                onTap: () {
                  Get.offAll(
                    () => DashboardView(),
                    transition: Transition.noTransition,
                  );
                },
              ),
              _buildNavItem(
                Icons.map_outlined,
                "Map",
                false,
                onTap: () {
                  Get.offAll(
                    () => MapView(),
                    transition: Transition.noTransition,
                  );
                },
              ),
              _buildNavItem(
                Icons.people_outline,
                "Teams",
                false,
                onTap: () {
                  Get.offAll(
                    () => TeamView(),
                    transition: Transition.noTransition,
                  );
                },
              ),
              _buildNavItem(Icons.account_circle_outlined, "Account", true),
            ],
          ),
        ),
      ),
    );
  }

  // Helper untuk List Tile Menu
  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF495057), size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212529),
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF495057), size: 22),
          ],
        ),
      ),
    );
  }

  // Helper untuk Bottom Nav
  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isSelected, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6600) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF131A26)
                  : const Color(0xFF495057),
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF131A26)
                    : const Color(0xFF495057),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
