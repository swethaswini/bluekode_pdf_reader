import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TrendVisualizationCardWidget extends StatefulWidget {
  final Map<String, dynamic> trendData;
  final Function(Map<String, dynamic>)? onChartTap;

  const TrendVisualizationCardWidget({
    super.key,
    required this.trendData,
    this.onChartTap,
  });

  @override
  State<TrendVisualizationCardWidget> createState() =>
      _TrendVisualizationCardWidgetState();
}

class _TrendVisualizationCardWidgetState
    extends State<TrendVisualizationCardWidget> {
  String _selectedChartType = 'bar';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final charts = (widget.trendData['charts'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    final confidence = widget.trendData['confidence'] as double? ?? 0.0;

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
                  iconName: 'trending_up',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Trend Visualization',
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
            if (charts.isEmpty) ...[
              Center(
                child: Column(
                  children: [
                    CustomIconWidget(
                      iconName: 'insert_chart_outlined',
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      size: 48,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'No trend data available',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Process more documents to see trends',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Chart Type Selector
              Container(
                height: 5.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildChartTypeButton(
                        'bar', 'Bar Chart', Icons.bar_chart, theme),
                    SizedBox(width: 2.w),
                    _buildChartTypeButton(
                        'line', 'Line Chart', Icons.show_chart, theme),
                    SizedBox(width: 2.w),
                    _buildChartTypeButton(
                        'pie', 'Pie Chart', Icons.pie_chart, theme),
                  ],
                ),
              ),
              SizedBox(height: 2.h),

              // Chart Container
              Container(
                height: 30.h,
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: _buildChart(theme),
              ),

              SizedBox(height: 2.h),

              // Chart Legend and Info
              _buildChartInfo(theme),

              SizedBox(height: 2.h),

              // Interaction Hints
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'touch_app',
                      color: theme.colorScheme.primary,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Tap chart for full-screen view with zoom and pan gestures',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
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

  Widget _buildChartTypeButton(
      String type, String label, IconData icon, ThemeData theme) {
    final isSelected = _selectedChartType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChartType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon.toString().split('.').last,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 16,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(ThemeData theme) {
    final charts = (widget.trendData['charts'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    if (charts.isEmpty) return const SizedBox.shrink();

    final chartData = charts.first;
    final data =
        (chartData['data'] as List? ?? []).cast<Map<String, dynamic>>();

    return GestureDetector(
      onTap: () => widget.onChartTap?.call(chartData),
      child: _selectedChartType == 'bar'
          ? _buildBarChart(data, theme)
          : _selectedChartType == 'line'
              ? _buildLineChart(data, theme)
              : _buildPieChart(data, theme),
    );
  }

  Widget _buildBarChart(List<Map<String, dynamic>> data, ThemeData theme) {
    if (data.isEmpty) return const Center(child: Text('No data available'));

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data
                .map((e) => (e['value'] as num? ?? 0).toDouble())
                .reduce((a, b) => a > b ? a : b) *
            1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: theme.colorScheme.surface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${data[group.x.toInt()]['label']}\n${rod.toY.toInt()}',
                theme.textTheme.bodySmall!,
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  final label = data[value.toInt()]['label'] as String? ?? '';
                  return Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: Text(
                      label.length > 8 ? '${label.substring(0, 8)}...' : label,
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: theme.textTheme.bodySmall,
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: (entry.value['value'] as num? ?? 0).toDouble(),
                color: theme.colorScheme.primary,
                width: 6.w,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLineChart(List<Map<String, dynamic>> data, ThemeData theme) {
    if (data.isEmpty) return const Center(child: Text('No data available'));

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  final label = data[value.toInt()]['label'] as String? ?? '';
                  return Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: Text(
                      label.length > 6 ? '${label.substring(0, 6)}...' : label,
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: theme.textTheme.bodySmall,
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                (entry.value['value'] as num? ?? 0).toDouble(),
              );
            }).toList(),
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: theme.colorScheme.primary,
                  strokeWidth: 2,
                  strokeColor: theme.colorScheme.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: theme.colorScheme.surface,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index >= 0 && index < data.length) {
                  return LineTooltipItem(
                    '${data[index]['label']}\n${spot.y.toInt()}',
                    theme.textTheme.bodySmall!,
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(List<Map<String, dynamic>> data, ThemeData theme) {
    if (data.isEmpty) return const Center(child: Text('No data available'));

    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    return PieChart(
      PieChartData(
        sections: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final value = (item['value'] as num? ?? 0).toDouble();
          final label = item['label'] as String? ?? '';

          return PieChartSectionData(
            color: colors[index % colors.length],
            value: value,
            title: '${value.toInt()}',
            radius: 15.w,
            titleStyle: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 8.w,
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            // Handle touch events for pie chart
          },
        ),
      ),
    );
  }

  Widget _buildChartInfo(ThemeData theme) {
    final charts = (widget.trendData['charts'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    if (charts.isEmpty) return const SizedBox.shrink();

    final chartData = charts.first;
    final data =
        (chartData['data'] as List? ?? []).cast<Map<String, dynamic>>();
    final title = chartData['title'] as String? ?? 'Trend Analysis';
    final description = chartData['description'] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        if (description.isNotEmpty) ...[
          SizedBox(height: 0.5.h),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
        SizedBox(height: 1.h),

        // Data Summary
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Data Points', '${data.length}', theme),
              _buildStatItem(
                  'Max Value',
                  '${data.map((e) => (e['value'] as num? ?? 0)).reduce((a, b) => a > b ? a : b)}',
                  theme),
              _buildStatItem(
                  'Avg Value',
                  '${(data.map((e) => (e['value'] as num? ?? 0)).reduce((a, b) => a + b) / data.length).toInt()}',
                  theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
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
        title: const Text('How Trend Visualization Works'),
        content: const Text(
          'Our AI extracts numerical data from your documents and creates interactive charts to visualize trends and patterns. You can switch between different chart types and interact with the data for deeper insights.',
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