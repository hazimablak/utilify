// lib/features/ocr_scanner/screens/ocr_screen.dart
import 'package:flutter/material.dart';
import 'package:utilify/features/ocr_scanner/screens/text_recognizer_screen.dart';
import 'package:utilify/features/ocr_scanner/screens/qr_barcode_screen.dart';
import 'package:utilify/features/ocr_scanner/screens/business_card_screen.dart';
import 'package:utilify/features/ocr_scanner/screens/translate_camera_screen.dart';

class OcrScreen extends StatelessWidget {
  const OcrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> tools = [
      {'title': 'Akıllı Tarayıcı', 'icon': Icons.document_scanner, 'color': Colors.teal},
      {'title': 'QR & Barkod', 'icon': Icons.qr_code_scanner, 'color': Colors.indigo},
      {'title': 'Kartvizit Oku', 'icon': Icons.contact_mail, 'color': Colors.orange},
      {'title': 'Çeviri Kamerası', 'icon': Icons.g_translate, 'color': Colors.purple},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tools.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final tool = tools[index];
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (tool['title'] == 'Akıllı Tarayıcı') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const TextRecognizerScreen()));
            } 
            else if (tool['title'] == 'QR & Barkod') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const QrBarcodeScreen()));
            }
            else if (tool['title'] == 'Kartvizit Oku') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const BusinessCardScreen()));
            }
            else if (tool['title'] == 'Çeviri Kamerası') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const TranslateCameraScreen()));
            }
            else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${tool['title']} yakında eklenecek! 🛠️'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(milliseconds: 1000),
                ),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: tool['color'].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(tool['icon'], size: 32, color: tool['color']),
                ),
                const SizedBox(height: 12),
                Text(
                  tool['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}