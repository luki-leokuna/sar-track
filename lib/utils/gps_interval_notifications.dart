import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Helper untuk tampilkan notifikasi perubahan GPS interval
class GpsIntervalNotificationHandler {
  /// Snackbar untuk leader setelah berhasil ubah interval
  static void showLeaderChangeNotification({
    required double fromInterval,
    required double toInterval,
  }) {
    Get.snackbar(
      '✓ GPS Interval Updated',
      '${fromInterval.toStringAsFixed(1)}m → ${toInterval.toStringAsFixed(1)}m',
      backgroundColor: const Color(0xFFFF6600),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  /// Snackbar untuk member saat leader ubah interval
  static void showMemberChangeNotification({
    required double fromInterval,
    required double toInterval,
    required String leaderName,
  }) {
    Get.snackbar(
      'ℹ️ GPS Interval Diubah',
      '$leaderName: ${fromInterval.toStringAsFixed(1)}m → ${toInterval.toStringAsFixed(1)}m',
      backgroundColor: const Color(0xFF131A26),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 5),
      borderRadius: 8,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ],
    );
  }
}
