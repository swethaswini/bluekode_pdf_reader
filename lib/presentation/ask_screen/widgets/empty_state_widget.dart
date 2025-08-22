import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final Function(String) onExampleTap;

  const EmptyStateWidget({
    super.key,
    required this.onExampleTap,
  });

  @override
  Widget build(BuildContext context) {
    final exampleQuestions = [
      'What are the key findings in this report?',
      'Summarize the main points of this document',
      'Find all the dates mentioned in the text',
      'Extract contact information from this document',
      'What are the financial figures mentioned?',
      'List all action items or tasks mentioned',
    ];

    return Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 8.h),
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.w),
              ),
              child: CustomIconWidget(
                iconName: 'chat',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 10.w,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Ask AI about your documents',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'Get instant answers, summaries, and insights from your PDF documents using natural language questions.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(3.w),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'lightbulb',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Example questions to get started:',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  ...exampleQuestions
                      .map((question) => _buildExampleQuestion(question)),
                ],
              ),
            ),
            SizedBox(height: 4.h),
            _buildFeatureHighlights(),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleQuestion(String question) {
    return GestureDetector(
      onTap: () => onExampleTap(question),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 1.h),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color:
              AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(2.w),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'chat_bubble_outline',
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.7),
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                question,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
            ),
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.5),
              size: 3.w,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureHighlights() {
    final features = [
      {
        'icon': 'search',
        'title': 'Smart Search',
        'description': 'Find specific information across all your documents',
      },
      {
        'icon': 'summarize',
        'title': 'Auto Summarize',
        'description': 'Get quick summaries of lengthy documents',
      },
      {
        'icon': 'psychology',
        'title': 'AI Insights',
        'description': 'Discover patterns and extract key insights',
      },
    ];

    return Column(
      children: [
        Text(
          'Powerful AI Features',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        ...features.map((feature) => Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 2.h),
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(2.w),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(5.w),
                    ),
                    child: CustomIconWidget(
                      iconName: feature['icon'] as String,
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 5.w,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature['title'] as String,
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          feature['description'] as String,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
