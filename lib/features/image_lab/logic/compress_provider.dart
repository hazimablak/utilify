import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart'; 

// 🔥 İSİM DÜZELTİLDİ: CompressProvider
class CompressProvider extends ChangeNotifier {
  // --- Değişkenler ---
  File? _originalImage;
  File? _compressedImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // AYARLAR (State)
  double _quality = 80; // Varsayılan kalite %80
  CompressFormat _format = CompressFormat.jpeg; // Varsayılan format JPG

  // --- Getterlar ---
  File? get originalImage => _originalImage;
  File? get compressedImage => _compressedImage;
  bool get isLoading => _isLoading;
  double get quality => _quality;
  CompressFormat get format => _format;

  // --- Setterlar (Arayüzden gelen emirler) ---
  void setQuality(double value) {
    _quality = value;
    notifyListeners();
  }

  void setFormat(CompressFormat value) {
    _format = value;
    notifyListeners();
  }

  // --- 1. Resim Seçme ---
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        _originalImage = File(pickedFile.path);
        _compressedImage = null; // Yeni resim gelince eski sonucu sil
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Hata: $e");
    }
  }

  // --- 2. PRO Sıkıştırma ve Dönüştürme ---
  Future<void> compressImage() async {
    if (_originalImage == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final tempDir = await getTemporaryDirectory();
      
      // Format uzantısını belirle (.jpg, .png, .webp)
      String extension = _format == CompressFormat.png ? ".png" : 
                         _format == CompressFormat.webp ? ".webp" : ".jpg";
      
      final targetPath = '${tempDir.path}/utilify_${DateTime.now().millisecondsSinceEpoch}$extension';

      // Sıkıştırma İşlemi
      final result = await FlutterImageCompress.compressAndGetFile(
        _originalImage!.absolute.path,
        targetPath,
        quality: _quality.toInt(), // Slider'dan gelen değer
        format: _format,           // Dropdown'dan gelen format
      );

      if (result != null) {
        _compressedImage = File(result.path);
      }
    } catch (e) {
      debugPrint("Sıkıştırma hatası: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 3. Yardımcılar ---
  Future<void> openCompressedFile() async {
    if (_compressedImage != null) await OpenFile.open(_compressedImage!.path);
  }

  void clear() {
    _originalImage = null;
    _compressedImage = null;
    notifyListeners();
  }

  String getFileSize(File? file) {
    if (file == null) return "";
    final bytes = file.lengthSync();
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB";
  }
}