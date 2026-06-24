import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sar_track/controllers/auth_controller.dart';
import 'package:sar_track/controllers/team_controller.dart';
import 'package:sar_track/services/database_service.dart';
import 'package:sar_track/models/tracker_model.dart';

class ProfileController extends GetxController {
  final DatabaseService _dbService = DatabaseService();
  final AuthController _authController = Get.find<AuthController>();
  
  // Use Get.isRegistered to avoid exceptions if TeamController isn't active yet
  TeamController? get _teamController => 
      Get.isRegistered<TeamController>() ? Get.find<TeamController>() : null;

  // RxBool for status. True = Available/Online, False = Busy/Sibuk
  final RxBool isAvailable = true.obs;

  void toggleStatus(bool value) async {
    isAvailable.value = value;
    
    final uid = _authController.currentUser.value?.uid;
    final teamId = _teamController?.activeTeam.value?.teamId;

    // Jika user sedang berada di dalam tim, update status ke backend Firebase
    if (uid != null && teamId != null) {
      final status = value ? MemberStatus.online.value : MemberStatus.busy.value;
      await _dbService.updateMemberStatus(teamId, uid, status);
      
      Get.snackbar(
        'Status Diperbarui',
        'Status kamu sekarang ${value ? "Tersedia" : "Sibuk"} di tim.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}
