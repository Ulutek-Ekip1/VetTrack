import 'package:flutter/foundation.dart';

/// Allows the owner/mobile experience to be previewed in a desktop browser.
/// This is only intended for development and does not alter real mobile builds.
class AppPlatform {
  static const bool _forceMobile =
      bool.fromEnvironment('FORCE_MOBILE', defaultValue: false);

  static bool get isMobileExperience => _forceMobile || !kIsWeb;
  static bool get isVetWebExperience => !isMobileExperience;
}
