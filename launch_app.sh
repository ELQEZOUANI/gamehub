#!/bin/bash

# Professional Galaxy Games App Launcher
# For Elite iOS Developer

echo "🚀 Launching Galaxy Games..."

# Set app path
APP_PATH="/Users/youssef/Desktop/gameapp/build/macos/Build/Products/Debug/gameapp.app"

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    echo "❌ App not found. Building first..."
    cd "/Users/youssef/Desktop/gameapp"
    flutter build macos --debug
fi

# Launch the app with proper macOS focus
echo "🌌 Starting Galaxy Games App..."
open -a "$APP_PATH" --args --enable-asserts

# Wait a moment and bring to front
sleep 2
osascript -e 'tell application "gameapp" to activate'

echo "✅ Galaxy Games launched successfully!"
echo "🎮 Enjoy your mobile-optimized gaming experience!"
