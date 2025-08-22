import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Custom search bar widget with real-time filtering
/// and OCR text search capabilities
class SearchBarWidget extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onViewToggle;
  final bool isGridView;

  const SearchBarWidget({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.onFilterTap,
    this.onViewToggle,
    this.isGridView = true,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Search input field
            Expanded(
              child: Container(
                height: 44.h,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: widget.onChanged,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: CustomIconWidget(
                        iconName: 'search',
                        color: colorScheme.onSurfaceVariant,
                        size: 20.sp,
                      ),
                    ),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _controller.clear();
                              widget.onChanged('');
                            },
                            icon: CustomIconWidget(
                              iconName: 'clear',
                              color: colorScheme.onSurfaceVariant,
                              size: 20.sp,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(width: 12.w),

            // Filter button
            if (widget.onFilterTap != null)
              Container(
                height: 44.h,
                width: 44.w,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: IconButton(
                  onPressed: widget.onFilterTap,
                  icon: CustomIconWidget(
                    iconName: 'tune',
                    color: colorScheme.onSurfaceVariant,
                    size: 20.sp,
                  ),
                ),
              ),

            SizedBox(width: 8.w),

            // View toggle button
            if (widget.onViewToggle != null)
              Container(
                height: 44.h,
                width: 44.w,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: IconButton(
                  onPressed: widget.onViewToggle,
                  icon: CustomIconWidget(
                    iconName: widget.isGridView ? 'list' : 'grid_view',
                    color: colorScheme.onSurfaceVariant,
                    size: 20.sp,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
