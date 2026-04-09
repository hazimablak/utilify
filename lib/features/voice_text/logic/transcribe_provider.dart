// lib/features/voice_text/logic/transcribe_provider.dart
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:share_plus/share_plus.dart';

class TranscribeProvider extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  bool _isListening = false;
  String _savedText = ""; // Önceki dinlemelerden kaydedilen metin
  String _currentWords = ""; // Şu an aktif olarak dinlenen metin
  String _currentLang = "tr_TR"; // Varsayılan Dil: Türkçe

  bool get isListening => _isListening;
  String get currentLang => _currentLang;
  
  // Ekranda gösterilecek toplam metin (Eski + Yeni)
  String get text => (_savedText + ( _savedText.isEmpty ? "" : " " ) + _currentWords).trim();

  void setLanguage(String lang) {
    _currentLang = lang;
    notifyListeners();
  }

  Future<void> toggleListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          // Dinleme kendiliğinden durursa (sessizlik vs.)
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            // Mevcut kelimeleri ana metne kaydet ve sıfırla
            if (_currentWords.isNotEmpty) {
              _savedText = text;
              _currentWords = "";
            }
            notifyListeners();
          }
        },
        onError: (error) {
          debugPrint('STT Hatası: $error');
          _isListening = false;
          notifyListeners();
        },
      );

      if (available) {
        _isListening = true;
        notifyListeners();
        
        _speech.listen(
          onResult: (result) {
            _currentWords = result.recognizedWords;
            notifyListeners();
          },
          localeId: _currentLang,
          cancelOnError: false,
          partialResults: true, // Konuşurken anlık yazsın
        );
      }
    } else {
      _isListening = false;
      _speech.stop();
      
      // Kapatırken mevcut kelimeleri kaydet
      if (_currentWords.isNotEmpty) {
        _savedText = text;
        _currentWords = "";
      }
      notifyListeners();
    }
  }

  void clearText() {
    _savedText = "";
    _currentWords = "";
    notifyListeners();
  }

  void shareText() {
    if (text.isNotEmpty) {
      Share.share(text, subject: "Utilify Deşifre Notu");
    }
  }
}