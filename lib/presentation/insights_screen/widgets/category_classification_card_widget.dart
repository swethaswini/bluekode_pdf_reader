import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CategoryClassificationCardWidget extends StatefulWidget {
  final Map<String, dynamic> categoryData;
  final Function(String)? onCategoryOverride;

  const CategoryClassificationCardWidget({
    super.key,
    required this.categoryData,
    this.onCategoryOverride,
  });

  @override
  State<CategoryClassificationCardWidget> createState() =>
      _CategoryClassificationCardWidgetState();
}

class _CategoryClassificationCardWidgetState
    extends State<CategoryClassificationCardWidget> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    final suggestions = (widget.categoryData['suggestions'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    if (suggestions.isNotEmpty) {
      _selectedCategory = suggestions.first['category'] as String?;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suggestions = (widget.categoryData['suggestions'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    final confidence = widget.categoryData['confidence'] as double? ?? 0.0;
    final manualOverride =
        widget.categoryData['manualOverride'] as bool? ?? false;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'category',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Category Classification',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildConfidenceIndicator(confidence, theme),
                SizedBox(width: 2.w),
                IconButton(
                  onPressed: () => _showHowItWorks(context),
                  icon: CustomIconWidget(
                    iconName: 'help_outline',
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  tooltip: 'How this works',
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Content
            if (suggestions.isEmpty) ...[
              Center(
                child: Column(
                  children: [
                    CustomIconWidget(
                      iconName: 'category_outlined',
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      size: 48,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'No categories detected',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // AI Suggestions
              Text(
                'AI Suggestions',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 1.h),

              ...suggestions.map((suggestion) {
                final category = suggestion['category'] as String? ?? '';
                final categoryConfidence =
                    suggestion['confidence'] as double? ?? 0.0;
                final description = suggestion['description'] as String? ?? '';
                final isSelected = _selectedCategory == category;

                return Container(
                  margin: EdgeInsets.only(bottom: 1.h),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : theme.colorScheme.surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(category)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: CustomIconWidget(
                                  iconName: _getCategoryIcon(category),
                                  color: _getCategoryColor(category),
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category,
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : null,
                                      ),
                                    ),
                                    if (description.isNotEmpty) ...[
                                      SizedBox(height: 0.5.h),
                                      Text(
                                        description,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 2.w, vertical: 0.5.h),
                                    decoration: BoxDecoration(
                                      color: _getConfidenceColor(
                                              categoryConfidence)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${(categoryConfidence * 100).toInt()}%',
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        color: _getConfidenceColor(
                                            categoryConfidence),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    SizedBox(height: 0.5.h),
                                    CustomIconWidget(
                                      iconName: 'check_circle',
                                      color: theme.colorScheme.primary,
                                      size: 16,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              SizedBox(height: 2.h),

              // Manual Override Section
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'edit',
                          color: theme.colorScheme.secondary,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Manual Override',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Not satisfied with AI suggestions? You can manually set the document category.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showCategoryPicker(context),
                        icon: CustomIconWidget(
                          iconName: 'tune',
                          color: theme.colorScheme.secondary,
                          size: 16,
                        ),
                        label: const Text('Choose Category'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.secondary,
                          side: BorderSide(color: theme.colorScheme.secondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Current Selection Summary
              if (_selectedCategory != null) ...[
                SizedBox(height: 2.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'check_circle',
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected Category',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _selectedCategory!,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (manualOverride)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Manual',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'legal':
        return Colors.indigo;
      case 'financial':
        return Colors.green;
      case 'medical':
        return Colors.red;
      case 'technical':
        return Colors.blue;
      case 'academic':
        return Colors.purple;
      case 'business':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'legal':
        return 'gavel';
      case 'financial':
        return 'attach_money';
      case 'medical':
        return 'local_hospital';
      case 'technical':
        return 'engineering';
      case 'academic':
        return 'school';
      case 'business':
        return 'business';
      default:
        return 'description';
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return Colors.green;
    } else if (confidence >= 0.6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Widget _buildConfidenceIndicator(double confidence, ThemeData theme) {
    Color indicatorColor;
    String confidenceText;

    if (confidence >= 0.9) {
      indicatorColor = AppTheme.lightTheme.colorScheme.tertiary;
      confidenceText = 'High';
    } else if (confidence >= 0.7) {
      indicatorColor = Colors.orange;
      confidenceText = 'Medium';
    } else {
      indicatorColor = AppTheme.lightTheme.colorScheme.error;
      confidenceText = 'Low';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: indicatorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: indicatorColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: indicatorColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 1.w),
          Text(
            confidenceText,
            style: theme.textTheme.labelSmall?.copyWith(
              color: indicatorColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showHowItWorks(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How Category Classification Works'),
        content: const Text(
          'Our AI analyzes document content, structure, and language patterns to automatically classify documents into relevant categories. You can review AI suggestions and manually override the classification if needed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showCategoryPicker(BuildContext context) {
    final categories = [
      'Legal Document',
      'Financial Report',
      'Medical Record',
      'Technical Manual',
      'Academic Paper',
      'Business Contract',
      'Research Document',
      'Government Form',
      'Insurance Document',
      'Personal Document',
      'Other',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Document Category',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 2.h),
            ...categories.map((category) => ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(category).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: _getCategoryIcon(category),
                      color: _getCategoryColor(category),
                      size: 20,
                    ),
                  ),
                  title: Text(category),
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                    Navigator.of(context).pop();
                    widget.onCategoryOverride?.call(category);
                  },
                )),
          ],
        ),
      ),
    );
  }
}
