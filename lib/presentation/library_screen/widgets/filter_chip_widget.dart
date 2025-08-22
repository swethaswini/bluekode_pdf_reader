import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Filter chip widget for displaying active filters
/// with remove functionality
class FilterChipWidget extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  final bool isActive;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.onRemove,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(right: 8.w),
      child: FilterChip(
        label: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color:
                isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        selected: isActive,
        onSelected: (_) => onRemove(),
        selectedColor: colorScheme.primary,
        backgroundColor: colorScheme.surfaceContainerHighest,
        deleteIcon: CustomIconWidget(
          iconName: 'close',
          color:
              isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
          size: 16.sp,
        ),
        onDeleted: onRemove,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isActive ? colorScheme.primary : colorScheme.outline,
            width: 1,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      ),
    );
  }
}
