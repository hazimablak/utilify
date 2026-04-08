import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:gal/gal.dart'; 
import 'package:utilify/utils/api_keys.dart'; 

class RemoverProvider extends ChangeNotifier {
  File? _selectedImage;
  Uint8List? _removedImageBytes;
  bool _isLoading = false;

  // ✅ SENİN API ANAHTARIN EKLENDİ
  final String _apiKey = ApiKeys.removeBgKey; 

  File? get selectedImage => _selectedImage;
  Uint8List? get removedImageBytes => _removedImageBytes;
  bool get isLoading => _isLoading;

  // 1. Resim Seç
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _selectedImage = File(image.path);
      _removedImageBytes = null;
      notifyListeners();
    }
  }

  // 2. Arka Planı Sil (API İsteği)
  Future<void> removeBackground(BuildContext context) async {
    if (_selectedImage == null) return;
    
    // Basit anahtar kontrolü
    if (_apiKey.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("API Anahtarı eksik!")));
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      var request = http.MultipartRequest("POST", Uri.parse("https://api.remove.bg/v1.0/removebg"));
      request.headers["X-Api-Key"] = _apiKey;
      request.files.add(await http.MultipartFile.fromPath("image_file", _selectedImage!.path));
      
      // 💡 TASARRUF MODU: 'preview' (50 Hak kullanır, 1 Kredini harcamaz)
      request.fields["size"] = "preview"; 

      var response = await request.send();

      if (response.statusCode == 200) {
        // BAŞARILI! 🎉
        http.Response imgResponse = await http.Response.fromStream(response);
        _removedImageBytes = imgResponse.bodyBytes;
      } else {
        // HATA YÖNETİMİ (Kullanıcıya mantıklı mesaj verelim)
        String errorMessage = "Bir hata oluştu. Kod: ${response.statusCode}";
        
        if (response.statusCode == 400) {
          // Manzara resmi vs. seçilirse bu hata gelir
          errorMessage = "Resimde insan veya nesne bulunamadı. Lütfen daha net bir fotoğraf seçin.";
        } else if (response.statusCode == 402) {
          // Kredi biterse
          errorMessage = "İşlem limiti doldu veya E-posta onayı yapılmadı.";
        } else if (response.statusCode == 403) {
          errorMessage = "API Anahtarı hatalı.";
        }

        // Terminale teknik detay yaz (Senin görmen için)
        http.Response errorResponse = await http.Response.fromStream(response);
        debugPrint("HATA DETAYI: ${errorResponse.body}");

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ));
        }
      }
    } catch (e) {
      debugPrint("Bağlantı Hatası: $e");
      if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("İnternet bağlantınızı kontrol edin.")));
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // 3. Galeriye Kaydet
  Future<bool> saveImage() async {
    if (_removedImageBytes == null) return false;
    try {
      await Gal.putImageBytes(_removedImageBytes!, name: "Utilify_NoBG_${DateTime.now().millisecondsSinceEpoch}");
      return true;
    } catch (e) {
      return false;
    }
  }

  // 4. Temizle
  void clear() {
    _selectedImage = null;
    _removedImageBytes = null;
    notifyListeners();
  }
}