#!/usr/bin/env dart

import 'dart:io';

/// Simple script to manually reset daily missions by clearing SharedPreferences files
Future<void> main() async {
  print('🎯 Resetting Daily Missions...');
  
  try {
    // Get the app's data directory (this varies by platform)
    // For iOS Simulator, it's usually in ~/Library/Developer/CoreSimulator/Devices/[device-id]/data/Containers/Data/Application/[app-id]/Documents/
    // For Android, it's in the app's private data directory
    
    // Since we can't directly access SharedPreferences from a standalone script,
    // we'll provide instructions for manual reset
    
    print('📱 To reset daily missions, follow these steps:');
    print('');
    print('Option 1 - Use the Debug Screen (Recommended):');
    print('1. Open the app');
    print('2. Go to Settings page');
    print('3. Tap "Debug Panel" button');
    print('4. Tap "🎯 Reset Daily Missions"');
    print('5. Confirm the reset');
    print('');
    print('Option 2 - Restart with fresh date:');
    print('1. Change your device date to tomorrow');
    print('2. Open the app (missions will auto-reset)');
    print('3. Change date back to today');
    print('');
    print('Option 3 - Clear app data:');
    print('1. Delete and reinstall the app');
    print('2. Or clear app data from device settings');
    print('');
    print('✅ Instructions provided!');
    
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}
