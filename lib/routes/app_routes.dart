import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/onboarding_screen/onboarding_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/home_screen/home_screen.dart';
import '../presentation/profile_screen/profile_screen.dart';
import '../presentation/profile_edit_screen/profile_edit_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String onboarding = '/onboarding-screen';
  static const String registration = '/registration-screen';
  static const String login = '/login-screen';
  static const String home = '/home-screen';
  static const String profile = '/profile-screen';
  static const String settings = '/settings';
  static const String editProfile = '/edit-profile';


  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingScreen(),
    registration: (context) => const RegistrationScreen(),
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
    profile: (context) => const ProfileScreen(),
    settings: (context) => const SettingsScreen(),
    editProfile: (context) => const EditProfileScreen(),

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

  /// Pop current route
  static void pop(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }

  /// Check if can pop current route
  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }
}

/// Settings Screen (moved from home_screen.dart)
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _buildSectionHeader('Compte'),
            _buildSettingsItem(
              icon: Icons.person_outline,
              title: 'Modifier le profil',
              subtitle: 'Changez vos informations personnelles',
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingsItem(
              icon: Icons.security,
              title: 'Confidentialité et sécurité',
              subtitle: 'Gérez vos paramètres de confidentialité',
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingsItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Gérez vos préférences de notification',
              onTap: () => _showComingSoon(context),
            ),

            const SizedBox(height: 24),

            // App Section
            _buildSectionHeader('Application'),
            _buildSettingsItem(
              icon: Icons.palette_outlined,
              title: 'Thème',
              subtitle: 'Clair, sombre ou automatique',
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingsItem(
              icon: Icons.language,
              title: 'Langue',
              subtitle: 'Français',
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingsItem(
              icon: Icons.storage,
              title: 'Stockage',
              subtitle: 'Gérez l\'espace de stockage utilisé',
              onTap: () => _showComingSoon(context),
            ),

            const SizedBox(height: 24),

            // Support Section
            _buildSectionHeader('Support'),
            _buildSettingsItem(
              icon: Icons.help_outline,
              title: 'Centre d\'aide',
              subtitle: 'FAQ et guides d\'utilisation',
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingsItem(
              icon: Icons.feedback_outlined,
              title: 'Envoyer des commentaires',
              subtitle: 'Aidez-nous à améliorer l\'application',
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingsItem(
              icon: Icons.info_outline,
              title: 'À propos',
              subtitle: 'Version de l\'application et informations',
              onTap: () => _showAbout(context),
            ),

            const SizedBox(height: 32),

            // Logout Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Se déconnecter',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.blue,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.grey,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Fonctionnalité bientôt disponible'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('À propos d\'InstaUSTHB'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Développé pour la communauté USTHB'),
            SizedBox(height: 8),
            Text('© 2024 InstaUSTHB'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Add logout logic here
              _showComingSoon(context);
            },
            child: const Text(
              'Se déconnecter',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}