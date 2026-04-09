// lib/features/ocr_scanner/logic/business_card_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class BusinessCardProvider extends ChangeNotifier {
  File? _image;
  bool _isScanning = false;
  
  // Ayıklanan Veriler
  List<String> _emails = [];
  List<String> _phones = [];
  List<String> _websites = [];

  File? get image => _image;
  bool get isScanning => _isScanning;
  List<String> get emails => _emails;
  List<String> get phones => _phones;
  List<String> get websites => _websites;

  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  // --- 1. Resim Seç ve Tara ---
  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _clearData();
        notifyListeners();
        
        await _scanCard();
      }
    } catch (e) {
      debugPrint("Resim seçme hatası: $e");
    }
  }

  // --- 2. Kartviziti Oku ve Verileri Ayıkla ---
  Future<void> _scanCard() async {
    if (_image == null) return;
    _isScanning = true;
    notifyListeners();

    try {
      final inputImage = InputImage.fromFile(_image!);
      final RecognizedText recognizedTextResult = await _textRecognizer.processImage(inputImage);
      String fullText = recognizedTextResult.text;

      // 🔥 Sihirli Regex (Düzenli İfadeler) Motoru
      // 1. E-postaları Bul
      _emails = _extractData(fullText, RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'));
      
      // 2. Telefon Numaralarını Bul (Boşluklu, tireli, +90'lı vs. formatları yakalar)
      _phones = _extractData(fullText, RegExp(r'(\+?\d{1,3}[\s-]?)?\(?\d{3}\)?[\s-]?\d{3}[\s-]?\d{2}[\s-]?\d{2}'));
      
      // 3. Web Sitelerini Bul
      _websites = _extractData(fullText, RegExp(r'(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)'));

      // Sadece domain olanları web sitesi listesinde bırakmak için e-postaları web sitesi listesinden temizleyelim
      _websites.removeWhere((url) => _emails.any((email) => email.contains(url)));

    } catch (e) {
      debugPrint("Tarama hatası: $e");
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  // Regex arayıcı yardımcı fonksiyon
  List<String> _extractData(String text, RegExp regex) {
    final matches = regex.allMatches(text);
    // toSet().toList() yaparak aynı numarayı/maili 2 kere yazmasını engelliyoruz
    return matches.map((m) => m.group(0)!.trim()).toSet().toList(); 
  }

  void clear() {
    _image = null;
    _clearData();
    notifyListeners();
  }

  void _clearData() {
    _emails.clear();
    _phones.clear();
    _websites.clear();
  }

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }
}