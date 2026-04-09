// lib/features/ocr_scanner/logic/translate_camera_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslateCameraProvider extends ChangeNotifier {
  File? _image;
  String _originalText = "";
  String _translatedText = "";
  bool _isProcessing = false;

  File? get image => _image;
  String get originalText => _originalText;
  String get translatedText => _translatedText;
  bool get isProcessing => _isProcessing;

  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  
  // Varsayılan diller (İngilizce -> Türkçe)
  TranslateLanguage _sourceLanguage = TranslateLanguage.english;
  TranslateLanguage _targetLanguage = TranslateLanguage.turkish;
  OnDeviceTranslator? _translator;

  TranslateCameraProvider() {
    _initTranslator();
  }

  void _initTranslator() {
    _translator = OnDeviceTranslator(
      sourceLanguage: _sourceLanguage,
      targetLanguage: _targetLanguage,
    );
  }

  Future<void> swapLanguages() async {
    final temp = _sourceLanguage;
    _sourceLanguage = _targetLanguage;
    _targetLanguage = temp;
    
    _translator?.close();
    _initTranslator();
    notifyListeners();
  }

  // --- 1. Resmi Seç ve Oku ---
  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _originalText = "";
        _translatedText = "";
        notifyListeners();
        
        await _processImage();
      }
    } catch (e) {
      debugPrint("Resim seçme hatası: $e");
    }
  }

  // --- 2. Resmi Oku ve Çevir ---
  Future<void> _processImage() async {
    if (_image == null) return;
    
    _isProcessing = true;
    notifyListeners();

    try {
      // 1. AŞAMA: Metni Oku (OCR)
      final inputImage = InputImage.fromFile(_image!);
      final RecognizedText recognizedTextResult = await _textRecognizer.processImage(inputImage);
      
      _originalText = recognizedTextResult.text.trim();
      
      if (_originalText.isEmpty) {
        _translatedText = "Fotoğrafta okunabilir bir metin bulunamadı.";
      } else {
        // 2. AŞAMA: Metni Çevir (Translation)
        await _translateDetectedText();
      }
    } catch (e) {
      _translatedText = "İşlem sırasında hata oluştu: $e";
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> _translateDetectedText() async {
    if (_originalText.isEmpty || _translator == null) return;

    try {
      final modelManager = OnDeviceTranslatorModelManager();
      
      if (!await modelManager.isModelDownloaded(_sourceLanguage.bcpCode)) {
        await modelManager.downloadModel(_sourceLanguage.bcpCode);
      }
      
      if (!await modelManager.isModelDownloaded(_targetLanguage.bcpCode)) {
        await modelManager.downloadModel(_targetLanguage.bcpCode);
      }

      _translatedText = await _translator!.translateText(_originalText);
    } catch (e) {
      _translatedText = "Çeviri hatası: $e";
    }
  }

  void clear() {
    _image = null;
    _originalText = "";
    _translatedText = "";
    notifyListeners();
  }

  @override
  void dispose() {
    _textRecognizer.close();
    _translator?.close();
    super.dispose();
  }
}