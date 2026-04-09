import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:provider/provider.dart';
import 'package:utilify/features/image_lab/logic/compress_provider.dart'; // 🔥 GÜNCELLENDİ
import 'package:image_picker/image_picker.dart';
import 'package:utilify/widgets/ad_banner_widget.dart';
import 'package:utilify/utils/rewarded_ad_manager.dart';

class CompressScreen extends StatefulWidget {
  const CompressScreen({super.key});

  @override
  State<CompressScreen> createState() => _CompressScreenState();
}

class _CompressScreenState extends State<CompressScreen> {
  final RewardedAdManager _rewardedAdManager = RewardedAdManager();

  @override
  void initState() {
    super.initState();
    _rewardedAdManager.loadRewardedAd();
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 GÜNCELLENDİ: CompressProvider
    final provider = Provider.of<CompressProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Görsel Stüdyo Pro'),
        actions: [
          if (provider.originalImage != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => provider.clear(),
            ),
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
        child: Column(
          children: [
            _buildImageArea(context, provider),
            const SizedBox(height: 20),

            if (provider.originalImage != null) ...[
              _buildSettingsCard(context, provider),
              const SizedBox(height: 20),

              if (provider.compressedImage == null)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: provider.isLoading 
                        ? null 
                        : () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("🚀 Pro Sıkıştırma"),
                                content: const Text("En yüksek kalitede işlem yapmak için kısa bir reklam izleyerek bize destek olur musunuz?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      provider.compressImage(); 
                                    },
                                    child: const Text("Hayır, direkt yap"),
                                  ),
                                  FilledButton.icon(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      _rewardedAdManager.showRewardedAd(
                                        onRewardEarned: () {
                                          provider.compressImage();
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.play_circle_fill),
                                    label: const Text("İzle ve Başlat"),
                                  ),
                                ],
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: provider.isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                        : const Icon(Icons.bolt),
                    label: Text(
                      provider.isLoading ? "İşleniyor..." : "DÖNÜŞTÜR VE SIKIŞTIR",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

              if (provider.compressedImage != null)
                _buildResultCard(context, provider),
            ],
          ],
        ),
      ),
    );
  }

  // 🔥 GÜNCELLENDİ: CompressProvider
  Widget _buildImageArea(BuildContext context, CompressProvider provider) {
    if (provider.originalImage == null) {
      return GestureDetector(
        onTap: () => _showPickerOptions(context, provider),
        child: Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.indigo.withOpacity(0.3), style: BorderStyle.solid),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined, size: 60, color: Colors.indigo[300]),
              const SizedBox(height: 10),
              Text("Fotoğraf Seç veya Çek", style: TextStyle(color: Colors.indigo[800], fontSize: 16)),
            ],
          ),
        ),
      );
    } else {
      return Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(provider.originalImage!, height: 250, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 8),
          Text("Orijinal: ${provider.getFileSize(provider.originalImage)}", style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      );
    }
  }

  // 🔥 GÜNCELLENDİ: CompressProvider
  Widget _buildSettingsCard(BuildContext context, CompressProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("⚙️ Ayarlar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Çıktı Formatı:", style: TextStyle(fontSize: 16)),
                DropdownButton<CompressFormat>(
                  value: provider.format,
                  underline: Container(),
                  items: const [
                    DropdownMenuItem(value: CompressFormat.jpeg, child: Text("JPG (Standart)")),
                    DropdownMenuItem(value: CompressFormat.png, child: Text("PNG (Kaliteli)")),
                    DropdownMenuItem(value: CompressFormat.webp, child: Text("WebP (Modern)")),
                  ],
                  onChanged: (val) {
                    if (val != null) provider.setFormat(val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Kalite:", style: TextStyle(fontSize: 16)),
                Text("%${provider.quality.toInt()}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
              ],
            ),
            Slider(
              value: provider.quality,
              min: 5,
              max: 100,
              activeColor: Colors.indigo,
              label: "%${provider.quality.toInt()}",
              onChanged: (val) => provider.setQuality(val),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 GÜNCELLENDİ: CompressProvider
  Widget _buildResultCard(BuildContext context, CompressProvider provider) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text("İşlem Başarılı!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Yeni Boyut:"),
              Text(provider.getFileSize(provider.compressedImage), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => provider.openCompressedFile(),
              icon: const Icon(Icons.share),
              label: const Text("Aç ve Paylaş"),
            ),
          )
        ],
      ),
    );
  }

  // 🔥 GÜNCELLENDİ: CompressProvider
  void _showPickerOptions(BuildContext context, CompressProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamerayı Aç'),
              onTap: () {
                Navigator.pop(ctx);
                provider.pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeriden Seç'),
              onTap: () {
                Navigator.pop(ctx);
                provider.pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}