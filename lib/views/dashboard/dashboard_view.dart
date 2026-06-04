import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sar_track/views/profile/profile_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Profile
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFF6600), width: 2),
                      image: const DecorationImage(
                        image: NetworkImage("https://i.pravatar.cc/150?img=11"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Cmdr. Thompson",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF131A26),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // 2. Card "Buat Tim Baru"
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFF6600), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFE5D9),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.add, color: Color(0xFF5E2B15), size: 28),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Buat Tim Baru",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5E2B15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 3. Card "Gabung Tim"
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131A26),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF131A26).withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2A3441),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.people_alt_outlined, color: Colors.white, size: 24),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Gabung Tim",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      
      // 4. Custom Bottom Navigation Bar
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
              _buildNavItem(Icons.assignment, "Missions", true),
              _buildNavItem(Icons.map_outlined, "Map", false),
              _buildNavItem(Icons.people_outline, "Teams", false),
              _buildNavItem(Icons.account_circle_outlined, "Account", false, onTap: () {
                Get.offAll(() => const ProfileView());
              }),
            ],
          ),
        ),
      ),
    );
  }

  // Helper untuk membuat item Bottom Navigation Bar
  Widget _buildNavItem(IconData icon, String label, bool isSelected, {VoidCallback? onTap}) {
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
              color: isSelected ? const Color(0xFF131A26) : const Color(0xFF495057),
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? const Color(0xFF131A26) : const Color(0xFF495057),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
