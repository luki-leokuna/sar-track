import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sar_track/views/dashboard/dashboard_view.dart';
import 'package:sar_track/views/profile/profile_view.dart';
import 'package:sar_track/views/tracking/map_view.dart';
import 'package:sar_track/controllers/tracking_controller.dart';
import 'package:sar_track/controllers/team_controller.dart';
import 'package:sar_track/controllers/auth_controller.dart';
import 'package:sar_track/models/tracker_model.dart';
import 'package:sar_track/models/team_model.dart';

class TeamView extends StatefulWidget {
  const TeamView({super.key});

  @override
  State<TeamView> createState() => _TeamViewState();
}

class _TeamViewState extends State<TeamView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ⚠️ PENTING: Jangan pakai Get.put() di sini!
    // Gunakan Get.find() atau Get.isRegistered() untuk avoid reset state
    final trackingController = Get.isRegistered<TrackingController>()
        ? Get.find<TrackingController>()
        : Get.put(TrackingController(), permanent: true);

    final teamController = Get.isRegistered<TeamController>()
        ? Get.find<TeamController>()
        : Get.put(TeamController(), permanent: true);

    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.people_alt,
                    color: Color(0xFFFF6600),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Tim Saya",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF131A26),
                    ),
                  ),
                ],
              ),
            ),

            // ── Tab: Tim Yang Saya Buat vs Tim Yang Saya Ikuti ────────────
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFFFF6600),
                labelColor: const Color(0xFF131A26),
                unselectedLabelColor: const Color(0xFF495057),
                tabs: const [
                  Tab(
                    child: Text(
                      "Tim Saya",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Tim Bergabung",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            // ── Tab Content ────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Tim Yang Saya Buat
                  _buildMyTeamsTab(
                    authController,
                    teamController,
                    trackingController,
                    context,
                  ),

                  // Tab 2: Tim Yang Saya Ikuti (tapi bukan saya buat)
                  _buildJoinedTeamsTab(
                    authController,
                    teamController,
                    trackingController,
                    context,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ─── Tab 1: Tim Yang Saya Buat ──────────────────────────────────────────
  Widget _buildMyTeamsTab(
    AuthController authController,
    TeamController teamController,
    TrackingController trackingController,
    BuildContext context,
  ) {
    return Obx(() {
      final myUid = authController.currentUser.value?.uid;
      final activeTeam = teamController.activeTeam.value;

      // Sekarang hanya tampil 1 tim (yang sedang aktif dan user yg buat)
      // Kalau mau multiple teams, perlu tambah field di TeamController
      if (activeTeam == null || myUid == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                "Anda belum membuat tim",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Get.to(() => const DashboardView()),
                icon: const Icon(Icons.add),
                label: const Text("Buat Tim Baru"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6600),
                ),
              ),
            ],
          ),
        );
      }

      // Cek apakah user adalah pembuat tim
      if (activeTeam.members.isEmpty || activeTeam.members.first != myUid) {
        return const Center(child: Text("Anda bukan pembuat tim ini"));
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card: Info Tim
            _buildTeamInfoCard(context, activeTeam),
            const SizedBox(height: 24),

            // Header: Anggota Tim
            const Text(
              "Anggota Tim",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF131A26),
              ),
            ),
            const SizedBox(height: 12),

            // List Anggota dengan Distance & Status
            _buildTeamMembersList(
              trackingController,
              activeTeam,
              myUid,
              isCreator: true,
            ),
          ],
        ),
      );
    });
  }

  // ─── Tab 2: Tim Yang Saya Ikuti ────────────────────────────────────────
  Widget _buildJoinedTeamsTab(
    AuthController authController,
    TeamController teamController,
    TrackingController trackingController,
    BuildContext context,
  ) {
    return Obx(() {
      final myUid = authController.currentUser.value?.uid;
      final activeTeam = teamController.activeTeam.value;

      if (activeTeam == null || myUid == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.people_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                "Anda belum bergabung dengan tim",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Get.to(() => const DashboardView()),
                icon: const Icon(Icons.add),
                label: const Text("Gabung Tim"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF131A26),
                ),
              ),
            ],
          ),
        );
      }

      // Cek apakah user adalah pembuat tim
      if (activeTeam.members.isNotEmpty && activeTeam.members.first == myUid) {
        // Ini tim yang user buat, bukan yang di-join
        return const Center(
          child: Text(
            "Anda tidak bergabung dengan tim ini (Anda adalah pembuatnya)",
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card: Info Tim
            _buildTeamInfoCard(context, activeTeam),
            const SizedBox(height: 24),

            // Header: Anggota Tim
            const Text(
              "Anggota Tim",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF131A26),
              ),
            ),
            const SizedBox(height: 12),

            // List Anggota dengan Distance & Leaderboard
            _buildTeamMembersList(
              trackingController,
              activeTeam,
              myUid,
              isCreator: false,
            ),
          ],
        ),
      );
    });
  }

  // ─── Card: Info Tim + Kode ───────────────────────────────────────────────
  Widget _buildTeamInfoCard(BuildContext context, TeamModel team) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF6600), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield, color: const Color(0xFFFF6600), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.teamName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF131A26),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Kode: ${team.teamId}",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF495057),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: team.teamId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Kode tim disalin")),
                  );
                },
                icon: const Icon(Icons.copy, color: Color(0xFFFF6600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "👥 ${team.memberCount} Anggota",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── List Anggota Tim dengan Distance & Leaderboard ────────────────────
  Widget _buildTeamMembersList(
    TrackingController trackingController,
    TeamModel team,
    String myUid, {
    required bool isCreator,
  }) {
    return Obx(() {
      final members = trackingController.teamTrackers;
      final creatorUid = team.members.isNotEmpty ? team.members.first : null;

      if (members.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text(
              "Belum ada anggota tim yang aktif",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        );
      }

      // Sort: creator terlebih dahulu, kemudian dari terdekat
      final sorted = [...members];
      sorted.sort((a, b) {
        // Creator selalu di awal
        bool aIsCreator = a.uid == creatorUid;
        bool bIsCreator = b.uid == creatorUid;
        if (aIsCreator && !bIsCreator) return -1;
        if (!aIsCreator && bIsCreator) return 1;

        // Kalau sama-sama creator atau sama-sama anggota, sort by distance
        double? distA = trackingController.distanceTo(a);
        double? distB = trackingController.distanceTo(b);
        distA ??= double.maxFinite;
        distB ??= double.maxFinite;
        return distA.compareTo(distB);
      });

      return Column(
        children: List.generate(sorted.length, (index) {
          final member = sorted[index];
          final isMemberCreator = member.uid == creatorUid;
          final distance = trackingController.distanceTo(member);
          final isMe = member.uid == myUid;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildTeamMemberCard(
              member,
              distance,
              isMemberCreator,
              isMe,
              leaderboardRank: index + 1,
            ),
          );
        }),
      );
    });
  }

  // ─── Card Anggota: Nama, Status, Distance, Leaderboard ─────────────────
  Widget _buildTeamMemberCard(
    TrackerModel member,
    double? distance,
    bool isCreator,
    bool isMe, {
    required int leaderboardRank,
  }) {
    Color statusColor;
    Color statusBgColor;
    Color statusDotColor;

    switch (member.status) {
      case MemberStatus.online:
        statusColor = const Color(0xFF2E7D32);
        statusBgColor = const Color(0xFFE8F5E9);
        statusDotColor = const Color(0xFF4CAF50);
        break;
      case MemberStatus.busy:
        statusColor = const Color(0xFFD84315);
        statusBgColor = const Color(0xFFFBE9E7);
        statusDotColor = const Color(0xFFFF9800);
        break;
      case MemberStatus.sos:
        statusColor = const Color(0xFFC62828);
        statusBgColor = const Color(0xFFFFEBEE);
        statusDotColor = const Color(0xFFF44336);
        break;
      case MemberStatus.offline:
        statusColor = const Color(0xFF616161);
        statusBgColor = const Color(0xFFEEEEEE);
        statusDotColor = const Color(0xFF9E9E9E);
    }

    final imageUrl =
        "https://ui-avatars.com/api/?name=${Uri.encodeComponent(member.username)}&background=random";
    final distanceLabel = distance == null
        ? "—"
        : distance >= 1000
        ? "${(distance / 1000).toStringAsFixed(1)} km"
        : "${distance.toStringAsFixed(0)} m";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isCreator ? const Color(0xFFFFFDF5) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCreator ? const Color(0xFFFFD54F) : Colors.grey.shade300,
          width: isCreator ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // ── Leaderboard Rank (nomor urut jarak) ─────────────────────────
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6600),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "#$leaderboardRank",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ── Avatar + Status Dot ─────────────────────────────────────────
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
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
          const SizedBox(width: 12),

          // ── Info: Nama + Status + Distance ──────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        isMe ? "${member.username} (Anda)" : member.username,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF131A26),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCreator) ...[
                      const SizedBox(width: 6),
                      const Text("👑", style: TextStyle(fontSize: 13)),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        member.statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.location_on, color: Colors.grey, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      distanceLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF495057),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Tombol aksi (optional: lihat di map) ─────────────────────────
          if (distance != null)
            IconButton(
              onPressed: () {
                // Navigasi ke map dan focus ke member ini
                Get.offAll(() => const MapView());
              },
              icon: const Icon(Icons.map_outlined, color: Color(0xFFFF6600)),
              tooltip: "Lihat di peta",
              iconSize: 20,
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
            _buildNavItem(
              Icons.assignment_outlined,
              "Missions",
              false,
              onTap: () => Get.offAll(
                () => const DashboardView(),
                transition: Transition.noTransition,
              ),
            ),
            _buildNavItem(
              Icons.map_outlined,
              "Map",
              false,
              onTap: () => Get.offAll(
                () => const MapView(),
                transition: Transition.noTransition,
              ),
            ),
            _buildNavItem(Icons.people, "Teams", true),
            _buildNavItem(
              Icons.account_circle_outlined,
              "Account",
              false,
              onTap: () => Get.offAll(
                () => const ProfileView(),
                transition: Transition.noTransition,
              ),
            ),
          ],
        ),
      ),
    );
  }

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