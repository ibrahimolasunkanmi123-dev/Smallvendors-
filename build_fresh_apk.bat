@echo off
echo ========================================
echo Building Fresh Small Vendors APK
echo ========================================
cd /d "C:\Users\user\Downloads\smallvendors"

echo.
echo [1/5] Cleaning previous builds...
flutter clean

echo.
echo [2/5] Getting dependencies...
flutter pub get

echo.
echo [3/5] Analyzing code...
flutter analyze --no-fatal-infos

echo.
echo [4/5] Building release APK...
flutter build apk --release --no-tree-shake-icons --target-platform android-arm,android-arm64,android-x64

echo.
echo [5/5] Checking build result...
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo ✅ SUCCESS! APK built successfully!
    echo ========================================
    echo.
    echo 📱 APK Location: build\app\outputs\flutter-apk\app-release.apk
    echo 📊 APK Size: 
    dir "build\app\outputs\flutter-apk\app-release.apk" | findstr "app-release.apk"
    echo.
    echo 🚀 Ready to install and showcase products immediately!
    echo.
    echo To install on device:
    echo adb install build\app\outputs\flutter-apk\app-release.apk
    echo.
) else (
    echo.
    echo ❌ Build failed. Trying debug build as fallback...
    flutter build apk --debug --no-tree-shake-icons
    if %ERRORLEVEL% EQU 0 (
        echo.
        echo ⚠️  Debug APK built successfully!
        echo 📱 Location: build\app\outputs\flutter-apk\app-debug.apk
    ) else (
        echo.
        echo ❌ Both release and debug builds failed.
        echo Please check your Flutter installation and network connection.
    )
)

echo.
echo Press any key to exit...
pause > nul