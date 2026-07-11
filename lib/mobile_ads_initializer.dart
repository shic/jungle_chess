// Shares one Google Mobile Ads SDK initialization across all ad services.

import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<InitializationStatus>? _initialization;

Future<InitializationStatus> initializeMobileAds() {
  return _initialization ??= MobileAds.instance.initialize();
}
