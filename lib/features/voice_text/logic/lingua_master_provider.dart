// lib/features/voice_text/logic/lingua_master_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; 
import 'package:share_plus/share_plus.dart'; 
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart'; 

// 🔥 İSİM DÜZELTİLDİ: LinguaMasterProvider
class LinguaMasterProvider extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  OnDeviceTranslator? _translator;

  bool _isListening = false;
  String _text = "Konuşmak için mikrofona basın...";
  String _translatedText = ""; 
  bool _isTranslating = false;
  
  TranslateLanguage _sourceLanguage = TranslateLanguage.turkish;
  TranslateLanguage _targetLanguage = TranslateLanguage.english;

  bool get isListening => _isListening;
  String get text => _text;
  String get translatedText => _translatedText;
  bool get isTranslating => _isTranslating;
  TranslateLanguage get sourceLanguage => _sourceLanguage;
  TranslateLanguage get targetLanguage => _targetLanguage;

  LinguaMasterProvider() {
    _initTts();
    _initTranslator(); 
  }

  Future<void> _initTts() async {
    await _flutterTts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback,
        [IosTextToSpeechAudioCategoryOptions.defaultToSpeaker]);
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
    
    if (_text != "Konuşmak için mikrofona basın...") {
      final tempText = _text;
      _text = _translatedText;
      _translatedText = tempText;
    }
    
    notifyListeners();
  }

  Future<void> toggleListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        _isListening = true;
        notifyListeners();

        String localeId = _sourceLanguage == TranslateLanguage.turkish ? "tr_TR" : "en_US";

        _speech.listen(
          onResult: (result) {
            _text = result.recognizedWords;
            notifyListeners();
            
            if (result.finalResult) {
               translate();
            }
          },
          localeId: localeId,
        );
      }
    } else {
      _isListening = false;
      _speech.stop();
      notifyListeners();
    }
  }

  Future<void> translate() async {
    if (_text.isEmpty || _translator == null) return;

    _isTranslating = true;
    notifyListeners();

    try {
      final modelManager = OnDeviceTranslatorModelManager();
      
      if (!await modelManager.isModelDownloaded(_sourceLanguage.bcpCode)) {
        await modelManager.downloadModel(_sourceLanguage.bcpCode);
      }
      
      if (!await modelManager.isModelDownloaded(_targetLanguage.bcpCode)) {
        await modelManager.downloadModel(_targetLanguage.bcpCode);
      }

      final String result = await _translator!.translateText(_text);
      _translatedText = result;

    } catch (e) {
      _translatedText = "Çeviri hatası (İnterneti kontrol et - ilk indirme için): $e";
    } finally {
      _isTranslating = false;
      notifyListeners();
    }
  }

  Future<void> speakText(String textToSpeak, bool isTargetLang) async {
    if (textToSpeak.isEmpty) return;
    
    String langCode = isTargetLang 
        ? (_targetLanguage == TranslateLanguage.turkish ? "tr-TR" : "en-US")
        : (_sourceLanguage == TranslateLanguage.turkish ? "tr-TR" : "en-US");

    await _flutterTts.setLanguage(langCode);
    await _flutterTts.speak(textToSpeak);
  }

  Future<void> shareAudioFile() async {
    if (_translatedText.isEmpty) return;

    try {
      String langCode = _targetLanguage == TranslateLanguage.turkish ? "tr-TR" : "en-US";
      await _flutterTts.setLanguage(langCode);

      final tempDir = await getTemporaryDirectory();
      final fileName = "utilify_audio_${DateTime.now().millisecondsSinceEpoch}.wav";
      final filePath = "${tempDir.path}/$fileName";

      if (Platform.isAndroid) {
        await _flutterTts.synthesizeToFile(_translatedText, fileName);
      } else {
        await _flutterTts.synthesizeToFile(_translatedText, fileName); 
      }

      await Future.delayed(const Duration(seconds: 1));
      
      final file = File(filePath);
      if (await file.exists()) {
        await Share.shareXFiles([XFile(filePath)], text: "Utilify Çeviri Ses Dosyası");
      }
    } catch (e) {
      debugPrint("Paylaşım hatası: $e");
    }
  }

  void updateText(String val) {
    _text = val;
  }

  void clear() {
    _text = "";
    _translatedText = "";
    notifyListeners();
  }

  @override
  void dispose() {
    _translator?.close();
    super.dispose();
  }
}