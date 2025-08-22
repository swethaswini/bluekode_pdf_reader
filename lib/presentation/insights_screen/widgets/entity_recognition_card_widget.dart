import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EntityRecognitionCardWidget extends StatelessWidget {
  final Map<String, dynamic> entityData;
  final Function(String, String)? onEntityTap;

  const EntityRecognitionCardWidget({
    super.key,
    required this.entityData,
    this.onEntityTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entities = entityData['entities'] as Map<String, dynamic>? ?? {};
    final confidence = entityData['confidence'] as double? ?? 0.0;

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
                  iconName: 'label',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Entity Recognition',
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

            // Entity Categories
            if (entities.isNotEmpty) ...[
              _buildEntityCategory('People', entities['people'] as List? ?? [],
                  Colors.blue, context),
              SizedBox(height: 1.5.h),
              _buildEntityCategory(
                  'Organizations',
                  entities['organizations'] as List? ?? [],
                  Colors.green,
                  context),
              SizedBox(height: 1.5.h),
              _buildEntityCategory('Locations',
                  entities['locations'] as List? ?? [], Colors.orange, context),
              SizedBox(height: 1.5.h),
              _buildEntityCategory('Dates', entities['dates'] as List? ?? [],
                  Colors.purple, context),
            ] else ...[
              Center(
                child: Column(
                  children: [
                    CustomIconWidget(
                      iconName: 'search_off',
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      size: 48,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'No entities detected',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEntityCategory(
      String category, List<dynamic> items, Color color, BuildContext context) {
    final theme = Theme.of(context);

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              category,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            SizedBox(width: 2.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${items.length}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: items.take(6).map((item) {
            final entityText =
                item is Map ? (item['text'] as String? ?? '') : item.toString();
            final confidence =
                item is Map ? (item['confidence'] as double? ?? 0.0) : 0.0;

            return GestureDetector(
              onTap: () =>
                  onEntityTap?.call(category.toLowerCase(), entityText),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        entityText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (confidence > 0) ...[
                      SizedBox(width: 1.w),
                      CustomIconWidget(
                        iconName: 'search',
                        color: color.withValues(alpha: 0.7),
                        size: 14,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (items.length > 6) ...[
          SizedBox(height: 1.h),
          GestureDetector(
            onTap: () => _showAllEntities(context, category, items, color),
            child: Text(
              'View all ${items.length} ${category.toLowerCase()}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
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
        title: const Text('How Entity Recognition Works'),
        content: const Text(
          'Our AI identifies and extracts important entities from your documents including people, organizations, locations, and dates. Each entity is color-coded by type and can be tapped to search for related content.',
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

  void _showAllEntities(
      BuildContext context, String category, List<dynamic> items, Color color) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'All $category',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final entityText = item is Map
                        ? (item['text'] as String? ?? '')
                        : item.toString();
                    final confidence = item is Map
                        ? (item['confidence'] as double? ?? 0.0)
                        : 0.0;

                    return ListTile(
                      leading: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(entityText),
                      trailing: confidence > 0
                          ? Text(
                              '${(confidence * 100).toInt()}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: color,
                                  ),
                            )
                          : null,
                      onTap: () {
                        Navigator.of(context).pop();
                        onEntityTap?.call(category.toLowerCase(), entityText);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
