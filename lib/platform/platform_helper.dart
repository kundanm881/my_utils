import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Platform detection and feature availability helper.
/// Fully safe across Web, Desktop (Windows, macOS, Linux), and Mobile (Android, iOS).
class AppPlatform {
  AppPlatform._();

  /// Whether running on Windows Desktop
  static bool get isWindows =>
      !kIsWeb &&
      (Platform.isWindows || defaultTargetPlatform == TargetPlatform.windows);

  /// Whether running on Linux Desktop
  static bool get isLinux =>
      !kIsWeb &&
      (Platform.isLinux || defaultTargetPlatform == TargetPlatform.linux);

  /// Whether running on macOS Desktop
  static bool get isMacOS =>
      !kIsWeb &&
      (Platform.isMacOS || defaultTargetPlatform == TargetPlatform.macOS);

  /// Whether running on Android
  static bool get isAndroid =>
      !kIsWeb &&
      (Platform.isAndroid || defaultTargetPlatform == TargetPlatform.android);

  /// Whether running on iOS
  static bool get isIOS =>
      !kIsWeb &&
      (Platform.isIOS || defaultTargetPlatform == TargetPlatform.iOS);

  /// Whether running on Web browser
  static bool get isWeb => kIsWeb;

  /// Whether running on any Desktop platform (Windows, macOS, Linux)
  static bool get isDesktop => isWindows || isLinux || isMacOS;

  /// Whether running on any Mobile platform (Android, iOS)
  static bool get isMobile => isAndroid || isIOS;

  /// Friendly operating system name for UI display
  static String get operatingSystemName {
    if (kIsWeb) return 'Web Browser';
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (isWindows) return 'Windows';
    if (isMacOS) return 'macOS';
    if (isLinux) return 'Linux';
    return 'Unknown';
  }

  /// Platform specific Icon for UI display
  static IconData get platformIcon {
    if (kIsWeb) return Icons.language_rounded;
    if (isAndroid) return Icons.phone_android_rounded;
    if (isIOS) return Icons.phone_iphone_rounded;
    if (isWindows) return Icons.desktop_windows_rounded;
    if (isMacOS) return Icons.laptop_mac_rounded;
    if (isLinux) return Icons.terminal_rounded;
    return Icons.devices_rounded;
  }

  /// Google Sign-In is only natively supported on Android, iOS, Web, and macOS.
  /// The official google_sign_in package does not support Windows or Linux desktop.
  static bool get isGoogleSignInSupported =>
      isWeb || isAndroid || isIOS || isMacOS;

  /// Firebase Cloud Messaging (FCM) is officially supported on Android and iOS.
  static bool get isFcmSupported => isAndroid || isIOS;
}

/// Convenient aliases for [AppPlatform]
typedef PlatformHelper = AppPlatform;
typedef KdPlatform = AppPlatform;
