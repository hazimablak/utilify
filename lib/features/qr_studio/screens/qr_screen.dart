import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:utilify/features/qr_studio/logic/qr_provider.dart';
import 'package:utilify/widgets/ad_banner_widget.dart'; // Reklam

class QrScreen extends StatelessWidget {
  const QrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider'ı burada oluşturmuyoruz, main.dart'ta tanımlayacağız
    final provider = Provider.of<QrProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('QR & Barkod Stüdyosu'),
          bottom: const TabBar(
            labelColor: Colors.indigo,
            indicatorColor: Colors.indigo,
            tabs: [
              Tab(icon: Icon(Icons.qr_code_scanner), text: "TARA"),
              Tab(icon: Icon(Icons.qr_code_2), text: "OLUŞTUR"),
            ],
          ),
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
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(), // Kaydırmayı kapat (Kamera karışmasın)
          children: [
            // --- 1. SEKME: TARAMA ---
            _buildScanTab(context, provider),

            // --- 2. SEKME: OLUŞTURMA ---
            _buildGenerateTab(context, provider),
          ],
        ),
      ),
    );
  }

  // --- 1. TARAMA EKRANI ---
  Widget _buildScanTab(BuildContext context, QrProvider provider) {
    return Column(
      children: [
        // Kamera Alanı
        Expanded(
          flex: 2,
          child: Stack(
            children: [
              MobileScanner(
                controller: provider.scannerController,
                onDetect: provider.onDetect,
              ),
              // Tarama Çerçevesi (Overlay)
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              // Flaş Butonu
              Positioned(
                bottom: 20,
                right: 20,
                child: IconButton.filled(
                  onPressed: () => provider.scannerController.toggleTorch(),
                  icon: const Icon(Icons.flash_on),
                ),
              ),
            ],
          ),
        ),
        
        // Sonuç Alanı
        Expanded(
          flex: 1,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: provider.isScanning
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text("Kodu çerçeveye tutun...", style: TextStyle(color: Colors.grey)),
                    ],
                  )
                : Column(
                    children: [
                      const Text("✅ TARANDI", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      const SizedBox(height: 10),
                      SelectableText(
                        provider.scannedResult,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: provider.scannedResult));
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kopyalandı")));
                            },
                            icon: const Icon(Icons.copy),
                            label: const Text("Kopyala"),
                          ),
                          const SizedBox(width: 10),
                          if (provider.scannedResult.startsWith("http"))
                            FilledButton.icon(
                              onPressed: () => provider.launchURL(provider.scannedResult),
                              icon: const Icon(Icons.open_in_new),
                              label: const Text("Siteye Git"),
                            ),
                          if (!provider.isScanning)
                            IconButton(
                              onPressed: () => provider.resetScan(),
                              icon: const Icon(Icons.refresh, color: Colors.indigo),
                              tooltip: "Tekrar Tara",
                            )
                        ],
                      )
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // --- 2. OLUŞTURMA EKRANI ---
  Widget _buildGenerateTab(BuildContext context, QrProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Giriş Alanı
          TextField(
            controller: provider.inputController,
            decoration: const InputDecoration(
              labelText: "Metin, Link veya Wi-Fi Şifresi girin",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.edit),
            ),
            onChanged: (val) => provider.updateData(val),
          ),
          
          const SizedBox(height: 20),

          // Renk Seçimi (Basit)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _colorDot(Colors.black, provider),
              _colorDot(Colors.indigo, provider),
              _colorDot(Colors.red, provider),
              _colorDot(Colors.green, provider),
              _colorDot(Colors.purple, provider),
            ],
          ),

          const SizedBox(height: 30),

          // QR Kodu Önizleme (Screenshot Widget içinde)
          if (provider.dataToGenerate.isNotEmpty)
            Screenshot(
              controller: provider.screenshotController,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10)],
                ),
                child: QrImageView(
                  data: provider.dataToGenerate,
                  version: QrVersions.auto,
                  size: 200.0,
                  foregroundColor: provider.qrColor,
                  backgroundColor: Colors.white,
                ),
              ),
            )
          else
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)),
              child: const Center(child: Icon(Icons.qr_code, size: 80, color: Colors.grey)),
            ),

          const SizedBox(height: 30),

          // Kaydet Butonu
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: provider.dataToGenerate.isEmpty || provider.isSaving
                  ? null
                  : () async {
                      bool success = await provider.saveQrToGallery();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? "Galeriye Kaydedildi! 📸" : "Kaydetme Başarısız."),
                            backgroundColor: success ? Colors.green : Colors.red,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              icon: provider.isSaving 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : const Icon(Icons.download),
              label: const Text("GALERİYE KAYDET"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorDot(Color color, QrProvider provider) {
    bool isSelected = provider.qrColor == color;
    return GestureDetector(
      onTap: () => provider.changeQrColor(color),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
        ),
      ),
    );
  }
}