// lib/features/image_lab/utils/filter_utils.dart

class FilterUtils {
  // Orijinal (Filtresiz) Hal
  static const List<double> noFilter = [
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ];

  // Siyah Beyaz (Grayscale)
  static const List<double> greyscale = [
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0,      0,      0,      1, 0,
  ];

  // Sepya (Eski Fotoğraf Hissi)
  static const List<double> sepia = [
    0.393, 0.769, 0.189, 0, 0,
    0.349, 0.686, 0.168, 0, 0,
    0.272, 0.534, 0.131, 0, 0,
    0,     0,     0,     1, 0,
  ];

  // Vintage (Sararmış 70'ler)
  static const List<double> vintage = [
    0.6, 0.3, 0.1, 0, 40,
    0.2, 0.7, 0.1, 0, 20,
    0.2, 0.2, 0.6, 0, -20,
    0,   0,   0,   1, 0,
  ];

  // Kontrastı Yüksek (Polaroid)
  static const List<double> polaroid = [
    1.438, -0.122, -0.016, 0, -0.03,
    -0.062, 1.378, -0.016, 0, 0.05,
    -0.062, -0.122, 1.483, 0, -0.02,
    0,      0,      0,     1, 0,
  ];

  // Menüde Göstermek İçin Liste
  static const List<Map<String, dynamic>> filters = [
    {'name': 'Orijinal', 'matrix': noFilter},
    {'name': 'Siyah Beyaz', 'matrix': greyscale},
    {'name': 'Sepya', 'matrix': sepia},
    {'name': 'Vintage', 'matrix': vintage},
    {'name': 'Polaroid', 'matrix': polaroid},
  ];
}