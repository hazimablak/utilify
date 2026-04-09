import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart'; 
// 🔥 GÜNCEL YOL
import 'package:utilify/features/image_lab/utils/filter_utils.dart';

class EditorProvider extends ChangeNotifier {
  File? _selectedImage;
  List<double> _currentFilter = FilterUtils.noFilter;
  bool _isSaving = false;
  
  final GlobalKey imageKey = GlobalKey();

  File? get selectedImage => _selectedImage;
  List<double> get currentFilter => _currentFilter;
  bool get isSaving => _isSaving;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _selectedImage = File(image.path);
      _currentFilter = FilterUtils.noFilter; 
      notifyListeners();
    }
  }

  void setFilter(List<double> matrix) {
    _currentFilter = matrix;
    notifyListeners();
  }

  void clearImage() {
    _selectedImage = null;
    notifyListeners();
  }

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