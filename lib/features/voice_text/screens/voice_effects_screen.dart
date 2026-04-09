// lib/features/voice_text/screens/voice_effects_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utilify/features/voice_text/logic/voice_effects_provider.dart';
import 'package:utilify/widgets/ad_banner_widget.dart';

class VoiceEffectsScreen extends StatelessWidget {
  const VoiceEffectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VoiceEffectsProvider>(context);

    // Efekt Listesi
    final List<Map<String, dynamic>> effects = [
      {"name": "Normal", "icon": Icons.face, "color": Colors.blue},
      {"name": "Helyum", "icon": Icons.child_care, "color": Colors.orange},
      {"name": "Dev", "icon": Icons.fitness_center, "color": Colors.green},
      {"name": "Robot", "icon": Icons.smart_toy, "color": Colors.grey},
      {"name": "Uzaylı", "icon": Icons.airplanemode_active, "color": Colors.purple},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ses Efektleri'),
        actions: [
          if (provider.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => provider.clearText(),
            )
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: const SafeArea(child: Padding(padding: EdgeInsets.only(bottom: 5), child: AdBannerWidget())),
      ),
      body: Column(
        children: [
          // --- KAYDEDİLEN METİN ALANI ---
          Container(
            height: 180,
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.purple.withOpacity(0.3)),
            ),
            child: SingleChildScrollView(
              child: provider.text.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        Icon(Icons.mic, size: 50, color: Colors.purple.withOpacity(0.5)),
                        const SizedBox(height: 10),
                        const Text("Efekt uygulamak için bir şeyler söyleyin...", style: TextStyle(color: Colors.grey)),
                      ],
                    )
                  : Text(provider.text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            ),
          ),

          // --- EFEKT BUTONLARI (GRID) ---
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: effects.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                final effect = effects[index];
                final isSelected = provider.selectedEffect == effect["name"];

                return GestureDetector(
                  onTap: () => provider.playWithEffect(effect["name"]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? effect["color"] : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: effect["color"], width: 2),
                      boxShadow: [
                        if (isSelected) BoxShadow(color: effect["color"].withOpacity(0.4), blurRadius: 10, spreadRadius: 2)
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          effect["icon"], 
                          size: 36, 
                          color: isSelected ? Colors.white : effect["color"]
                        ),
                        const SizedBox(height: 8),
                        Text(
                          effect["name"], 
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            color: isSelected ? Colors.white : effect["color"]
                          )
                        ),
                        if (isSelected && provider.isPlaying)
                          const Padding(
                            padding: EdgeInsets.only(top: 4.0),
                            child: SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // --- MİKROFON BUTONU ---
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: GestureDetector(
              onTap: () => provider.toggleListening(),
              child: Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: provider.isListening ? Colors.red : Colors.purple,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (provider.isListening) BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)
                  ],
                ),
                child: Icon(
                  provider.isListening ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}