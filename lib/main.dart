import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

// 🎨 GÖRSEL ATÖLYESİ BEYİNLERİ
import 'package:utilify/features/image_lab/logic/compress_provider.dart'; 
import 'package:utilify/features/image_lab/logic/crop_provider.dart';
import 'package:utilify/features/image_lab/logic/remover_provider.dart';
import 'package:utilify/features/image_lab/logic/blur_provider.dart';
import 'package:utilify/features/image_lab/logic/editor_provider.dart'; 
import 'package:utilify/features/image_lab/logic/meme_provider.dart';   

// 📄 PDF BEYİNLERİ
import 'package:utilify/features/pdf_studio/logic/image_to_pdf_provider.dart'; 
import 'package:utilify/features/pdf_studio/logic/pdf_merge_provider.dart';
import 'package:utilify/features/pdf_studio/logic/pdf_encrypt_provider.dart';
import 'package:utilify/features/pdf_studio/logic/pdf_extract_provider.dart';

// 🎙️ SES VE ÇEVİRİ BEYİNLERİ
import 'package:utilify/features/voice_text/logic/lingua_master_provider.dart'; 
import 'package:utilify/features/voice_text/logic/tts_provider.dart'; 
import 'package:utilify/features/voice_text/logic/transcribe_provider.dart';
import 'package:utilify/features/voice_text/logic/voice_effects_provider.dart';

// OCR TARAYICI BEYİNİ
import 'package:utilify/features/ocr_scanner/logic/text_recognizer_provider.dart';
import 'package:utilify/features/ocr_scanner/logic/qr_barcode_provider.dart';
import 'package:utilify/features/ocr_scanner/logic/business_card_provider.dart';
import 'package:utilify/features/ocr_scanner/logic/translate_camera_provider.dart';

// 🏠 ANA EKRAN (Klasör yolunu projenin mevcut durumuna göre yazdım)
import 'package:utilify/features/home/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize(); 

  // --- EKRAN TAŞMASINI ÖNLEYEN AYAR ---
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, 
    statusBarIconBrightness: Brightness.dark, 
    systemNavigationBarColor: Colors.white, 
    systemNavigationBarIconBrightness: Brightness.dark, 
  ));

  runApp(const UtilifyApp());
}

class UtilifyApp extends StatelessWidget {
  const UtilifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Görsel Providers
        ChangeNotifierProvider(create: (_) => CompressProvider()), 
        ChangeNotifierProvider(create: (_) => CropProvider()),
        ChangeNotifierProvider(create: (_) => RemoverProvider()),
        ChangeNotifierProvider(create: (_) => BlurProvider()),
        ChangeNotifierProvider(create: (_) => EditorProvider()),
        ChangeNotifierProvider(create: (_) => MemeProvider()),
        
        // PDF Providers
        ChangeNotifierProvider(create: (_) => ImageToPdfProvider()), 
        ChangeNotifierProvider(create: (_) => PdfMergeProvider()),
        ChangeNotifierProvider(create: (_) => PdfEncryptProvider()),
        ChangeNotifierProvider(create: (_) => PdfExtractProvider()),
        
        // Ses Providers
        ChangeNotifierProvider(create: (_) => LinguaMasterProvider()), 
        ChangeNotifierProvider(create: (_) => TtsProvider()),
        ChangeNotifierProvider(create: (_) => TranscribeProvider()),
        ChangeNotifierProvider(create: (_) => VoiceEffectsProvider()),

        // OCR Provider
        ChangeNotifierProvider(create: (_) => TextRecognizerProvider()),
        ChangeNotifierProvider(create: (_) => QrBarcodeProvider()),
        ChangeNotifierProvider(create: (_) => BusinessCardProvider()),
        ChangeNotifierProvider(create: (_) => TranslateCameraProvider()),

      ],
      child: MaterialApp(
        title: 'utilify',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF5F7FA),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
            iconTheme: IconThemeData(color: Colors.black87),
          ),
        ),
        home: const HomeScreen(), 
      ),
    );
  }
}