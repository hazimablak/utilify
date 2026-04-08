import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdManager {
  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  final int maxFailedLoadAttempts = 3;

  // Google Test ID (Ödüllü Reklam için)
  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';

  // 1. Reklamı Yükle
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          debugPrint('Ödüllü reklam yüklendi.');
          _rewardedAd = ad;
          _numRewardedLoadAttempts = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('Ödüllü reklam yüklenemedi: $error');
          _rewardedAd = null;
          _numRewardedLoadAttempts += 1;
          if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
            loadRewardedAd();
          }
        },
      ),
    );
  }

  // 2. Reklamı Göster
  // onRewardEarned: Kullanıcı reklamı sonuna kadar izlerse çalışacak fonksiyon
  void showRewardedAd({required VoidCallback onRewardEarned, VoidCallback? onAdFailed}) {
    if (_rewardedAd == null) {
      debugPrint('Ödüllü reklam hazır değil.');
      // Reklam yoksa kullanıcıyı cezalandırma, işlemi yapmasına izin ver (veya uyarı ver)
      onRewardEarned(); 
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) => debugPrint('Reklam gösteriliyor.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint('Reklam kapatıldı.');
        ad.dispose();
        loadRewardedAd(); // Yenisini yükle
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debugPrint('Reklam hatası: $error');
        ad.dispose();
        loadRewardedAd();
        if (onAdFailed != null) onAdFailed();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        debugPrint('Kullanıcı ödülü kazandı: ${reward.amount} ${reward.type}');
        // İŞTE BURASI ÖNEMLİ: Ödülü veriyoruz
        onRewardEarned();
      },
    );
    _rewardedAd = null;
  }
}