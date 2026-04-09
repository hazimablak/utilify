// lib/features/pdf_studio/screens/pdf_encrypt_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utilify/features/pdf_studio/logic/pdf_encrypt_provider.dart';
import 'package:utilify/widgets/ad_banner_widget.dart';

class PdfEncryptScreen extends StatefulWidget {
  const PdfEncryptScreen({super.key});

  @override
  State<PdfEncryptScreen> createState() => _PdfEncryptScreenState();
}

class _PdfEncryptScreenState extends State<PdfEncryptScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PdfEncryptProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Şifrele"),
        actions: [
          if (provider.selectedPdf != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                provider.clearPdf();
                _passwordController.clear();
              },
              tooltip: "Temizle",
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- BİLGİ KARTLARI ---
            const Text(
              "Bu araç, PDF dosyanızı askeri düzeyde (AES-256) şifreleyerek korunmasını sağlar. Dosyayı açmak isteyen herkes bu parolayı girmek zorunda kalacaktır.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // --- PDF SEÇİM ALANI ---
            GestureDetector(
              onTap: provider.isEncrypting ? null : () => provider.pickPdf(),
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: provider.selectedPdf == null ? Colors.red.withOpacity(0.05) : Colors.green.withOpacity(0.05),
                  border: Border.all(
                    color: provider.selectedPdf == null ? Colors.redAccent.withOpacity(0.3) : Colors.green.withOpacity(0.5),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      provider.selectedPdf == null ? Icons.upload_file : Icons.check_circle,
                      size: 48,
                      color: provider.selectedPdf == null ? Colors.redAccent : Colors.green,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      provider.selectedPdf == null ? "Şifrelenecek PDF'i Seçin" : provider.selectedPdf!.path.split('/').last,
                      style: TextStyle(
                        color: provider.selectedPdf == null ? Colors.redAccent : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),

            // --- ŞİFRE GİRİŞ ALANI ---
            if (provider.selectedPdf != null) ...[
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "PDF Parolası Belirleyin",
                  hintText: "Örn: GucluSifre123",
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.redAccent),
                  // 🔥 HATA BURADA ÇÖZÜLDÜ: onColor silindi, doğrudan Icon içine color eklendi
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // --- ŞİFRELE BUTONU ---
              if (provider.isEncrypting)
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: Colors.redAccent),
                      const SizedBox(height: 10),
                      Text(provider.statusMessage, style: const TextStyle(color: Colors.redAccent)),
                    ],
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: () {
                    provider.encryptPdf(context, _passwordController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.enhanced_encryption),
                  label: const Text("ŞİFRELE VE KAYDET", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
            ],
          ],
        ),
      ),
    );
  }
}