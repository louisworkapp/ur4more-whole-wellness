import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/auth_button_widget.dart';
import './widgets/brand_logo_widget.dart';
import './widgets/email_input_widget.dart';
import './widgets/otp_input_widget.dart';
import './widgets/resend_code_widget.dart';

enum AuthState { emailInput, otpVerification }

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen>
    with TickerProviderStateMixin {
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // State variables
  AuthState _currentState = AuthState.emailInput;
  bool _isLoading = false;
  String? _emailError;
  String? _otpError;
  String _userEmail = '';

  // Mock credentials for testing
  final Map<String, String> _mockCredentials = {
    'admin@ur4more.com': '123456',
    'user@ur4more.com': '654321',
    'test@ur4more.com': '111111',
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _fadeController.forward();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _validateEmail() {
    setState(() {
      if (_emailController.text.isEmpty) {
        _emailError = 'Email address is required';
      } else if (!_isValidEmail(_emailController.text)) {
        _emailError = 'Please enter a valid email address';
      } else {
        _emailError = null;
      }
    });
  }

  Future<void> _sendOtpCode() async {
    _validateEmail();
    if (_emailError != null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      _userEmail = _emailController.text.toLowerCase().trim();

      // Check if email exists in mock credentials
      if (!_mockCredentials.containsKey(_userEmail)) {
        setState(() {
          _emailError =
              'Email not found. Please use: admin@ur4more.com, user@ur4more.com, or test@ur4more.com';
          _isLoading = false;
        });
        return;
      }

      // Transition to OTP verification
      await _slideController.forward();
      setState(() {
        _currentState = AuthState.otpVerification;
        _isLoading = false;
      });

      HapticFeedback.lightImpact();
    } catch (e) {
      setState(() {
        _emailError =
            'Network error. Please check your connection and try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOtpCode() async {
    if (_otpController.text.length != 6) {
      setState(() {
        _otpError = 'Please enter the complete 6-digit code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _otpError = null;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      final expectedCode = _mockCredentials[_userEmail];

      if (_otpController.text != expectedCode) {
        setState(() {
          _otpError = 'Invalid verification code. Please try again.';
          _isLoading = false;
        });
        HapticFeedback.heavyImpact();
        return;
      }

      // Success - navigate to home using proper route constant
      HapticFeedback.lightImpact();

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.homeDashboard,
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _otpError = 'Verification failed. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOtpCode() async {
    setState(() {
      _otpController.clear();
      _otpError = null;
    });

    // Simulate resend API call
    await Future.delayed(const Duration(milliseconds: 500));
    HapticFeedback.lightImpact();
  }

  void _goBackToEmail() {
    _slideController.reverse();
    setState(() {
      _currentState = AuthState.emailInput;
      _otpController.clear();
      _otpError = null;
    });
  }

  // Add quick login method
  Future<void> _quickLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      HapticFeedback.lightImpact();

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.homeDashboard,
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _emailError = 'Quick login failed. Please try regular login.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Column(
                      children: [
                        SizedBox(height: 8.h),

                        // Brand Logo with error handling
                        BrandLogoWidget(
                          size: 25.w,
                          tintColor: colorScheme.primary,
                        ),

                        SizedBox(height: 6.h),

                        // Content Area
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) {
                              return SlideTransition(
                                position: _slideAnimation,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: _currentState == AuthState.emailInput
                                ? _buildEmailInputSection()
                                : _buildOtpVerificationSection(),
                          ),
                        ),

                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailInputSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      key: const ValueKey('email_section'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Welcome Back',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Enter your email to receive a verification code',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 16.sp,
            color: colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        SizedBox(height: 4.h),

        // Email Input
        EmailInputWidget(
          controller: _emailController,
          errorText: _emailError,
          onChanged: () {
            if (_emailError != null) {
              setState(() {
                _emailError = null;
              });
            }
          },
        ),

        SizedBox(height: 4.h),

        // Send Code Button
        AuthButtonWidget(
          text: 'Send Verification Code',
          onPressed: _sendOtpCode,
          isLoading: _isLoading,
          isEnabled: _emailController.text.isNotEmpty,
        ),

        SizedBox(height: 2.h),

        // Quick access button for testing
        TextButton.icon(
          onPressed: _quickLogin,
          icon: Icon(
            Icons.flash_on,
            color: colorScheme.primary,
            size: 5.w,
          ),
          label: Text(
            'Quick Login for Demo',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: colorScheme.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // Mock credentials info
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                'Demo Accounts',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'admin@ur4more.com (Code: 123456)\nuser@ur4more.com (Code: 654321)\ntest@ur4more.com (Code: 111111)',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12.sp,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpVerificationSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      key: const ValueKey('otp_section'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: _goBackToEmail,
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: CustomIconWidget(
                  iconName: 'arrow_back_ios',
                  color: colorScheme.onSurface,
                  size: 5.w,
                ),
              ),
            ),
            Expanded(
              child: Text(
                'Verify Code',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            SizedBox(width: 9.w), // Balance the back button
          ],
        ),

        SizedBox(height: 2.h),

        Text(
          'We sent a 6-digit code to',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 16.sp,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          _userEmail,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),

        SizedBox(height: 4.h),

        // OTP Input
        OtpInputWidget(
          controller: _otpController,
          errorText: _otpError,
          onCompleted: _verifyOtpCode,
          onChanged: () {
            if (_otpError != null) {
              setState(() {
                _otpError = null;
              });
            }
          },
        ),

        SizedBox(height: 4.h),

        // Verify Button
        AuthButtonWidget(
          text: 'Verify Code',
          onPressed: _verifyOtpCode,
          isLoading: _isLoading,
          isEnabled: _otpController.text.length == 6,
        ),

        SizedBox(height: 3.h),

        // Resend Code
        ResendCodeWidget(
          onResend: _resendOtpCode,
          countdownSeconds: 60,
        ),
      ],
    );
  }
}

class ErrorBoundaryWidget extends StatelessWidget {
  final Widget child;
  final Widget fallback;

  const ErrorBoundaryWidget({
    super.key,
    required this.child,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (e) {
          debugPrint('Error in widget: $e');
          return fallback;
        }
      },
    );
  }
}
