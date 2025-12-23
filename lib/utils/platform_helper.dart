import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformHelper {
  static bool get isWeb => kIsWeb;
  static bool get isMobile => !kIsWeb;

  static bool get supportsAuth => !kIsWeb;
  static bool get supportsStorage => !kIsWeb;
  static bool get supportsCamera => !kIsWeb;
}