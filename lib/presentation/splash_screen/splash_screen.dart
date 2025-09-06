import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:ui';
import 'package:instaappusthb/core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _primaryController;
  late AnimationController _secondaryController;
  late AnimationController _pulseController;
  late AnimationController _shineController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shineAnimation;
  late Animation<double> _backgroundAnimation;

  bool _isInitialized = false;
  String _loadingText = 'Initialisation...';
  double _loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    // Primary animation controller for main sequence
    _primaryController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Secondary controller for continuous animations
    _secondaryController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Pulse controller for logo breathing effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Shine controller for logo shine effect
    _shineController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Logo animations
    _logoScaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _primaryController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _primaryController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));

    // Text animations
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _primaryController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _primaryController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOutBack),
    ));

    // Progress animation
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _secondaryController,
      curve: Curves.easeInOut,
    ));

    // Pulse animation for logo
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Shine effect animation
    _shineAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shineController,
      curve: Curves.easeInOut,
    ));

    // Background gradient animation
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _secondaryController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _primaryController.forward();
    _secondaryController.repeat();
    _pulseController.repeat(reverse: true);
    _shineController.repeat();
  }

  Future<void> _initializeApp() async {
    try {
      // Enhanced initialization with progress tracking
      await _initializeStep('Vérification de l\'authentification...', 0.2);
      await _initializeStep('Chargement des préférences...', 0.4);
      await _initializeStep('Configuration USTHB...', 0.7);
      await _initializeStep('Préparation du contenu...', 0.9);
      await _initializeStep('Prêt!', 1.0);

      setState(() {
        _isInitialized = true;
      });

      // Wait for animations to complete
      await Future.delayed(const Duration(milliseconds: 800));
      _navigateToNextScreen();
    } catch (e) {
      _handleInitializationError();
    }
  }

  Future<void> _initializeStep(String text, double progress) async {
    setState(() {
      _loadingText = text;
      _loadingProgress = progress;
    });

    // Variable delay based on step complexity
    int delay = text.contains('Configuration') ? 800 :
    text.contains('Vérification') ? 1000 : 600;

    await Future.delayed(Duration(milliseconds: delay));
  }

  void _navigateToNextScreen() {
    final bool isAuthenticated = _checkAuthenticationStatus();
    final bool isFirstTime = _checkFirstTimeUser();

    if (isAuthenticated) {
      Navigator.pushReplacementNamed(context,'/home-screen');
    } else if (isFirstTime) {
      Navigator.pushReplacementNamed(context, '/onboarding-screen');
    } else {
      Navigator.pushReplacementNamed(context, '/login-screen');
    }
  }

  bool _checkAuthenticationStatus() {
    return false;
  }

  bool _checkFirstTimeUser() {
    return true;
  }

  void _handleInitializationError() {
    setState(() {
      _loadingText = 'Erreur de connexion';
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _showRetryDialog();
      }
    });
  }

  void _showRetryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Problème de connexion',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          content: Text(
            'Impossible de se connecter aux serveurs USTHB. Vérifiez votre connexion internet.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _initializeApp();
              },
              child: Text(
                'Réessayer',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _secondaryController.dispose();
    _pulseController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _primaryController,
          _secondaryController,
          _pulseController,
          _shineController,
        ]),
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                transform: GradientRotation(_backgroundAnimation.value * 0.1),
                colors: [
                  AppTheme.lightTheme.colorScheme.primary,
                  AppTheme.lightTheme.colorScheme.primary.withOpacity(0.8),
                  AppTheme.lightTheme.colorScheme.primaryContainer,
                  AppTheme.lightTheme.colorScheme.secondary.withOpacity(0.3),
                ],
                stops: const [0.0, 0.4, 0.8, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Animated background particles
                ...List.generate(20, (index) => _buildFloatingParticle(index)),

                // Main content - Fixed with SingleChildScrollView and LayoutBuilder
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: SafeArea(
                            child: Column(
                              children: [
                                // Top spacer
                                Flexible(
                                  flex: 2,
                                  child: Container(
                                    constraints: BoxConstraints(
                                      minHeight: constraints.maxHeight * 0.08,
                                      maxHeight: constraints.maxHeight * 0.15,
                                    ),
                                  ),
                                ),

                                // Logo section
                                Flexible(
                                  flex: 4,
                                  child: Container(
                                    constraints: BoxConstraints(
                                      minHeight: constraints.maxHeight * 0.25,
                                      maxHeight: constraints.maxHeight * 0.35,
                                    ),
                                    child: _buildLogoSection(),
                                  ),
                                ),

                                // Content section
                                Flexible(
                                  flex: 3,
                                  child: Container(
                                    constraints: BoxConstraints(
                                      minHeight: constraints.maxHeight * 0.15,
                                      maxHeight: constraints.maxHeight * 0.25,
                                    ),
                                    child: _buildContentSection(),
                                  ),
                                ),

                                // Loading section
                                Flexible(
                                  flex: 2,
                                  child: Container(
                                    constraints: BoxConstraints(
                                      minHeight: constraints.maxHeight * 0.12,
                                      maxHeight: constraints.maxHeight * 0.18,
                                    ),
                                    child: _buildLoadingSection(),
                                  ),
                                ),

                                // Footer
                                _buildFooter(),

                                // Bottom spacer
                                SizedBox(height: 2.h),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final double animationOffset = (index * 0.1) % 1.0;
    final double size = (index % 3 + 1) * 2.0;
    final double left = (index * 7.3) % 100;
    final double animationValue = (_backgroundAnimation.value + animationOffset) % 1.0;

    return Positioned(
      left: left.w,
      top: (animationValue * 120).h,
      child: Opacity(
        opacity: 0.1 + (animationValue * 0.3),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.5),
                blurRadius: size * 2,
                spreadRadius: 0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Center(
      child: Transform.scale(
        scale: _logoScaleAnimation.value * _pulseAnimation.value,
        child: Opacity(
          opacity: _logoFadeAnimation.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow effect
              Container(
                width: 32.w, // Slightly reduced
                height: 32.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                    BoxShadow(
                      color: AppTheme.lightTheme.colorScheme.secondary.withOpacity(0.4),
                      blurRadius: 60,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),

              // Main logo container
              Container(
                width: 28.w, // Slightly reduced
                height: 28.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Logo image
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 23.w, // Slightly reduced
                          height: 23.w,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.school_rounded,
                              size: 13.w, // Slightly reduced
                              color: AppTheme.lightTheme.colorScheme.primary,
                            );
                          },
                        ),
                      ),
                    ),

                    // Shine effect overlay
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: OverflowBox(
                          child: Transform.translate(
                            offset: Offset(_shineAnimation.value * 28.w, 0),
                            child: Container(
                              width: 8.w, // Slightly reduced
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withOpacity(0.6),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return SlideTransition(
      position: _textSlideAnimation,
      child: FadeTransition(
        opacity: _textFadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // App name with gradient text effect
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Colors.white,
                  Colors.white.withOpacity(0.8),
                  Colors.white,
                ],
                stops: const [0.0, 0.5, 1.0],
              ).createShader(bounds),
              child: Text(
                'InstaUSTHB',
                style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  fontSize: 28.sp, // Slightly reduced
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 1.5.h), // Reduced

            // Subtitle
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 0.8.h), // Reduced padding
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'Réseau Social Universitaire',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.8,
                ),
              ),
            ),

            SizedBox(height: 1.h), // Reduced

            // University info
            Text(
              'Faculté d\'Informatique',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Custom loading indicator
        SizedBox(
          width: 10.w, // Slightly reduced
          height: 10.w,
          child: Stack(
            children: [
              // Background circle
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),

              // Progress circle
              CircularProgressIndicator(
                value: _loadingProgress,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                backgroundColor: Colors.transparent,
                strokeWidth: 3,
              ),

              // Center dot
              Center(
                child: Container(
                  width: 2.5.w, // Slightly reduced
                  height: 2.5.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 2.h), // Reduced

        // Loading text with animated switcher
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            _loadingText,
            key: ValueKey(_loadingText),
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.95),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),

        SizedBox(height: 1.h), // Reduced

        // Progress percentage
        Text(
          '${(_loadingProgress * 100).toInt()}%',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w400,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // University name
          Text(
            'Université des Sciences et de la Technologie',
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w400,
              letterSpacing: 0.3,
            ),
          ),

          SizedBox(height: 0.3.h), // Reduced

          Text(
            'Houari Boumediene - Alger',
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w400,
              letterSpacing: 0.3,
            ),
          ),

          SizedBox(height: 1.h), // Reduced

          // Version with decorative elements
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6.w, // Slightly reduced
                height: 1,
                color: Colors.white.withOpacity(0.3),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Text(
                  'Version 1.0.0',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.8,
                  ),
                ),
              ),

              Container(
                width: 6.w, // Slightly reduced
                height: 1,
                color: Colors.white.withOpacity(0.3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}