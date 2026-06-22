import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:sar_track/views/dashboard/dashboard_view.dart';
import 'package:sar_track/views/teams/team_view.dart';
import 'package:sar_track/views/profile/profile_view.dart';

enum MapLayerType { defaultMap, topo, satellite }

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final MapController _mapController = MapController();
  Position? _currentPosition;

  final List<Marker> _markers = [];
  final List<CircleMarker> _circles = [];
  final List<Polyline> _polylines = [];
  final List<Polygon> _polygons = [];

  bool _isSosActive = false;
  double _currentZoom = 14.0;
  MapLayerType _currentMapLayer = MapLayerType.defaultMap;

  // Default fallback location (Mount Rainier / Seattle area from original code)
  LatLng _initialPosition = const LatLng(47.4521, -121.8245);

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _setupMockData();
  }

  void _setupMockData() {
    // Missing Hiker Zone Circle
    _circles.add(
      CircleMarker(
        point: const LatLng(47.4521, -121.8100),
        radius: 800, // 800m radius
        useRadiusInMeter: true,
        color: Colors.red.withValues(alpha: 0.3),
        borderColor: Colors.red,
        borderStrokeWidth: 2,
      ),
    );

    // Search Sector Polygon
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

    // Team Member Breadcrumbs
    _polylines.add(
      Polyline(
        points: const [
          LatLng(47.4620, -121.8350),
          LatLng(47.4600, -121.8320),
          LatLng(47.4580, -121.8300),
        ],
        strokeWidth: 4,
        color: Colors.blue,
      ),
    );

    _polylines.add(
      Polyline(
        points: const [
          LatLng(47.4400, -121.8100),
          LatLng(47.4430, -121.8120),
          LatLng(47.4460, -121.8150),
        ],
        strokeWidth: 4,
        color: Colors.green,
      ),
    );

    // Adding Mock Markers for Team Members
    _markers.add(
      Marker(
        point: const LatLng(47.4580, -121.8300),
        width: 80,
        height: 80,
        child: GestureDetector(
          onTap: () => _showTeamMemberInfo(
            'Andi (Alpha)',
            '85%',
            '1200 mdpl',
            'Baru saja',
          ),
          child: Column(
            children: [
              const Icon(Icons.location_on, color: Colors.blue, size: 40),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Alpha',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    _markers.add(
      Marker(
        point: const LatLng(47.4460, -121.8150),
        width: 80,
        height: 80,
        child: GestureDetector(
          onTap: () => _showTeamMemberInfo(
            'Siti (Bravo)',
            '40%',
            '1180 mdpl',
            '5 menit lalu',
          ),
          child: Column(
            children: [
              const Icon(Icons.location_on, color: Colors.green, size: 40),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Bravo',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTeamMemberInfo(
    String name,
    String battery,
    String altitude,
    String lastSeen,
  ) {
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
                const Icon(Icons.person, color: Color(0xFFFF6600), size: 30),
                const SizedBox(width: 12),
                Text(
                  name,
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
                _buildInfoColumn(Icons.battery_4_bar, "Baterai", battery),
                _buildInfoColumn(Icons.terrain, "Ketinggian", altitude),
                _buildInfoColumn(Icons.access_time, "Terakhir", lastSeen),
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

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar(
        'Akses Lokasi',
        'Layanan lokasi (GPS) pada perangkat belum aktif.',
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar(
          'Izin Ditolak',
          'Akses lokasi dibutuhkan untuk pelacakan.',
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'Izin Diblokir',
        'Izin lokasi diblokir secara permanen di pengaturan.',
      );
      return;
    }

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          bool initialMove = _currentPosition == null;
          _currentPosition = position;
          _initialPosition = LatLng(position.latitude, position.longitude);

          if (initialMove) {
            _mapController.move(_initialPosition, _currentZoom);
          }
        });
      }
    });
  }

  void _triggerSOS() {
    setState(() {
      _isSosActive = true;

      final pos = _currentPosition != null
          ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
          : _initialPosition;

      _markers.add(
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

      Get.snackbar(
        "SOS Terkirim!",
        "Pusat komando dan anggota tim telah menerima sinyal.",
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
      );
    });
  }

  void _cancelSOS() {
    setState(() {
      _isSosActive = false;
      _markers.removeWhere((marker) => marker.key == const Key('sos_signal'));
      Get.snackbar(
        "SOS Dibatalkan",
        "Sinyal darurat telah dinonaktifkan.",
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
      );
    });
  }

  void _showSOSDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131A26),
        title: const Text(
          "Konfirmasi SOS",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Kirim sinyal darurat ke semua tim? Aksi ini akan membunyikan alarm di Command Center.",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _triggerSOS();
            },
            child: const Text(
              "Kirim SOS",
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
              "Pilih Tipe Peta",
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
                "Default (OSM)",
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
                "Topografi (OpenTopo)",
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
                "Satelit (Esri)",
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

  void _goToMyLocation() async {
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        _currentZoom,
      );
    } else {
      await _checkLocationPermission();
    }
  }

  String _getMapUrl() {
    switch (_currentMapLayer) {
      case MapLayerType.topo:
        return 'https://a.tile.opentopomap.org/{z}/{x}/{y}.png';
      case MapLayerType.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case MapLayerType.defaultMap:
      default:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Base Map using flutter_map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialPosition,
              initialZoom: _currentZoom,
            ),
            children: [
              TileLayer(
                urlTemplate: _getMapUrl(),
                userAgentPackageName: 'com.example.sartrack',
                retinaMode: true,
              ),
              PolygonLayer(polygons: _polygons),
              CircleLayer(circles: _circles),
              PolylineLayer(polylines: _polylines),
              MarkerLayer(markers: _markers),
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
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
                                BoxShadow(color: Colors.black26, blurRadius: 4),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // 2. Top Left Overlay Card
          Positioned(top: 50, left: 16, child: _buildTopOverlay()),

          // 3. Right Controls
          Positioned(
            bottom: 32,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Map Layers Button
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
                // Zoom Controls
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
                // Location Button
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

          // 4. Bottom Left SOS & Coordinates
          Positioned(
            bottom: 32,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // SOS Long Press Button
                GestureDetector(
                  onLongPress: _isSosActive ? _cancelSOS : _showSOSDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: _isSosActive
                          ? Colors.red
                          : const Color(0xFFFF6600),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (_isSosActive
                                      ? Colors.red
                                      : const Color(0xFFFF6600))
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
                          _isSosActive ? Icons.cancel : Icons.warning_rounded,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isSosActive
                              ? "BATALKAN SOS (TAHAN)"
                              : "TAHAN UNTUK SOS",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Coordinates & Accuracy
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentPosition != null
                            ? "${_currentPosition!.latitude.toStringAsFixed(5)}°, ${_currentPosition!.longitude.toStringAsFixed(5)}°"
                            : "Mencari Lokasi...",
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                      if (_currentPosition != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          "Akurasi: ±${_currentPosition!.accuracy.toStringAsFixed(1)} m | Elevasi: ${_currentPosition!.altitude.toStringAsFixed(0)} mdpl",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
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

  Widget _buildTopOverlay() {
    return Container(
      width: 260,
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
              const Text(
                "Active Mission",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Sector 7 - West Ridge Search",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Teams Deployed",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                "04",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Comms Status",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Row(
                children: const [
                  Text(
                    "Stable",
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF4CAF50),
                    size: 16,
                  ),
                ],
              ),
            ],
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
              onTap: () {
                Get.offAll(
                  () => DashboardView(),
                  transition: Transition.noTransition,
                );
              },
            ),
            _buildNavItem(Icons.map, "Map", true), // Selected
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
            _buildNavItem(
              Icons.account_circle_outlined,
              "Account",
              false,
              onTap: () {
                Get.offAll(
                  () => ProfileView(),
                  transition: Transition.noTransition,
                );
              },
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
