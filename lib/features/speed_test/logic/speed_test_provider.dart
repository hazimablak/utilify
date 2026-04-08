import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class SpeedTestProvider extends ChangeNotifier {
  bool _isTesting = false;
  double _downloadSpeed = 0.0; // Mbps cinsinden
  double _progress = 0.0; // 0.0 ile 1.0 arası
  String _status = "Testi Başlat";

  bool get isTesting => _isTesting;
  double get downloadSpeed => _downloadSpeed;
  double get progress => _progress;
  String get status => _status;

  Future<void> startTest() async {
    if (_isTesting) return;

    _isTesting = true;
    _downloadSpeed = 0.0;
    _progress = 0.0;
    _status = "Sunucuya Bağlanılıyor...";
    notifyListeners();

    try {
      // Test için GitHub'dan 5MB'lık güvenli bir test dosyası indireceğiz
      // Bu dosya aslında yoktur, sadece hız testi için kullanılan yaygın bir tekniktir.
      final url = Uri.parse('http://speedtest.tele2.net/10MB.zip'); 
      final stopwatch = Stopwatch()..start();
      
      final client = http.Client();
      final request = http.Request('GET', url);
      final response = await client.send(request);

      int totalBytes = 0;
      int expectedBytes = 10 * 1024 * 1024; // 10 MB

      _status = "İndiriliyor...";
      notifyListeners();

      await response.stream.listen(
        (List<int> chunk) {
          totalBytes += chunk.length;
          
          // Anlık Hız Hesaplama
          final durationInSeconds = stopwatch.elapsedMilliseconds / 1000.0;
          if (durationInSeconds > 0) {
            // Byte -> Bit (*8) -> Megabit (/1000000)
            final speedMbs = (totalBytes * 8) / (1000000 * durationInSeconds);
            _downloadSpeed = speedMbs;
            
            // İlerleme çubuğu (Max 10MB varsayıyoruz)
            _progress = (totalBytes / expectedBytes).clamp(0.0, 1.0);
            notifyListeners();
          }
        },
        onDone: () {
          _isTesting = false;
          _status = "Tamamlandı";
          _progress = 1.0;
          notifyListeners();
          client.close();
        },
        onError: (e) {
          _isTesting = false;
          _status = "Hata: İnternet Yok";
          notifyListeners();
        },
        cancelOnError: true,
      );

    } catch (e) {
      _isTesting = false;
      _status = "Bağlantı Hatası";
      notifyListeners();
    }
  }
}