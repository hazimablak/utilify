// lib/features/pdf_studio/logic/pdf_merge_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfMergeProvider extends ChangeNotifier {
  final List<File> _selectedPdfs = [];
  bool _isMerging = false;
  String _statusMessage = "";

  List<File> get selectedPdfs => _selectedPdfs;
  bool get isMerging => _isMerging;
  String get statusMessage => _statusMessage;

  // 1. Cihazdan PDF Seçme
  Future<void> pickPdfs() async {
    try {
      // 🔥 İŞTE ÇÖZÜM BURADA: .platform yazısını sildik!
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null) {
        List<File> files = result.paths.map((path) => File(path!)).toList();
        _selectedPdfs.addAll(files);
        notifyListeners();
      }
    } catch (e) {
      _setStatus("PDF seçilirken hata oluştu.");
    }
  }

  // 2. Listeden PDF Çıkarma
  void removePdf(int index) {
    _selectedPdfs.removeAt(index);
    notifyListeners();
  }

  // 3. Sürükle Bırak Sıralaması
  void reorderPdfs(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final File item = _selectedPdfs.removeAt(oldIndex);
    _selectedPdfs.insert(newIndex, item);
    notifyListeners();
  }

  // 4. Listeyi Temizle
  void clearAll() {
    _selectedPdfs.clear();
    notifyListeners();
  }

  // 5. PDF'leri Birleştirme (Core Logic)
  Future<bool> mergePdfs(BuildContext context) async {
    if (_selectedPdfs.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Birleştirmek için en az 2 PDF seçmelisiniz.')),
      );
      return false;
    }

    _setMerging(true, "PDF'ler okunuyor...");

    try {
      final PdfDocument document = PdfDocument();
      // Boşluk (Margin) olmasın ki sayfalar tam otursun
      document.pageSettings.margins.all = 0; 

      for (int i = 0; i < _selectedPdfs.length; i++) {
        _setMerging(true, "${i + 1}. belge işleniyor...");
        
        final List<int> bytes = await _selectedPdfs[i].readAsBytes();
        final PdfDocument loadedDocument = PdfDocument(inputBytes: bytes);

        // Doğru Sayfa Birleştirme Mantığı
        for (int j = 0; j < loadedDocument.pages.count; j++) {
          final PdfPage loadedPage = loadedDocument.pages[j];
          final PdfTemplate template = loadedPage.createTemplate();
          
          document.pageSettings.size = loadedPage.size;
          document.pages.add().graphics.drawPdfTemplate(template, const Offset(0, 0));
        }
        
        loadedDocument.dispose(); 
      }

      _setMerging(true, "Birleştiriliyor ve kaydediliyor...");

      final Directory directory = await getApplicationDocumentsDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String outPath = '${directory.path}/Birlestirilmis_$timestamp.pdf';
      final File file = File(outPath);

      await file.writeAsBytes(await document.save());
      document.dispose();

      _setMerging(false, "");
      OpenFile.open(outPath);
      return true;

    } catch (e) {
      _setMerging(false, "Birleştirme başarısız: $e");
      return false;
    }
  }

  void _setMerging(bool val, String msg) {
    _isMerging = val;
    _statusMessage = msg;
    notifyListeners();
  }

  void _setStatus(String msg) {
    _statusMessage = msg;
    notifyListeners();
  }
}