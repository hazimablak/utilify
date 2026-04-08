import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utilify/features/unit_converter/logic/converter_provider.dart';
import 'package:utilify/widgets/ad_banner_widget.dart';

class ConverterScreen extends StatelessWidget {
  const ConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ConverterProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Birim & Döviz Çevirici"),
        actions: [
          // Eğer döviz seçiliyse yenileme butonu göster
          if (provider.selectedCategory == 'Döviz (Canlı)')
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => provider.convert(),
              tooltip: "Kurları Güncelle",
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- KATEGORİ SEÇİMİ (YATAY LİSTE) ---
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: provider.categories.map((cat) {
                  bool isSelected = provider.selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(
                        cat, 
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold
                        )
                      ),
                      selected: isSelected,
                      selectedColor: Colors.indigo,
                      backgroundColor: Colors.grey[200],
                      onSelected: (v) => provider.setCategory(cat),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // --- GİRİŞ KISMI ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  const Align(alignment: Alignment.centerLeft, child: Text("Çevirilecek Miktar", style: TextStyle(color: Colors.grey))),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            hintText: "0",
                            border: InputBorder.none,
                          ),
                          onChanged: (v) => provider.setInput(v),
                          controller: TextEditingController(text: provider.inputValue)
                            ..selection = TextSelection.fromPosition(TextPosition(offset: provider.inputValue.length)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // GİRİŞ BİRİMİ SEÇİMİ
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: provider.fromUnit,
                          underline: Container(),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.indigo),
                          items: provider.currentUnits.map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)))).toList(),
                          onChanged: (v) => provider.setFromUnit(v!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // --- OK İŞARETİ ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: CircleAvatar(
                backgroundColor: Colors.grey[100],
                child: const Icon(Icons.arrow_downward, color: Colors.grey),
              ),
            ),
            
            // --- SONUÇ KISMI ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo, // Sonuç kısmı koyu renk olsun
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  const Align(alignment: Alignment.centerLeft, child: Text("Sonuç", style: TextStyle(color: Colors.white70))),
                  Row(
                    children: [
                      Expanded(
                        child: provider.isLoading
                            ? const Align(
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  height: 30, 
                                  width: 30, 
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                                )
                              )
                            : Text(
                                provider.resultValue.isEmpty ? "0.00" : provider.resultValue,
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                      const SizedBox(width: 10),
                      // HEDEF BİRİM SEÇİMİ
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: provider.toUnit,
                          dropdownColor: Colors.indigo, // Açılan menü de koyu olsun
                          underline: Container(),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          items: provider.currentUnits.map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))).toList(),
                          onChanged: (v) => provider.setToUnit(v!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            
            // Bilgi Notu (Döviz Seçiliyse)
            if (provider.selectedCategory == 'Döviz (Canlı)')
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  "ℹ️ Kurlar internet üzerinden anlık çekilmektedir.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}