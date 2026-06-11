import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sar_track/views/dashboard/dashboard_view.dart';
import 'package:sar_track/views/profile/profile_view.dart';
import 'package:sar_track/views/tracking/map_view.dart';

class TeamMember {
  final String name;
  final String status;
  final String imageUrl;

  TeamMember({
    required this.name,
    required this.status,
    required this.imageUrl,
  });
}

class TeamView extends StatelessWidget {
  const TeamView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<TeamMember> teamMembers = [
      TeamMember(
          name: "Cmdr. Thompson",
          status: "Online",
          imageUrl: "https://i.pravatar.cc/150?img=11"),
      TeamMember(
          name: "Sgt. Miller",
          status: "Busy",
          imageUrl: "https://i.pravatar.cc/150?img=12"),
      TeamMember(
          name: "Sgt. Sarah",
          status: "Online",
          imageUrl: "https://i.pravatar.cc/150?img=5"),
      TeamMember(
          name: "Medic Harris",
          status: "Offline",
          imageUrl: "https://i.pravatar.cc/150?img=13"),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Team",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF131A26),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: teamMembers.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final member = teamMembers[index];
                    return _buildTeamCard(member);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFFF6600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        child: const Icon(Icons.person_add_alt_1, color: Colors.white),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildTeamCard(TeamMember member) {
    Color statusColor;
    Color statusBgColor;
    Color statusDotColor;

    switch (member.status.toLowerCase()) {
      case "online":
        statusColor = const Color(0xFF2E7D32); // Dark Green
        statusBgColor = const Color(0xFFE8F5E9); // Light Green
        statusDotColor = const Color(0xFF4CAF50); // Green Dot
        break;
      case "busy":
        statusColor = const Color(0xFFD84315); // Dark Orange
        statusBgColor = const Color(0xFFFBE9E7); // Light Orange
        statusDotColor = const Color(0xFFFF9800); // Orange Dot
        break;
      default: // offline
        statusColor = const Color(0xFF616161); // Dark Grey
        statusBgColor = const Color(0xFFEEEEEE); // Light Grey
        statusDotColor = const Color(0xFF9E9E9E); // Grey Dot
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          // Avatar with status dot
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(member.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: statusDotColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Name
          Expanded(
            child: Text(
              member.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF131A26),
              ),
            ),
          ),
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              member.status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
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
            _buildNavItem(Icons.assignment, "Missions", false, onTap: () {
              Get.offAll(() => const DashboardView(),
                  transition: Transition.noTransition);
            }),
            _buildNavItem(Icons.map_outlined, "Map", false, onTap: () {
              Get.offAll(() => const MapView(), transition: Transition.noTransition);
            }),
            _buildNavItem(Icons.people, "Teams", true), // Selected
            _buildNavItem(Icons.account_circle_outlined, "Account", false,
                onTap: () {
              Get.offAll(() => const ProfileView(),
                  transition: Transition.noTransition);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected,
      {VoidCallback? onTap}) {
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
