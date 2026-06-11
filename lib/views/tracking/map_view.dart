import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:sar_track/views/dashboard/dashboard_view.dart';
import 'package:sar_track/views/teams/team_view.dart';
import 'package:sar_track/views/profile/profile_view.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  
  bool _isSosActive = false;
  double _currentZoom = 14.0;
  
  // Default fallback location (e.g., if permission denied)
  CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(47.4521, -121.8245),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _setupMockData();
  }

  void _setupMockData() {
    // Adding Mock Markers for Team Members
    _markers.add(
      const Marker(
        markerId: MarkerId('team_member_1'),
        position: LatLng(47.4580, -121.8300),
        infoWindow: InfoWindow(title: 'Andi Pratama', snippet: 'Tim Alpha'),
      ),
    );

    _markers.add(
      const Marker(
        markerId: MarkerId('team_member_2'),
        position: LatLng(47.4460, -121.8150),
        infoWindow: InfoWindow(title: 'Siti Aisyah', snippet: 'Tim Bravo'),
      ),
    );

    // Adding Missing Hiker Zone Circle
    _circles.add(
      Circle(
        circleId: const CircleId('missing_hiker_zone'),
        center: const LatLng(47.4521, -121.8100),
        radius: 800, // 800m radius
        fillColor: Colors.red.withValues(alpha: 0.3),
        strokeColor: Colors.red,
        strokeWidth: 2,
      ),
    );
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Akses Lokasi', 'Layanan lokasi (GPS) pada perangkat belum aktif.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Izin Ditolak', 'Akses lokasi dibutuhkan untuk pelacakan.');
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('Izin Diblokir', 'Izin lokasi diblokir secara permanen di pengaturan.');
      return;
    } 

    // When we reach here, permissions are granted
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
      _initialPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: _currentZoom,
      );
    });
    
    _mapController?.animateCamera(CameraUpdate.newCameraPosition(_initialPosition));
  }

  void _toggleSOS() {
    setState(() {
      _isSosActive = !_isSosActive;
      
      if (_isSosActive) {
        // Add SOS Marker at current location
        if (_currentPosition != null) {
          _markers.add(
            Marker(
              markerId: const MarkerId('sos_signal'),
              position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              infoWindow: const InfoWindow(title: 'SOS! Bantuan Diperlukan'),
            )
          );
          
          _mapController?.animateCamera(CameraUpdate.newLatLng(
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
          ));
        } else {
           _markers.add(
            Marker(
              markerId: const MarkerId('sos_signal'),
              position: const LatLng(47.4521, -121.8245), // fallback
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              infoWindow: const InfoWindow(title: 'SOS! Bantuan Diperlukan'),
            )
          );
        }
        
        Get.snackbar(
          "SOS Terkirim", 
          "Sinyal darurat telah disebarkan ke anggota tim lain.",
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
        );
      } else {
        // Remove SOS Marker
        _markers.removeWhere((marker) => marker.markerId.value == 'sos_signal');
        Get.snackbar(
          "SOS Dibatalkan", 
          "Sinyal darurat telah dinonaktifkan.",
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
        );
      }
    });
  }

  void _zoomIn() {
    _currentZoom++;
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _currentZoom--;
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void _goToMyLocation() async {
    if (_currentPosition != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          _currentZoom,
        )
      );
    } else {
      await _checkLocationPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Base Map
          GoogleMap(
            initialCameraPosition: _initialPosition,
            mapType: MapType.satellite,
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: false,
            markers: _markers,
            circles: _circles,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
          ),

          // 2. Top Left Overlay Card
          Positioned(
            top: 50,
            left: 16,
            child: _buildTopOverlay(),
          ),

          // 3. Right Controls
          Positioned(
            bottom: 32,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Zoom Controls
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))
                    ],
                  ),
                  child: Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.black87),
                        onPressed: _zoomIn,
                      ),
                      Container(height: 1, width: 30, color: Colors.grey.shade300),
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.black87),
                        onPressed: _zoomOut,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Bar Chart Button
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6600),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))
                    ],
                  ),
                  child: const Icon(Icons.bar_chart, color: Colors.white),
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
                        BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))
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
                // SOS Button
                GestureDetector(
                  onTap: _toggleSOS,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isSosActive ? Colors.red : const Color(0xFFFF6600), 
                        width: 2
                      ),
                      color: (_isSosActive ? Colors.red : const Color(0xFFFF6600)).withValues(alpha: 0.2),
                    ),
                    child: Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _isSosActive ? Colors.red : const Color(0xFFFF6600),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "SOS",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Coordinates
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131A26).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    _currentPosition != null 
                      ? "${_currentPosition!.latitude.toStringAsFixed(4)}° N, ${_currentPosition!.longitude.toStringAsFixed(4)}° W"
                      : "Mencari Lokasi...",
                    style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 12),
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
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Teams Deployed", style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text("04", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Comms Status", style: TextStyle(color: Colors.grey, fontSize: 12)),
              Row(
                children: const [
                  Text("Stable", style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(width: 4),
                  Icon(Icons.check_circle_outline, color: Color(0xFF4CAF50), size: 16),
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
            _buildNavItem(Icons.assignment_outlined, "Missions", false, onTap: () {
              Get.offAll(() => const DashboardView(), transition: Transition.noTransition);
            }),
            _buildNavItem(Icons.map, "Map", true), // Selected
            _buildNavItem(Icons.people_outline, "Teams", false, onTap: () {
              Get.offAll(() => const TeamView(), transition: Transition.noTransition);
            }),
            _buildNavItem(Icons.account_circle_outlined, "Account", false, onTap: () {
              Get.offAll(() => const ProfileView(), transition: Transition.noTransition);
            }),
          ],
        ),
      ),
    );
  }

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
