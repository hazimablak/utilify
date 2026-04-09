// lib/features/ocr_scanner/screens/translate_camera_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:utilify/features/ocr_scanner/logic/translate_camera_provider.dart';
import 'package:utilify/widgets/ad_banner_widget.dart';

class TranslateCameraScreen extends StatelessWidget {
  const TranslateCameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslateCameraProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Çeviri Kamerası'),
        actions: [
          if (provider.image != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => provider.clear(),
            )
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: const SafeArea(child: Padding(padding: EdgeInsets.only(bottom: 5), child: AdBannerWidget())),
      ),
      body: Column(
        children: [
          // --- GÖRSEL ALANI ---
          Container(
            height: 220,
            width: double.infinity,
            color: Colors.grey[200],
            child: provider.image != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(provider.image!, fit: BoxFit.cover),
                      if (provider.isProcessing)
                        Container(
                          color: Colors.black54,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.purpleAccent),
                                SizedBox(height: 16),
                                Text("Metinler Okunup Çevriliyor...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        )
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.g_translate, size: 60, color: Colors.purple[300]),
                      const SizedBox(height: 16),
                      Text("Yabancı Bir Metnin Fotoğrafını Çekin", style: TextStyle(color: Colors.purple[800], fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
          ),

          // --- BUTONLAR ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: provider.isProcessing ? null : () => provider.pickImage(ImageSource.camera),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("KAMERA"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: provider.isProcessing ? null : () => provider.pickImage(ImageSource.gallery),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    icon: const Icon(Icons.photo_library, color: Colors.purple),
                    label: const Text("GALERİ", style: TextStyle(color: Colors.purple)),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // --- ÇEVİRİ SONUÇLARI ALANI ---
          Expanded(
            child: Container(
              color: Colors.white,
              child: provider.image == null && !provider.isProcessing
                  ? Center(child: Text("Sonuçlar burada görünecek.", style: TextStyle(color: Colors.grey[500])))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Orijinal Metin
                        if (provider.originalText.isNotEmpty) ...[
                          const Row(
                            children: [
                              Icon(Icons.text_snippet_outlined, color: Colors.grey, size: 20),
                              SizedBox(width: 8),
                              Text("Okunan Orijinal Metin:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                            child: SelectableText(provider.originalText),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Çevrilmiş Metin (Büyük ve Renkli)
                        if (provider.translatedText.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.g_translate, color: Colors.purple, size: 20),
                                  SizedBox(width: 8),
                                  Text("Türkçe Çevirisi:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple, fontSize: 16)),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, color: Colors.grey),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: provider.translatedText));
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Çeviri Kopyalandı!")));
                                },
                              )
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.05),
                              border: Border.all(color: Colors.purple.withOpacity(0.2)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SelectableText(
                              provider.translatedText,
                              style: const TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}