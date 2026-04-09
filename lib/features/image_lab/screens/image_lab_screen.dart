import 'package:flutter/material.dart';

// 🎨 GÖRSEL ATÖLYESİ (IMAGE LAB) İMPORTLARI 
import 'package:utilify/features/image_lab/screens/compress_screen.dart';
import 'package:utilify/features/image_lab/screens/crop_screen.dart';
import 'package:utilify/features/image_lab/screens/remover_screen.dart';
import 'package:utilify/features/image_lab/screens/blur_screen.dart';
import 'package:utilify/features/image_lab/screens/meme_screen.dart';
import 'package:utilify/features/image_lab/screens/editor_screen.dart';

class ImageLabScreen extends StatelessWidget {
  const ImageLabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> tools = [
      {'title': 'Foto Sıkıştırma', 'icon': Icons.compress, 'color': Colors.green},
      {'title': 'Foto Kırpma', 'icon': Icons.crop, 'color': Colors.blue},
      {'title': 'Arka Plan Silici', 'icon': Icons.layers_clear, 'color': Colors.redAccent},
      {'title': 'Bulanıklaştırma', 'icon': Icons.blur_on, 'color': Colors.purple},
      {'title': 'Meme Yapıcı', 'icon': Icons.emoji_emotions, 'color': Colors.orange},
      {'title': 'Foto Editörü', 'icon': Icons.edit, 'color': Colors.teal},
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
            Widget targetPage;
            
            if (tool['title'] == 'Foto Sıkıştırma') {
              targetPage = const CompressScreen();
            } else if (tool['title'] == 'Foto Kırpma') {
              targetPage = const CropScreen();
            } else if (tool['title'] == 'Arka Plan Silici') {
              targetPage = const RemoverScreen();
            } else if (tool['title'] == 'Bulanıklaştırma') {
              targetPage = const BlurScreen();
            } else if (tool['title'] == 'Meme Yapıcı') {
              targetPage = const MemeScreen();
            } else if (tool['title'] == 'Foto Editörü') {
              targetPage = const EditorScreen(); 
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sayfa bulunamadı!'), duration: Duration(milliseconds: 800)),
              );
              return; 
            }

            Navigator.push(context, MaterialPageRoute(builder: (context) => targetPage));
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
                  decoration: BoxDecoration(color: tool['color'].withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(tool['icon'], size: 32, color: tool['color']),
                ),
                const SizedBox(height: 12),
                Text(tool['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87), textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      },
    );
  }
}