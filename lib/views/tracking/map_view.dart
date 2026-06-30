import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:sar_track/views/dashboard/dashboard_view.dart';
import 'package:sar_track/views/teams/team_view.dart';
import 'package:sar_track/views/profile/profile_view.dart';
import 'package:sar_track/controllers/tracking_controller.dart';
import 'package:sar_track/controllers/team_controller.dart';
import 'package:sar_track/controllers/auth_controller.dart';
import 'package:sar_track/models/tracker_model.dart';
import 'package:sar_track/views/tracking/map_view_with_gps_settings.dart';
import 'package:sar_track/utils/gps_interval_notifications.dart';

enum MapLayerType { defaultMap, topo, satellite }

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final MapController _mapController = MapController();

  late final TrackingController trackingController;
  late final TeamController teamController;
  late final AuthController authController;

  Worker? _trackerWorker;
  bool _trackingInitialized = false;

  // ── GPS Settings Menu State ─────────────────────────────────────────────
  bool _gpsSettingsMenuOpen = false;

  final List<CircleMarker> _circles = [];
  final List<Polyline> _polylines = [];
  final List<Polygon> _polygons = [];
  final List<Marker> _sosMarker = [];

  double _currentZoom = 14.0;
  MapLayerType _currentMapLayer = MapLayerType.defaultMap;
  LatLng _initialPosition = const LatLng(47.4521, -121.8245);

  @override
  void initState() {
    super.initState();

    trackingController = Get.isRegistered<TrackingController>()
        ? Get.find<TrackingController>()
        : Get.put(TrackingController(), permanent: true);

    teamController = Get.isRegistered<TeamController>()
        ? Get.find<TeamController>()
        : Get.put(TeamController(), permanent: true);

    authController = Get.find<AuthController>();

    // Langsung pakai posisi terakhir yang sudah ada di controller
    // supaya saat balik dari tab lain, peta tidak mulai dari Seattle
    final existingPos = trackingController.myTracker.value;
    if (existingPos != null) {
      _initialPosition = LatLng(existingPos.latitude, existingPos.longitude);
    }

    _setupStaticOverlays();
    _initializeTracking();
  }

  @override
  void dispose() {
    _trackerWorker?.dispose();
    super.dispose();
  }

  // ── Tracking Init ─────────────────────────────────────────────────────────

  void _initializeTracking() {
    if (_trackingInitialized) return;
    _trackingInitialized = true;

    final teamId = _resolveTeamId();

    if (teamId == null) {
      Get.snackbar(
        'Belum Ada Tim',
        'Kamu belum tergabung dalam tim manapun.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (trackingController.isTracking.value) {
      _setupTrackerListener();
      return;
    }

    _startTracking(teamId);
  }

  String? _resolveTeamId() {
    final args = Get.arguments;
    if (args is Map && args['teamId'] is String) {
      return args['teamId'] as String;
    }
    return teamController.activeTeam.value?.teamId;
  }

  Future<void> _startTracking(String teamId) async {
    try {
      if (!trackingController.isTracking.value) {
        await trackingController.startTracking(teamId);
      }
      _setupTrackerListener();
    } catch (e) {
      if (mounted) {
        Get.snackbar('Error', 'Gagal mulai tracking: $e');
      }
    }
  }

  void _setupTrackerListener() {
    _trackerWorker?.dispose();

    _trackerWorker = ever<TrackerModel?>(trackingController.myTracker, (
      tracker,
    ) {
      if (tracker == null || !mounted) return;

      // Hanya pindahkan kamera saat PERTAMA KALI dapat posisi
      // (saat _initialPosition masih di koordinat default Seattle)
      // Kalau sudah punya posisi (balik dari tab lain), jangan override kamera
      final isDefaultPosition =
          _initialPosition.latitude == 47.4521 &&
          _initialPosition.longitude == -121.8245;

      if (isDefaultPosition) {
        _initialPosition = LatLng(tracker.latitude, tracker.longitude);
        _mapController.move(_initialPosition, _currentZoom);
      }

      if (mounted) setState(() {});
    });
  }

  // ── GPS Settings ──────────────────────────────────────────────────────────

  Future<void> _onGpsIntervalChanged(double newInterval) async {
    final oldInterval =
        teamController.activeTeam.value?.gpsDistanceFilter ?? 3.5;
    try {
      await teamController.updateGpsInterval(newInterval);
      GpsIntervalNotificationHandler.showLeaderChangeNotification(
        fromInterval: oldInterval,
        toInterval: newInterval,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ── Static Overlays ───────────────────────────────────────────────────────

  void _setupStaticOverlays() {
    _circles.add(
      CircleMarker(
        point: const LatLng(47.4521, -121.8100),
        radius: 800,
        useRadiusInMeter: true,
        color: Colors.red.withValues(alpha: 0.3),
        borderColor: Colors.red,
        borderStrokeWidth: 2,
      ),
    );

    _polygons.add(
      Polygon(
        points: const [
          LatLng(47.4600, -121.8400),
          LatLng(47.4600, -121.8200),
          LatLng(47.4400, -121.8200),
          LatLng(47.4400, -121.8400),
        ],
        color: Colors.orange.withValues(alpha: 0.2),
        borderColor: Colors.orange,
        borderStrokeWidth: 2,
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _relativeTime(int timestampMs) {
    final diff = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(timestampMs),
    );
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    return '${diff.inHours} jam lalu';
  }

  String _distanceLabel(TrackerModel tracker) {
    final distance = trackingController.distanceTo(tracker);
    if (distance == null) return '—';
    return distance >= 1000
        ? '${(distance / 1000).toStringAsFixed(1)} km'
        : '${distance.toStringAsFixed(0)} m';
  }

  Color _statusColor(MemberStatus status) {
    switch (status) {
      case MemberStatus.online:
        return Colors.blue;
      case MemberStatus.busy:
        return Colors.orange;
      case MemberStatus.sos:
        return Colors.red;
      case MemberStatus.offline:
        return Colors.grey;
    }
  }

  // ── Dialogs & Sheets ──────────────────────────────────────────────────────

  void _showTeamMemberInfo(TrackerModel tracker) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF131A26),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: _statusColor(tracker.status),
                  size: 30,
                ),
                const SizedBox(width: 12),
                Text(
                  tracker.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn(Icons.flag, 'Status', tracker.statusLabel),
                _buildInfoColumn(
                  Icons.social_distance,
                  'Jarak',
                  _distanceLabel(tracker),
                ),
                _buildInfoColumn(
                  Icons.access_time,
                  'Terakhir',
                  _relativeTime(tracker.timestamp),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey, size: 24),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _triggerSOS() {
    trackingController.activateSOS();
    setState(() {
      final myPos = trackingController.myTracker.value;
      final pos = myPos != null
          ? LatLng(myPos.latitude, myPos.longitude)
          : _initialPosition;
      _sosMarker
        ..clear()
        ..add(
          Marker(
            key: const Key('sos_signal'),
            point: pos,
            width: 80,
            height: 80,
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 50,
            ),
          ),
        );
      _mapController.move(pos, _currentZoom);
    });

    Get.snackbar(
      'SOS Terkirim!',
      'Pusat komando dan anggota tim telah menerima sinyal.',
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 5),
    );
  }

  void _cancelSOS() {
    trackingController.deactivateSOS();
    setState(() => _sosMarker.clear());

    Get.snackbar(
      'SOS Dibatalkan',
      'Sinyal darurat telah dinonaktifkan.',
      backgroundColor: Colors.green.shade700,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
    );
  }

  void _showSOSDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131A26),
        title: const Text(
          'Konfirmasi SOS',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Kirim sinyal darurat ke semua tim? Aksi ini akan membunyikan alarm di Command Center.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _triggerSOS();
            },
            child: const Text(
              'Kirim SOS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMapLayerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131A26),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Tipe Peta',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.map, color: Colors.blue),
              title: const Text(
                'Default (OSM)',
                style: TextStyle(color: Colors.white),
              ),
              trailing: _currentMapLayer == MapLayerType.defaultMap
                  ? const Icon(Icons.check, color: Color(0xFFFF6600))
                  : null,
              onTap: () {
                setState(() => _currentMapLayer = MapLayerType.defaultMap);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.terrain, color: Colors.green),
              title: const Text(
                'Topografi (OpenTopo)',
                style: TextStyle(color: Colors.white),
              ),
              trailing: _currentMapLayer == MapLayerType.topo
                  ? const Icon(Icons.check, color: Color(0xFFFF6600))
                  : null,
              onTap: () {
                setState(() => _currentMapLayer = MapLayerType.topo);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.satellite, color: Colors.amber),
              title: const Text(
                'Satelit (Esri)',
                style: TextStyle(color: Colors.white),
              ),
              trailing: _currentMapLayer == MapLayerType.satellite
                  ? const Icon(Icons.check, color: Color(0xFFFF6600))
                  : null,
              onTap: () {
                setState(() => _currentMapLayer = MapLayerType.satellite);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Map Controls ──────────────────────────────────────────────────────────

  void _zoomIn() {
    setState(() {
      _currentZoom++;
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom--;
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  void _goToMyLocation() {
    final myPos = trackingController.myTracker.value;
    if (myPos != null) {
      _mapController.move(
        LatLng(myPos.latitude, myPos.longitude),
        _currentZoom,
      );
    }
  }

  String _getMapUrl() {
    switch (_currentMapLayer) {
      case MapLayerType.topo:
        return 'https://a.tile.opentopomap.org/{z}/{x}/{y}.png';
      case MapLayerType.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case MapLayerType.defaultMap:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Peta ───────────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialPosition,
              initialZoom: _currentZoom,
              // Tutup GPS menu saat user tap/drag peta
              onTap: (_, _) {
                if (_gpsSettingsMenuOpen) {
                  setState(() => _gpsSettingsMenuOpen = false);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _getMapUrl(),
                userAgentPackageName: 'com.example.sartrack',
                retinaMode: false, // false lebih cepat load di web
                // Cache tile di memory supaya tidak fetch ulang saat zoom/pan
                tileBuilder: (context, tileWidget, tile) => tileWidget,
                errorTileCallback: (tile, error, stackTrace) {
                  // Abaikan error tile — jangan crash
                },
              ),
              PolygonLayer(polygons: _polygons),
              CircleLayer(circles: _circles),
              PolylineLayer(polylines: _polylines),

              // Marker anggota tim — real-time dari Firebase
              Obx(() {
                final myUid = trackingController.myTracker.value?.uid;
                final teammates = trackingController.teamTrackers
                    .where((t) => t.uid != myUid)
                    .toList();

                final teammateMarkers = teammates.map((t) {
                  final color = _statusColor(t.status);
                  return Marker(
                    point: LatLng(t.latitude, t.longitude),
                    width: 80,
                    height: 80,
                    child: GestureDetector(
                      onTap: () => _showTeamMemberInfo(t),
                      child: Column(
                        children: [
                          Icon(Icons.location_on, color: color, size: 40),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              t.username,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList();

                return MarkerLayer(
                  markers: [..._sosMarker, ...teammateMarkers],
                );
              }),

              // Titik biru posisi sendiri
              Builder(
                builder: (context) {
                  final myPos = trackingController.myTracker.value;
                  if (myPos == null) return const SizedBox.shrink();
                  return MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(myPos.latitude, myPos.longitude),
                        width: 60,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),

          // ── Top Left: Info Tim ─────────────────────────────────────────────
          Positioned(top: 50, left: 16, child: _buildTopOverlay()),

          // ── Top Right: GPS Settings Button ────────────────────────────────
          Positioned(
            top: 50,
            right: 16,
            child: GestureDetector(
              onTap: () {
                setState(() => _gpsSettingsMenuOpen = !_gpsSettingsMenuOpen);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _gpsSettingsMenuOpen
                      ? const Color(0xFFFF6600)
                      : const Color(0xFF131A26),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.settings,
                  color: _gpsSettingsMenuOpen
                      ? const Color(0xFF131A26)
                      : Colors.white,
                ),
              ),
            ),
          ),

          // ── GPS Settings Floating Menu ─────────────────────────────────────
          if (_gpsSettingsMenuOpen)
            Positioned(
              top: 110,
              right: 16,
              child: Obx(() {
                final currentInterval =
                    teamController.activeTeam.value?.gpsDistanceFilter ?? 3.5;
                final isLeader = teamController.isTeamLeader(
                  authController.currentUser.value?.uid,
                );
                return GpsSettingsFloatingMenu(
                  currentInterval: currentInterval,
                  isLeader: isLeader,
                  onIntervalChanged: _onGpsIntervalChanged,
                  onClose: () => setState(() => _gpsSettingsMenuOpen = false),
                );
              }),
            ),

          // ── Bottom Right: Zoom + Layer + Location ─────────────────────────
          Positioned(
            bottom: 32,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: _showMapLayerBottomSheet,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF131A26),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.layers, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.black87),
                        onPressed: _zoomIn,
                      ),
                      Container(
                        height: 1,
                        width: 30,
                        color: Colors.grey.shade300,
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.black87),
                        onPressed: _zoomOut,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _goToMyLocation,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6600),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.my_location, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom Left: SOS + Koordinat ──────────────────────────────────
          Positioned(
            bottom: 32,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() {
                  final isSos =
                      trackingController.myTracker.value?.status ==
                      MemberStatus.sos;
                  return GestureDetector(
                    onLongPress: isSos ? _cancelSOS : _showSOSDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSos ? Colors.red : const Color(0xFFFF6600),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (isSos ? Colors.red : const Color(0xFFFF6600))
                                    .withValues(alpha: 0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSos ? Icons.cancel : Icons.warning_rounded,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isSos ? 'BATALKAN SOS (TAHAN)' : 'TAHAN UNTUK SOS',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131A26).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    () {
                      final p = trackingController.myTracker.value;
                      return p != null
                          ? '${p.latitude.toStringAsFixed(5)}°, ${p.longitude.toStringAsFixed(5)}°'
                          : 'Mencari Lokasi...';
                    }(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────────────

  Widget _buildTopOverlay() {
    return Obx(() {
      final team = teamController.activeTeam.value;
      final memberCount = trackingController.teamTrackers.length;

      return Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF131A26).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6600),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    team?.teamName ?? 'Belum Ada Tim',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (team != null) ...[
              const SizedBox(height: 6),
              Text(
                'Kode: ${team.teamId}',
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Anggota',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
                Text(
                  memberCount.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'GPS',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
                Text(
                  team != null
                      ? '${team.gpsDistanceFilter.toStringAsFixed(1)}m'
                      : '—',
                  style: const TextStyle(
                    color: Color(0xFFFF6600),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Status',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
                Row(
                  children: [
                    Text(
                      trackingController.isTracking.value
                          ? 'Aktif'
                          : 'Nonaktif',
                      style: TextStyle(
                        color: trackingController.isTracking.value
                            ? const Color(0xFF4CAF50)
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      trackingController.isTracking.value
                          ? Icons.check_circle_outline
                          : Icons.pause_circle_outline,
                      color: trackingController.isTracking.value
                          ? const Color(0xFF4CAF50)
                          : Colors.grey,
                      size: 13,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });
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
              'Missions',
              false,
              onTap: () => Get.offAll(
                () => const DashboardView(),
                transition: Transition.noTransition,
              ),
            ),
            _buildNavItem(Icons.map, 'Map', true),
            _buildNavItem(
              Icons.people_outline,
              'Teams',
              false,
              onTap: () => Get.offAll(
                () => const TeamView(),
                transition: Transition.noTransition,
              ),
            ),
            _buildNavItem(
              Icons.account_circle_outlined,
              'Account',
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
