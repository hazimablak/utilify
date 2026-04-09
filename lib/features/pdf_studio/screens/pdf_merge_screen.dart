// lib/features/pdf_studio/screens/pdf_merge_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utilify/features/pdf_studio/logic/pdf_merge_provider.dart';
import 'package:utilify/widgets/ad_banner_widget.dart';

class PdfMergeScreen extends StatelessWidget {
  const PdfMergeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PdfMergeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Birleştir"),
        actions: [
          if (provider.selectedPdfs.isNotEmpty)
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
          if (provider.selectedPdfs.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.blue.withOpacity(0.1),
              width: double.infinity,
              child: const Text(
                "💡 Sıralamak için basılı tutun ve sürükleyin",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blue, fontSize: 12),
              ),
            ),
          Expanded(
            child: provider.selectedPdfs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.picture_as_pdf, size: 80, color: Colors.blue.withOpacity(0.3)),
                        const SizedBox(height: 10),
                        const Text("Birleştirmek için PDF dosyalarını seçin", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.selectedPdfs.length,
                    onReorder: (oldIndex, newIndex) => provider.reorderPdfs(oldIndex, newIndex),
                    itemBuilder: (context, index) {
                      final File pdf = provider.selectedPdfs[index];
                      // Sadece dosyanın adını ekranda gösteriyoruz (uzun yolunu değil)
                      final String fileName = pdf.path.split('/').last;

                      return Card(
                        key: ValueKey(pdf.path),
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 40),
                          title: Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("${index + 1}. Sıra"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () => provider.removePdf(index),
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
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (provider.isMerging)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      provider.statusMessage,
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: provider.isMerging ? null : () => provider.pickPdfs(),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        icon: const Icon(Icons.add_box_outlined),
                        label: const Text("PDF Ekle"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: provider.selectedPdfs.length < 2 || provider.isMerging
                            ? null
                            : () => provider.mergePdfs(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        icon: provider.isMerging
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.merge_type),
                        label: Text(provider.isMerging ? "İşleniyor..." : "BİRLEŞTİR"),
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
}