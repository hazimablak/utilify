// lib/features/pdf_studio/screens/image_to_pdf_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// 🔥 İMPORT YOLU SİMETRİ İÇİN DÜZELTİLDİ
import 'package:utilify/features/pdf_studio/logic/image_to_pdf_provider.dart';
import 'package:utilify/widgets/ad_banner_widget.dart';

class ImageToPdfScreen extends StatelessWidget {
  const ImageToPdfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 PROVIDER ADI SİMETRİ İÇİN DÜZELTİLDİ
    final provider = Provider.of<ImageToPdfProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Görselden PDF'),
        actions: [
          if (provider.selectedImages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => provider.clearAll(),
              tooltip: "Tümünü Temizle",
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
      body: Column(
        children: [
          if (provider.selectedImages.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.orange.withOpacity(0.1),
              width: double.infinity,
              child: const Text(
                "💡 Sıralamak için basılı tutun ve sürükleyin",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ),
          Expanded(
            child: provider.selectedImages.isEmpty
                ? _buildEmptyState(context, provider)
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.selectedImages.length,
                    onReorder: (oldIndex, newIndex) => provider.reorderImages(oldIndex, newIndex),
                    itemBuilder: (context, index) {
                      final File img = provider.selectedImages[index];
                      return Card(
                        key: ValueKey(img.path),
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(img, width: 60, height: 60, fit: BoxFit.cover),
                          ),
                          title: Text("Sayfa ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.crop, color: Colors.indigo),
                                onPressed: () => provider.cropImage(index, context),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () => provider.removeImage(index),
                              ),
                              const Icon(Icons.drag_handle, color: Colors.grey),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (provider.isGenerating)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      provider.statusMessage,
                      style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: provider.isGenerating ? null : () => provider.pickImages(),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text("Sayfa Ekle"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: provider.selectedImages.isEmpty || provider.isGenerating
                            ? null
                            : () => provider.createAndShowPdf(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                        ),
                        icon: provider.isGenerating
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.picture_as_pdf),
                        label: Text(provider.isGenerating ? "Bekleyiniz..." : "PDF OLUŞTUR"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ImageToPdfProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.snippet_folder_rounded, size: 80, color: Colors.indigo.withOpacity(0.3)),
          const SizedBox(height: 10),
          const Text("Belgeniz boş", style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 20),
          FilledButton.tonalIcon(
            onPressed: () => provider.pickImages(),
            icon: const Icon(Icons.add),
            label: const Text("İlk Sayfayı Ekle"),
          ),
        ],
      ),
    );
  }
}