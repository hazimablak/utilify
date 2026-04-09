// lib/features/ocr_scanner/screens/qr_barcode_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:utilify/features/ocr_scanner/logic/qr_barcode_provider.dart';
import 'package:utilify/widgets/ad_banner_widget.dart';

class QrBarcodeScreen extends StatefulWidget {
  const QrBarcodeScreen({super.key});

  @override
  State<QrBarcodeScreen> createState() => _QrBarcodeScreenState();
}

class _QrBarcodeScreenState extends State<QrBarcodeScreen> {
  // Manuel start() sildik, paket kendi yönetsin
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates, // Aynı QR'ı saniyede 10 kere okumasını engeller
    facing: CameraFacing.back,
  );

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('QR & Barkod Stüdyosu'),
          bottom: const TabBar(
            labelColor: Colors.indigo,
            indicatorColor: Colors.indigo,
            tabs: [
              Tab(icon: Icon(Icons.qr_code_scanner), text: "Tara"),
              Tab(icon: Icon(Icons.qr_code), text: "Oluştur"),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          color: Colors.white,
          child: const SafeArea(child: Padding(padding: EdgeInsets.only(bottom: 5), child: AdBannerWidget())),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(), // Kaydırma kapalı
          children: [
            _ScanTab(scannerController: _scannerController), 
            const _GenerateTab(),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 1. SEKME: TARAMA (KAMERA) EKRANI
// ==========================================
class _ScanTab extends StatelessWidget {
  final MobileScannerController scannerController;
  const _ScanTab({required this.scannerController});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QrBarcodeProvider>(context);

    return Column(
      children: [
        // --- KAMERA ALANI ---
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              MobileScanner(
                controller: scannerController,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                    provider.setScannedResult(barcodes.first.rawValue!);
                  }
                },
              ),
              // Hedef Göstergesi (Süsleme)
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.greenAccent.withOpacity(0.8), width: 3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),

        // --- SONUÇ ALANI ---
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
            ),
            child: provider.scannedResult.isEmpty
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner, size: 50, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("Kamerayı bir QR Koda veya Barkoda tutun.", style: TextStyle(color: Colors.grey)),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Bulunan Sonuç:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo)),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.red),
                            onPressed: () => provider.clearScanned(),
                            tooltip: "Yeniden Tara",
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                          child: SingleChildScrollView(
                            child: SelectableText(provider.scannedResult, style: const TextStyle(fontSize: 16)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: provider.scannedResult));
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kopyalandı!")));
                              },
                              icon: const Icon(Icons.copy),
                              label: const Text("KOPYALA"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Share.share(provider.scannedResult),
                              icon: const Icon(Icons.share),
                              label: const Text("PAYLAŞ"),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 2. SEKME: OLUŞTURMA EKRANI
// ==========================================
class _GenerateTab extends StatelessWidget {
  const _GenerateTab();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QrBarcodeProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            "Bir web sitesi linki, Wi-Fi şifresi veya herhangi bir metin yazarak anında kendi QR kodunuzu oluşturun.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // --- GİRİŞ ALANI ---
          TextField(
            onChanged: (val) => provider.setGenerateText(val),
            decoration: InputDecoration(
              labelText: "İçerik Girin (Link, Metin vb.)",
              prefixIcon: const Icon(Icons.link, color: Colors.indigo),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.indigo, width: 2),
              ),
            ),
            maxLines: 3,
            minLines: 1,
          ),
          const SizedBox(height: 40),

          // --- QR KOD GÖSTERİMİ & İNDİRME ---
          if (provider.generateText.isNotEmpty)
            Column(
              children: [
                RepaintBoundary(
                  key: provider.qrKey,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: QrImageView(
                      data: provider.generateText,
                      version: QrVersions.auto,
                      size: 200.0,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: provider.isSaving 
                      ? null 
                      : () async {
                          bool success = await provider.saveQrCode();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(success ? "Galeriye İndirildi! 📥" : "Hata Oluştu"),
                              backgroundColor: success ? Colors.green : Colors.red,
                            ));
                          }
                        },
                    icon: provider.isSaving 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.download),
                    label: const Text("GALERİYE İNDİR", style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                Icon(Icons.qr_code_2, size: 100, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text("QR Kod burada belirecek", style: TextStyle(color: Colors.grey[400])),
              ],
            )
        ],
      ),
    );
  }
}