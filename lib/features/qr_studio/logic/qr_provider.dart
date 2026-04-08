import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Tarayıcı
import 'package:screenshot/screenshot.dart'; // Ekran görüntüsü alıcı
import 'package:gal/gal.dart'; // Kaydedici
import 'package:permission_handler/permission_handler.dart'; // İzinler
import 'package:url_launcher/url_launcher.dart'; // Link açmak için

class QrProvider extends ChangeNotifier {
  // --- Değişkenler ---
  
  // TARAMA (SCAN) KISMI
  bool _isScanning = true; // Tarama aktif mi?
  String _scannedResult = ""; // Okunan değer
  final MobileScannerController scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  // OLUŞTURMA (GENERATE) KISMI
  String _dataToGenerate = ""; // QR yapılacak metin
  Color _qrColor = Colors.black; // QR Rengi
  final ScreenshotController screenshotController = ScreenshotController();
  final TextEditingController inputController = TextEditingController();
  bool _isSaving = false;

  // --- Getterlar ---
  bool get isScanning => _isScanning;
  String get scannedResult => _scannedResult;
  String get dataToGenerate => _dataToGenerate;
  Color get qrColor => _qrColor;
  bool get isSaving => _isSaving;

  // --- 1. TARAMA İŞLEMLERİ ---
  
  void onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        _scannedResult = code;
        _isScanning = false; // Taramayı durdur (Sonucu göstermek için)
        notifyListeners();
      }
    }
  }

  void resetScan() {
    _scannedResult = "";
    _isScanning = true;
    notifyListeners();
  }

  Future<void> launchURL(String url) async {
    final Uri uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> copyToClipboard(String text) async {
    // Clipboard işlemi UI tarafında (ScaffoldMessenger) halledilecek
  }

  // --- 2. OLUŞTURMA İŞLEMLERİ ---

  void updateData(String val) {
    _dataToGenerate = val;
    notifyListeners();
  }

  void changeQrColor(Color color) {
    _qrColor = color;
    notifyListeners();
  }

// QR Kodunu Galeriye Kaydetme (YENİ - GAL PAKETİ)
  Future<bool> saveQrToGallery() async {
    if (_dataToGenerate.isEmpty) return false;
    _isSaving = true;
    notifyListeners();

    try {
      // 1. Android için İzin Kontrolü (Gal paketi akıllıdır ama garanti olsun)
      if (Platform.isAndroid) {
        await Permission.storage.request();
        // Android 13+ (Senin telefonun) için fotolara erişim izni
        await Permission.photos.request(); 
      }

      // 2. QR Kodun resmini çek
      final Uint8List? imageBytes = await screenshotController.capture();
      
      if (imageBytes != null) {
        // 3. Galeriye kaydet (Modern Yöntem)
        await Gal.putImageBytes(imageBytes, name: "Utilify_QR_${DateTime.now().millisecondsSinceEpoch}");
        
        _isSaving = false;
        notifyListeners();
        return true; // Başarılı
      }
    } catch (e) {
      debugPrint("QR Kaydetme Hatası: $e");
      if (e is GalException) {
         debugPrint("Gal Hatası Türü: ${e.type}");
      }
    }
    
    _isSaving = false;
    notifyListeners();
    return false;
  }

  void clear() {
    _dataToGenerate = "";
    inputController.clear();
    _scannedResult = "";
    _isScanning = true;
    notifyListeners();
  }
}