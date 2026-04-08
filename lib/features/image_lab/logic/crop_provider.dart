import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart'; // Kaydetmek için

class CropProvider extends ChangeNotifier {
  File? _selectedImage;
  bool _isSaving = false;

  File? get selectedImage => _selectedImage;
  bool get isSaving => _isSaving;

  // 1. Resim Seç
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      _selectedImage = File(image.path);
      notifyListeners();
      // Resmi seçer seçmez kırpma ekranını açalım mı? Bence havalı olur.
      // cropImage(); // İstersen bunu açabilirsin, ama manuel buton daha güvenli.
    }
  }

  // 2. Kırpma Ekranını Aç (Paketin kendi UI'ı)
  Future<void> cropImage(BuildContext context) async {
    if (_selectedImage == null) return;

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: _selectedImage!.path,
      // Görünüm Ayarları
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Kırp & Döndür',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          // Hangi oranlar görünsün?
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square, // Instagram (1:1)
            CropAspectRatioPreset.ratio16x9, // YouTube
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio5x3, // Story
          ],
        ),
        IOSUiSettings(
          title: 'Kırp & Döndür',
        ),
      ],
    );

    if (croppedFile != null) {
      _selectedImage = File(croppedFile.path);
      notifyListeners();
    }
  }

  // 3. Galeriye Kaydet
  Future<bool> saveImage() async {
    if (_selectedImage == null) return false;
    _isSaving = true;
    notifyListeners();

    try {
      await Gal.putImage(_selectedImage!.path); // Dosya yolundan direkt kaydet
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Hata: $e");
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  // 4. Temizle
  void clear() {
    _selectedImage = null;
    notifyListeners();
  }
}