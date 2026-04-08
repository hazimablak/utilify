import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Sistem ayarları için gerekli
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

// Senin mevcut Provider importların
import 'package:utilify/features/image_lab/logic/image_lab_provider.dart';
import 'package:utilify/features/pdf_studio/logic/pdf_studio_provider.dart';
import 'package:utilify/features/voice_text/logic/voice_text_provider.dart';
import 'package:utilify/features/ocr/logic/ocr_provider.dart';
import 'package:utilify/features/qr_studio/logic/qr_provider.dart';
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
        // SENİN YAZDIĞIN MEVCUT PROVIDERLAR
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
        
        // 🔥 YENİ EKLENEN: Alt menü geçişleri için Navigasyon Provider'ı
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: MaterialApp(
        title: 'utilify', // Marka ismine uygun güncellendi
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
        // 🔥 YENİ EKLENEN: Uygulamanın başlayacağı ana ekran bağlandı
        home: const MainScreen(), 
      ),
    );
  }
}

// ==========================================
// 📌 STATE MANAGEMENT (Navigasyon Kontrolü)
// ==========================================
class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}

// ==========================================
// 📌 ANA EKRAN & BOTTOM NAVIGATION BAR
// ==========================================
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  final List<Widget> _pages = const [
    ImageLabScreen(),
    PdfStudioScreen(),
    VoiceTextScreen(),
    OcrReaderScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('utilify', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _pages[navProvider.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navProvider.currentIndex,
        onTap: (index) => navProvider.setIndex(index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey.shade600,
        backgroundColor: Colors.white,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.image_outlined), activeIcon: Icon(Icons.image), label: 'Görsel'),
          BottomNavigationBarItem(icon: Icon(Icons.picture_as_pdf_outlined), activeIcon: Icon(Icons.picture_as_pdf), label: 'PDF'),
          BottomNavigationBarItem(icon: Icon(Icons.mic_none), activeIcon: Icon(Icons.mic), label: 'Çevirici'),
          BottomNavigationBarItem(icon: Icon(Icons.document_scanner_outlined), activeIcon: Icon(Icons.document_scanner), label: 'OCR'),
        ],
      ),
    );
  }
}

// ==========================================
// 📌 MODÜL PLACEHOLDER'LARI (Geçici Ekranlar)
// ==========================================
class ImageLabScreen extends StatelessWidget {
  const ImageLabScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('🎨 Görsel Atölyesi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)));
}

class PdfStudioScreen extends StatelessWidget {
  const PdfStudioScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('📄 Belge Masası', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)));
}

class VoiceTextScreen extends StatelessWidget {
  const VoiceTextScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('🎙️ Dil Çevirici', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)));
}

class OcrReaderScreen extends StatelessWidget {
  const OcrReaderScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('🔍 Optik Okuyucu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)));
}