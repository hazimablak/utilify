// lib/features/voice_text/logic/tts_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsProvider extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();

  // Durum Değişkenleri
  bool _isPlaying = false;
  String _currentLang = "tr-TR"; // Varsayılan Türkçe
  final double _volume = 1.0;
  double _pitch = 1.0; // Ses Tonu (1.0 normal)
  double _rate = 0.5;  // Okuma Hızı (0.5 normal)

  // Dil Listesi
  List<String> _languages = [];

  // Getterlar
  bool get isPlaying => _isPlaying;
  String get currentLang => _currentLang;
  double get pitch => _pitch;
  double get rate => _rate;
  List<String> get languages => _languages;

  TtsProvider() {
    _initTts();
  }

  Future<void> _initTts() async {
    // Dilleri yükle
    try {
      dynamic langs = await _flutterTts.getLanguages;
      if (langs != null) {
        _languages = List<String>.from(langs);
        // Listeyi alfabetik sırala
        _languages.sort(); 
      }
    } catch (e) {
      debugPrint("Dil yükleme hatası: $e");
    }

    // Durum dinleyicileri
    _flutterTts.setStartHandler(() {
      _isPlaying = true;
      notifyListeners();
    });

    _flutterTts.setCompletionHandler(() {
      _isPlaying = false;
      notifyListeners();
    });

    _flutterTts.setCancelHandler(() {
      _isPlaying = false;
      notifyListeners();
    });
    
    // Hata yakalama
    _flutterTts.setErrorHandler((msg) {
      _isPlaying = false;
      notifyListeners();
    });
  }

  // --- AYARLAR ---
  void setLanguage(String lang) {
    _currentLang = lang;
    _flutterTts.setLanguage(lang);
    notifyListeners();
  }

  void setPitch(double val) {
    _pitch = val;
    notifyListeners();
  }

  void setRate(double val) {
    _rate = val;
    notifyListeners();
  }

  // --- OYNAT / DURDUR ---
  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    
    // Ayarları uygula
    await _flutterTts.setVolume(_volume);
    await _flutterTts.setSpeechRate(_rate);
    await _flutterTts.setPitch(_pitch);
    await _flutterTts.setLanguage(_currentLang);

    if (_isPlaying) {
      await stop();
    }
    
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _isPlaying = false;
    notifyListeners();
  }
}