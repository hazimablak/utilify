// lib/features/ocr_scanner/screens/business_card_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:utilify/features/ocr_scanner/logic/business_card_provider.dart';
import 'package:utilify/widgets/ad_banner_widget.dart';

class BusinessCardScreen extends StatelessWidget {
  const BusinessCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BusinessCardProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kartvizit Okuyucu'),
        actions: [
          if (provider.image != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => provider.clear(),
              tooltip: "Temizle",
            )
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: const SafeArea(child: Padding(padding: EdgeInsets.only(bottom: 5), child: AdBannerWidget())),
      ),
      body: Column(
        children: [
          // --- GÖRSEL ALANI ---
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey[200],
            child: provider.image != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(provider.image!, fit: BoxFit.cover),
                      if (provider.isScanning)
                        Container(
                          color: Colors.black54,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.orange),
                                SizedBox(height: 16),
                                Text("Bilgiler Ayıklanıyor...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        )
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.contact_mail, size: 60, color: Colors.orange[300]),
                      const SizedBox(height: 16),
                      Text("Kartvizit Fotoğrafı Çekin", style: TextStyle(color: Colors.orange[800], fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
          ),

          // --- BUTONLAR ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: provider.isScanning ? null : () => provider.pickImage(ImageSource.camera),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("KAMERA"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: provider.isScanning ? null : () => provider.pickImage(ImageSource.gallery),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    icon: const Icon(Icons.photo_library, color: Colors.orange),
                    label: const Text("GALERİ", style: TextStyle(color: Colors.orange)),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // --- AYIKLANAN BİLGİLER ALANI ---
          Expanded(
            child: Container(
              color: Colors.white,
              child: provider.image == null && !provider.isScanning
                  ? Center(child: Text("Ayıklanan bilgiler burada görünecek.", style: TextStyle(color: Colors.grey[500])))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (!provider.isScanning && provider.phones.isEmpty && provider.emails.isEmpty && provider.websites.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text("Bu fotoğrafta telefon, mail veya web sitesi bulunamadı.", textAlign: TextAlign.center),
                            ),
                          ),
                          
                        // Telefonlar
                        if (provider.phones.isNotEmpty) ...[
                          const Text("📱 Telefon Numaraları", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 8),
                          ...provider.phones.map((phone) => _buildInfoCard(context, phone, Icons.phone, Colors.green)),
                          const SizedBox(height: 20),
                        ],

                        // E-Postalar
                        if (provider.emails.isNotEmpty) ...[
                          const Text("📧 E-Posta Adresleri", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 8),
                          ...provider.emails.map((email) => _buildInfoCard(context, email, Icons.email, Colors.blue)),
                          const SizedBox(height: 20),
                        ],

                        // Web Siteleri
                        if (provider.websites.isNotEmpty) ...[
                          const Text("🌍 Web Siteleri", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 8),
                          ...provider.websites.map((web) => _buildInfoCard(context, web, Icons.language, Colors.purple)),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Bilgi Kartı Tasarımı
  Widget _buildInfoCard(BuildContext context, String text, IconData icon, Color color) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
        title: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: IconButton(
          icon: const Icon(Icons.copy, color: Colors.grey),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: text));
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$text kopyalandı!")));
          },
        ),
      ),
    );
  }
}