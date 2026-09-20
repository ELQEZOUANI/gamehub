import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';

class TrackingTransparencyService {
  TrackingTransparencyService._();
  static final instance = TrackingTransparencyService._();

  Future<void> requestIfNeeded() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;

    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } catch (error) {
      debugPrint('ATT request failed: $error');
    }
  }
}
