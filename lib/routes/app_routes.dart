import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/onboarding_screen/onboarding_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/home_screen/home_screen.dart';
import '../presentation/profile_screen/profile_screen.dart';
import '../presentation/profile_edit_screen/profile_edit_screen.dart' as profile_edit;
import '../presentation/qr_code_screen/qr_code_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/post_screen/post_screen.dart';


class AppRoutes {
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String onboarding = '/onboarding-screen';
  static const String registration = '/registration-screen';
  static const String login = '/login-screen';
  static const String home = '/home-screen';
  static const String profile = '/profile-screen';
  static const String editProfile = '/edit-profile';
  static const String qrCode = '/qr-code';
  static const String settings = '/settings';
  static const String post = '/post';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingScreen(),
    registration: (context) => const RegistrationScreen(),
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
    profile: (context) => const ProfileScreen(),
    editProfile: (context) => const profile_edit.EditProfileScreen(),
    qrCode: (context) => const QRCodeScreen(),
    settings: (context) => const SettingsScreen(),
    post: (context) => const CreatePostScreen(),
  };

  /// Navigate to a specific route with optional arguments
  static Future<dynamic> pushNamed(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  /// Navigate to a route and remove all previous routes
  static Future<dynamic> pushNamedAndRemoveUntil(
      BuildContext context,
      String routeName, {
        Object? arguments,
      }) {
    return Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
          (route) => false,
      arguments: arguments,
    );
  }

  /// Navigate to profile screen with user ID
  static Future<dynamic> pushProfile(BuildContext context, {String? userId, bool isCurrentUser = false}) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          userId: userId,
          isCurrentUser: isCurrentUser,
        ),
      ),
    );
  }

  /// Navigate to edit profile screen
  static Future<dynamic> pushEditProfile(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const profile_edit.EditProfileScreen(),
      ),
    );
  }

  /// Navigate to QR code screen
  static Future<dynamic> pushQRCode(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QRCodeScreen(),
      ),
    );
  }

  /// Navigate to settings screen
  static Future<dynamic> pushSettings(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  /// Pop current route
  static void pop(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }

  /// Check if can pop current route
  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }
}