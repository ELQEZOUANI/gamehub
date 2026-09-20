import 'app_open_ad_service.dart';
import 'interstitial_ad_service.dart';
import 'tracking_transparency_service.dart';

/// Starts ads only after the user has had the opportunity to answer ATT.
class AdSetupService {
  AdSetupService._();

  static Future<void>? _initialization;

  static Future<void> initializeAfterConsent() {
    return _initialization ??= _initialize();
  }

  static Future<void> _initialize() async {
    await TrackingTransparencyService.instance.requestIfNeeded();
    await InterstitialAdService.instance.initialize();
    await AppOpenAdService.instance.initialize();
  }
}
