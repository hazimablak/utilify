import 'package:flutter/material.dart';
import 'package:utilify/features/image_lab/screens/image_lab_screen.dart';
import 'package:utilify/features/pdf_studio/screens/pdf_studio_screen.dart';
import 'package:utilify/features/voice_text/screens/voice_text_screen.dart';
import 'package:utilify/features/ocr/screens/ocr_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Sayfaları Listeye Atıyoruz
  final List<Widget> _pages = const [
    ImageLabScreen(),
    PdfStudioScreen(),
    VoiceTextScreen(),
    OcrScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Seçili sayfayı göster
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      // Alt Navigasyon Çubuğu
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.image_outlined),
            selectedIcon: Icon(Icons.image),
            label: 'Image',
          ),
          NavigationDestination(
            icon: Icon(Icons.picture_as_pdf_outlined),
            selectedIcon: Icon(Icons.picture_as_pdf),
            label: 'PDF',
          ),
          NavigationDestination(
            icon: Icon(Icons.mic_none_outlined),
            selectedIcon: Icon(Icons.mic),
            label: 'Voice',
          ),
          NavigationDestination(
            icon: Icon(Icons.document_scanner_outlined),
            selectedIcon: Icon(Icons.document_scanner),
            label: 'OCR',
          ),
        ],
      ),
    );
  }
}