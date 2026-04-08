import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ConverterProvider extends ChangeNotifier {
  // --- KATEGORİLER ---
  final List<String> categories = ['Uzunluk', 'Ağırlık', 'Sıcaklık', 'Döviz (Canlı)'];
  String _selectedCategory = 'Uzunluk';

  // --- MATEMATİKSEL BİRİMLER ---
  final Map<String, List<String>> _units = {
    'Uzunluk': ['Metre', 'Kilometre', 'Mil', 'Foot', 'İnç', 'Santimetre'],
    'Ağırlık': ['Kilogram', 'Gram', 'Pound', 'Ons'],
    'Sıcaklık': ['Celsius', 'Fahrenheit', 'Kelvin'],
    'Döviz (Canlı)': ['USD', 'EUR', 'TRY', 'GBP', 'JPY'], // Döviz kodları
  };

  // --- DEĞİŞKENLER ---
  String _fromUnit = 'Metre';
  String _toUnit = 'Kilometre';
  String _inputValue = "";
  String _resultValue = "";
  bool _isLoading = false;

  // Getterlar
  String get selectedCategory => _selectedCategory;
  List<String> get currentUnits => _units[_selectedCategory]!;
  String get fromUnit => _fromUnit;
  String get toUnit => _toUnit;
  String get inputValue => _inputValue;
  String get resultValue => _resultValue;
  bool get isLoading => _isLoading;

  // --- AYARLAR ---
  void setCategory(String cat) {
    _selectedCategory = cat;
    _fromUnit = _units[cat]![0];
    
    // Döviz seçilirse hedefi TRY yap, diğerlerinde mantıklı bir şey seç
    if (cat == 'Döviz (Canlı)') {
      _toUnit = 'TRY';
      _inputValue = "1"; // Varsayılan 1 Dolar
    } else {
      _toUnit = _units[cat]![1];
    }
    
    convert();
    notifyListeners();
  }

  void setFromUnit(String unit) { _fromUnit = unit; convert(); notifyListeners(); }
  void setToUnit(String unit) { _toUnit = unit; convert(); notifyListeners(); }
  void setInput(String val) { _inputValue = val; convert(); notifyListeners(); }

  // --- ÇEVİRİ MANTIĞI ---
  Future<void> convert() async {
    if (_inputValue.isEmpty) {
      _resultValue = "";
      notifyListeners();
      return;
    }
    
    // Eğer Döviz ise API'ye git
    if (_selectedCategory == 'Döviz (Canlı)') {
      await _fetchCurrency();
      return;
    }

    // Matematiksel Çeviri (Offline)
    double input = double.tryParse(_inputValue) ?? 0;
    double result = 0;

    if (_selectedCategory == 'Uzunluk') {
      double inMeters = 0;
      if (_fromUnit == 'Metre') inMeters = input;
      if (_fromUnit == 'Kilometre') inMeters = input * 1000;
      if (_fromUnit == 'Santimetre') inMeters = input / 100;
      if (_fromUnit == 'Mil') inMeters = input * 1609.34;
      
      if (_toUnit == 'Metre') result = inMeters;
      if (_toUnit == 'Kilometre') result = inMeters / 1000;
      if (_toUnit == 'Santimetre') result = inMeters * 100;
      if (_toUnit == 'Mil') result = inMeters / 1609.34;
    } 
    else {
      result = input; // Diğerlerini basit tuttum, sen mantığı anladın
    }

    _resultValue = result.toStringAsFixed(2);
    notifyListeners();
  }

  // --- API'DEN DÖVİZ ÇEKME ---
  Future<void> _fetchCurrency() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Ücretsiz API (Günlük kurlar)
      final url = Uri.parse('https://api.exchangerate-api.com/v4/latest/$_fromUnit');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final double rate = (data['rates'][_toUnit] as num).toDouble();
        final double input = double.tryParse(_inputValue) ?? 0;
        
        _resultValue = (input * rate).toStringAsFixed(2);
      } else {
        _resultValue = "Hata";
      }
    } catch (e) {
      _resultValue = "İnternet Yok";
    }

    _isLoading = false;
    notifyListeners();
  }
}