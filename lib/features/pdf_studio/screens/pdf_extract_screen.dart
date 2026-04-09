// lib/features/pdf_studio/screens/pdf_extract_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utilify/features/pdf_studio/logic/pdf_extract_provider.dart';
import 'package:utilify/widgets/ad_banner_widget.dart';

class PdfExtractScreen extends StatefulWidget {
  const PdfExtractScreen({super.key});

  @override
  State<PdfExtractScreen> createState() => _PdfExtractScreenState();
}

class _PdfExtractScreenState extends State<PdfExtractScreen> {
  final TextEditingController _pagesController = TextEditingController();

  @override
  void dispose() {
    _pagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PdfExtractProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sayfa Çıkart"),
        actions: [
          if (provider.selectedPdf != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                provider.clearPdf();
                _pagesController.clear();
              },
              tooltip: "Temizle",
            )
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: const SafeArea(child: Padding(padding: EdgeInsets.only(bottom: 5), child: AdBannerWidget())),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Büyük bir PDF dosyasından sadece istediğiniz sayfaları ayırarak yeni bir dosya oluşturun.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // --- PDF SEÇİM ALANI ---
            GestureDetector(
              onTap: provider.isExtracting ? null : () => provider.pickPdf(),
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: provider.selectedPdf == null ? Colors.teal.withOpacity(0.05) : Colors.green.withOpacity(0.05),
                  border: Border.all(
                    color: provider.selectedPdf == null ? Colors.teal.withOpacity(0.3) : Colors.green.withOpacity(0.5),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      provider.selectedPdf == null ? Icons.file_upload : Icons.check_circle,
                      size: 48,
                      color: provider.selectedPdf == null ? Colors.teal : Colors.green,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      provider.selectedPdf == null ? "İşlenecek PDF'i Seçin" : provider.selectedPdf!.path.split('/').last,
                      style: TextStyle(
                        color: provider.selectedPdf == null ? Colors.teal : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (provider.selectedPdf != null) ...[
                      const SizedBox(height: 8),
                      Text("Toplam: ${provider.totalPages} Sayfa", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ]
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),

            // --- SAYFA GİRİŞ ALANI ---
            if (provider.selectedPdf != null) ...[
              TextField(
                controller: _pagesController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Çıkartılacak Sayfalar",
                  hintText: "Örn: 1, 4, 5, 12",
                  helperText: "Aralarına virgül koyarak sayfa numaralarını yazın.",
                  prefixIcon: const Icon(Icons.content_cut, color: Colors.teal),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.teal, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              if (provider.isExtracting)
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: Colors.teal),
                      const SizedBox(height: 10),
                      Text(provider.statusMessage, style: const TextStyle(color: Colors.teal)),
                    ],
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: () {
                    provider.extractPages(context, _pagesController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.copy_all),
                  label: const Text("SAYFALARI ÇIKART", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
            ],
          ],
        ),
      ),
    );
  }
}