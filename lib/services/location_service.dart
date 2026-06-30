import 'package:geolocator/geolocator.dart';

class LocationService {
  // distanceFilter harus int (Geolocator API requirement).
  // Nilai 4 = pembulatan dari 3.5m target kita.
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 4,
  );

  // ─── Izin Lokasi ──────────────────────────────────────────────────────────

  Future<bool> requestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'GPS perangkat tidak aktif. Aktifkan lokasi terlebih dahulu.';
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Izin lokasi ditolak. Aplikasi SAR-Track membutuhkan akses lokasi.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Izin lokasi ditolak permanen. '
          'Buka Pengaturan > Izin Aplikasi untuk mengaktifkan.';
    }

    return true;
  }

  Future<bool> hasPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  // ─── Ambil Posisi ─────────────────────────────────────────────────────────

  /// Ambil posisi sekali dengan akurasi tinggi + timeout 10 detik.
  Future<Position> getCurrentPosition() async {
    await requestPermission();
    return await Geolocator.getCurrentPosition(
      locationSettings: _locationSettings,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw 'GPS timeout. Pastikan lokasi aktif.',
    );
  }

  // ─── Stream Posisi Real-Time ──────────────────────────────────────────────

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(locationSettings: _locationSettings);
  }

  // ─── Utilitas ─────────────────────────────────────────────────────────────

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
