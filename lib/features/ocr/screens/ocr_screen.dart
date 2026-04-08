import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:utilify/features/ocr/logic/ocr_provider.dart';
import 'package:utilify/widgets/ad_banner_widget.dart'; // Reklam

class OcrScreen extends StatelessWidget {
  const OcrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OcrProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intelligent Scanner'),
        actions: [
          if (provider.selectedImage != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => provider.clear(),
            )
        ],
      ),
      // --- REKLAM ALANI ---
      bottomNavigationBar: Container(
        color: Colors.white,
        child: const SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: AdBannerWidget(),
          ),
        ),
      ),
      // --------------------
      body: Column(
        children: [
          // RESİM ALANI
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: provider.selectedImage == null
                  ? _buildPlaceholder(provider)
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(provider.selectedImage!, fit: BoxFit.contain),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: FloatingActionButton.small(
                            onPressed: () => provider.pickAndScanImage(ImageSource.camera),
                            child: const Icon(Icons.camera_alt),
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          // AKILLI VERİLER
          if (provider.emails.isNotEmpty || provider.phones.isNotEmpty || provider.urls.isNotEmpty)
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              color: Colors.indigo[50],
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...provider.phones.map((p) => _buildSmartChip(Icons.phone, p, 'tel', provider)),
                  ...provider.emails.map((e) => _buildSmartChip(Icons.email, e, 'mail', provider)),
                  ...provider.urls.map((u) => _buildSmartChip(Icons.link, u, 'web', provider)),
                ],
              ),
            ),

          // METİN ALANI
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0), // Alt boşluk yok, Expanded çözecek
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        provider.showTranslation ? "🇹🇷 Türkçe Çeviri" : "📄 Orijinal Metin",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                      Row(
                        children: [
                          if (provider.extractedText.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.translate, color: provider.showTranslation ? Colors.green : Colors.grey),
                            onPressed: () => provider.translateText(),
                          ),
                          if (provider.currentText.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: provider.currentText));
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kopyalandı")));
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(),
                  
                  Expanded(
                    child: provider.isScanning || provider.isTranslating
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            child: SelectableText(
                              provider.currentText.isEmpty 
                                  ? "Henüz bir metin taranmadı." 
                                  : provider.currentText,
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

  Widget _buildPlaceholder(OcrProvider provider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.document_scanner, size: 60, color: Colors.grey),
        const SizedBox(height: 10),
        const Text("Metni Taramak İçin Seçin", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => provider.pickAndScanImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text("Kamera"),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () => provider.pickAndScanImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text("Galeri"),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildSmartChip(IconData icon, String label, String type, OcrProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, top: 10, bottom: 10),
      child: ActionChip(
        avatar: Icon(icon, size: 16, color: Colors.white),
        label: Text(
          label.length > 20 ? "${label.substring(0, 18)}..." : label, 
          style: const TextStyle(color: Colors.white)
        ),
        backgroundColor: Colors.indigo,
        onPressed: () => provider.launchSmartAction(label, type),
      ),
    );
  }
}