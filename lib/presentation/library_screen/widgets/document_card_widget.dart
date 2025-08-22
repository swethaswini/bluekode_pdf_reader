import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Document card widget displaying PDF document information
/// with thumbnail, title, processing status, and metadata
class DocumentCardWidget extends StatelessWidget {
  final Map<String, dynamic> document;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const DocumentCardWidget({
    super.key,
    required this.document,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Document thumbnail
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: colorScheme.surface,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: document['thumbnail'] != null
                        ? CustomImageWidget(
                            imageUrl: document['thumbnail'] as String,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: colorScheme.primaryContainer,
                            child: Center(
                              child: CustomIconWidget(
                                iconName: 'description',
                                color: colorScheme.primary,
                                size: 32.sp,
                              ),
                            ),
                          ),
                  ),
                ),
              ),

              SizedBox(height: 8.h),

              // Document title
              Expanded(
                flex: 1,
                child: Text(
                  document['title'] as String? ?? 'Untitled Document',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              SizedBox(height: 4.h),

              // Processing status and confidence
              Row(
                children: [
                  _buildStatusIndicator(context),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '${document['confidence'] ?? 0}% confidence',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 4.h),

              // Document metadata
              Text(
                _formatDate(document['lastModified'] as DateTime?),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build status indicator based on processing status
  Widget _buildStatusIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final status = document['status'] as String? ?? 'unknown';

    Color indicatorColor;
    IconData iconData;

    switch (status.toLowerCase()) {
      case 'processed':
        indicatorColor = colorScheme.tertiary;
        iconData = Icons.check_circle;
        break;
      case 'processing':
        indicatorColor = colorScheme.primary;
        iconData = Icons.hourglass_empty;
        break;
      case 'failed':
        indicatorColor = colorScheme.error;
        iconData = Icons.error;
        break;
      default:
        indicatorColor = colorScheme.onSurfaceVariant;
        iconData = Icons.help;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: indicatorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: iconData.codePoint.toString(),
            color: indicatorColor,
            size: 12.sp,
          ),
          SizedBox(width: 4.w),
          Text(
            status.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: indicatorColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Format date for display
  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
