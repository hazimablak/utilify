import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utilify/features/image_lab/logic/blur_provider.dart';
import 'package:utilify/widgets/ad_banner_widget.dart';

class BlurScreen extends StatelessWidget {
  const BlurScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BlurProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Yüz Sansürle"),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: () => provider.undo(),
            tooltip: "Geri Al",
          ),
          if (provider.selectedImage != null)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: () => provider.resetImage(),
            )
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: const SafeArea(child: Padding(padding: EdgeInsets.only(bottom: 5), child: AdBannerWidget())),
      ),
      body: Column(
        children: [
          // --- RESİM VE ÇİZİM ALANI ---
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.black12, // Çalışma alanı belli olsun
              child: provider.selectedImage == null
                  ? Center(
                      child: GestureDetector(
                        onTap: () => provider.pickImage(),
                        child: Container(
                          width: 150, height: 150,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.face, size: 50, color: Colors.blueGrey),
                              Text("Resim Seç"),
                            ],
                          ),
                        ),
                      ),
                    )
                  : RepaintBoundary(
                      key: provider.imageKey,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // 1. Ana Resim
                          Image.file(provider.selectedImage!, fit: BoxFit.contain),

                          // 2. Dokunma Algılayıcı ve Bulanıklık
                          GestureDetector(
                            onPanUpdate: (details) {
                              provider.addBlurPoint(details.localPosition);
                            },
                            onTapDown: (details) => provider.addBlurPoint(details.localPosition),
                            child: CustomPaint(
                              painter: BlurPainter(points: provider.blurPoints),
                              size: Size.infinite,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          
          // --- ALT BİLGİ VE BUTON ---
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                const Text("👆 Parmağınızı gizlemek istediğiniz yerde gezdirin", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: provider.selectedImage == null 
                        ? () => provider.pickImage()
                        : (provider.isSaving ? null : () async {
                            bool s = await provider.saveImage();
                            if(context.mounted) {
                               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s ? "Kaydedildi! 🔒" : "Hata")));
                            }
                        }),
                    icon: Icon(provider.selectedImage == null ? Icons.add_photo_alternate : Icons.save),
                    label: Text(provider.selectedImage == null ? "RESİM SEÇ" : "GALERİYE KAYDET"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: provider.selectedImage == null ? Colors.blueGrey : Colors.green,
                      foregroundColor: Colors.white
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// --- BULANIKLIK RESSAMI ---
class BlurPainter extends CustomPainter {
  final List<Offset> points;
  BlurPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5) 
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 25.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10); 

    for (var point in points) {
      canvas.drawCircle(point, 15, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}