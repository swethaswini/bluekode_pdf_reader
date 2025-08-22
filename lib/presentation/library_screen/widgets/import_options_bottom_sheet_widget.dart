import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Import options bottom sheet widget for selecting document source
/// with camera scanning and file import options
class ImportOptionsBottomSheetWidget extends StatelessWidget {
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;
  final VoidCallback onFileTap;
  final VoidCallback onCloudTap;

  const ImportOptionsBottomSheetWidget({
    super.key,
    required this.onCameraTap,
    required this.onGalleryTap,
    required this.onFileTap,
    required this.onCloudTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 8.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: EdgeInsets.all(16.w),
            child: Text(
              'Import Document',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Import options
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                _buildImportOption(
                  context,
                  icon: 'camera_alt',
                  title: 'Scan with Camera',
                  subtitle: 'Capture documents with your camera',
                  onTap: onCameraTap,
                ),
                SizedBox(height: 8.h),
                _buildImportOption(
                  context,
                  icon: 'photo_library',
                  title: 'Choose from Gallery',
                  subtitle: 'Select images from your photo library',
                  onTap: onGalleryTap,
                ),
                SizedBox(height: 8.h),
                _buildImportOption(
                  context,
                  icon: 'folder',
                  title: 'Browse Files',
                  subtitle: 'Import PDF files from device storage',
                  onTap: onFileTap,
                ),
                SizedBox(height: 8.h),
                _buildImportOption(
                  context,
                  icon: 'cloud_upload',
                  title: 'Cloud Storage',
                  subtitle: 'Import from Google Drive, Dropbox, etc.',
                  onTap: onCloudTap,
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Cancel button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportOption(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: icon,
                  color: colorScheme.primary,
                  size: 24.sp,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: colorScheme.onSurfaceVariant,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}
