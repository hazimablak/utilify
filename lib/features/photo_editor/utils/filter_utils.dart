
class FilterUtils {
  static const List<double> noFilter = [
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ];

  static const List<double> greyScale = [
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0,      0,      0,      1, 0,
  ];

  static const List<double> sepia = [
    0.393, 0.769, 0.189, 0, 0,
    0.349, 0.686, 0.168, 0, 0,
    0.272, 0.534, 0.131, 0, 0,
    0,     0,     0,     1, 0,
  ];

  static const List<double> vintage = [
    0.9, 0.5, 0.1, 0, 0,
    0.3, 0.8, 0.1, 0, 0,
    0.2, 0.3, 0.5, 0, 0,
    0,   0,   0,   1, 0,
  ];

  static const List<double> purple = [
    1, -0.2, 0, 0, 0,
    0, 1, 0, -0.1, 0,
    0, 1.2, 1, 0.1, 0,
    0, 0, 1.7, 1, 0,
  ];

  static List<double> brightness(double value) {
    // Value: -1 ile 1 arası olmalı
    return [
      1, 0, 0, 0, value * 255,
      0, 1, 0, 0, value * 255,
      0, 0, 1, 0, value * 255,
      0, 0, 0, 1, 0,
    ];
  }

  // Filtre Listesi (İsim ve Matris)
  static final List<Map<String, dynamic>> filters = [
    {'name': 'Normal', 'matrix': noFilter},
    {'name': 'Siyah-Beyaz', 'matrix': greyScale},
    {'name': 'Sepya', 'matrix': sepia},
    {'name': 'Vintage', 'matrix': vintage},
    {'name': 'Cyber', 'matrix': purple},
  ];
}