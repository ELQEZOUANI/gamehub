import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Uses Google's demo IDs. Replace these and the native app IDs for production.
class InterstitialAdService {
  InterstitialAdService._();
  static final instance = InterstitialAdService._();

  // Paste your iOS interstitial ad unit ID here before publishing.
  static const String iosInterstitialAdUnitId =
      'ca-app-pub-9283129936552011/7600432573';

  InterstitialAd? _ad;
  bool _loading = false;
  bool _showing = false;
  bool _initialized = false;

  bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  Future<void> initialize() async {
    if (!_supported || _initialized) return;
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      unawaited(preload());
    } catch (error) {
      debugPrint('Ads initialization failed: $error');
    }
  }

  Future<void> preload() async {
    if (!_initialized || _loading || _ad != null) return;
    _loading = true;
    try {
      await InterstitialAd.load(
        adUnitId: iosInterstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _loading = false;
            _ad = ad;
          },
          onAdFailedToLoad: (error) {
            _loading = false;
            debugPrint('Interstitial load failed: $error');
          },
        ),
      );
    } catch (error) {
      _loading = false;
      debugPrint('Interstitial load failed: $error');
    }
  }

  /// False means another game selection is already showing an ad.
  /// No available ad: continue immediately, and prepare the next one.
  Future<bool> showBeforeGame() async {
    if (_showing) return false;
    final ad = _ad;
    if (ad == null) {
      unawaited(_initialized ? preload() : initialize());
      return true;
    }
    _ad = null;
    _showing = true;
    final finished = Completer<void>();
    void finish() {
      if (finished.isCompleted) return;
      unawaited(ad.dispose());
      finished.complete();
    }

    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdDismissedFullScreenContent: (_) => finish(),
      onAdFailedToShowFullScreenContent: (_, error) {
        debugPrint('Interstitial show failed: $error');
        finish();
      },
    );
    try {
      await ad.show();
      await finished.future;
    } catch (error) {
      debugPrint('Interstitial show failed: $error');
      finish();
    } finally {
      _showing = false;
      unawaited(preload());
    }
    return true;
  }
}
