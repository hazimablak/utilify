import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  final int maxFailedLoadAttempts = 3;

  // Google'ın Test ID'si (Geçiş Reklamı için)
  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  // 1. Reklamı Arka Planda Yükle
  void loadInterstitialAd() {
    InterstitialAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            debugPrint('Geçiş reklamı yüklendi.');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('Geçiş reklamı yüklenemedi: $error');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              loadInterstitialAd(); // Tekrar dene
            }
          },
        ));
  }

  // 2. Reklamı Göster ve Sonra İşlemi Yap
  // onAdDismissed: Reklam kapatılınca ne yapılacağı (Örn: Sayfaya git)
  void showInterstitialAd(VoidCallback onAdDismissed) {
    if (_interstitialAd == null) {
      debugPrint('Reklam hazır değil, direkt geçiliyor.');
      onAdDismissed(); // Reklam yoksa bekletme, direkt devam et
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('Reklam kapatıldı.');
        ad.dispose();
        loadInterstitialAd(); // Bir sonraki için yenisini yükle
        onAdDismissed(); // İşleme devam et
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('Reklam gösterilemedi.');
        ad.dispose();
        loadInterstitialAd();
        onAdDismissed();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null; // Kullanılan reklamı boşalt
  }
}