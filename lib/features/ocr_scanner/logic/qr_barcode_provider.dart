// lib/features/ocr_scanner/logic/qr_barcode_provider.dart
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';

class QrBarcodeProvider extends ChangeNotifier {
  String _scannedResult = "";
  String _generateText = "";
  bool _isSaving = false;

  // QR Kodu fotoğraf olarak çekmek için anahtar (Key)
  final GlobalKey qrKey = GlobalKey();

  String get scannedResult => _scannedResult;
  String get generateText => _generateText;
  bool get isSaving => _isSaving;

  void setScannedResult(String result) {
    if (_scannedResult != result) {
      _scannedResult = result;
      notifyListeners();
    }
  }

  void setGenerateText(String text) {
    _generateText = text;
    notifyListeners();
  }

  void clearScanned() {
    _scannedResult = "";
    notifyListeners();
  }

  // --- OLUŞTURULAN QR KODU GALERİYE İNDİR ---
  Future<bool> saveQrCode() async {
    if (_generateText.isEmpty) return false;
    
    _isSaving = true;
    notifyListeners();

    try {
      // RepaintBoundary ile ekrandaki QR kodun resmini çekiyoruz
      RenderRepaintBoundary? boundary = qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary != null) {
        ui.Image image = await boundary.toImage(pixelRatio: 3.0); // Yüksek kalite
        ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        Uint8List pngBytes = byteData!.buffer.asUint8List();

        // Galeriye kaydet
        await Gal.putImageBytes(pngBytes, name: "Utilify_QR_${DateTime.now().millisecondsSinceEpoch}");
        
        _isSaving = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("QR Kaydetme Hatası: $e");
    }

    _isSaving = false;
    notifyListeners();
    return false;
  }
}