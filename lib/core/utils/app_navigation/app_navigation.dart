import 'package:get/get.dart';

/// Navigation utility for smooth transitions
class AppNavigation {
  AppNavigation._();

  /// Navigate to a route with fade transition
  /// Note: Transitions are configured in route definitions
  static Future<T?>? toNamedWithFade<T>(String routeName) {
    return Get.toNamed<T>(routeName);
  }

  /// Navigate and remove all previous routes
  static Future<T?>? offAllNamed<T>(String routeName) {
    return Get.offAllNamed<T>(routeName);
  }
}

