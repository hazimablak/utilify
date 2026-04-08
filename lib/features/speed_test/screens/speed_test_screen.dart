import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utilify/features/speed_test/logic/speed_test_provider.dart';
import 'package:utilify/widgets/ad_banner_widget.dart';

class SpeedTestScreen extends StatelessWidget {
  const SpeedTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider'ı main.dart'ta tanımlayacağız
    final provider = Provider.of<SpeedTestProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Koyu tema
      appBar: AppBar(
        title: const Text("Turbo Hız Testi", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: const SafeArea(child: Padding(padding: EdgeInsets.only(bottom: 5), child: AdBannerWidget())),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hız Göstergesi (Daire)
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.5), width: 10),
                boxShadow: [
                  BoxShadow(color: Colors.cyanAccent.withOpacity(0.2), blurRadius: 30, spreadRadius: 5)
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.downloadSpeed.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const Text("Mbps", style: TextStyle(fontSize: 20, color: Colors.cyanAccent)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // İlerleme Çubuğu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: LinearProgressIndicator(
                value: provider.progress,
                backgroundColor: Colors.white24,
                color: Colors.cyanAccent,
                minHeight: 10,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Text(provider.status, style: const TextStyle(color: Colors.white70, fontSize: 16)),
            
            const SizedBox(height: 50),
            
            // Başlat Butonu
            ElevatedButton.icon(
              onPressed: provider.isTesting ? null : () => provider.startTest(),
              icon: const Icon(Icons.rocket_launch),
              label: Text(provider.isTesting ? "ÖLÇÜLÜYOR..." : "TESTİ BAŞLAT"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}