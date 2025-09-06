import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_export.dart';

/// Professional Quantum Error Widget
/// Features glassmorphism design, smooth animations, and comprehensive error handling
class CustomErrorWidget extends StatefulWidget {
  final FlutterErrorDetails? errorDetails;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool showTechnicalDetails;

  const CustomErrorWidget({
    Key? key,
    this.errorDetails,
    this.errorMessage,
    this.onRetry,
    this.showTechnicalDetails = false,
  }) : super(key: key);

  @override
  State<CustomErrorWidget> createState() => _CustomErrorWidgetState();
}

class _CustomErrorWidgetState extends State<CustomErrorWidget>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _fadeController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _fadeAnimation;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _bounceController.forward();
        _fadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  String get _displayErrorMessage {
    if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty) {
      return widget.errorMessage!;
    }

    if (widget.errorDetails?.exception != null) {
      return widget.errorDetails!.exception.toString();
    }

    return 'An unexpected error occurred';
  }

  String get _technicalDetails {
    if (widget.errorDetails == null) return 'No technical details available';

    final buffer = StringBuffer();
    buffer.writeln('Error: ${widget.errorDetails!.exception}');

    if (widget.errorDetails!.stack != null) {
      final stackLines = widget.errorDetails!.stack.toString().split('\n');
      buffer.writeln('Stack Trace:');
      for (int i = 0; i < stackLines.length && i < 5; i++) {
        buffer.writeln('  ${stackLines[i]}');
      }
      if (stackLines.length > 5) {
        buffer.writeln('  ... and ${stackLines.length - 5} more lines');
      }
    }

    return buffer.toString();
  }

  void _handleBackAction() {
    HapticFeedback.lightImpact();
    bool canBeBack = Navigator.canPop(context);
    if (canBeBack) {
      Navigator.of(context).pop();
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.initial,
            (route) => false,
      );
    }
  }

  void _handleRetryAction() {
    HapticFeedback.mediumImpact();
    if (widget.onRetry != null) {
      widget.onRetry!();
    } else {
      _handleBackAction();
    }
  }

  void _copyErrorDetails() {
    HapticFeedback.selectionClick();
    Clipboard.setData(ClipboardData(text: _technicalDetails));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Error details copied to clipboard',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.auroraDream : AppTheme.quantumPulse,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Quantum Error Icon with Glassmorphism
                    ScaleTransition(
                      scale: _bounceAnimation,
                      child: _buildQuantumErrorIcon(isDark),
                    ),

                    const SizedBox(height: 32),

                    // Error Title
                    _buildErrorTitle(theme),

                    const SizedBox(height: 16),

                    // Error Description
                    _buildErrorDescription(theme),

                    const SizedBox(height: 40),

                    // Action Buttons
                    _buildActionButtons(isDark),

                    if (widget.showTechnicalDetails) ...[
                      const SizedBox(height: 32),
                      _buildTechnicalDetailsSection(theme, isDark),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantumErrorIcon(bool isDark) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (isDark ? AppTheme.glassDark : AppTheme.glassLight).withOpacity(0.1),
        border: Border.all(
          color: (isDark ? AppTheme.etherealBorderDark : AppTheme.etherealBorderLight)
              .withOpacity(0.3),
          width: 2,
        ),
        boxShadow: AppTheme.getQuantumGlow(isDark, intensity: 0.5),
      ),
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppTheme.errorLight.withOpacity(0.2),
              AppTheme.errorLight.withOpacity(0.05),
            ],
          ),
        ),
        child: Icon(
          Icons.error_outline_rounded,
          size: 48,
          color: isDark ? AppTheme.errorDark : AppTheme.errorLight,
        ),
      ),
    );
  }

  Widget _buildErrorTitle(ThemeData theme) {
    return Text(
      'Oops! Something went wrong',
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildErrorDescription(ThemeData theme) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        children: [
          Text(
            'We encountered an unexpected error while processing your request. '
                'Don\'t worry, our team has been notified.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
          if (_displayErrorMessage.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.error.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                _displayErrorMessage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Column(
      children: [
        // Primary Actions Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.onRetry != null) ...[
              _buildQuantumButton(
                onPressed: _handleRetryAction,
                icon: Icons.refresh_rounded,
                label: 'Try Again',
                isPrimary: true,
                isDark: isDark,
              ),
              const SizedBox(width: 16),
            ],
            _buildQuantumButton(
              onPressed: _handleBackAction,
              icon: Icons.arrow_back_rounded,
              label: 'Go Back',
              isPrimary: widget.onRetry == null,
              isDark: isDark,
            ),
          ],
        ),

        if (widget.showTechnicalDetails) ...[
          const SizedBox(height: 16),
          _buildQuantumButton(
            onPressed: _copyErrorDetails,
            icon: Icons.copy_rounded,
            label: 'Copy Details',
            isPrimary: false,
            isDark: isDark,
          ),
        ],
      ],
    );
  }

  Widget _buildQuantumButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool isPrimary,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isPrimary ? AppTheme.getEtherealFloat(isDark) : null,
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: isPrimary
            ? Theme.of(context).elevatedButtonTheme.style
            : Theme.of(context).outlinedButtonTheme.style?.copyWith(
          backgroundColor: MaterialStateProperty.all(
            (isDark ? AppTheme.glassDark : AppTheme.glassLight).withOpacity(0.1),
          ),
        ),
      ),
    );
  }

  Widget _buildTechnicalDetailsSection(ThemeData theme, bool isDark) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Technical Details Toggle
          InkWell(
            onTap: () {
              setState(() {
                _showDetails = !_showDetails;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.glassDark : AppTheme.glassLight).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isDark ? AppTheme.etherealBorderDark : AppTheme.etherealBorderLight)
                      .withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _showDetails
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_right_rounded,
                    size: 20,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Technical Details',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Technical Details Content
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _showDetails ? null : 0,
            child: _showDetails
                ? Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.glassDark : AppTheme.glassLight)
                    .withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isDark
                      ? AppTheme.etherealBorderDark
                      : AppTheme.etherealBorderLight)
                      .withOpacity(0.2),
                ),
              ),
              child: SelectableText(
                _technicalDetails,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  height: 1.5,
                ),
              ),
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}