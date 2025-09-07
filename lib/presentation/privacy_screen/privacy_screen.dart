import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      setState(() {
        _showBackToTopButton = _scrollController.offset > 300;
      });
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showErrorSnackBar('Impossible d\'ouvrir le lien');
    }
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

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _showBackToTopButton
          ? FloatingActionButton(
        onPressed: _scrollToTop,
        backgroundColor: Colors.blue,
        child: Icon(Icons.keyboard_arrow_up, color: Colors.white),
      )
          : null,
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
        'Politique de Confidentialité',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
          fontSize: 18.sp,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 3.h),
            _buildSection(
              'Collecte des Informations',
              'Nous collectons les informations suivantes lors de votre inscription et utilisation de l\'application :\n\n'
                  '• Informations personnelles (nom, prénom, email)\n'
                  '• Numéro d\'étudiant USTHB\n'
                  '• Informations académiques (année, spécialité)\n'
                  '• Photo de profil (optionnelle)\n'
                  '• Données d\'utilisation de l\'application',
            ),
            _buildSection(
              'Utilisation des Données',
              'Vos données sont utilisées exclusivement pour :\n\n'
                  '• Fournir les services de l\'application\n'
                  '• Personnaliser votre expérience utilisateur\n'
                  '• Améliorer nos services\n'
                  '• Assurer la sécurité de la plateforme\n'
                  '• Communiquer avec vous concernant l\'application',
            ),
            _buildSection(
              'Partage des Données',
              'Nous ne partageons jamais vos données personnelles avec des tiers, sauf :\n\n'
                  '• Avec votre consentement explicite\n'
                  '• Pour respecter des obligations légales\n'
                  '• Pour protéger nos droits et notre sécurité\n'
                  '• Avec des prestataires de services essentiels (sous contrat strict)',
            ),
            _buildSection(
              'Sécurité des Données',
              'Nous mettons en œuvre des mesures de sécurité appropriées :\n\n'
                  '• Chiffrement des données sensibles\n'
                  '• Accès restreint aux données personnelles\n'
                  '• Surveillance continue de nos systèmes\n'
                  '• Mises à jour de sécurité régulières\n'
                  '• Audits de sécurité périodiques',
            ),
            _buildSection(
              'Vos Droits',
              'Vous avez le droit de :\n\n'
                  '• Accéder à vos données personnelles\n'
                  '• Rectifier des informations incorrectes\n'
                  '• Supprimer votre compte et vos données\n'
                  '• Vous opposer au traitement de vos données\n'
                  '• Porter réclamation auprès des autorités',
            ),
            _buildSection(
              'Cookies et Tracking',
              'Nous utilisons des technologies similaires aux cookies pour :\n\n'
                  '• Mémoriser vos préférences\n'
                  '• Analyser l\'utilisation de l\'application\n'
                  '• Améliorer les performances\n\n'
                  'Vous pouvez gérer ces préférences dans les paramètres de l\'application.',
            ),
            _buildSection(
              'Conservation des Données',
              'Nous conservons vos données :\n\n'
                  '• Tant que votre compte est actif\n'
                  '• Pendant la durée nécessaire aux fins légales\n'
                  '• Jusqu\'à 30 jours après suppression de votre compte\n\n'
                  'Les données anonymisées peuvent être conservées à des fins statistiques.',
            ),
            _buildSection(
              'Modifications de la Politique',
              'Cette politique peut être modifiée. En cas de changement significatif :\n\n'
                  '• Vous serez notifié par email\n'
                  '• Une notification apparaîtra dans l\'application\n'
                  '• La date de dernière mise à jour sera indiquée\n\n'
                  'L\'utilisation continue constitue votre acceptation des modifications.',
            ),
            _buildContactSection(),
            SizedBox(height: 4.h),
            _buildLastUpdated(),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[50]!, Colors.blue[100]!],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.privacy_tip,
            size: 12.w,
            color: Colors.blue,
          ),
          SizedBox(height: 2.h),
          Text(
            'Protection de vos Données',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Text(
            'Nous nous engageons à protéger votre vie privée et la sécurité de vos informations personnelles.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 3.h),
      child: Column(
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
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contact_support, color: Colors.blue, size: 6.w),
              SizedBox(width: 3.w),
              Text(
                'Nous Contacter',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Pour toute question concernant cette politique ou vos données personnelles :',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 2.h),
          _buildContactItem(
            Icons.email,
            'Email',
            'privacy@usthb.dz',
                () => _launchUrl('mailto:privacy@usthb.dz'),
          ),
          SizedBox(height: 1.h),
          _buildContactItem(
            Icons.phone,
            'Téléphone',
            '+213 21 24 79 00',
                () => _launchUrl('tel:+21321247900'),
          ),
          SizedBox(height: 1.h),
          _buildContactItem(
            Icons.location_on,
            'Adresse',
            'BP 32, El Alia, Bab Ezzouar, 16111 Alger',
            null,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
      IconData icon,
      String label,
      String value,
      VoidCallback? onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 5.w),
            SizedBox(width: 3.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: onTap != null ? Colors.blue : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (onTap != null) ...[
              Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 4.w,
                color: Colors.blue,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdated() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            Icons.update,
            color: Colors.grey[600],
            size: 5.w,
          ),
          SizedBox(height: 1.h),
          Text(
            'Dernière mise à jour',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '15 Janvier 2025',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}