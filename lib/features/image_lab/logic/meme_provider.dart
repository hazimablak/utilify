import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart'; // Kaydetme paketi

class MemeProvider extends ChangeNotifier {
  File? _selectedImage;
  String _topText = "";
  String _bottomText = "";
  Color _textColor = Colors.white;
  double _fontSize = 24.0;
  bool _isSaving = false;

  // Ekran Görüntüsü Anahtarı
  final GlobalKey memeKey = GlobalKey();

  // Getterlar
  File? get selectedImage => _selectedImage;
  String get topText => _topText;
  String get bottomText => _bottomText;
  Color get textColor => _textColor;
  double get fontSize => _fontSize;
  bool get isSaving => _isSaving;

  // 1. Resim Seç
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _selectedImage = File(image.path);
      notifyListeners();
    }
  }

  // 2. Yazıları Güncelle
  void updateTopText(String val) { _topText = val; notifyListeners(); }
  void updateBottomText(String val) { _bottomText = val; notifyListeners(); }
  
  // 3. Stil Ayarları
  void setTextColor(Color color) { _textColor = color; notifyListeners(); }
  void increaseFontSize() { _fontSize += 2; notifyListeners(); }
  void decreaseFontSize() { if(_fontSize > 10) _fontSize -= 2; notifyListeners(); }

  // 4. Temizle
  void reset() {
    _selectedImage = null;
    _topText = "";
    _bottomText = "";
    notifyListeners();
  }

  // 5. Meme Kaydet (Sihirli Kısım)
  Future<bool> saveMeme() async {
    if (_selectedImage == null) return false;
    _isSaving = true;
    notifyListeners();

    try {
      RenderRepaintBoundary? boundary = memeKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary != null) {
        ui.Image image = await boundary.toImage(pixelRatio: 3.0); // Yüksek kalite
        ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        Uint8List pngBytes = byteData!.buffer.asUint8List();

        await Gal.putImageBytes(pngBytes, name: "Utilify_Meme_${DateTime.now().millisecondsSinceEpoch}");
        
        _isSaving = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Meme Hata: $e");
    }

    _isSaving = false;
    notifyListeners();
    return false;
  }
}