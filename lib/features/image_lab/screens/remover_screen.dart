import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utilify/features/image_lab/logic/remover_provider.dart';
import 'package:utilify/widgets/ad_banner_widget.dart';

class RemoverScreen extends StatelessWidget {
  const RemoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RemoverProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sihirli Silgi"),
        actions: [
          if (provider.selectedImage != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => provider.clear(),
            )
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: const SafeArea(child: Padding(padding: EdgeInsets.only(bottom: 5), child: AdBannerWidget())),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- GÖRSEL ALANI ---
            Container(
              height: 400,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300], 
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: provider.selectedImage == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_fix_high, size: 80, color: Colors.purpleAccent),
                        SizedBox(height: 10),
                        Text("Bir fotoğraf seçin", style: TextStyle(color: Colors.grey)),
                      ],
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        // Orijinal Resim
                        if (provider.removedImageBytes == null)
                          Image.file(provider.selectedImage!, fit: BoxFit.contain),
                        
                        // Sonuç Resim
                        if (provider.removedImageBytes != null)
                          Image.memory(provider.removedImageBytes!, fit: BoxFit.contain),

                        // Yükleniyor
                        if (provider.isLoading)
                          Container(
                            color: Colors.black54,
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(color: Colors.white),
                                  SizedBox(height: 10),
                                  Text("Sihir yapılıyor... ✨", style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
            ),

            const SizedBox(height: 30),

            // --- BUTONLAR ---
            if (provider.selectedImage == null)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () => provider.pickImage(),
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text("FOTOĞRAF SEÇ"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                ),
              )
            else if (provider.removedImageBytes == null)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: provider.isLoading ? null : () => provider.removeBackground(context),
                  icon: const Icon(Icons.cleaning_services),
                  label: const Text("ARKA PLANI SİL"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent, 
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else
              Row(
                children: [
                  // Tekrar Dene
                  Expanded(
                    child: SizedBox(
                      height: 55,
                      child: OutlinedButton.icon(
                        onPressed: () => provider.pickImage(),
                        icon: const Icon(Icons.refresh),
                        label: const Text("YENİ"),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Kaydet
                  Expanded(
                    child: SizedBox(
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          bool success = await provider.saveImage();
                          if(context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(success ? "PNG Olarak Kaydedildi! ✅" : "Hata"),
                              backgroundColor: success ? Colors.green : Colors.red,
                            ));
                          }
                        },
                        icon: const Icon(Icons.download),
                        label: const Text("KAYDET"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 10),
            if(provider.removedImageBytes != null)
              const Text("💡 Resim şeffaf (PNG) olarak kaydedilecektir.", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}