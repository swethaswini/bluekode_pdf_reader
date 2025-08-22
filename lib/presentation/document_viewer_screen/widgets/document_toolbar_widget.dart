import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Bottom toolbar widget for document viewer actions
class DocumentToolbarWidget extends StatelessWidget {
  final VoidCallback? onShare;
  final VoidCallback? onExport;
  final VoidCallback? onSearch;
  final VoidCallback? onInsights;
  final VoidCallback? onReprocess;
  final bool isProcessing;

  const DocumentToolbarWidget({
    super.key,
    this.onShare,
    this.onExport,
    this.onSearch,
    this.onInsights,
    this.onReprocess,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.shadowColor,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildToolbarButton(
                icon: 'share',
                label: 'Share',
                onTap: onShare,
              ),
              _buildToolbarButton(
                icon: 'download',
                label: 'Export',
                onTap: onExport,
              ),
              _buildToolbarButton(
                icon: 'search',
                label: 'Search',
                onTap: onSearch,
              ),
              _buildToolbarButton(
                icon: 'insights',
                label: 'Insights',
                onTap: onInsights,
              ),
              _buildToolbarButton(
                icon: isProcessing ? 'hourglass_empty' : 'refresh',
                label: 'Reprocess',
                onTap: isProcessing ? null : onReprocess,
                isLoading: isProcessing,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarButton({
    required String icon,
    required String label,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: onTap != null
                        ? AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1)
                        : AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isLoading
                      ? Center(
                          child: SizedBox(
                            width: 5.w,
                            height: 5.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.lightTheme.colorScheme.primary,
                              ),
                            ),
                          ),
                        )
                      : CustomIconWidget(
                          iconName: icon,
                          size: 24,
                          color: onTap != null
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.4),
                        ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  label,
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: onTap != null
                        ? AppTheme.lightTheme.colorScheme.onSurface
                        : AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.4),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
