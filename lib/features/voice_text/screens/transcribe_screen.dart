// lib/features/voice_text/screens/transcribe_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:utilify/features/voice_text/logic/transcribe_provider.dart';
import 'package:utilify/widgets/ad_banner_widget.dart';

class TranscribeScreen extends StatelessWidget {
  const TranscribeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranscribeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deşifre Stüdyosu'),
        actions: [
          if (provider.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => provider.clearText(),
              tooltip: "Metni Temizle",
            )
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: const SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: AdBannerWidget(),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- DİL SEÇİMİ ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.language, color: Colors.orange),
                      SizedBox(width: 8),
                      Text("Konuşma Dili:", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: provider.currentLang,
                      items: const [
                        DropdownMenuItem(value: "tr_TR", child: Text("🇹🇷 Türkçe")),
                        DropdownMenuItem(value: "en_US", child: Text("🇬🇧 İngilizce")),
                      ],
                      onChanged: (val) {
                        if (val != null) provider.setLanguage(val);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- METİN ALANI ---
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                  border: Border.all(color: provider.isListening ? Colors.redAccent : Colors.grey[200]!, width: 2),
                ),
                child: SingleChildScrollView(
                  child: provider.text.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 50),
                              Icon(Icons.mic_none, size: 80, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              const Text(
                                "Toplantı, ders veya röportaj... Konuşmaları metne dökmek için aşağıdaki mikrofona dokunun.",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : SelectableText(
                          provider.text,
                          style: const TextStyle(fontSize: 18, height: 1.5, color: Colors.black87),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // --- İŞLEM BUTONLARI ---
            if (provider.text.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: provider.text));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Metin Kopyalandı!")));
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text("Kopyala"),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => provider.shareText(),
                    icon: const Icon(Icons.share),
                    label: const Text("Paylaş"),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // --- KAYIT BUTONU ---
            GestureDetector(
              onTap: () => provider.toggleListening(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: provider.isListening ? Colors.red : Colors.orange,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (provider.isListening)
                      BoxShadow(color: Colors.red.withOpacity(0.6), blurRadius: 20, spreadRadius: 5)
                  ],
                ),
                child: Icon(
                  provider.isListening ? Icons.stop_rounded : Icons.mic,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              provider.isListening ? "Dinleniyor... (Durdurmak için bas)" : "Deşifreyi Başlat",
              style: TextStyle(
                color: provider.isListening ? Colors.red : Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}