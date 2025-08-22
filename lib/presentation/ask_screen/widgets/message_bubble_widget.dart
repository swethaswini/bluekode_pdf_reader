import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MessageBubbleWidget extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? citedSources;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;
  final VoidCallback? onSaveToNotes;
  final Function(String)? onSourceTap;

  const MessageBubbleWidget({
    super.key,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.citedSources,
    this.onCopy,
    this.onShare,
    this.onSaveToNotes,
    this.onSourceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4.w),
              ),
              child: CustomIconWidget(
                iconName: 'smart_toy',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 4.w,
              ),
            ),
            SizedBox(width: 2.w),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: isUser ? null : _showContextMenu,
              child: Container(
                constraints: BoxConstraints(maxWidth: 75.w),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isUser
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4.w),
                    topRight: Radius.circular(4.w),
                    bottomLeft:
                        isUser ? Radius.circular(4.w) : Radius.circular(1.w),
                    bottomRight:
                        isUser ? Radius.circular(1.w) : Radius.circular(4.w),
                  ),
                  border: isUser
                      ? null
                      : Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.2),
                          width: 1,
                        ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: isUser
                            ? AppTheme.lightTheme.colorScheme.onPrimary
                            : AppTheme.lightTheme.colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                    if (citedSources != null && citedSources!.isNotEmpty) ...[
                      SizedBox(height: 1.h),
                      _buildCitedSources(),
                    ],
                    SizedBox(height: 1.h),
                    Text(
                      _formatTimestamp(timestamp),
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: isUser
                            ? AppTheme.lightTheme.colorScheme.onPrimary
                                .withValues(alpha: 0.7)
                            : AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isUser) ...[
            SizedBox(width: 2.w),
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary,
                borderRadius: BorderRadius.circular(4.w),
              ),
              child: CustomIconWidget(
                iconName: 'person',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 4.w,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCitedSources() {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sources:',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 1.w,
            runSpacing: 0.5.h,
            children: citedSources!
                .map((source) => GestureDetector(
                      onTap: () => onSourceTap?.call(source),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(1.w),
                        ),
                        child: Text(
                          source,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontSize: 9.sp,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  void _showContextMenu() {
    // This would typically show a context menu
    // For now, we'll trigger the callbacks directly
    if (onCopy != null) onCopy!();
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
