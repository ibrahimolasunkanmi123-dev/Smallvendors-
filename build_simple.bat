@echo off
echo Building APK without problematic plugins...
cd /d "C:\Users\user\Downloads\smallvendors"

echo Temporarily removing problematic plugins...
copy pubspec.yaml pubspec.yaml.backup

echo Creating minimal pubspec.yaml...
(
echo name: smallvendors
echo description: "Small Vendors Catalog App - Digital catalog for small businesses"
echo publish_to: 'none'
echo version: 0.1.0
echo.
echo environment:
echo   sdk: ^3.9.2
echo.
echo dependencies:
echo   flutter:
echo     sdk: flutter
echo   shared_preferences: ^2.2.2
echo   url_launcher: ^6.2.1
echo   qr_flutter: ^4.1.0
echo   uuid: ^4.0.0
echo   intl: ^0.19.0
echo   fl_chart: ^0.68.0
echo   csv: ^6.0.0
echo   path_provider: ^2.1.0
echo   share_plus: ^7.2.1
echo   package_info_plus: ^5.0.1
echo   provider: ^6.1.1
echo.
echo dev_dependencies:
echo   flutter_test:
echo     sdk: flutter
echo   flutter_lints: ^5.0.0
echo.
echo flutter:
echo   uses-material-design: true
) > pubspec_minimal.yaml

copy pubspec_minimal.yaml pubspec.yaml
flutter pub get
flutter build apk --release

if %ERRORLEVEL% EQU 0 (
    echo APK built successfully!
    echo Location: build\app\outputs\flutter-apk\app-release.apk
) else (
    echo Build failed. Trying debug build...
    flutter build apk --debug
    if %ERRORLEVEL% EQU 0 (
        echo Debug APK built successfully!
        echo Location: build\app\outputs\flutter-apk\app-debug.apk
    )
)

echo Restoring original pubspec.yaml...
copy pubspec.yaml.backup pubspec.yaml
del pubspec_minimal.yaml
del pubspec.yaml.backup
pause