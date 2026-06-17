// Loads and shows an interstitial only on mobile platforms that support Google Mobile Ads.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ResetInterstitialAdService {
  ResetInterstitialAdService._();

  static const String _androidTestInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _androidProductionInterstitialAdUnitId =
      'ca-app-pub-8928964610230447/6462710410';
  static const String _iosTestInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/4411468910';
  static const String _iosProductionInterstitialAdUnitId =
      'ca-app-pub-8928964610230447/1135532974';

  static final ResetInterstitialAdService instance =
      ResetInterstitialAdService._();

  InterstitialAd? _interstitialAd;
  bool _initialized = false;
  bool _loading = false;

  Future<void> initialize() async {
    final adUnitId = _adUnitId;
    if (adUnitId == null || _initialized) {
      return;
    }

    await MobileAds.instance.initialize();
    _initialized = true;
    _loadAd(adUnitId);
  }

  Future<void> showBeforeReset() => showBeforeAction();

  Future<void> showBeforeAction() async {
    final ad = _interstitialAd;
    if (!_initialized || ad == null) {
      _loadAd(_adUnitId);
      return;
    }

    _interstitialAd = null;
    final completer = Completer<void>();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _completeAdFlow(completer);
        _loadAd(_adUnitId);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Interstitial failed to show: $error');
        ad.dispose();
        _completeAdFlow(completer);
        _loadAd(_adUnitId);
      },
    );

    ad.show();
    await completer.future.timeout(
      const Duration(seconds: 20),
      onTimeout: () {},
    );
  }

  void _loadAd(String? adUnitId) {
    if (!_initialized || _loading || adUnitId == null) {
      return;
    }

    _loading = true;
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _loading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed to load: $error');
          _interstitialAd = null;
          _loading = false;
        },
      ),
    );
  }

  void _completeAdFlow(Completer<void> completer) {
    if (!completer.isCompleted) {
      completer.complete();
    }
  }

  String? get _adUnitId {
    if (kIsWeb) {
      return null;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android =>
        kReleaseMode
            ? _androidProductionInterstitialAdUnitId
            : _androidTestInterstitialAdUnitId,
      TargetPlatform.iOS =>
        kReleaseMode
            ? _iosProductionInterstitialAdUnitId
            : _iosTestInterstitialAdUnitId,
      _ => null,
    };
  }
}
