import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// 플랫폼 감지를 위한 유틸리티 클래스
class PlatformUtils {
  /// 현재 iOS 플랫폼인지 확인
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// 현재 Android 플랫폼인지 확인
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// 현재 웹 플랫폼인지 확인
  static bool get isWeb => kIsWeb;

  /// 현재 macOS 플랫폼인지 확인
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  /// 현재 Windows 플랫폼인지 확인
  static bool get isWindows => !kIsWeb && Platform.isWindows;

  /// 현재 Linux 플랫폼인지 확인
  static bool get isLinux => !kIsWeb && Platform.isLinux;

  /// 현재 모바일 플랫폼인지 확인 (iOS 또는 Android)
  static bool get isMobile => isIOS || isAndroid;

  /// 현재 데스크톱 플랫폼인지 확인 (Windows, macOS, Linux)
  static bool get isDesktop => isMacOS || isWindows || isLinux;
}
