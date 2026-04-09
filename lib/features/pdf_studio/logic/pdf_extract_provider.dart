// lib/features/pdf_studio/logic/pdf_extract_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfExtractProvider extends ChangeNotifier {
  File? _selectedPdf;
  int _totalPages = 0;
  bool _isExtracting = false;
  String _statusMessage = "";

  File? get selectedPdf => _selectedPdf;
  int get totalPages => _totalPages;
  bool get isExtracting => _isExtracting;
  String get statusMessage => _statusMessage;

  // 1. PDF Seçme ve Toplam Sayfayı Okuma
  Future<void> pickPdf() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        _selectedPdf = File(result.files.single.path!);
        
        // Hızlıca dosyayı okuyup toplam sayfa sayısını alalım
        final bytes = await _selectedPdf!.readAsBytes();
        final document = PdfDocument(inputBytes: bytes);
        _totalPages = document.pages.count;
        document.dispose(); // RAM'i şişirmemek için hemen kapatıyoruz
        
        notifyListeners();
      }
    } catch (e) {
      _setStatus("PDF seçilirken hata oluştu.");
    }
  }

  // 2. Seçimi Temizle
  void clearPdf() {
    _selectedPdf = null;
    _totalPages = 0;
    notifyListeners();
  }

  // 3. Sayfaları Çıkartma (Core Logic)
  Future<bool> extractPages(BuildContext context, String pagesInput) async {
    if (_selectedPdf == null) return false;

    // Girilen metni (Örn: "1, 3, 5") sayılara dönüştür
    List<int> pagesToExtract = [];
    try {
      var parts = pagesInput.split(',');
      for (var part in parts) {
        int? page = int.tryParse(part.trim());
        // Geçerli bir sayfa numarası mı kontrol et
        if (page != null && page > 0 && page <= _totalPages) {
          pagesToExtract.add(page);
        }
      }
    } catch (e) {
      debugPrint("Sayfa ayrıştırma hatası");
    }

    if (pagesToExtract.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen geçerli sayfa numaraları girin. (Örn: 1, 3, 5)')),
      );
      return false;
    }

    _setExtracting(true, "Sayfalar çıkartılıyor...");

    try {
      final bytes = await _selectedPdf!.readAsBytes();
      final loadedDocument = PdfDocument(inputBytes: bytes);
      
      final newDocument = PdfDocument();
      newDocument.pageSettings.margins.all = 0;

      for (int pageNum in pagesToExtract) {
         // Kullanıcı 1 derse kodda 0. indexi almalıyız (-1 mantığı)
         final loadedPage = loadedDocument.pages[pageNum - 1];
         final template = loadedPage.createTemplate();
         
         newDocument.pageSettings.size = loadedPage.size;
         newDocument.pages.add().graphics.drawPdfTemplate(template, const Offset(0, 0));
      }

      _setExtracting(true, "Yeni belge kaydediliyor...");

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final outPath = '${directory.path}/Cikarilan_Sayfalar_$timestamp.pdf';
      final file = File(outPath);

      await file.writeAsBytes(await newDocument.save());
      
      loadedDocument.dispose();
      newDocument.dispose();

      _setExtracting(false, "");
      OpenFile.open(outPath); // Sonucu aç
      return true;

    } catch (e) {
      _setExtracting(false, "İşlem başarısız: $e");
      return false;
    }
  }

  void _setExtracting(bool val, String msg) {
    _isExtracting = val;
    _statusMessage = msg;
    notifyListeners();
  }

  void _setStatus(String msg) {
    _statusMessage = msg;
    notifyListeners();
  }
}