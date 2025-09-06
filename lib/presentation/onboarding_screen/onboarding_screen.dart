import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:ui';

import 'package:instaappusthb/core/app_export.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late AnimationController _buttonAnimationController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _buttonFadeAnimation;
  late Animation<Offset> _buttonSlideAnimation;

  int _currentPage = 0;

  // Onboarding data
  final List<OnboardingData> _onboardingPages = [
    OnboardingData(
      image: 'assets/images/onboarding1.jpg',
      title: 'Connectez-vous avec vos collègues',
      description: 'Découvrez et interagissez avec les étudiants et professeurs de votre faculté. Créez des liens durables dans votre parcours académique.',
      fallbackIcon: Icons.people_rounded,
    ),
    OnboardingData(
      image: 'assets/images/onboarding2.png',
      title: 'Partagez vos expériences',
      description: 'Partagez vos moments universitaires, vos projets et vos réussites. Inspirez et soyez inspiré par la communauté USTHB.',
      fallbackIcon: Icons.share_rounded,
    ),
    OnboardingData(
      image: 'assets/images/onboarding3.png',
      title: 'Restez informé',
      description: 'Ne manquez aucune actualité importante, événements universitaires et opportunités académiques grâce à notre flux personnalisé.',
      fallbackIcon: Icons.notifications_active_rounded,
    ),
    OnboardingData(
      image: 'assets/images/onboarding4.png',
      title: 'Prêt à commencer?',
      description: 'Rejoignez la communauté InstaUSTHB dès maintenant et vivez une expérience universitaire enrichissante et connectée.',
      fallbackIcon: Icons.rocket_launch_rounded,
      isLastPage: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _buttonFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeOut,
    ));

    _buttonSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });

    _animationController.reset();
    _animationController.forward();

    if (index == _onboardingPages.length - 1) {
      _buttonAnimationController.forward();
    } else {
      _buttonAnimationController.reset();
    }
  }

  void _nextPage() {
    if (_currentPage < _onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToRegister() {
    Navigator.pushReplacementNamed(context, '/registration-screen');
  }

  void _navigateToSignIn() {
    Navigator.pushReplacementNamed(context, '/login-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.lightTheme.colorScheme.primary,
              AppTheme.lightTheme.colorScheme.primary.withOpacity(0.8),
              AppTheme.lightTheme.colorScheme.primaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              _buildTopBar(),

              // Page content - Fixed the overflow issue here
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _onboardingPages.length,
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(_onboardingPages[index]);
                  },
                ),
              ),

              // Bottom navigation
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button (only show if not first page)
          if (_currentPage > 0)
            GestureDetector(
              onTap: _previousPage,
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            )
          else
            SizedBox(width: 10.w),

          // Page indicator
          Row(
            children: List.generate(
              _onboardingPages.length,
                  (index) => _buildPageIndicator(index == _currentPage),
            ),
          ),

          // Skip button (hide on last page)
          if (_currentPage < _onboardingPages.length - 1)
            GestureDetector(
              onTap: () => _navigateToSignIn(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Passer',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
            SizedBox(width: 10.w),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 1.w),
      height: 1.h,
      width: isActive ? 8.w : 2.w,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(5),
        boxShadow: isActive
            ? [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ]
            : [],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData data) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        child: Column(
                          children: [
                            // Image Section - More flexible sizing
                            Flexible(
                              flex: 4,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxHeight: constraints.maxHeight * 0.4,
                                  minHeight: constraints.maxHeight * 0.25,
                                ),
                                child: _buildImageSection(data),
                              ),
                            ),

                            SizedBox(height: 2.h),

                            // Text Section - More flexible
                            Flexible(
                              flex: 3,
                              child: _buildTextSection(data),
                            ),

                            // Action buttons or spacer
                            if (data.isLastPage) ...[
                              SizedBox(height: 2.h),
                              _buildActionButtons(),
                              SizedBox(height: 2.h),
                            ] else ...[
                              SizedBox(height: 4.h),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection(OnboardingData data) {
    return Center(
      child: Container(
        width: 65.w, // Slightly smaller to prevent overflow
        height: 65.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Image or fallback icon
            Center(
              child: ClipOval(
                child: Container(
                  width: 55.w,
                  height: 55.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: data.image.isNotEmpty
                      ? Image.asset(
                    data.image,
                    width: 55.w,
                    height: 55.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildFallbackIcon(data.fallbackIcon);
                    },
                  )
                      : _buildFallbackIcon(data.fallbackIcon),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(IconData icon) {
    return Icon(
      icon,
      size: 22.w, // Slightly smaller
      color: AppTheme.lightTheme.colorScheme.primary,
    );
  }

  Widget _buildTextSection(OnboardingData data) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          data.title,
          textAlign: TextAlign.center,
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            height: 1.2,
          ),
        ),

        SizedBox(height: 1.5.h), // Reduced spacing

        // Description
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Text(
            data.description,
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w400,
              letterSpacing: 0.3,
              height: 1.4, // Reduced line height
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return AnimatedBuilder(
      animation: _buttonAnimationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _buttonFadeAnimation,
          child: SlideTransition(
            position: _buttonSlideAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Get Started button
                Container(
                  width: double.infinity,
                  height: 6.h,
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  child: ElevatedButton(
                    onPressed: _navigateToRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.lightTheme.colorScheme.primary,
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Commencer',
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 1.5.h), // Reduced spacing

                // Sign In button
                Container(
                  width: double.infinity,
                  height: 6.h,
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  child: OutlinedButton(
                    onPressed: _navigateToSignIn,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.8),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Se connecter',
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigation() {
    if (_currentPage == _onboardingPages.length - 1) {
      return SizedBox(height: 2.h); // Reduced height
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      child: Center(
        child: GestureDetector(
          onTap: _nextPage,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.5.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.white.withOpacity(0.95),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  blurRadius: 8,
                  spreadRadius: -2,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(1.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 4.5.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  'Suivant',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(width: 1.w),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Data model for onboarding pages
class OnboardingData {
  final String image;
  final String title;
  final String description;
  final IconData fallbackIcon;
  final bool isLastPage;

  OnboardingData({
    required this.image,
    required this.title,
    required this.description,
    required this.fallbackIcon,
    this.isLastPage = false,
  });
}