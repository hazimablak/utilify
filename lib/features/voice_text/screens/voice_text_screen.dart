// lib/features/voice_text/screens/voice_text_screen.dart
import 'package:flutter/material.dart';
import 'package:utilify/features/voice_text/screens/lingua_master_screen.dart';
import 'package:utilify/features/voice_text/screens/tts_screen.dart';
import 'package:utilify/features/voice_text/screens/transcribe_screen.dart';
import 'package:utilify/features/voice_text/screens/voice_effects_screen.dart';
class VoiceTextScreen extends StatelessWidget {
  const VoiceTextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🎙️ SES ARAÇLARI LİSTESİ (Şu an 2'si aktif, 3.sü yolda!)
    final List<Map<String, dynamic>> tools = [
      {'title': 'Anında Çeviri', 'icon': Icons.translate, 'color': Colors.indigo},
      {'title': 'Metin Seslendir', 'icon': Icons.record_voice_over, 'color': Colors.teal},
      {'title': 'Sesten Metne', 'icon': Icons.mic_external_on, 'color': Colors.orange},
      {'title': 'Ses Efektleri', 'icon': Icons.graphic_eq, 'color': Colors.purple},
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
            if (tool['title'] == 'Anında Çeviri') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LinguaMasterScreen()));
            } 
            else if (tool['title'] == 'Metin Seslendir') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const TtsScreen()));
            }
            else if (tool['title'] == 'Sesten Metne') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const TranscribeScreen()));
            }
            else if (tool['title'] == 'Ses Efektleri') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const VoiceEffectsScreen()));
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