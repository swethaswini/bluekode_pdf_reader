import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Filter bottom sheet widget with collapsible sections
/// for date range, processing status, document type, and tags
class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final ValueChanged<Map<String, dynamic>> onFiltersChanged;

  const FilterBottomSheetWidget({
    super.key,
    required this.currentFilters,
    required this.onFiltersChanged,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, dynamic> _filters;
  final Map<String, bool> _expandedSections = {
    'dateRange': true,
    'status': true,
    'documentType': false,
    'tags': false,
  };

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
  }

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
            child: Row(
              children: [
                Text(
                  'Filter Documents',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: Text(
                    'Clear All',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter sections
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildDateRangeSection(context),
                  _buildStatusSection(context),
                  _buildDocumentTypeSection(context),
                  _buildTagsSection(context),
                ],
              ),
            ),
          ),

          // Apply button
          Container(
            padding: EdgeInsets.all(16.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                child: Text('Apply Filters'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSection(BuildContext context) {
    return _buildExpandableSection(
      context,
      title: 'Date Range',
      sectionKey: 'dateRange',
      child: Column(
        children: [
          _buildDateRangeOption('Today', 'today'),
          _buildDateRangeOption('This Week', 'thisWeek'),
          _buildDateRangeOption('This Month', 'thisMonth'),
          _buildDateRangeOption('Last 3 Months', 'last3Months'),
          _buildDateRangeOption('Custom Range', 'custom'),
        ],
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    return _buildExpandableSection(
      context,
      title: 'Processing Status',
      sectionKey: 'status',
      child: Column(
        children: [
          _buildStatusOption('Processed', 'processed'),
          _buildStatusOption('Processing', 'processing'),
          _buildStatusOption('Failed', 'failed'),
          _buildStatusOption('Needs Review', 'needsReview'),
        ],
      ),
    );
  }

  Widget _buildDocumentTypeSection(BuildContext context) {
    return _buildExpandableSection(
      context,
      title: 'Document Type',
      sectionKey: 'documentType',
      child: Column(
        children: [
          _buildDocumentTypeOption('Invoice', 'invoice'),
          _buildDocumentTypeOption('Receipt', 'receipt'),
          _buildDocumentTypeOption('Contract', 'contract'),
          _buildDocumentTypeOption('Report', 'report'),
          _buildDocumentTypeOption('Other', 'other'),
        ],
      ),
    );
  }

  Widget _buildTagsSection(BuildContext context) {
    final availableTags = [
      'Important',
      'Urgent',
      'Personal',
      'Business',
      'Tax',
      'Legal'
    ];

    return _buildExpandableSection(
      context,
      title: 'Tags',
      sectionKey: 'tags',
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: availableTags.map((tag) => _buildTagChip(tag)).toList(),
      ),
    );
  }

  Widget _buildExpandableSection(
    BuildContext context, {
    required String title,
    required String sectionKey,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isExpanded = _expandedSections[sectionKey] ?? false;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedSections[sectionKey] = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  CustomIconWidget(
                    iconName: isExpanded ? 'expand_less' : 'expand_more',
                    color: colorScheme.onSurfaceVariant,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: child,
            ),
        ],
      ),
    );
  }

  Widget _buildDateRangeOption(String title, String value) {
    final theme = Theme.of(context);
    final isSelected = _filters['dateRange'] == value;

    return RadioListTile<String>(
      title: Text(
        title,
        style: theme.textTheme.bodyMedium,
      ),
      value: value,
      groupValue: _filters['dateRange'] as String?,
      onChanged: (String? newValue) {
        setState(() {
          _filters['dateRange'] = newValue;
        });
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildStatusOption(String title, String value) {
    final theme = Theme.of(context);
    final selectedStatuses = (_filters['status'] as List<String>?) ?? [];
    final isSelected = selectedStatuses.contains(value);

    return CheckboxListTile(
      title: Text(
        title,
        style: theme.textTheme.bodyMedium,
      ),
      value: isSelected,
      onChanged: (bool? checked) {
        setState(() {
          final statuses = List<String>.from(selectedStatuses);
          if (checked == true) {
            statuses.add(value);
          } else {
            statuses.remove(value);
          }
          _filters['status'] = statuses;
        });
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDocumentTypeOption(String title, String value) {
    final theme = Theme.of(context);
    final selectedTypes = (_filters['documentType'] as List<String>?) ?? [];
    final isSelected = selectedTypes.contains(value);

    return CheckboxListTile(
      title: Text(
        title,
        style: theme.textTheme.bodyMedium,
      ),
      value: isSelected,
      onChanged: (bool? checked) {
        setState(() {
          final types = List<String>.from(selectedTypes);
          if (checked == true) {
            types.add(value);
          } else {
            types.remove(value);
          }
          _filters['documentType'] = types;
        });
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildTagChip(String tag) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedTags = (_filters['tags'] as List<String>?) ?? [];
    final isSelected = selectedTags.contains(tag);

    return FilterChip(
      label: Text(tag),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          final tags = List<String>.from(selectedTags);
          if (selected) {
            tags.add(tag);
          } else {
            tags.remove(tag);
          }
          _filters['tags'] = tags;
        });
      },
      selectedColor: colorScheme.primaryContainer,
      backgroundColor: colorScheme.surfaceContainerHighest,
    );
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
    });
  }

  void _applyFilters() {
    widget.onFiltersChanged(_filters);
    Navigator.of(context).pop();
  }
}
