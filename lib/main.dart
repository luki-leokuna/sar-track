import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:sar_track/views/auth/login_view.dart';
import 'firebase_options.dart';

/// Entry point aplikasi SAR-Track.
/// File ini HANYA berisi inisialisasi Firebase dan root widget.
/// Jangan tambahkan logika fitur atau UI dekoratif di sini. (Golden Rule #1)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      // Halaman awal sementara — akan digantikan oleh AuthController
      // yang otomatis redirect berdasarkan session login.
      home: const LoginView(),
    );
  }
}
