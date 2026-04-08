import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart'; 
class OcrProvider extends ChangeNotifier {
  // --- Değişkenler ---
  File? _selectedImage;
  String _extractedText = "";
  String _translatedText = ""; 
  bool _isScanning = false;
  bool _isTranslating = false;
  bool _showTranslation = false;

  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  
  final OnDeviceTranslator _translator = OnDeviceTranslator(
    sourceLanguage: TranslateLanguage.english,
    targetLanguage: TranslateLanguage.turkish,
  );

  // Akıllı Veriler
  List<String> _phones = [];
  List<String> _emails = [];
  List<String> _urls = [];

  // --- Getterlar ---
  File? get selectedImage => _selectedImage;
  
  // EKSİK OLAN BUYDU (Hata bunun yüzünden çıkıyordu):
  String get extractedText => _extractedText; 

  String get currentText => _showTranslation ? _translatedText : _extractedText;
  bool get isScanning => _isScanning;
  bool get isTranslating => _isTranslating;
  bool get showTranslation => _showTranslation;
  List<String> get phones => _phones;
  List<String> get emails => _emails;
  List<String> get urls => _urls;

  // 1. Resim Seç ve Tara
  Future<void> pickAndScanImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
        _extractedText = "";
        _translatedText = "";
        _showTranslation = false;
        _clearSmartData();
        notifyListeners();

        await _scanText();
      }
    } catch (e) {
      debugPrint("Hata: $e");
    }
  }

  // 2. Metni Okuma (OCR)
  Future<void> _scanText() async {
    if (_selectedImage == null) return;

    _isScanning = true;
    notifyListeners();

    try {
      final inputImage = InputImage.fromFile(_selectedImage!);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      _extractedText = recognizedText.text;
      
      if (_extractedText.isEmpty) {
        _extractedText = "Okunabilir metin bulunamadı.";
      } else {
        _extractSmartData(_extractedText);
      }

    } catch (e) {
      _extractedText = "Hata: $e";
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  // 3. Çeviri Yap
  Future<void> translateText() async {
    if (_extractedText.isEmpty || _translatedText.isNotEmpty) {
      _showTranslation = !_showTranslation; 
      notifyListeners();
      return;
    }

    _isTranslating = true;
    notifyListeners();

    try {
      final modelManager = OnDeviceTranslatorModelManager();
      if (!await modelManager.isModelDownloaded(TranslateLanguage.english.bcpCode)) {
        await modelManager.downloadModel(TranslateLanguage.english.bcpCode);
      }
      if (!await modelManager.isModelDownloaded(TranslateLanguage.turkish.bcpCode)) {
        await modelManager.downloadModel(TranslateLanguage.turkish.bcpCode);
      }

      final result = await _translator.translateText(_extractedText);
      _translatedText = result;
      _showTranslation = true;

    } catch (e) {
      _extractedText += "\n\n[Çeviri Hatası]: $e";
    } finally {
      _isTranslating = false;
      notifyListeners();
    }
  }

  // 4. Akıllı Veri Madenciliği
  void _extractSmartData(String text) {
    final emailRegex = RegExp(r"[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    _emails = emailRegex.allMatches(text).map((m) => m.group(0)!).toList();

    final urlRegex = RegExp(r"https?://(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)");
    _urls = urlRegex.allMatches(text).map((m) => m.group(0)!).toList();

    final phoneRegex = RegExp(r"\b\d{3}[- .]?\d{3}[- .]?\d{4}\b");
    _phones = phoneRegex.allMatches(text).map((m) => m.group(0)!).toList();
  }

  void _clearSmartData() {
    _phones = [];
    _emails = [];
    _urls = [];
  }

  // 5. Aksiyonlar (Arama, Mail, Web)
  Future<void> launchSmartAction(String data, String type) async {
    Uri? uri;
    if (type == 'tel') uri = Uri.parse("tel:$data");
    if (type == 'mail') uri = Uri.parse("mailto:$data");
    if (type == 'web') {
       uri = Uri.parse(data.startsWith('http') ? data : 'https://$data');
    }

    if (uri != null) {
      // canLaunchUrl kontrolü yapmadan doğrudan launchUrl deniyoruz (daha stabil)
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint("Link açılamadı: $e");
      }
    }
  }

  void clear() {
    _selectedImage = null;
    _extractedText = "";
    _translatedText = "";
    _clearSmartData();
    notifyListeners();
  }

  @override
  void dispose() {
    _textRecognizer.close();
    _translator.close();
    super.dispose();
  }
}