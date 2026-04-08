import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart'; // Kaydetme paketi

class BlurProvider extends ChangeNotifier {
  File? _selectedImage;
  bool _isSaving = false;
  
  // Sansürlenecek bölgelerin listesi (x, y koordinatları)
  List<Offset> _blurPoints = [];
  double _blurRadius = 20.0; // Fırça büyüklüğü

  final GlobalKey imageKey = GlobalKey();

  File? get selectedImage => _selectedImage;
  bool get isSaving => _isSaving;
  List<Offset> get blurPoints => _blurPoints;
  double get blurRadius => _blurRadius;

  // 1. Resim Seç
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _selectedImage = File(image.path);
      _blurPoints.clear(); // Yeni resim gelince eski çizimleri sil
      notifyListeners();
    }
  }

  // 2. Dokunulan Noktayı Ekle
  void addBlurPoint(Offset point) {
    _blurPoints.add(point);
    notifyListeners();
  }

  // 3. Son İşlemi Geri Al (Undo)
  void undo() {
    if (_blurPoints.isNotEmpty) {
      // Son eklenen 1-2 noktayı siler (basılı tutunca çok nokta oluşur)
      int removeCount = (_blurPoints.length > 5) ? 5 : 1; 
      for(int i=0; i<removeCount; i++) {
        if(_blurPoints.isNotEmpty) _blurPoints.removeLast();
      }
      notifyListeners();
    }
  }

  // 4. Temizle
  void clearAll() {
    _blurPoints.clear();
    notifyListeners();
  }
  
  void resetImage() {
    _selectedImage = null;
    _blurPoints.clear();
    notifyListeners();
  }

  // 5. Kaydet (RepaintBoundary ile)
  Future<bool> saveImage() async {
    if (_selectedImage == null) return false;
    _isSaving = true;
    notifyListeners();

    try {
      RenderRepaintBoundary? boundary = imageKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary != null) {
        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        Uint8List pngBytes = byteData!.buffer.asUint8List();

        await Gal.putImageBytes(pngBytes, name: "Utilify_Blur_${DateTime.now().millisecondsSinceEpoch}");
        
        _isSaving = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Hata: $e");
    }

    _isSaving = false;
    notifyListeners();
    return false;
  }
}