import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SummaryCardWidget extends StatefulWidget {
  final Map<String, dynamic> summaryData;
  final VoidCallback? onExpand;

  const SummaryCardWidget({
    super.key,
    required this.summaryData,
    this.onExpand,
  });

  @override
  State<SummaryCardWidget> createState() => _SummaryCardWidgetState();
}

class _SummaryCardWidgetState extends State<SummaryCardWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyPoints =
        (widget.summaryData['keyPoints'] as List? ?? []).cast<String>();
    final fullSummary = widget.summaryData['fullSummary'] as String? ?? '';
    final confidence = widget.summaryData['confidence'] as double? ?? 0.0;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with confidence indicator
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'summarize',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Document Summary',
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

            // Key Points
            if (keyPoints.isNotEmpty) ...[
              Text(
                'Key Points:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 1.h),
              ...keyPoints.take(3).map((point) => Padding(
                    padding: EdgeInsets.only(bottom: 0.5.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: EdgeInsets.only(top: 0.8.h, right: 2.w),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            point,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )),
              SizedBox(height: 2.h),
            ],

            // Expandable Full Summary
            if (fullSummary.isNotEmpty) ...[
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                  widget.onExpand?.call();
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Full Summary',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          CustomIconWidget(
                            iconName:
                                _isExpanded ? 'expand_less' : 'expand_more',
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                        ],
                      ),
                      if (_isExpanded) ...[
                        SizedBox(height: 1.h),
                        Text(
                          fullSummary,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ] else ...[
                        SizedBox(height: 0.5.h),
                        Text(
                          '${fullSummary.substring(0, fullSummary.length > 100 ? 100 : fullSummary.length)}${fullSummary.length > 100 ? '...' : ''}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
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
        title: const Text('How Document Summary Works'),
        content: const Text(
          'Our AI analyzes your document content to extract key information and generate comprehensive summaries. The system identifies main topics, important details, and creates structured overviews to help you quickly understand document contents.',
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
