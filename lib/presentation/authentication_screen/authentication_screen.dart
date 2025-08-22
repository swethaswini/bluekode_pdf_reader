import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/biometric_auth_widget.dart';
import './widgets/enterprise_sso_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/security_indicator_widget.dart';

/// Authentication Screen for secure access to enterprise PDF processing features
class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  bool _isLoading = false;
  bool _isBiometricAvailable = true;
  String? _errorMessage;

  // Mock credentials for testing
  final Map<String, String> _mockCredentials = {
    'admin@bluekode.com': 'admin123',
    'user@bluekode.com': 'user123',
    'demo@bluekode.com': 'demo123',
  };

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    // Simulate checking biometric availability
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isBiometricAvailable = true;
      });
    }
  }

  Future<void> _handleSignIn(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulate authentication delay
      await Future.delayed(const Duration(seconds: 2));

      // Check mock credentials
      if (_mockCredentials.containsKey(email) &&
          _mockCredentials[email] == password) {
        // Provide haptic feedback for success
        HapticFeedback.lightImpact();

        // Navigate to Library screen
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/library-screen');
        }
      } else {
        // Handle authentication failure
        setState(() {
          _errorMessage = 'Invalid email or password. Please try again.';
        });

        // Provide haptic feedback for error
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Network error. Please check your connection and try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleBiometricSuccess() async {
    // Provide haptic feedback
    HapticFeedback.lightImpact();

    // Navigate to Library screen
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/library-screen');
    }
  }

  Future<void> _handleSsoSuccess() async {
    // Provide haptic feedback
    HapticFeedback.lightImpact();

    // Navigate to Library screen
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/library-screen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
              AppTheme.lightTheme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 8.h),

                  // Bluekode Logo
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 20.w,
                          height: 20.w,
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(4.w),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.lightTheme.colorScheme.primary
                                    .withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'B',
                              style: TextStyle(
                                color:
                                    AppTheme.lightTheme.colorScheme.onPrimary,
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Bluekode PDF Reader',
                          style: TextStyle(
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.02,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Enterprise Document Processing',
                          style: TextStyle(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 6.h),

                  // Error Message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.error
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2.w),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.error
                              .withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'error_outline',
                            color: AppTheme.lightTheme.colorScheme.error,
                            size: 20,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: AppTheme.lightTheme.colorScheme.error,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 3.h),
                  ],

                  // Login Form
                  LoginFormWidget(
                    onSignIn: _handleSignIn,
                    isLoading: _isLoading,
                  ),

                  // Biometric Authentication
                  BiometricAuthWidget(
                    onBiometricSuccess: _handleBiometricSuccess,
                    isAvailable: _isBiometricAvailable && !_isLoading,
                  ),

                  // Enterprise SSO
                  EnterpriseSsoWidget(
                    onSsoSuccess: _handleSsoSuccess,
                  ),

                  SizedBox(height: 4.h),

                  // Security Indicator
                  const Center(
                    child: SecurityIndicatorWidget(),
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
