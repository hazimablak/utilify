import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart'; // Kaydetme paketi
import 'package:utilify/features/photo_editor/utils/filter_utils.dart';

class EditorProvider extends ChangeNotifier {
  File? _selectedImage;
  List<double> _currentFilter = FilterUtils.noFilter;
  bool _isSaving = false;
  
  // Resim Key'i (Ekran görüntüsü almak için)
  final GlobalKey imageKey = GlobalKey();

  File? get selectedImage => _selectedImage;
  List<double> get currentFilter => _currentFilter;
  bool get isSaving => _isSaving;

  // 1. Resim Seç
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _selectedImage = File(image.path);
      _currentFilter = FilterUtils.noFilter; // Filtreyi sıfırla
      notifyListeners();
    }
  }

  // 2. Filtre Değiştir
  void setFilter(List<double> matrix) {
    _currentFilter = matrix;
    notifyListeners();
  }

  // 3. Resmi Temizle
  void clearImage() {
    _selectedImage = null;
    notifyListeners();
  }

  // 4. Filtreli Resmi Kaydet (Sihirli Kısım)
  Future<bool> saveImage() async {
    if (_selectedImage == null) return false;
    _isSaving = true;
    notifyListeners();

    try {
      // RepaintBoundary kullanarak filtrelenmiş görüntüyü yakalıyoruz
      RenderRepaintBoundary? boundary = imageKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary != null) {
        ui.Image image = await boundary.toImage(pixelRatio: 3.0); // Yüksek kalite
        ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        Uint8List pngBytes = byteData!.buffer.asUint8List();

        // Gal paketini kullan (Daha önce eklemiştik, sorunsuz çalışır)
        await Gal.putImageBytes(pngBytes, name: "Utilify_Edit_${DateTime.now().millisecondsSinceEpoch}");
        
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