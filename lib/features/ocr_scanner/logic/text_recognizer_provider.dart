// lib/features/ocr_scanner/logic/text_recognizer_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:share_plus/share_plus.dart';

class TextRecognizerProvider extends ChangeNotifier {
  File? _image;
  String _recognizedText = "";
  bool _isScanning = false;

  File? get image => _image;
  String get recognizedText => _recognizedText;
  bool get isScanning => _isScanning;

  final ImagePicker _picker = ImagePicker();
  // Latin alfabesi (Türkçe ve İngilizce karakterleri kusursuz okur)
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin); 

  // --- 1. Resim Seç ve Otomatik Tara ---
  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _recognizedText = ""; // Eski metni temizle
        notifyListeners();
        
        await _scanTextFromImage(); // Resmi seçer seçmez taramaya başla
      }
    } catch (e) {
      debugPrint("Resim seçme hatası: $e");
    }
  }

  // --- 2. Görüntüden Metin Çıkarma (Sihirli Kısım) ---
  Future<void> _scanTextFromImage() async {
    if (_image == null) return;

    _isScanning = true;
    notifyListeners();

    try {
      final inputImage = InputImage.fromFile(_image!);
      final RecognizedText recognizedTextResult = await _textRecognizer.processImage(inputImage);
      
      _recognizedText = recognizedTextResult.text;
      
      if (_recognizedText.trim().isEmpty) {
        _recognizedText = "Bu görselde okunabilir bir metin bulunamadı.";
      }
    } catch (e) {
      _recognizedText = "Tarama sırasında bir hata oluştu: $e";
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  // --- 3. Paylaşma ve Temizleme ---
  void shareText() {
    if (_recognizedText.isNotEmpty) {
      Share.share(_recognizedText, subject: "Utilify Tarama Sonucu");
    }
  }

  void clear() {
    _image = null;
    _recognizedText = "";
    notifyListeners();
  }

  @override
  void dispose() {
    _textRecognizer.close(); // RAM'i şişirmemek için kapatıyoruz
    super.dispose();
  }
}