import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

import 'services/database_service.dart';
import 'controllers/auth_controller.dart';
import 'controllers/team_controller.dart';
import 'controllers/tracking_controller.dart';
import 'views/auth/login_view.dart';
import 'views/auth/register_view.dart';
import 'views/dashboard/dashboard_view.dart';
import 'views/tracking/map_view.dart';
import 'views/teams/team_view.dart';
import 'views/profile/profile_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ── Registrasi dependency secara berurutan ──────────────────────────────
  // URUTAN PENTING: Service dulu → Controller yang pakai service → Controller
  // yang pakai controller lain

  // 1. Service (tidak ada dependency ke controller)
  Get.put(DatabaseService(), permanent: true);

  // 2. AuthController (pakai AuthService internal, tidak pakai DatabaseService di constructor)
  Get.put(AuthController(), permanent: true);

  // 3. TeamController (pakai DatabaseService + AuthController)
  Get.put(TeamController(), permanent: true);

  // 4. TrackingController (pakai DatabaseService + AuthController + TeamController)
  Get.put(TrackingController(), permanent: true);

  runApp(const SARTrackApp());
}

class SARTrackApp extends StatelessWidget {
  const SARTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SAR-Track',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => const LoginView()),
        GetPage(name: '/register', page: () => const RegisterView()),
        GetPage(name: '/dashboard', page: () => const DashboardView()),
        GetPage(name: '/tracking', page: () => const MapView()),
        GetPage(name: '/team', page: () => const TeamView()),
        GetPage(name: '/profile', page: () => const ProfileView()),
      ],
    );
  }
}
