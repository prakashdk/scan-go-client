# Android permissions needed in android/app/src/main/AndroidManifest.xml
# Add these inside the <manifest> tag, before <application>:
#
#   <uses-permission android:name="android.permission.CAMERA" />
#   <uses-feature android:name="android.hardware.camera" android:required="false" />
#
# Also set minSdkVersion to 21 in android/app/build.gradle:
#   minSdkVersion 21
#
# And add the following to android/app/build.gradle inside android { defaultConfig { ... } }:
#   multiDexEnabled true

# iOS: add to ios/Runner/Info.plist inside the <dict>:
#   <key>NSCameraUsageDescription</key>
#   <string>ScanPay needs camera access to scan store QR codes and product barcodes.</string>
