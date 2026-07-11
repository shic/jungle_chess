// Loads the rewarded interstitial used to unlock an undo on mobile platforms.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:jungle_chess/ad_diagnostics_logger.dart';
import 'package:jungle_chess/mobile_ads_initializer.dart';

class UndoRewardedInterstitialAdService {
  UndoRewardedInterstitialAdService._();

  static const String _androidTestAdUnitId =
      'ca-app-pub-3940256099942544/5354046379';
  static const String _androidProductionAdUnitId =
      'ca-app-pub-8928964610230447/9101846428';
  static const String _iosTestAdUnitId =
      'ca-app-pub-3940256099942544/6978759866';
  static const String _iosProductionAdUnitId =
      'ca-app-pub-8928964610230447/5354173101';

  static final UndoRewardedInterstitialAdService instance =
      UndoRewardedInterstitialAdService._();

  RewardedInterstitialAd? _ad;
  final AdDiagnosticsLogger _diagnosticsLogger = createAdDiagnosticsLogger();
  bool _initialized = false;
  bool _loading = false;

  Future<void> initialize() async {
    final adUnitId = _adUnitId;
    if (adUnitId == null || _initialized) {
      return;
    }

    try {
      _logLines([
        'Undo rewarded interstitial SDK initialization requested',
        'platform: $_platformLabel',
        'buildMode: $_buildModeLabel',
        'adUnitId: $adUnitId',
      ]);
      await initializeMobileAds();
      _initialized = true;
      _logLines([
        'Undo rewarded interstitial SDK initialized',
        'platform: $_platformLabel',
        'buildMode: $_buildModeLabel',
        'adUnitId: $adUnitId',
      ]);
      _loadAd(adUnitId);
    } catch (error, stackTrace) {
      _logException(
        'Undo rewarded interstitial SDK initialization failed',
        error,
        stackTrace,
        adUnitId,
      );
    }
  }

