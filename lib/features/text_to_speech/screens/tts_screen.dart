import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:utilify/features/text_to_speech/logic/tts_provider.dart';
import 'package:utilify/widgets/ad_banner_widget.dart';

class TtsScreen extends StatefulWidget {
  const TtsScreen({super.key});

  @override
  State<TtsScreen> createState() => _TtsScreenState();
}

class _TtsScreenState extends State<TtsScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TtsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Metin Seslendirici")),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: const SafeArea(child: Padding(padding: EdgeInsets.only(bottom: 5), child: AdBannerWidget())),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- METİN GİRİŞ ALANI ---
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _textController,
                maxLines: null, // Sınırsız satır
                expands: true,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  hintText: "Buraya metin yazın veya yapıştırın...",
                  border: InputBorder.none,
                ),
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Temizle ve Yapıştır Butonları
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _textController.clear(), 
                  icon: const Icon(Icons.clear, size: 18), 
                  label: const Text("Temizle")
                ),
                TextButton.icon(
                  onPressed: () async {
                    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data != null && data.text != null) {
                      _textController.text = data.text!;
                    }
                  }, 
                  icon: const Icon(Icons.paste, size: 18), 
                  label: const Text("Yapıştır")
                ),
              ],
            ),

            const Divider(height: 30),

            // --- KONTROL PANELİ ---
            
            // Dil Seçimi
            Row(
              children: [
                const Icon(Icons.language, color: Colors.indigo),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: provider.languages.contains(provider.currentLang) ? provider.currentLang : null,
                        hint: const Text("Dil Seçiliyor..."),
                        items: provider.languages.map((lang) {
                          return DropdownMenuItem(value: lang, child: Text(lang));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) provider.setLanguage(val);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Hız Ayarı
            _buildSlider(
              "Okuma Hızı", 
              provider.rate, 
              0.0, 1.0, 
              (v) => provider.setRate(v),
              Icons.speed
            ),

            // Ton Ayarı
            _buildSlider(
              "Ses Tonu", 
              provider.pitch, 
              0.5, 2.0, 
              (v) => provider.setPitch(v),
              Icons.graphic_eq
            ),

            const SizedBox(height: 30),

            // Oynat Butonu (Devasa)
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (provider.isPlaying) {
                    provider.stop();
                  } else {
                    provider.speak(_textController.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: provider.isPlaying ? Colors.red : Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: Icon(provider.isPlaying ? Icons.stop_circle : Icons.play_circle_fill, size: 32),
                label: Text(
                  provider.isPlaying ? "DURDUR" : "SESLENDİR",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double val, double min, double max, Function(double) onChanged, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: val,
          min: min,
          max: max,
          activeColor: Colors.indigo,
          onChanged: onChanged,
        ),
      ],
    );
  }
}