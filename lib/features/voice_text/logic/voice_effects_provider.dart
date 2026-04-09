// lib/features/voice_text/logic/voice_effects_provider.dart
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class VoiceEffectsProvider extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isListening = false;
  bool _isPlaying = false;
  String _text = "";
  String _selectedEffect = "Normal";

  bool get isListening => _isListening;
  bool get isPlaying => _isPlaying;
  String get text => _text;
  String get selectedEffect => _selectedEffect;

  VoiceEffectsProvider() {
    _flutterTts.setStartHandler(() {
      _isPlaying = true;
      notifyListeners();
    });
    _flutterTts.setCompletionHandler(() {
      _isPlaying = false;
      notifyListeners();
    });
  }

  // --- 1. MİKROFONDAN SESİ AL ---
  Future<void> toggleListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        _isListening = true;
        _text = ""; // Yeni kayıtta eskiyi sil
        notifyListeners();

        _speech.listen(
          onResult: (result) {
            _text = result.recognizedWords;
            notifyListeners();
          },
          localeId: "tr_TR", // Türkçe dinle
        );
      }
    } else {
      _isListening = false;
      _speech.stop();
      notifyListeners();
    }
  }

  // --- 2. EFEKTİ SEÇ VE OYNAT ---
  Future<void> playWithEffect(String effectName) async {
    if (_text.isEmpty) return;

    _selectedEffect = effectName;
    notifyListeners();

    // Efekt Ayarları (Pitch: Ses İnceliği, Rate: Okuma Hızı)
    double pitch = 1.0;
    double rate = 0.5;

    switch (effectName) {
      case "Helyum":
        pitch = 2.0; // Çok ince
        rate = 0.8;  // Hızlı
        break;
      case "Dev":
        pitch = 0.5; // Çok kalın
        rate = 0.3;  // Yavaş
        break;
      case "Robot":
        pitch = 1.2; 
        rate = 0.4;  
        break;
      case "Uzaylı":
        pitch = 1.8;
        rate = 0.6;
        break;
      case "Normal":
      default:
        pitch = 1.0;
        rate = 0.5;
        break;
    }

    if (_isPlaying) await _flutterTts.stop();

    await _flutterTts.setLanguage("tr-TR");
    await _flutterTts.setPitch(pitch);
    await _flutterTts.setSpeechRate(rate);
    await _flutterTts.speak(_text);
  }

  Future<void> stopPlaying() async {
    await _flutterTts.stop();
    _isPlaying = false;
    notifyListeners();
  }

  void clearText() {
    _text = "";
    _selectedEffect = "Normal";
    notifyListeners();
  }
}