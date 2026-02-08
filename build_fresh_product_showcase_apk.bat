@echo off
echo ========================================
echo Building Fresh APK with Product Showcase
echo ========================================

echo.
echo Cleaning previous builds...
call flutter clean

echo.
echo Getting dependencies...
call flutter pub get

echo.
echo Building APK with product showcase optimization...
call flutter build apk --release --target-platform android-arm,android-arm64,android-x64

echo.
echo ========================================
echo APK Build Complete!
echo ========================================
echo.
echo APK Location: build\app\outputs\flutter-apk\app-release.apk
echo.
echo Features included:
echo - Immediate product showcase on app launch
echo - Products displayed on home page after login
echo - Enhanced product cards with animations
echo - Featured products section
echo - Search functionality
echo - Vendor profiles
echo.
echo Ready to install and test!
echo ========================================

pause