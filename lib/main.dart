import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Sistem ayarları için gerekli
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:utilify/features/image_lab/logic/image_lab_provider.dart';// Providerlar
import 'package:utilify/features/pdf_studio/logic/pdf_studio_provider.dart';// Providerlar
import 'package:utilify/features/voice_text/logic/voice_text_provider.dart';// Providerlar
import 'package:utilify/features/ocr/logic/ocr_provider.dart';// Providerlar
import 'package:utilify/features/qr_studio/logic/qr_provider.dart';// Providerlar
import 'package:utilify/features/password_manager/logic/password_provider.dart';
import 'package:utilify/features/unit_converter/logic/converter_provider.dart';
import 'package:utilify/features/speed_test/logic/speed_test_provider.dart';
import 'package:utilify/features/photo_editor/logic/editor_provider.dart';
import 'package:utilify/features/meme_maker/logic/meme_provider.dart';
import 'package:utilify/features/text_to_speech/logic/tts_provider.dart';
import 'package:utilify/features/image_lab/logic/crop_provider.dart';
import 'package:utilify/features/image_lab/logic/remover_provider.dart';
import 'package:utilify/features/image_lab/logic/blur_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize(); // Reklamları başlat

  // --- EKRAN TAŞMASINI ÖNLEYEN AYAR ---
  // Uygulamanın sadece "Dikey" (Portrait) çalışmasını zorunlu kılalım (Reklamlar kaymasın diye)
  // Ve Sistem çubuklarının rengini ayarlayalım.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Üst çubuk şeffaf olsun
    statusBarIconBrightness: Brightness.dark, // İkonlar siyah (Saat, Pil vs.)
    systemNavigationBarColor: Colors.white, // Alt çubuk beyaz olsun
    systemNavigationBarIconBrightness: Brightness.dark, // Alt tuşlar siyah
  ));
  // -------------------------------------

  runApp(const UtilifyApp());
}

class UtilifyApp extends StatelessWidget {
  const UtilifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImageLabProvider()),
        ChangeNotifierProvider(create: (_) => PdfStudioProvider()),
        ChangeNotifierProvider(create: (_) => VoiceTextProvider()),
        ChangeNotifierProvider(create: (_) => OcrProvider()),
        ChangeNotifierProvider(create: (_) => QrProvider()),
        ChangeNotifierProvider(create: (_) => PasswordProvider()),
        ChangeNotifierProvider(create: (_) => ConverterProvider()),
        ChangeNotifierProvider(create: (_) => SpeedTestProvider()),
        ChangeNotifierProvider(create: (_) => EditorProvider()),
        ChangeNotifierProvider(create: (_) => MemeProvider()),
        ChangeNotifierProvider(create: (_) => TtsProvider()),
        ChangeNotifierProvider(create: (_) => CropProvider()),
        ChangeNotifierProvider(create: (_) => RemoverProvider()),
        ChangeNotifierProvider(create: (_) => BlurProvider()),
      ],
      child: MaterialApp(
        title: 'Utilify Ultimate',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF5F7FA),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            titleTextStyle: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
            iconTheme: IconThemeData(color: Colors.black87),
          ),
        ),
        ),
    );
  }
}