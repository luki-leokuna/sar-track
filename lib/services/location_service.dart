// ignore_for_file: dangling_library_doc_comments
/// [BACKEND] location_service.dart
/// Layanan akses GPS internal perangkat menggunakan package Geolocator.
/// Menangani izin lokasi, ambil posisi sekali, dan stream posisi real-time.

import 'package:geolocator/geolocator.dart';

class LocationService {
  // Konfigurasi akurasi dan interval update GPS
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5, // Update setiap bergerak minimal 5 meter
  );

  // ─── Izin Lokasi ───────────────────────────────────────────────────────────

  /// Cek dan minta izin lokasi dari pengguna.
  /// Mengembalikan true jika izin diberikan, false jika ditolak.
  Future<bool> requestPermission() async {
    // Cek apakah GPS aktif di perangkat
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'GPS perangkat tidak aktif. Aktifkan lokasi terlebih dahulu.';
    }

    LocationPermission permission = await Geolocator.checkPermission();

    // Jika belum pernah diminta, minta sekarang
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Izin lokasi ditolak. Aplikasi SAR-Track membutuhkan akses lokasi.';
      }
    }

    // Jika ditolak permanen, arahkan ke pengaturan sistem
    if (permission == LocationPermission.deniedForever) {
      throw 'Izin lokasi ditolak permanen. '
          'Buka Pengaturan > Izin Aplikasi untuk mengaktifkan.';
    }

    return true;
  }

  /// Cek status izin tanpa meminta (untuk validasi awal)
  Future<bool> hasPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  // ─── Ambil Posisi ──────────────────────────────────────────────────────────

  /// Ambil posisi GPS saat ini sekali (one-shot).
  /// Digunakan saat pertama kali anggota join tim.
  Future<Position> getCurrentPosition() async {
    await requestPermission();
    return await Geolocator.getCurrentPosition(
      locationSettings: _locationSettings,
    );
  }

  // ─── Stream Posisi Real-Time ───────────────────────────────────────────────

  /// Stream posisi GPS yang terus berjalan selama tracking aktif.
  /// Didengarkan oleh TrackingController untuk update ke Firebase.
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(locationSettings: _locationSettings);
  }

  // ─── Utilitas ──────────────────────────────────────────────────────────────

  /// Hitung jarak antara dua titik koordinat dalam meter.
  /// Wrapper dari Geolocator.distanceBetween() untuk kemudahan akses.
  double distanceBetween({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}
