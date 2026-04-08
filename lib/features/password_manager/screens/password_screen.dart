import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:utilify/features/password_manager/logic/password_provider.dart';
import 'package:utilify/widgets/ad_banner_widget.dart';

class PasswordScreen extends StatelessWidget {
  const PasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider'ı burada değil, main.dart'ta oluşturacağız
    final provider = Provider.of<PasswordProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Cyber Vault")),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: const SafeArea(child: Padding(padding: EdgeInsets.only(bottom: 5), child: AdBannerWidget())),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- OLUŞTURMA KARTI ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      provider.generatedPassword.isEmpty ? "Ayarları Seçin" : provider.generatedPassword,
                      style: TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold,
                        color: provider.generatedPassword.isEmpty ? Colors.grey : Colors.indigo,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    if (provider.generatedPassword.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton.filledTonal(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: provider.generatedPassword));
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kopyalandı!")));
                            },
                          ),
                          const SizedBox(width: 10),
                          IconButton.filled(
                            icon: const Icon(Icons.save),
                            onPressed: () => _showSaveDialog(context, provider),
                          ),
                        ],
                      ),
                    const Divider(height: 30),
                    // Ayarlar
                    Row(
                      children: [
                        const Text("Uzunluk: "),
                        Expanded(
                          child: Slider(
                            value: provider.length, min: 6, max: 32, divisions: 26,
                            label: provider.length.toInt().toString(),
                            onChanged: (v) => provider.setLength(v),
                          ),
                        ),
                        Text("${provider.length.toInt()}"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        FilterChip(label: const Text("ABC"), selected: provider.useLetters, onSelected: (v) => provider.toggleLetters(v)),
                        FilterChip(label: const Text("123"), selected: provider.useNumbers, onSelected: (v) => provider.toggleNumbers(v)),
                        FilterChip(label: const Text("@#?"), selected: provider.useSpecial, onSelected: (v) => provider.toggleSpecial(v)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => provider.generatePassword(),
                        icon: const Icon(Icons.refresh),
                        label: const Text("OLUŞTUR"),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // --- KASA (LİSTE) ---
            const Align(alignment: Alignment.centerLeft, child: Text("🔐 Kayıtlı Şifrelerim", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
            
            provider.savedPasswords.isEmpty
                ? const Padding(padding: EdgeInsets.all(20), child: Text("Henüz kayıtlı şifre yok.", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.savedPasswords.length,
                    itemBuilder: (context, index) {
                      final item = provider.savedPasswords[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.vpn_key, color: Colors.orange),
                          title: Text(item['title'] ?? "Adsız"),
                          subtitle: Text("••••••••"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.copy, size: 20),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: item['pass']!));
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Şifre Kopyalandı")));
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () => provider.deletePassword(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  void _showSaveDialog(BuildContext context, PasswordProvider provider) {
    final txtController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Şifreyi Kaydet"),
        content: TextField(controller: txtController, decoration: const InputDecoration(hintText: "Örn: Instagram, Gmail...")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal")),
          FilledButton(
            onPressed: () {
              provider.savePassword(txtController.text);
              Navigator.pop(ctx);
            },
            child: const Text("Kaydet"),
          )
        ],
      ),
    );
  }
}