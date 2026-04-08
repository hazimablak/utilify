import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class PasswordProvider extends ChangeNotifier {
  // Ayarlar
  double _length = 12;
  bool _useLetters = true;
  bool _useNumbers = true;
  bool _useSpecial = true;
  String _generatedPassword = "";
  
  // Kayıtlı Şifreler
  final _storage = const FlutterSecureStorage();
  List<Map<String, String>> _savedPasswords = [];
  bool _isLoading = true;

  // Getterlar
  double get length => _length;
  bool get useLetters => _useLetters;
  bool get useNumbers => _useNumbers;
  bool get useSpecial => _useSpecial;
  String get generatedPassword => _generatedPassword;
  List<Map<String, String>> get savedPasswords => _savedPasswords;
  bool get isLoading => _isLoading;

  PasswordProvider() {
    _loadPasswords();
  }

  // Ayar Değiştirme
  void setLength(double val) { _length = val; notifyListeners(); }
  void toggleLetters(bool val) { _useLetters = val; notifyListeners(); }
  void toggleNumbers(bool val) { _useNumbers = val; notifyListeners(); }
  void toggleSpecial(bool val) { _useSpecial = val; notifyListeners(); }

  // Şifre Üretme Mantığı
  void generatePassword() {
    const letterChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const numberChars = "0123456789";
    const specialChars = "@#=+!£\$%&?[](){}";

    String chars = "";
    if (_useLetters) chars += letterChars;
    if (_useNumbers) chars += numberChars;
    if (_useSpecial) chars += specialChars;

    if (chars.isEmpty) {
      _generatedPassword = "";
      notifyListeners();
      return;
    }

    String result = "";
    final rnd = Random();
    for (int i = 0; i < _length; i++) {
      result += chars[rnd.nextInt(chars.length)];
    }

    _generatedPassword = result;
    notifyListeners();
  }

  // Şifreyi Kaydet
  Future<void> savePassword(String title) async {
    if (_generatedPassword.isEmpty || title.isEmpty) return;

    final newEntry = {'title': title, 'pass': _generatedPassword, 'date': DateTime.now().toString()};
    _savedPasswords.add(newEntry);
    
    // Listeyi JSON yapıp sakla
    await _storage.write(key: 'user_passwords', value: jsonEncode(_savedPasswords));
    notifyListeners();
  }

  // Şifreleri Yükle
  Future<void> _loadPasswords() async {
    String? data = await _storage.read(key: 'user_passwords');
    if (data != null) {
      List<dynamic> decoded = jsonDecode(data);
      _savedPasswords = decoded.map((e) => Map<String, String>.from(e)).toList();
    }
    _isLoading = false;
    notifyListeners();
  }

  // Şifre Sil
  Future<void> deletePassword(int index) async {
    _savedPasswords.removeAt(index);
    await _storage.write(key: 'user_passwords', value: jsonEncode(_savedPasswords));
    notifyListeners();
  }
}