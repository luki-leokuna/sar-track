import 'package:flutter/material.dart';

class HelpFaqView extends StatelessWidget {
  const HelpFaqView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Pusat Bantuan / FAQ', style: TextStyle(color: Color(0xFF131A26), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF131A26)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildFaqItem(
            'Bagaimana cara bergabung dengan tim?', 
            'Pilih menu "Teams" lalu masukkan kode tim (contoh: SAR-AB12CD) yang diberikan oleh komandan lapangan kamu.'
          ),
          _buildFaqItem(
            'Apa fungsi tombol SOS?', 
            'Tombol SOS digunakan untuk mengirim sinyal darurat ke seluruh anggota tim. Lokasi kamu akan ditandai dengan ikon bahaya di peta. Gunakan HANYA pada situasi kritis.'
          ),
          _buildFaqItem(
            'Kenapa lokasi saya tidak terdeteksi?', 
            'Pastikan layanan GPS / Lokasi di perangkat kamu aktif dan aplikasi diberikan izin akses lokasi "Selalu" atau "Sepanjang waktu" (Always).'
          ),
          _buildFaqItem(
            'Bagaimana cara mengubah status kesiapan?', 
            'Buka menu "Account" lalu ketuk switch (tombol alih) di samping "Status: Tersedia". Perubahan ini langsung terlihat oleh anggota tim lainnya saat kamu tergabung dalam tim.'
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF131A26))),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(answer, style: const TextStyle(color: Colors.black87, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