  /// Returns true only after a mobile ad reports that its reward was earned.
  /// Unsupported desktop and web builds keep the existing ad-free undo flow.
  Future<bool> showBeforeUndo() async {
    final adUnitId = _adUnitId;
    if (adUnitId == null) {
      _logLines([
        'Undo rewarded interstitial bypassed on unsupported platform',
        'platform: $_platformLabel',
      ]);
      return true;
    }

    final ad = _ad;
    if (!_initialized || ad == null) {
      _logNotReady(adUnitId);
      _loadAd(adUnitId);
      return false;
    }

    _ad = null;
    var rewardEarned = false;
    final completer = Completer<bool>();
    _logLines([
      'Undo rewarded interstitial show requested',
      'platform: $_platformLabel',
      'buildMode: $_buildModeLabel',
      'adUnitId: $adUnitId',
    ]);

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _logLines([
          'Undo rewarded interstitial shown',
          'platform: $_platformLabel',
          'adUnitId: $adUnitId',
        ]);
      },
      onAdDismissedFullScreenContent: (ad) {
        _logLines([
          'Undo rewarded interstitial dismissed',
          'platform: $_platformLabel',
          'adUnitId: $adUnitId',
          'rewardEarned: $rewardEarned',
        ]);
        ad.dispose();
        _complete(completer, rewardEarned);
        _loadAd(_adUnitId);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _logShowFailure(error, adUnitId);
        ad.dispose();
        _complete(completer, false);
        _loadAd(_adUnitId);
      },
    );

    try {
      await ad.show(
        onUserEarnedReward: (ad, reward) {
          rewardEarned = true;
          _logLines([
            'Undo rewarded interstitial reward earned',
            'platform: $_platformLabel',
            'adUnitId: $adUnitId',
            'rewardType: ${reward.type}',
            'rewardAmount: ${reward.amount}',
          ]);
        },
      );
      return await completer.future.timeout(
        const Duration(minutes: 2),
        onTimeout: () {
          _logLines([
            'Undo rewarded interstitial flow timed out',
            'platform: $_platformLabel',
            'adUnitId: $adUnitId',
          ]);
          return false;
        },
      );
    } catch (error, stackTrace) {
      ad.dispose();
      _logException(
        'Undo rewarded interstitial show threw an exception',
        error,
        stackTrace,
        adUnitId,
      );
      _loadAd(_adUnitId);
      return false;
    }
  }

  void _loadAd(String? adUnitId) {
    if (!_initialized || _loading || adUnitId == null) {
      return;
    }

    _loading = true;
    _logLines([
      'Undo rewarded interstitial load requested',
      'platform: $_platformLabel',
      'buildMode: $_buildModeLabel',
      'adUnitId: $adUnitId',
    ]);
    RewardedInterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loading = false;
          _logAdLoaded(ad, adUnitId);
        },
        onAdFailedToLoad: (error) {
          _ad = null;
          _loading = false;
          _logLoadFailure(error, adUnitId);
        },
      ),
    );
  }

  void _complete(Completer<bool> completer, bool value) {
    if (!completer.isCompleted) {
      completer.complete(value);
    }
  }

  void _logNotReady(String adUnitId) {
    _logLines([
      'Undo rewarded interstitial was requested before it was ready',
      'platform: $_platformLabel',
      'buildMode: $_buildModeLabel',
      'adUnitId: $adUnitId',
      'initialized: $_initialized',
      'loading: $_loading',
      'hasCachedAd: ${_ad != null}',
    ]);
  }

  void _logAdLoaded(RewardedInterstitialAd ad, String adUnitId) {
    final responseInfo = ad.responseInfo;
    _logLines([
      'Undo rewarded interstitial loaded',
      'platform: $_platformLabel',
      'buildMode: $_buildModeLabel',
      'adUnitId: $adUnitId',
      'responseId: ${responseInfo?.responseId ?? 'none'}',
      'mediationAdapterClassName: '
          '${responseInfo?.mediationAdapterClassName ?? 'none'}',
    ]);
  }

  void _logLoadFailure(LoadAdError error, String adUnitId) {
    _logLines([
      'Undo rewarded interstitial failed to load',
      'platform: $_platformLabel',
      'buildMode: $_buildModeLabel',
      'adUnitId: $adUnitId',
      'errorCode: ${error.code}',
      'errorDomain: ${error.domain}',
      'errorMessage: ${error.message}',
      'responseId: ${error.responseInfo?.responseId ?? 'none'}',
    ]);
  }

  void _logShowFailure(AdError error, String adUnitId) {
    _logLines([
      'Undo rewarded interstitial failed to show',
      'platform: $_platformLabel',
      'buildMode: $_buildModeLabel',
      'adUnitId: $adUnitId',
      'errorCode: ${error.code}',
      'errorDomain: ${error.domain}',
      'errorMessage: ${error.message}',
    ]);
  }

  void _logException(
    String title,
    Object error,
    StackTrace stackTrace,
    String adUnitId,
  ) {
    _logLines([
      title,
      'platform: $_platformLabel',
      'buildMode: $_buildModeLabel',
      'adUnitId: $adUnitId',
      'error: $error',
      'stackTrace: $stackTrace',
    ]);
  }

  void _logLines(List<String> lines) {
    debugPrint('[AdMob] ${lines.first}');
    for (final line in lines.skip(1)) {
      debugPrint('[AdMob]   $line');
    }
    unawaited(_diagnosticsLogger.writeLines(lines));
  }

  String get _buildModeLabel {
    if (kReleaseMode) {
      return 'release';
    }
    if (kProfileMode) {
      return 'profile';
    }
    return 'debug';
  }

  String get _platformLabel => kIsWeb ? 'web' : defaultTargetPlatform.name;

  String? get _adUnitId {
    if (kIsWeb) {
      return null;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android =>
        kReleaseMode ? _androidProductionAdUnitId : _androidTestAdUnitId,
      TargetPlatform.iOS =>
        kReleaseMode ? _iosProductionAdUnitId : _iosTestAdUnitId,
      _ => null,
    };
  }
}
