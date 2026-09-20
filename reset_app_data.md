# App Reset Guide for Production

## 🚀 Complete App Reset for App Store Publishing

This guide helps you reset all app data to prepare for App Store submission.

### Method 1: Using Debug Panel (Recommended)

1. Open the app
2. Go to **Settings** tab
3. Scroll down and tap **"Debug Panel"**
4. Tap **"🚀 Complete Reset (Production Ready)"**
5. Confirm the action
6. ✅ App is now clean and ready for publishing

### Method 2: Programmatic Reset

Add this code to your app initialization (for testing only):

```dart
import 'package:gameapp/utils/app_reset.dart';

// In your main() function or app initialization
await AppReset.resetAppForProduction();
```

### Method 3: Manual Reset

If you need to reset specific data types:

```dart
// Reset only missions
await AppReset.resetMissionsOnly();

// Reset only scores and statistics
await AppReset.resetScoresOnly();

// Reset only user profile
await AppReset.resetProfileOnly();
```

### What Gets Reset

✅ **Complete Reset includes:**
- All game scores and high scores
- Daily missions and progress
- User profile data (name, avatar)
- Game statistics and levels
- All preferences and settings
- Mission tracking data
- Last played games history

### Storage Information

You can check current storage usage:

```dart
// Print detailed storage info
await AppReset.printStorageInfo();

// Get storage info as data
final info = await AppReset.getStorageInfo();
print('Total keys: ${info['total_keys']}');
```

### Before Publishing Checklist

- [ ] Run complete app reset
- [ ] Test app launches properly
- [ ] Verify no old data appears
- [ ] Check all games work correctly
- [ ] Confirm missions generate properly
- [ ] Test user profile creation flow

### Production Notes

⚠️ **Important:** Remove or disable the debug panel before App Store submission:

1. Comment out the debug button in `settings_screen.dart`
2. Or wrap it in a debug-only condition:

```dart
// Only show in debug mode
if (kDebugMode) {
  _ActionButton(
    icon: Icons.developer_mode,
    title: 'Debug Panel',
    // ... rest of button
  ),
}
```

### Files Modified

- `lib/utils/app_reset.dart` - Reset functionality
- `lib/screens/debug_screen.dart` - Debug UI
- `lib/screens/settings_screen.dart` - Debug panel access
- `lib/services/mission_service.dart` - Mission reset methods

---

**Ready for App Store! 🎉**

Your app is now clean and ready for production deployment.
