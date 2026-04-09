// lib/features/pdf_studio/screens/pdf_studio_screen.dart
import 'package:flutter/material.dart';

import 'package:utilify/features/pdf_studio/screens/image_to_pdf_screen.dart';
import 'package:utilify/features/pdf_studio/screens/pdf_merge_screen.dart';
import 'package:utilify/features/pdf_studio/screens/pdf_encrypt_screen.dart';
import 'package:utilify/features/pdf_studio/screens/pdf_extract_screen.dart';

class PdfStudioScreen extends StatelessWidget {
  const PdfStudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> pdfTools = [
      {'title': 'Görseli PDF Yap', 'icon': Icons.picture_as_pdf, 'color': Colors.orange},
      {'title': 'PDF Birleştir', 'icon': Icons.merge_type, 'color': Colors.blue},
      {'title': 'PDF Şifrele', 'icon': Icons.lock_outline, 'color': Colors.redAccent},
      {'title': 'Sayfa Çıkart', 'icon': Icons.content_copy, 'color': Colors.teal},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pdfTools.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final tool = pdfTools[index];
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (tool['title'] == 'Görseli PDF Yap') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ImageToPdfScreen()));
            } 
            else if (tool['title'] == 'PDF Birleştir') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PdfMergeScreen()));
            }
            else if (tool['title'] == 'PDF Şifrele') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PdfEncryptScreen()));
            }
            else if (tool['title'] == 'Sayfa Çıkart') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PdfExtractScreen()));
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