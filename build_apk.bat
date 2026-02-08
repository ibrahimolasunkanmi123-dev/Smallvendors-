@echo off
echo Building APK for Small Vendors App...
cd /d "C:\Users\user\Downloads\smallvendors"
flutter build apk --release --no-tree-shake-icons
if %ERRORLEVEL% EQU 0 (
    echo APK built successfully!
    echo Location: build\app\outputs\flutter-apk\app-release.apk
) else (
    echo Build failed. Trying debug build...
    flutter build apk --debug --no-tree-shake-icons
    if %ERRORLEVEL% EQU 0 (
        echo Debug APK built successfully!
        echo Location: build\app\outputs\flutter-apk\app-debug.apk
    ) else (
        echo Build failed. Please check your Flutter installation and network connection.
    )
)
pause