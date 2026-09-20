import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Shows Google's demo App Open ad when the app launches or returns foreground.
/// Replace the demo IDs with your AdMob unit IDs before publishing.
class AppOpenAdService {
  AppOpenAdService._();
  static final instance = AppOpenAdService._();

  // Paste your iOS App Open ad unit ID here before publishing.
  static const String iosAppOpenAdUnitId =
      'ca-app-pub-9283129936552011/5030109556';

  AppOpenAd? _ad;
  DateTime? _loadedAt;
  StreamSubscription<AppState>? _appStateSubscription;
  bool _initialized = false;
  bool _showing = false;
  Future<void>? _loadFuture;

  bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  bool get _isFresh =>
      _loadedAt != null &&
      DateTime.now().difference(_loadedAt!) < const Duration(hours: 4);

  Future<void> initialize() async {
    if (!_supported || _initialized) return;
    _initialized = true;
    try {
      await MobileAds.instance.initialize();
      await AppStateEventNotifier.startListening();
      _appStateSubscription =
          AppStateEventNotifier.appStateStream.listen((state) {
        if (state == AppState.foreground) unawaited(showIfAvailable());
      });
      await _load();
      await showIfAvailable();
    } catch (error) {
      debugPrint('App Open ad initialization failed: $error');
    }
  }

  Future<void> _load() {
    if (!_initialized || (_ad != null && _isFresh)) {
      return Future.value();
    }
    if (_loadFuture != null) return _loadFuture!;

    _ad?.dispose();
    _ad = null;
    final completed = Completer<void>();
    _loadFuture = completed.future;
    unawaited(_requestLoad(completed));
    return _loadFuture!.whenComplete(() {
      _loadFuture = null;
    });
  }

  Future<void> _requestLoad(Completer<void> completed) async {
    void finish() {
      if (!completed.isCompleted) completed.complete();
    }

    try {
      await AppOpenAd.load(
        adUnitId: iosAppOpenAdUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _ad = ad;
            _loadedAt = DateTime.now();
            debugPrint('App Open ad loaded.');
            finish();
          },
          onAdFailedToLoad: (error) {
            debugPrint('App Open ad load failed: $error');
            finish();
          },
        ),
      );
    } catch (error) {
      debugPrint('App Open ad load failed: $error');
      finish();
    }
  }

  Future<void> showIfAvailable() async {
    if (!_initialized || _showing) return;
    if (_ad == null || !_isFresh) {
      await _load();
    }

    if (_showing || _ad == null || !_isFresh) return;
    final ad = _ad!;
    _ad = null;
    _loadedAt = null;
    _showing = true;
    final finished = Completer<void>();
    void finish() {
      if (finished.isCompleted) return;
      unawaited(ad.dispose());
      finished.complete();
    }

    ad.fullScreenContentCallback = FullScreenContentCallback<AppOpenAd>(
      onAdShowedFullScreenContent: (_) {
        debugPrint('App Open ad shown.');
      },
      onAdDismissedFullScreenContent: (_) => finish(),
      onAdFailedToShowFullScreenContent: (_, error) {
        debugPrint('App Open ad show failed: $error');
        finish();
      },
    );
    try {
      await ad.show();
      await finished.future;
    } catch (error) {
      debugPrint('App Open ad show failed: $error');
      finish();
    } finally {
      _showing = false;
      unawaited(_load());
    }
  }

  void dispose() {
    _appStateSubscription?.cancel();
    _appStateSubscription = null;
    _ad?.dispose();
    _ad = null;
    _loadFuture = null;
  }
}
