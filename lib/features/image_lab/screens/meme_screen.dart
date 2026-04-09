import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utilify/features/image_lab/logic/meme_provider.dart';
import 'package:utilify/widgets/ad_banner_widget.dart';

class MemeScreen extends StatelessWidget {
  const MemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider'ı main.dart'ta tanımlayacağız
    final provider = Provider.of<MemeProvider>(context);

    // Meme Yazı Stili (Dış hatlı yazı - Klasik Caps tarzı)
    TextStyle memeTextStyle = TextStyle(
      fontFamily: 'Impact', // Sistemde varsa Impact, yoksa kalın font kullanır
      fontSize: provider.fontSize,
      fontWeight: FontWeight.w900,
      color: provider.textColor,
      shadows: const [
        Shadow(offset: Offset(-1.5, -1.5), color: Colors.black),
        Shadow(offset: Offset(1.5, -1.5), color: Colors.black),
        Shadow(offset: Offset(1.5, 1.5), color: Colors.black),
        Shadow(offset: Offset(-1.5, 1.5), color: Colors.black),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Meme (Caps) Yapıcı")),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: const SafeArea(child: Padding(padding: EdgeInsets.only(bottom: 5), child: AdBannerWidget())),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- MEME ÖNİZLEME ALANI ---
            RepaintBoundary(
              key: provider.memeKey,
              child: Container(
                width: double.infinity,
                height: 350,
                color: Colors.grey[300],
                child: provider.selectedImage == null
                    ? Center(
                        child: IconButton(
                          icon: const Icon(Icons.add_photo_alternate, size: 80, color: Colors.grey),
                          onPressed: () => provider.pickImage(),
                        ),
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          // Resim
                          Image.file(
                            provider.selectedImage!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.contain,
                          ),
                          // Üst Yazı
                          Positioned(
                            top: 10,
                            left: 10,
                            right: 10,
                            child: Text(
                              provider.topText.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: memeTextStyle,
                            ),
                          ),
                          // Alt Yazı
                          Positioned(
                            bottom: 10,
                            left: 10,
                            right: 10,
                            child: Text(
                              provider.bottomText.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: memeTextStyle,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 20),

            // --- KONTROL PANELİ ---
            if (provider.selectedImage != null)
              Column(
                children: [
                  // Yazı Girişleri
                  TextField(
                    decoration: const InputDecoration(labelText: "Üst Yazı", border: OutlineInputBorder(), prefixIcon: Icon(Icons.vertical_align_top)),
                    onChanged: (v) => provider.updateTopText(v),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: const InputDecoration(labelText: "Alt Yazı", border: OutlineInputBorder(), prefixIcon: Icon(Icons.vertical_align_bottom)),
                    onChanged: (v) => provider.updateBottomText(v),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Stil Ayarları (Renk ve Boyut)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Font Büyüt/Küçült
                      Row(
                        children: [
                          IconButton.filledTonal(onPressed: () => provider.decreaseFontSize(), icon: const Icon(Icons.text_decrease)),
                          const SizedBox(width: 5),
                          IconButton.filledTonal(onPressed: () => provider.increaseFontSize(), icon: const Icon(Icons.text_increase)),
                        ],
                      ),
                      // Renk Seç
                      Row(
                        children: [
                          _colorBtn(Colors.white, provider),
                          _colorBtn(Colors.red, provider),
                          _colorBtn(Colors.yellow, provider),
                          _colorBtn(Colors.green, provider),
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Butonlar
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => provider.reset(),
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text("Sil", style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: provider.isSaving ? null : () async {
                            bool s = await provider.saveMeme();
                            if(context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(s ? "Galeriye Kaydedildi! 😂" : "Hata"),
                                backgroundColor: s ? Colors.green : Colors.red,
                              ));
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                          icon: provider.isSaving 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.download),
                          label: const Text("KAYDET"),
                        ),
                      ),
                    ],
                  )
                ],
              )
            else
              const Text("Caps yapmak için yukarıdan resim seçin 👆", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _colorBtn(Color color, MemeProvider provider) {
    return GestureDetector(
      onTap: () => provider.setTextColor(color),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 30, 
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey, width: 1),
          boxShadow: provider.textColor == color ? [const BoxShadow(color: Colors.black26, blurRadius: 5)] : null,
        ),
      ),
    );
  }
}