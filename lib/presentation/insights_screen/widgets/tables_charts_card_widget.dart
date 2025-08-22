import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TablesChartsCardWidget extends StatelessWidget {
  final Map<String, dynamic> tablesChartsData;
  final Function(Map<String, dynamic>)? onTableTap;
  final Function(Map<String, dynamic>)? onChartTap;

  const TablesChartsCardWidget({
    super.key,
    required this.tablesChartsData,
    this.onTableTap,
    this.onChartTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tables = (tablesChartsData['tables'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    final charts = (tablesChartsData['charts'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    final confidence = tablesChartsData['confidence'] as double? ?? 0.0;

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
                  iconName: 'table_chart',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Tables & Charts',
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
            if (tables.isEmpty && charts.isEmpty) ...[
              Center(
                child: Column(
                  children: [
                    CustomIconWidget(
                      iconName: 'table_view_outlined',
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      size: 48,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'No tables or charts detected',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Tables Section
              if (tables.isNotEmpty) ...[
                _buildSectionHeader(
                    'Tables', tables.length, Icons.table_rows, theme),
                SizedBox(height: 1.h),
                SizedBox(
                  height: 20.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: tables.length,
                    itemBuilder: (context, index) {
                      final table = tables[index];
                      return _buildTablePreview(table, context);
                    },
                  ),
                ),
                if (charts.isNotEmpty) SizedBox(height: 2.h),
              ],

              // Charts Section
              if (charts.isNotEmpty) ...[
                _buildSectionHeader(
                    'Charts', charts.length, Icons.bar_chart, theme),
                SizedBox(height: 1.h),
                SizedBox(
                  height: 20.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: charts.length,
                    itemBuilder: (context, index) {
                      final chart = charts[index];
                      return _buildChartPreview(chart, context);
                    },
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      String title, int count, IconData icon, ThemeData theme) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: icon.toString().split('.').last,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        SizedBox(width: 2.w),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(width: 2.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTablePreview(Map<String, dynamic> table, BuildContext context) {
    final theme = Theme.of(context);
    final title = table['title'] as String? ?? 'Table ${table['id'] ?? ''}';
    final rows = table['rows'] as int? ?? 0;
    final columns = table['columns'] as int? ?? 0;
    final preview = (table['preview'] as List? ?? []).cast<List<String>>();

    return Container(
      width: 70.w,
      margin: EdgeInsets.only(right: 3.w),
      child: GestureDetector(
        onTap: () => onTableTap?.call(table),
        child: Container(
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
              // Table Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${rows}x$columns',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),

              // Table Preview
              Expanded(
                child: preview.isNotEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          children: preview
                              .take(3)
                              .map((row) => Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 2.w, vertical: 0.5.h),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: theme.colorScheme.outline
                                              .withValues(alpha: 0.2),
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: row
                                          .take(3)
                                          .map((cell) => Expanded(
                                                child: Text(
                                                  cell,
                                                  style:
                                                      theme.textTheme.bodySmall,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  ))
                              .toList(),
                        ),
                      )
                    : Center(
                        child: CustomIconWidget(
                          iconName: 'table_view',
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                          size: 32,
                        ),
                      ),
              ),

              SizedBox(height: 1.h),
              // Export Options
              Row(
                children: [
                  _buildExportButton('CSV', Icons.file_download, theme),
                  SizedBox(width: 2.w),
                  _buildExportButton('JSON', Icons.code, theme),
                  const Spacer(),
                  CustomIconWidget(
                    iconName: 'open_in_full',
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartPreview(Map<String, dynamic> chart, BuildContext context) {
    final theme = Theme.of(context);
    final title = chart['title'] as String? ?? 'Chart ${chart['id'] ?? ''}';
    final type = chart['type'] as String? ?? 'bar';
    final dataPoints = chart['dataPoints'] as int? ?? 0;

    return Container(
      width: 70.w,
      margin: EdgeInsets.only(right: 3.w),
      child: GestureDetector(
        onTap: () => onChartTap?.call(chart),
        child: Container(
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
              // Chart Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      type.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),

              // Chart Preview
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: _getChartIcon(type),
                          color: theme.colorScheme.primary,
                          size: 32,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '$dataPoints data points',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 1.h),
              // View Options
              Row(
                children: [
                  Text(
                    'Tap to view full chart',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  CustomIconWidget(
                    iconName: 'zoom_out_map',
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportButton(String label, IconData icon, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: icon.toString().split('.').last,
            color: theme.colorScheme.primary,
            size: 12,
          ),
          SizedBox(width: 1.w),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getChartIcon(String type) {
    switch (type.toLowerCase()) {
      case 'bar':
        return 'bar_chart';
      case 'line':
        return 'show_chart';
      case 'pie':
        return 'pie_chart';
      case 'scatter':
        return 'scatter_plot';
      default:
        return 'insert_chart';
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
        title: const Text('How Tables & Charts Work'),
        content: const Text(
          'Our AI detects and extracts structured data from tables and charts in your documents. You can view full-screen versions, export data in various formats, and interact with the content for better analysis.',
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
}
