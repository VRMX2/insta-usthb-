import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instaappusthb/services/auth_sevice.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();

  // Settings states
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _profilePublic = true;
  bool _showOnlineStatus = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load user settings from preferences or Firebase
    // For now, using default values
    setState(() {
      // You can load actual settings here
    });
  }

  Future<void> _saveSettings() async {
    // Save settings to preferences or Firebase
    _showSuccessSnackBar('Paramètres sauvegardés');
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Changer le mot de passe',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogTextField(
              controller: currentPasswordController,
              label: 'Mot de passe actuel',
              obscureText: true,
            ),
            SizedBox(height: 2.h),
            _buildDialogTextField(
              controller: newPasswordController,
              label: 'Nouveau mot de passe',
              obscureText: true,
            ),
            SizedBox(height: 2.h),
            _buildDialogTextField(
              controller: confirmPasswordController,
              label: 'Confirmer le mot de passe',
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement password change logic
              Navigator.pop(context);
              _changePassword(
                currentPasswordController.text,
                newPasswordController.text,
                confirmPasswordController.text,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Changer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: EdgeInsets.all(3.w),
      ),
    );
  }

  Future<void> _changePassword(String current, String newPassword, String confirm) async {
    if (newPassword != confirm) {
      _showErrorSnackBar('Les mots de passe ne correspondent pas');
      return;
    }

    if (newPassword.length < 6) {
      _showErrorSnackBar('Le mot de passe doit contenir au moins 6 caractères');
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Re-authenticate user
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: current,
        );

        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);

        _showSuccessSnackBar('Mot de passe modifié avec succès');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'Mot de passe actuel incorrect';
          break;
        case 'weak-password':
          errorMessage = 'Le nouveau mot de passe est trop faible';
          break;
        default:
          errorMessage = 'Erreur lors de la modification du mot de passe';
      }
      _showErrorSnackBar(errorMessage);
    } catch (e) {
      _showErrorSnackBar('Erreur lors de la modification du mot de passe');
    }
  }

  Future<void> _showAboutDialog() async {
    showAboutDialog(
      context: context,
      applicationName: 'USTHB Social',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 15.w,
        height: 15.w,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.school,
          color: Colors.white,
          size: 8.w,
        ),
      ),
      children: [
        Text(
          'Application de réseau social pour les étudiants de l\'USTHB.\n\nConnectez-vous avec vos collègues étudiants et partagez votre expérience universitaire.',
          style: TextStyle(fontSize: 14.sp),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Paramètres',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
          fontSize: 18.sp,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNotificationSettings(),
          SizedBox(height: 4.h),
          _buildPrivacySettings(),
          SizedBox(height: 4.h),
          _buildAccountSettings(),
          SizedBox(height: 4.h),
          _buildAppSettings(),
          SizedBox(height: 4.h),
          _buildSupportSection(),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return _buildSettingsSection(
      title: 'Notifications',
      children: [
        _buildSwitchTile(
          icon: Icons.notifications,
          title: 'Notifications push',
          subtitle: 'Recevoir des notifications sur votre appareil',
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
            _saveSettings();
          },
        ),
      ],
    );
  }

  Widget _buildPrivacySettings() {
    return _buildSettingsSection(
      title: 'Confidentialité',
      children: [
        _buildSwitchTile(
          icon: Icons.public,
          title: 'Profil public',
          subtitle: 'Permettre aux autres de voir votre profil',
          value: _profilePublic,
          onChanged: (value) {
            setState(() {
              _profilePublic = value;
            });
            _saveSettings();
          },
        ),
        _buildSwitchTile(
          icon: Icons.circle,
          title: 'Statut en ligne',
          subtitle: 'Montrer quand vous êtes en ligne',
          value: _showOnlineStatus,
          onChanged: (value) {
            setState(() {
              _showOnlineStatus = value;
            });
            _saveSettings();
          },
        ),
      ],
    );
  }

  Widget _buildAccountSettings() {
    return _buildSettingsSection(
      title: 'Compte',
      children: [
        _buildActionTile(
          icon: Icons.lock,
          title: 'Changer le mot de passe',
          subtitle: 'Modifier votre mot de passe',
          onTap: _showChangePasswordDialog,
        ),
        _buildActionTile(
          icon: Icons.email,
          title: 'Notifications par email',
          subtitle: 'Gérer les notifications par email',
          onTap: () {
            _showErrorSnackBar('Fonctionnalité en cours de développement');
          },
        ),
      ],
    );
  }

  Widget _buildAppSettings() {
    return _buildSettingsSection(
      title: 'Application',
      children: [
        _buildSwitchTile(
          icon: Icons.dark_mode,
          title: 'Mode sombre',
          subtitle: 'Utiliser le thème sombre',
          value: _darkModeEnabled,
          onChanged: (value) {
            setState(() {
              _darkModeEnabled = value;
            });
            _saveSettings();
          },
        ),
        _buildActionTile(
          icon: Icons.language,
          title: 'Langue',
          subtitle: 'Français',
          onTap: () {
            _showErrorSnackBar('Fonctionnalité en cours de développement');
          },
        ),
        _buildActionTile(
          icon: Icons.storage,
          title: 'Stockage et données',
          subtitle: 'Gérer le cache et les données',
          onTap: () {
            _showErrorSnackBar('Fonctionnalité en cours de développement');
          },
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _buildSettingsSection(
      title: 'Support',
      children: [
        _buildActionTile(
          icon: Icons.help_outline,
          title: 'Centre d\'aide',
          subtitle: 'FAQ et guides d\'utilisation',
          onTap: () {
            _showErrorSnackBar('Fonctionnalité en cours de développement');
          },
        ),
        _buildActionTile(
          icon: Icons.bug_report,
          title: 'Signaler un problème',
          subtitle: 'Nous aider à améliorer l\'application',
          onTap: () {
            _showErrorSnackBar('Fonctionnalité en cours de développement');
          },
        ),
        _buildActionTile(
          icon: Icons.info_outline,
          title: 'À propos',
          subtitle: 'Version et informations sur l\'app',
          onTap: _showAboutDialog,
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: children.map((child) {
              final index = children.indexOf(child);
              return Column(
                children: [
                  child,
                  if (index < children.length - 1)
                    Divider(
                      height: 1,
                      color: Colors.grey[200],
                      indent: 16.w,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 10.w,
        height: 10.w,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.blue,
          size: 5.w,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 10.w,
        height: 10.w,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.grey[700],
          size: 5.w,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey[400],
        size: 4.w,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
    );
  }
}