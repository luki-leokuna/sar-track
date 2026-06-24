import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ImgbbService {
  // Hardcoded API Key provided by the user
  static const String _apiKey = 'b34955f0c56077cd6b93edc93536aed8';
  static const String _apiUrl = 'https://api.imgbb.com/1/upload';

  /// Mengunggah byte gambar ke ImgBB dan mengembalikan URL langsung ke gambar.
  static Future<String?> uploadImage(Uint8List imageBytes) async {
    try {
      // Mengubah byte gambar menjadi base64 agar lebih stabil saat dikirim
      final base64Image = base64Encode(imageBytes);

      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        body: {
          'image': base64Image,
        },
      );

      if (response.statusCode == 200) {
        final jsonResult = jsonDecode(response.body);
        if (jsonResult['success'] == true) {
          // Mengambil URL foto yang diunggah
          return jsonResult['data']['url']; 
        } else {
          return 'ERROR: API mengembalikan success=false. Body: ${response.body}';
        }
      } else {
        return 'ERROR: HTTP ${response.statusCode}. Body: ${response.body}';
      }
    } catch (e) {
      return 'ERROR: Exception terjadi saat upload: $e';
    }
  }
}
