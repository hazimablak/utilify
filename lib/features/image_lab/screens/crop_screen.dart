import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utilify/features/image_lab/logic/crop_provider.dart';
import 'package:utilify/widgets/ad_banner_widget.dart';

class CropScreen extends StatelessWidget {
  const CropScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CropProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kırp & Boyutlandır"),
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
      body: SafeArea( // <--- 1. YENİ EKLENEN (Kalkan Widget)
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // --- RESİM ALANI ---
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: provider.selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.crop_rotate, size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 10),
                            const Text("Fotoğraf seçin", style: TextStyle(color: Colors.grey)),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(provider.selectedImage!, fit: BoxFit.contain),
                        ),
                ),
              ),
  
              const SizedBox(height: 30),
  
              // --- BUTONLAR ---
              // ... (Buradaki buton kodları aynen kalacak)
              if (provider.selectedImage == null)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => provider.pickImage(),
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text("FOTOĞRAF SEÇ"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
                  ),
                )
              else
                Row(
                  children: [
                    // Düzenle Butonu
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () => provider.cropImage(context),
                          icon: const Icon(Icons.crop),
                          label: const Text("DÜZENLE"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo, 
                            foregroundColor: Colors.white
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    // Kaydet Butonu
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: provider.isSaving ? null : () async {
                            bool success = await provider.saveImage();
                            if(context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(success ? "Galeriye Kaydedildi! ✅" : "Hata"),
                                backgroundColor: success ? Colors.green : Colors.red,
                              ));
                            }
                          },
                          icon: provider.isSaving 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                            : const Icon(Icons.save),
                          label: const Text("KAYDET"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, 
                            foregroundColor: Colors.white
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ), // <--- SafeArea Kapanışı
    );
  }
}