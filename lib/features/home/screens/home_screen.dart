import 'package:flutter/material.dart';

// 🔥 SADECE 3 TANE MÜDÜRÜ (ANA MENÜYÜ) İMPORT EDİYORUZ
import 'package:utilify/features/image_lab/screens/image_lab_screen.dart';
import 'package:utilify/features/pdf_studio/screens/pdf_studio_screen.dart';
import 'package:utilify/features/voice_text/screens/voice_text_screen.dart';
import 'package:utilify/features/ocr_scanner/screens/ocr_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Sadece Müdür Sayfalarını Listeye Atıyoruz (Tertemiz)
  final List<Widget> _pages = const [
    ImageLabScreen(),    // 🎨 Görsel Menüsü
    PdfStudioScreen(),   // 📄 PDF Menüsü
    VoiceTextScreen(),   // 🎙️ Ses Menüsü
    OcrScreen(),         // 🔍 OCR Menüsü (Yakında)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('utilify'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.image_outlined), selectedIcon: Icon(Icons.image), label: 'Görsel'),
          NavigationDestination(icon: Icon(Icons.picture_as_pdf_outlined), selectedIcon: Icon(Icons.picture_as_pdf), label: 'PDF'),
          NavigationDestination(icon: Icon(Icons.mic_none_outlined), selectedIcon: Icon(Icons.mic), label: 'Ses'),
          NavigationDestination(icon: Icon(Icons.document_scanner_outlined), selectedIcon: Icon(Icons.document_scanner), label: 'OCR'),
        ],
      ),
    );
  }
}