import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SentimentAnalysisCardWidget extends StatelessWidget {
  final Map<String, dynamic> sentimentData;
  final Function(String)? onHighlightTap;

  const SentimentAnalysisCardWidget({
    super.key,
    required this.sentimentData,
    this.onHighlightTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overallSentiment = sentimentData['overall'] as String? ?? 'neutral';
    final confidence = sentimentData['confidence'] as double? ?? 0.0;
    final highlights = (sentimentData['highlights'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    final breakdown = sentimentData['breakdown'] as Map<String, dynamic>? ?? {};

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
                  iconName: 'sentiment_satisfied',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Sentiment Analysis',
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

            // Overall Sentiment
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color:
                    _getSentimentColor(overallSentiment).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getSentimentColor(overallSentiment)
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: _getSentimentIcon(overallSentiment),
                        color: _getSentimentColor(overallSentiment),
                        size: 32,
                      ),
                      SizedBox(width: 3.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Overall Tone',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                          Text(
                            _getSentimentLabel(overallSentiment),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _getSentimentColor(overallSentiment),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),

                  // Confidence Meter
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Confidence',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                          Text(
                            '${(confidence * 100).toInt()}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _getSentimentColor(overallSentiment),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.5.h),
                      LinearProgressIndicator(
                        value: confidence,
                        backgroundColor:
                            theme.colorScheme.outline.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getSentimentColor(overallSentiment),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Sentiment Breakdown
            if (breakdown.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Text(
                'Sentiment Breakdown',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  Expanded(
                    child: _buildSentimentBar(
                        'Positive',
                        breakdown['positive'] as double? ?? 0.0,
                        Colors.green,
                        theme),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: _buildSentimentBar(
                        'Neutral',
                        breakdown['neutral'] as double? ?? 0.0,
                        Colors.grey,
                        theme),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: _buildSentimentBar(
                        'Negative',
                        breakdown['negative'] as double? ?? 0.0,
                        Colors.red,
                        theme),
                  ),
                ],
              ),
            ],

            // Highlighted Text Spans
            if (highlights.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Text(
                'Supporting Evidence',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 1.h),
              ...highlights
                  .take(3)
                  .map((highlight) => _buildHighlightItem(highlight, theme)),
              if (highlights.length > 3) ...[
                SizedBox(height: 1.h),
                GestureDetector(
                  onTap: () => _showAllHighlights(context, highlights),
                  child: Text(
                    'View all ${highlights.length} highlights',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSentimentBar(
      String label, double value, Color color, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        LinearProgressIndicator(
          value: value,
          backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildHighlightItem(Map<String, dynamic> highlight, ThemeData theme) {
    final text = highlight['text'] as String? ?? '';
    final sentiment = highlight['sentiment'] as String? ?? 'neutral';
    final confidence = highlight['confidence'] as double? ?? 0.0;

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      child: GestureDetector(
        onTap: () => onHighlightTap?.call(text),
        child: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: _getSentimentColor(sentiment).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getSentimentColor(sentiment).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: _getSentimentIcon(sentiment),
                    color: _getSentimentColor(sentiment),
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    _getSentimentLabel(sentiment),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _getSentimentColor(sentiment),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(confidence * 100).toInt()}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _getSentimentColor(sentiment),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.5.h),
              Text(
                text,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSentimentColor(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return Colors.green;
      case 'negative':
        return Colors.red;
      case 'neutral':
      default:
        return Colors.grey;
    }
  }

  String _getSentimentIcon(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return 'sentiment_very_satisfied';
      case 'negative':
        return 'sentiment_very_dissatisfied';
      case 'neutral':
      default:
        return 'sentiment_neutral';
    }
  }

  String _getSentimentLabel(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return 'Positive';
      case 'negative':
        return 'Negative';
      case 'neutral':
      default:
        return 'Neutral';
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
        title: const Text('How Sentiment Analysis Works'),
        content: const Text(
          'Our AI analyzes the emotional tone and sentiment expressed in your document text. It identifies positive, negative, and neutral sentiments with confidence scores and highlights supporting text passages.',
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

  void _showAllHighlights(
      BuildContext context, List<Map<String, dynamic>> highlights) {
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
              Text(
                'All Sentiment Highlights',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: highlights.length,
                  itemBuilder: (context, index) {
                    final highlight = highlights[index];
                    return _buildHighlightItem(highlight, Theme.of(context));
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
