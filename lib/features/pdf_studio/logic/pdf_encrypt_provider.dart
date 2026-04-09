// lib/features/pdf_studio/logic/pdf_encrypt_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfEncryptProvider extends ChangeNotifier {
  File? _selectedPdf;
  bool _isEncrypting = false;
  String _statusMessage = "";

  File? get selectedPdf => _selectedPdf;
  bool get isEncrypting => _isEncrypting;
  String get statusMessage => _statusMessage;

  // 1. Cihazdan Tek Bir PDF Seçme
  Future<void> pickPdf() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false, // Sadece bir tane seçilebilir
      );

      if (result != null && result.files.single.path != null) {
        _selectedPdf = File(result.files.single.path!);
        notifyListeners();
      }
    } catch (e) {
      _setStatus("PDF seçilirken hata oluştu.");
    }
  }

  // 2. Seçili PDF'i Temizle
  void clearPdf() {
    _selectedPdf = null;
    notifyListeners();
  }

  // 3. PDF'i Şifreleme (Core Logic)
  Future<bool> encryptPdf(BuildContext context, String password) async {
    if (_selectedPdf == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen önce bir PDF seçin.')),
      );
      return false;
    }

    if (password.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parola boş bırakılamaz.')),
      );
      return false;
    }

    _setEncrypting(true, "PDF şifreleniyor...");

    try {
      // Seçilen PDF'i belleğe oku
      final List<int> bytes = await _selectedPdf!.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      // 🔥 Syncfusion ile Şifreleme Ayarları (AES 256-bit Güçlü Şifreleme)
      final PdfSecurity security = document.security;
      security.userPassword = password; // Açılış şifresi
      security.algorithm = PdfEncryptionAlgorithm.aesx256Bit;

      _setEncrypting(true, "Şifreli dosya kaydediliyor...");

      // Yeni dosyayı kaydet
      final Directory directory = await getApplicationDocumentsDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String outPath = '${directory.path}/Sifreli_$timestamp.pdf';
      final File file = File(outPath);

      await file.writeAsBytes(await document.save());
      document.dispose();

      _setEncrypting(false, "");
      
      // Oluşan şifreli dosyayı aç
      OpenFile.open(outPath);
      return true;

    } catch (e) {
      _setEncrypting(false, "Şifreleme başarısız: $e");
      return false;
    }
  }

  // Yardımcı fonksiyonlar
  void _setEncrypting(bool val, String msg) {
    _isEncrypting = val;
    _statusMessage = msg;
    notifyListeners();
  }

  void _setStatus(String msg) {
    _statusMessage = msg;
    notifyListeners();
  }
}