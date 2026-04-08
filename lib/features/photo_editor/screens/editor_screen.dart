import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utilify/features/photo_editor/logic/editor_provider.dart';
import 'package:utilify/features/photo_editor/utils/filter_utils.dart';
import 'package:utilify/widgets/ad_banner_widget.dart';

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Main.dart'ta provider tanımlayacağız
    final provider = Provider.of<EditorProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black, // Profesyonel görünüm için koyu tema
      appBar: AppBar(
        title: const Text("PhotoFX Stüdyo", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (provider.selectedImage != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => provider.clearImage(),
            )
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        child: const SafeArea(child: Padding(padding: EdgeInsets.only(bottom: 5), child: AdBannerWidget())),
      ),
      body: Column(
        children: [
          // --- RESİM ALANI ---
          Expanded(
            child: Center(
              child: provider.selectedImage == null
                  ? GestureDetector(
                      onTap: () => provider.pickImage(),
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 50, color: Colors.indigoAccent),
                            SizedBox(height: 10),
                            Text("Fotoğraf Seç", style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                    )
                  : RepaintBoundary( // Resmi kaydetmek için sınır çiziyoruz
                      key: provider.imageKey,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.matrix(provider.currentFilter),
                        child: Image.file(
                          provider.selectedImage!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
            ),
          ),

          // --- KONTROL ALANI ---
          if (provider.selectedImage != null)
            Container(
              height: 260,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Filtre İsimleri
                  const Align(alignment: Alignment.centerLeft, child: Text("Filtreler", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 10),
                  
                  // Filtre Listesi
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: FilterUtils.filters.length,
                      itemBuilder: (context, index) {
                        final filter = FilterUtils.filters[index];
                        return GestureDetector(
                          onTap: () => provider.setFilter(filter['matrix']),
                          child: Container(
                            margin: const EdgeInsets.only(right: 15),
                            child: Column(
                              children: [
                                // Küçük Önizleme
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: provider.currentFilter == filter['matrix'] ? Colors.indigoAccent : Colors.transparent, 
                                      width: 2
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: ColorFiltered(
                                      colorFilter: ColorFilter.matrix(filter['matrix']),
                                      child: Image.file(provider.selectedImage!, fit: BoxFit.cover),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(filter['name'], style: const TextStyle(color: Colors.white70, fontSize: 10)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Kaydet Butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: provider.isSaving 
                          ? null 
                          : () async {
                              bool success = await provider.saveImage();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(success ? "Galeriye Kaydedildi! ✨" : "Hata Oluştu"),
                                  backgroundColor: success ? Colors.green : Colors.red,
                                ));
                              }
                            },
                      icon: provider.isSaving 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.download),
                      label: const Text("KAYDET"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigoAccent, foregroundColor: Colors.white),
                    ),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }
}