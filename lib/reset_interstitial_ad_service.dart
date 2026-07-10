// Loads and shows an interstitial only on mobile platforms that support Google Mobile Ads.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:jungle_chess/ad_diagnostics_logger.dart';

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
  final AdDiagnosticsLogger _diagnosticsLogger = createAdDiagnosticsLogger();
  bool _initialized = false;
  bool _loading = false;

  Future<void> initialize() async {
    final adUnitId = _adUnitId;
    if (adUnitId == null || _initialized) {
      return;
    }

    try {
      _logAdLines([
        'Interstitial SDK initialization requested',
        'platform: $_platformLabel',
        'buildMode: $_buildModeLabel',
        'adUnitId: $adUnitId',
      ]);
      await MobileAds.instance.initialize();
      _initialized = true;
      _logAdLines([
        'Interstitial SDK initialized',
        'platform: $_platformLabel',
        'buildMode: $_buildModeLabel',
        'adUnitId: $adUnitId',
      ]);
      _loadAd(adUnitId);
    } catch (error, stackTrace) {
      _logAdException(
        'Interstitial SDK initialization failed',
        error,
        stackTrace,
        adUnitId: adUnitId,
      );
    }
  }

  Future<void> showBeforeReset() => showBeforeAction();

  Future<void> showBeforeAction() async {
    final ad = _interstitialAd;
    final adUnitId = _adUnitId;
    if (!_initialized || ad == null) {
      _logAdNotReady(adUnitId);
      _loadAd(adUnitId);
      return;
    }

    _interstitialAd = null;
    final completer = Completer<void>();
    _logAdLines([
      'Interstitial show requested',
      'platform: $_platformLabel',
      'buildMode: $_buildModeLabel',
      'adUnitId: ${adUnitId ?? 'none'}',
    ]);

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _logAdLines([
          'Interstitial dismissed',
          'platform: $_platformLabel',
          'buildMode: $_buildModeLabel',
          'adUnitId: ${adUnitId ?? 'none'}',
        ]);
        ad.dispose();
        _completeAdFlow(completer);
        _loadAd(_adUnitId);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _logAdShowFailure(error, adUnitId);
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
      _logAdLines([
        'Interstitial load skipped',
        'platform: $_platformLabel',
        'buildMode: $_buildModeLabel',
        'adUnitId: ${adUnitId ?? 'none'}',
        'initialized: $_initialized',
        'loading: $_loading',
      ]);
      return;
    }

    _loading = true;
    _logAdLines([
      'Interstitial load requested',
      'platform: $_platformLabel',
      'buildMode: $_buildModeLabel',
      'adUnitId: $adUnitId',
    ]);
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _loading = false;
          _logAdLoaded(ad, adUnitId);
        },
        onAdFailedToLoad: (error) {
          _logAdLoadFailure(error, adUnitId);
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

  void _logAdNotReady(String? adUnitId) {
    _logAdLines([
      'Interstitial was requested before it was ready',
      'platform: $_platformLabel',
      'buildMode: $_buildModeLabel',
      'adUnitId: ${adUnitId ?? 'none'}',
      'initialized: $_initialized',
      'loading: $_loading',
      'hasCachedAd: ${_interstitialAd != null}',
    ]);
  }

  void _logAdLoadFailure(LoadAdError error, String adUnitId) {
    final responseInfo = error.responseInfo;
    final adapterResponses = responseInfo?.adapterResponses;
    final lines = <String>[
      'Interstitial failed to load',
      'platform: $_platformLabel',
      'buildMode: $_buildModeLabel',
      'adUnitId: $adUnitId',
      'errorCode: ${error.code}',
      'errorDomain: ${error.domain}',
      'errorMessage: ${error.message}',
      'responseId: ${responseInfo?.responseId ?? 'none'}',
      'mediationAdapterClassName: '
          '${responseInfo?.mediationAdapterClassName ?? 'none'}',
      'responseExtras: ${responseInfo?.responseExtras ?? const {}}',
      'adapterResponseCount: ${adapterResponses?.length ?? 0}',
    ];

    if (adapterResponses != null) {
      for (var i = 0; i < adapterResponses.length; i += 1) {
        final adapter = adapterResponses[i];
        lines.addAll([
          'adapter[$i].adapterClassName: ${adapter.adapterClassName}',
          'adapter[$i].adSourceName: ${adapter.adSourceName}',
          'adapter[$i].adSourceId: ${adapter.adSourceId}',
          'adapter[$i].adSourceInstanceName: ${adapter.adSourceInstanceName}',
          'adapter[$i].adSourceInstanceId: ${adapter.adSourceInstanceId}',
          'adapter[$i].latencyMillis: ${adapter.latencyMillis}',
          'adapter[$i].description: ${adapter.description}',
          'adapter[$i].adError: ${_formatAdError(adapter.adError)}',
        ]);
      }
    }

    _logAdLines(lines);
  }

  void _logAdLoaded(InterstitialAd ad, String adUnitId) {
    final responseInfo = ad.responseInfo;
    _logAdLines([
      'Interstitial loaded',
      'platform: $_platformLabel',
      'buildMode: $_buildModeLabel',
      'adUnitId: $adUnitId',
      'responseId: ${responseInfo?.responseId ?? 'none'}',
      'mediationAdapterClassName: '
          '${responseInfo?.mediationAdapterClassName ?? 'none'}',
      'responseExtras: ${responseInfo?.responseExtras ?? const {}}',
      'adapterResponseCount: ${responseInfo?.adapterResponses?.length ?? 0}',
    ]);
  }

  void _logAdShowFailure(AdError error, String? adUnitId) {
    _logAdLines([
      'Interstitial failed to show',
      'platform: $_platformLabel',
      'buildMode: $_buildModeLabel',
      'adUnitId: ${adUnitId ?? 'none'}',
      'errorCode: ${error.code}',
      'errorDomain: ${error.domain}',
      'errorMessage: ${error.message}',
    ]);
  }

  void _logAdException(
    String title,
    Object error,
    StackTrace stackTrace, {
    required String adUnitId,
  }) {
    _logAdLines([
      title,
      'platform: $_platformLabel',
      'buildMode: $_buildModeLabel',
      'adUnitId: $adUnitId',
      'error: $error',
      'stackTrace: $stackTrace',
    ]);
  }

  void _logAdLines(List<String> lines) {
    debugPrint('[AdMob] ${lines.first}');
    for (final line in lines.skip(1)) {
      debugPrint('[AdMob]   $line');
    }
    unawaited(_diagnosticsLogger.writeLines(lines));
  }

  String _formatAdError(AdError? error) {
    if (error == null) {
      return 'none';
    }

    return 'code=${error.code}, domain=${error.domain}, '
        'message=${error.message}';
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

  String get _platformLabel {
    if (kIsWeb) {
      return 'web';
    }

    return defaultTargetPlatform.name;
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
