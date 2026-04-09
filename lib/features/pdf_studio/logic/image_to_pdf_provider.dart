// lib/features/pdf_studio/logic/image_to_pdf_provider.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart'; 
import 'package:open_file/open_file.dart'; 
import 'package:flutter_image_compress/flutter_image_compress.dart'; 

// SINIF ADI SİMETRİ İÇİN DÜZELTİLDİ
class ImageToPdfProvider extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  
  List<File> _selectedImages = [];
  bool _isGenerating = false;
  String _statusMessage = ""; 

  List<File> get selectedImages => _selectedImages;
  bool get isGenerating => _isGenerating;
  String get statusMessage => _statusMessage;

  // 1. Resim Seçme
  Future<void> pickImages() async {
    try {
      final List<XFile> pickedFileList = await _picker.pickMultiImage();
      if (pickedFileList.isNotEmpty) {
        _selectedImages.addAll(pickedFileList.map((x) => File(x.path)).toList());
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Hata: $e");
    }
  }

  // 2. Kırpma
  Future<void> cropImage(int index, BuildContext context) async {
    File imageFile = _selectedImages[index];
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Düzenle & Kırp',
          toolbarColor: Colors.indigo,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Düzenle'),
      ],
    );
    if (croppedFile != null) {
      _selectedImages[index] = File(croppedFile.path);
      notifyListeners();
    }
  }

  // 3. Sıralama
  void reorderImages(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final File item = _selectedImages.removeAt(oldIndex);
    _selectedImages.insert(newIndex, item);
    notifyListeners();
  }

  // 4. Silme
  void removeImage(int index) {
    _selectedImages.removeAt(index);
    notifyListeners();
  }

  void clearAll() {
    _selectedImages.clear();
    notifyListeners();
  }

  // 5. PDF Oluşturma
  Future<void> createAndShowPdf(BuildContext context) async {
    if (_selectedImages.isEmpty) return;

    _isGenerating = true;
    _statusMessage = "Hazırlanıyor...";
    notifyListeners();

    try {
      final pdf = pw.Document();

      for (int i = 0; i < _selectedImages.length; i++) {
        _statusMessage = "Sayfa ${i + 1} / ${_selectedImages.length} işleniyor...";
        notifyListeners();

        File imgFile = _selectedImages[i];
        
        Uint8List? imageBytes = await FlutterImageCompress.compressWithFile(
          imgFile.absolute.path,
          minWidth: 1080, 
          minHeight: 1080,
          quality: 80, 
        );

        imageBytes ??= await imgFile.readAsBytes();

        final image = pw.MemoryImage(imageBytes);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(20), 
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(image, fit: pw.BoxFit.contain),
              );
            },
          ),
        );
      }

      _statusMessage = "PDF Kaydediliyor...";
      notifyListeners();

      final output = await getTemporaryDirectory();
      final file = File("${output.path}/Utilify_Belge_${DateTime.now().millisecondsSinceEpoch}.pdf");
      
      await file.writeAsBytes(await pdf.save());

      await OpenFile.open(file.path);

    } catch (e) {
      debugPrint("PDF Hatası: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata oluştu: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      _isGenerating = false;
      _statusMessage = "";
      notifyListeners();
    }
  }
}