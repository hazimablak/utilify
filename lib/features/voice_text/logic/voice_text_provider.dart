import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // Dosya yolu için
import 'package:share_plus/share_plus.dart'; // Paylaşım için
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart'; // Çeviri paketi

class VoiceTextProvider extends ChangeNotifier {
  // --- Araçlar ---
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  // Çevirmen (Başlangıçta null)
  OnDeviceTranslator? _translator;

  // --- Değişkenler ---
  bool _isListening = false;
  String _text = "Konuşmak için mikrofona basın...";
  String _translatedText = ""; // Çevrilmiş metin
  bool _isTranslating = false;
  
  // Dil Ayarları (Varsayılan: Türkçe -> İngilizce)
  TranslateLanguage _sourceLanguage = TranslateLanguage.turkish;
  TranslateLanguage _targetLanguage = TranslateLanguage.english;

  // --- Getterlar ---
  bool get isListening => _isListening;
  String get text => _text;
  String get translatedText => _translatedText;
  bool get isTranslating => _isTranslating;
  TranslateLanguage get sourceLanguage => _sourceLanguage;
  TranslateLanguage get targetLanguage => _targetLanguage;

  VoiceTextProvider() {
    _initTts();
    _initTranslator(); // Çevirmeni başlat
  }

  // TTS Ayarları
  Future<void> _initTts() async {
    // iOS için ses kategorisi ayarı
    await _flutterTts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback,
        [IosTextToSpeechAudioCategoryOptions.defaultToSpeaker]);
  }

  // Çevirmeni Hazırla
  void _initTranslator() {
    _translator = OnDeviceTranslator(
      sourceLanguage: _sourceLanguage,
      targetLanguage: _targetLanguage,
    );
  }

  // --- 1. Dil Değiştirme ---
  Future<void> swapLanguages() async {
    final temp = _sourceLanguage;
    _sourceLanguage = _targetLanguage;
    _targetLanguage = temp;
    
    // Çevirmeni yeni dillerle güncelle
    _translator?.close();
    _initTranslator();
    
    // Metinleri de takas et
    if (_text != "Konuşmak için mikrofona basın...") {
      final tempText = _text;
      _text = _translatedText;
      _translatedText = tempText;
    }
    
    notifyListeners();
  }

  // --- 2. Sesi Yazıya Dökme (STT) ---
  Future<void> toggleListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        _isListening = true;
        notifyListeners();

        // Seçilen kaynak dile göre dinle (TR veya EN)
        String localeId = _sourceLanguage == TranslateLanguage.turkish ? "tr_TR" : "en_US";

        _speech.listen(
          onResult: (result) {
            _text = result.recognizedWords;
            notifyListeners();
            
            // Konuşma bitince veya duraklayınca otomatik çevir
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

  // --- 3. Çeviri Yap (Offline) ---
  Future<void> translate() async {
    if (_text.isEmpty || _translator == null) return;

    _isTranslating = true;
    notifyListeners();

    try {
      // Önce modelin yüklü olup olmadığına bakıyoruz
      final modelManager = OnDeviceTranslatorModelManager();
      
      // Kaynak dil modeli yüklü mü?
      if (!await modelManager.isModelDownloaded(_sourceLanguage.bcpCode)) {
        debugPrint("Model indiriliyor: ${_sourceLanguage.name}");
        await modelManager.downloadModel(_sourceLanguage.bcpCode);
      }
      
      // Hedef dil modeli yüklü mü?
      if (!await modelManager.isModelDownloaded(_targetLanguage.bcpCode)) {
        debugPrint("Model indiriliyor: ${_targetLanguage.name}");
        await modelManager.downloadModel(_targetLanguage.bcpCode);
      }

      // Çeviri yap
      final String result = await _translator!.translateText(_text);
      _translatedText = result;

    } catch (e) {
      _translatedText = "Çeviri hatası (İnterneti kontrol et - ilk indirme için): $e";
    } finally {
      _isTranslating = false;
      notifyListeners();
    }
  }

  // --- 4. Yazıyı Oku (TTS) ---
  Future<void> speakText(String textToSpeak, bool isTargetLang) async {
    if (textToSpeak.isEmpty) return;
    
    // Hangi dilde okuyacağını ayarla
    String langCode = isTargetLang 
        ? (_targetLanguage == TranslateLanguage.turkish ? "tr-TR" : "en-US")
        : (_sourceLanguage == TranslateLanguage.turkish ? "tr-TR" : "en-US");

    await _flutterTts.setLanguage(langCode);
    await _flutterTts.speak(textToSpeak);
  }

  // --- 5. Ses Dosyasını Paylaş (WhatsApp vb.) ---
  Future<void> shareAudioFile() async {
    if (_translatedText.isEmpty) return;

    try {
      // Hangi dilde kayıt yapacağız? Hedef dilde (Örn: İngilizce)
      String langCode = _targetLanguage == TranslateLanguage.turkish ? "tr-TR" : "en-US";
      await _flutterTts.setLanguage(langCode);

      // Dosya ismini oluştur
      final tempDir = await getTemporaryDirectory();
      final fileName = "utilify_audio_${DateTime.now().millisecondsSinceEpoch}.wav";
      final filePath = "${tempDir.path}/$fileName";

      // Dosyaya yaz (Android ve iOS uyumlu sentezleme)
      if (Platform.isAndroid) {
        await _flutterTts.synthesizeToFile(_translatedText, fileName);
      } else {
        await _flutterTts.synthesizeToFile(_translatedText, fileName); 
      }

      // Dosyanın oluşturulmasını biraz bekle
      await Future.delayed(const Duration(seconds: 1));
      
      final file = File(filePath);
      if (await file.exists()) {
        // Paylaşım penceresini aç (Share Plus paketi)
        await Share.shareXFiles([XFile(filePath)], text: "Utilify Çeviri Ses Dosyası");
      }
    } catch (e) {
      debugPrint("Paylaşım hatası: $e");
    }
  }

  void updateText(String val) {
    _text = val;
    // notifyListeners() yok, TextField yönetiyor
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