import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:utilify/features/voice_text/logic/voice_text_provider.dart';
import 'package:utilify/widgets/ad_banner_widget.dart'; // Reklam

class VoiceTextScreen extends StatefulWidget {
  const VoiceTextScreen({super.key});

  @override
  State<VoiceTextScreen> createState() => _VoiceTextScreenState();
}

class _VoiceTextScreenState extends State<VoiceTextScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VoiceTextProvider>(context);

    if (provider.text != _controller.text && 
        provider.text != "Konuşmak için mikrofona basın...") {
      _controller.text = provider.text;
      _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lingua Master'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              provider.clear();
              _controller.clear();
            },
          )
        ],
      ),
      // --- REKLAM ALANI ---
      bottomNavigationBar: Container(
        color: Colors.white,
        child: const SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: AdBannerWidget(),
          ),
        ),
      ),
      // --------------------
      body: SingleChildScrollView(
        // Alt boşluğu artır
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 50), 
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLangBadge(provider.sourceLanguage),
                  IconButton(
                    icon: const Icon(Icons.swap_horiz, color: Colors.indigo),
                    onPressed: () => provider.swapLanguages(),
                  ),
                  _buildLangBadge(provider.targetLanguage),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // Giriş Alanı
            Container(
              height: 150,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      expands: true,
                      onChanged: (val) => provider.updateText(val),
                      decoration: const InputDecoration(
                        hintText: "Yazın veya konuşun...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.volume_up_outlined),
                        onPressed: () => provider.speakText(provider.text, false),
                      ),
                      IconButton(
                        icon: const Icon(Icons.translate, color: Colors.indigo),
                        onPressed: () => provider.translate(),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Çeviri Alanı
            Container(
              height: 150,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.indigo.withOpacity(0.3)),
              ),
              child: provider.isTranslating
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: SelectableText(
                              provider.translatedText.isEmpty 
                                  ? "Çeviri sonucu burada görünecek" 
                                  : provider.translatedText,
                              style: TextStyle(
                                fontSize: 18, 
                                color: provider.translatedText.isEmpty ? Colors.grey : Colors.black87
                              ),
                            ),
                          ),
                        ),
                        if (provider.translatedText.isNotEmpty)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: provider.translatedText));
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kopyalandı")));
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.volume_up, color: Colors.indigo),
                                onPressed: () => provider.speakText(provider.translatedText, true),
                              ),
                              IconButton(
                                icon: const Icon(Icons.share, color: Colors.green),
                                onPressed: () => provider.shareAudioFile(),
                              ),
                            ],
                          )
                      ],
                    ),
            ),

            const SizedBox(height: 30),

            // Mikrofon
            AvatarGlowWidget(
              animate: provider.isListening,
              child: SizedBox(
                width: 70,
                height: 70,
                child: FloatingActionButton(
                  onPressed: () => provider.toggleListening(),
                  backgroundColor: provider.isListening ? Colors.red : Colors.indigo,
                  child: Icon(provider.isListening ? Icons.mic_off : Icons.mic, size: 35),
                ),
              ),
            ),
             const SizedBox(height: 10),
             Text(provider.isListening ? "Dinleniyor..." : "Konuşmak için bas", style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildLangBadge(TranslateLanguage lang) {
    String text = lang == TranslateLanguage.turkish ? "🇹🇷 Türkçe" : "🇬🇧 İngilizce";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class AvatarGlowWidget extends StatelessWidget {
  final bool animate;
  final Widget child;
  const AvatarGlowWidget({super.key, required this.animate, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: animate ? BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)]
      ) : null,
      child: child,
    );
  }
}