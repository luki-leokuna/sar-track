import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportProblemView extends StatefulWidget {
  const ReportProblemView({super.key});

  @override
  State<ReportProblemView> createState() => _ReportProblemViewState();
}

class _ReportProblemViewState extends State<ReportProblemView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  void _submitReport() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // Simulasi pengiriman data (misalnya ke Firebase atau API)
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() => _isLoading = false);
      
      Get.back(); // Kembali ke halaman Profile
      
      Get.snackbar(
        'Laporan Terkirim',
        'Terima kasih! Tim teknis kami akan segera meninjau masalah ini.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Lapor Masalah', style: TextStyle(color: Color(0xFF131A26), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF131A26)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Silakan jelaskan masalah yang kamu alami saat menggunakan aplikasi SAR Track.', 
                  style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.5)
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Judul Masalah',
                    hintText: 'Contoh: Peta tidak muncul',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Judul tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi Detail',
                    hintText: 'Jelaskan kronologi masalah yang terjadi...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6600),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: _isLoading 
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Kirim Laporan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
