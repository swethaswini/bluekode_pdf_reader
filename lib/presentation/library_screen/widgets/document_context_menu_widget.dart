import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Context menu widget for document long-press actions
/// with share, export, delete, tags, and reprocess options
class DocumentContextMenuWidget extends StatelessWidget {
  final Map<String, dynamic> document;
  final VoidCallback onShare;
  final VoidCallback onExport;
  final VoidCallback onDelete;
  final VoidCallback onAddTags;
  final VoidCallback onReprocess;

  const DocumentContextMenuWidget({
    super.key,
    required this.document,
    required this.onShare,
    required this.onExport,
    required this.onDelete,
    required this.onAddTags,
    required this.onReprocess,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Document info header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'description',
                      color: colorScheme.primary,
                      size: 20.sp,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document['title'] as String? ?? 'Untitled Document',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${document['confidence'] ?? 0}% confidence',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action items
          _buildMenuItem(
            context,
            icon: 'share',
            title: 'Share',
            onTap: onShare,
          ),
          _buildMenuItem(
            context,
            icon: 'download',
            title: 'Export',
            onTap: onExport,
          ),
          _buildMenuItem(
            context,
            icon: 'label',
            title: 'Add Tags',
            onTap: onAddTags,
          ),
          _buildMenuItem(
            context,
            icon: 'refresh',
            title: 'Reprocess',
            onTap: onReprocess,
          ),
          _buildMenuItem(
            context,
            icon: 'delete',
            title: 'Delete',
            onTap: onDelete,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = isDestructive ? colorScheme.error : colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: color,
              size: 20.sp,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
