import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Enterprise SSO authentication widget
class EnterpriseSsoWidget extends StatefulWidget {
  final VoidCallback onSsoSuccess;

  const EnterpriseSsoWidget({
    super.key,
    required this.onSsoSuccess,
  });

  @override
  State<EnterpriseSsoWidget> createState() => _EnterpriseSsoWidgetState();
}

class _EnterpriseSsoWidgetState extends State<EnterpriseSsoWidget> {
  bool _isSsoLoading = false;

  Future<void> _handleSsoLogin() async {
    setState(() {
      _isSsoLoading = true;
    });

    try {
      // Simulate SSO authentication process
      await Future.delayed(const Duration(seconds: 2));

      widget.onSsoSuccess();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SSO authentication failed: ${e.toString()}'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSsoLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 3.h),

        // Enterprise SSO Button
        SizedBox(
          height: 6.h,
          child: OutlinedButton.icon(
            onPressed: _isSsoLoading ? null : _handleSsoLogin,
            icon: _isSsoLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  )
                : CustomIconWidget(
                    iconName: 'business',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
            label: Text(
              'Sign in with Company',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.lightTheme.colorScheme.primary,
              side: BorderSide(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.w),
              ),
            ),
          ),
        ),

        SizedBox(height: 4.h),

        // Support Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'New to enterprise? ',
              style: TextStyle(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            GestureDetector(
              onTap: () {
                // Handle contact admin
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Contact your system administrator for access'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              child: Text(
                'Contact Admin',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
