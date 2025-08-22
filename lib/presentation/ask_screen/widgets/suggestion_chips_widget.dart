import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SuggestionChipsWidget extends StatelessWidget {
  final Function(String) onSuggestionTap;
  final bool isVisible;

  const SuggestionChipsWidget({
    super.key,
    required this.onSuggestionTap,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    final suggestions = [
      {'text': 'Summarize this document', 'icon': 'summarize'},
      {'text': 'Find all dates', 'icon': 'calendar_today'},
      {'text': 'Extract contact information', 'icon': 'contacts'},
      {'text': 'List key points', 'icon': 'format_list_bulleted'},
      {'text': 'Find financial data', 'icon': 'attach_money'},
      {'text': 'Identify action items', 'icon': 'task_alt'},
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick suggestions:',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          SizedBox(
            height: 5.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.length,
              separatorBuilder: (context, index) => SizedBox(width: 2.w),
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return _buildSuggestionChip(
                  suggestion['text'] as String,
                  suggestion['icon'] as String,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text, String iconName) {
    return GestureDetector(
      onTap: () => onSuggestionTap(text),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 4.w,
            ),
            SizedBox(width: 1.w),
            Text(
              text,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
