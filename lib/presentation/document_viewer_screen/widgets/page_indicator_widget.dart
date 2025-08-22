import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Widget for displaying page navigation and current page indicator
class PageIndicatorWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int)? onPageChanged;
  final bool showPageNumbers;

  const PageIndicatorWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onPageChanged,
    this.showPageNumbers = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNavigationButton(
            icon: 'keyboard_arrow_left',
            onTap: currentPage > 1 ? () => _previousPage() : null,
          ),
          SizedBox(width: 3.w),
          if (showPageNumbers) _buildPageNumbers(),
          if (!showPageNumbers) _buildPageDots(),
          SizedBox(width: 3.w),
          _buildNavigationButton(
            icon: 'keyboard_arrow_right',
            onTap: currentPage < totalPages ? () => _nextPage() : null,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required String icon,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: onTap != null
                ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: CustomIconWidget(
            iconName: icon,
            size: 24,
            color: onTap != null
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildPageNumbers() {
    return GestureDetector(
      onTap: () => _showPageJumpDialog(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          '$currentPage of $totalPages',
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPageDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        totalPages > 5 ? 5 : totalPages,
        (index) {
          int pageIndex;
          if (totalPages <= 5) {
            pageIndex = index + 1;
          } else {
            // Show dots around current page
            if (currentPage <= 3) {
              pageIndex = index + 1;
            } else if (currentPage >= totalPages - 2) {
              pageIndex = totalPages - 4 + index;
            } else {
              pageIndex = currentPage - 2 + index;
            }
          }

          final isActive = pageIndex == currentPage;

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 1.w),
            child: GestureDetector(
              onTap: () => onPageChanged?.call(pageIndex),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: isActive ? 8.w : 2.w,
                height: 2.w,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(1.w),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _previousPage() {
    if (currentPage > 1) {
      onPageChanged?.call(currentPage - 1);
    }
  }

  void _nextPage() {
    if (currentPage < totalPages) {
      onPageChanged?.call(currentPage + 1);
    }
  }

  void _showPageJumpDialog() {
    // This would show a dialog to jump to a specific page
    // Implementation would depend on the parent widget's context
  }
}
