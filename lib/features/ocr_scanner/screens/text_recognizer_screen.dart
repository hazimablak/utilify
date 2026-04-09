// lib/features/ocr_scanner/screens/text_recognizer_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:utilify/features/ocr_scanner/logic/text_recognizer_provider.dart';
import 'package:utilify/widgets/ad_banner_widget.dart';

class TextRecognizerScreen extends StatelessWidget {
  const TextRecognizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TextRecognizerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Akıllı Metin Tarayıcı'),
        actions: [
          if (provider.image != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => provider.clear(),
              tooltip: "Temizle",
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
            height: 250,
            width: double.infinity,
            color: Colors.grey[200],
            child: provider.image != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(provider.image!, fit: BoxFit.cover),
                      if (provider.isScanning)
                        Container(
                          color: Colors.black54,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.tealAccent),
                                SizedBox(height: 16),
                                Text("Metinler Okunuyor...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        )
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.document_scanner, size: 60, color: Colors.teal[300]),
                      const SizedBox(height: 16),
                      Text("Taranacak Belgeyi Ekleyin", style: TextStyle(color: Colors.teal[800], fontSize: 16, fontWeight: FontWeight.bold)),
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
                    onPressed: provider.isScanning ? null : () => provider.pickImage(ImageSource.camera),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("KAMERA"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: provider.isScanning ? null : () => provider.pickImage(ImageSource.gallery),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    icon: const Icon(Icons.photo_library, color: Colors.teal),
                    label: const Text("GALERİ", style: TextStyle(color: Colors.teal)),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // --- SONUÇ ALANI ---
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: provider.recognizedText.isEmpty && !provider.isScanning
                  ? Center(
                      child: Text(
                        "Fotoğraf yüklediğinizde içindeki yazılar burada belirecektir.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Bulunan Metin:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 20),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: provider.recognizedText));
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Metin Kopyalandı!")));
                                  },
                                  tooltip: "Kopyala",
                                ),
                                IconButton(
                                  icon: const Icon(Icons.share, size: 20),
                                  onPressed: () => provider.shareText(),
                                  tooltip: "Paylaş",
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            child: SelectableText(
                              provider.recognizedText,
                              style: const TextStyle(fontSize: 16, height: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}