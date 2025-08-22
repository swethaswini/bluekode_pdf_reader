import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Biometric authentication widget for Face ID/Touch ID
class BiometricAuthWidget extends StatefulWidget {
  final VoidCallback onBiometricSuccess;
  final bool isAvailable;

  const BiometricAuthWidget({
    super.key,
    required this.onBiometricSuccess,
    required this.isAvailable,
  });

  @override
  State<BiometricAuthWidget> createState() => _BiometricAuthWidgetState();
}

class _BiometricAuthWidgetState extends State<BiometricAuthWidget> {
  bool _isAuthenticating = false;

  Future<void> _authenticateWithBiometrics() async {
    if (!widget.isAvailable || _isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    try {
      // Simulate biometric authentication
      await Future.delayed(const Duration(milliseconds: 1500));

      // Provide haptic feedback
      HapticFeedback.lightImpact();

      widget.onBiometricSuccess();
    } catch (e) {
      // Handle biometric authentication error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Biometric authentication failed: ${e.toString()}'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAvailable) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(height: 3.h),

        // Divider with "OR" text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.5),
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'OR',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.5),
                thickness: 1,
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        // Biometric Authentication Button
        Container(
          width: 15.w,
          height: 15.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(15.w),
              onTap: _isAuthenticating ? null : _authenticateWithBiometrics,
              child: Center(
                child: _isAuthenticating
                    ? SizedBox(
                        width: 6.w,
                        height: 6.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                      )
                    : CustomIconWidget(
                        iconName: 'fingerprint',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 8.w,
                      ),
              ),
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // Biometric Authentication Text
        Text(
          'Use Face ID / Touch ID',
          style: TextStyle(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
