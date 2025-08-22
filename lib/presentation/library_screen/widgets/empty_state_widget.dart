import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Empty state widget displayed when no documents are available
/// with illustration and call-to-action for importing documents
class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onImportTap;
  final VoidCallback onScanTap;

  const EmptyStateWidget({
    super.key,
    required this.onImportTap,
    required this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              width: 200.w,
              height: 200.h,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'folder_open',
                  color: colorScheme.primary,
                  size: 80.sp,
                ),
              ),
            ),

            SizedBox(height: 32.h),

            // Title
            Text(
              'No Documents Yet',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 16.h),

            // Description
            Text(
              'Start building your digital document library by importing or scanning your first PDF.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 32.h),

            // Action buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onScanTap,
                    icon: CustomIconWidget(
                      iconName: 'camera_alt',
                      color: colorScheme.onPrimary,
                      size: 20.sp,
                    ),
                    label: Text('Scan Document'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onImportTap,
                    icon: CustomIconWidget(
                      iconName: 'upload_file',
                      color: colorScheme.primary,
                      size: 20.sp,
                    ),
                    label: Text('Import from Device'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Help text
            Text(
              'Supported formats: PDF, JPG, PNG',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
