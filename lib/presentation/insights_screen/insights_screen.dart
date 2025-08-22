import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/category_classification_card_widget.dart';
import './widgets/entity_recognition_card_widget.dart';
import './widgets/sentiment_analysis_card_widget.dart';
import './widgets/summary_card_widget.dart';
import './widgets/tables_charts_card_widget.dart';
import './widgets/trend_visualization_card_widget.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDocument = 'All Documents';
  String _selectedDateRange = 'Last 30 days';
  bool _isLoading = false;
  bool _isRefreshing = false;

  // Mock data for insights
  final List<Map<String, dynamic>> _mockInsightsData = [
    {
      "id": 1,
      "type": "summary",
      "data": {
        "keyPoints": [
          "Document contains 15 financial transactions totaling \$45,230",
          "Three main parties identified: ABC Corp, XYZ Ltd, and John Smith",
          "Contract period spans from January 2024 to December 2024",
          "Payment terms specify net 30 days with 2% early payment discount"
        ],
        "fullSummary":
            "This comprehensive financial agreement outlines the terms and conditions for a year-long business partnership between ABC Corp and XYZ Ltd, with John Smith serving as the intermediary. The document establishes clear payment schedules, delivery milestones, and performance metrics. Key financial commitments include quarterly payments of \$11,307.50, with provisions for early payment discounts and late payment penalties. The agreement also covers intellectual property rights, confidentiality clauses, and dispute resolution procedures.",
        "confidence": 0.92
      }
    },
    {
      "id": 2,
      "type": "entities",
      "data": {
        "entities": {
          "people": [
            {"text": "John Smith", "confidence": 0.95},
            {"text": "Sarah Johnson", "confidence": 0.88},
            {"text": "Michael Brown", "confidence": 0.91}
          ],
          "organizations": [
            {"text": "ABC Corporation", "confidence": 0.97},
            {"text": "XYZ Limited", "confidence": 0.93},
            {"text": "Global Tech Solutions", "confidence": 0.89}
          ],
          "locations": [
            {"text": "New York", "confidence": 0.96},
            {"text": "San Francisco", "confidence": 0.92},
            {"text": "London", "confidence": 0.87}
          ],
          "dates": [
            {"text": "January 15, 2024", "confidence": 0.98},
            {"text": "March 30, 2024", "confidence": 0.94},
            {"text": "December 31, 2024", "confidence": 0.96}
          ]
        },
        "confidence": 0.89
      }
    },
    {
      "id": 3,
      "type": "tables_charts",
      "data": {
        "tables": [
          {
            "id": 1,
            "title": "Quarterly Revenue Breakdown",
            "rows": 5,
            "columns": 4,
            "preview": [
              ["Quarter", "Revenue", "Expenses", "Profit"],
              ["Q1 2024", "\$125,000", "\$85,000", "\$40,000"],
              ["Q2 2024", "\$138,000", "\$92,000", "\$46,000"]
            ]
          },
          {
            "id": 2,
            "title": "Employee Performance Metrics",
            "rows": 8,
            "columns": 6,
            "preview": [
              ["Name", "Department", "Score", "Rating"],
              ["John Doe", "Sales", "92", "Excellent"],
              ["Jane Smith", "Marketing", "88", "Good"]
            ]
          }
        ],
        "charts": [
          {
            "id": 1,
            "title": "Monthly Sales Trend",
            "type": "line",
            "dataPoints": 12
          },
          {
            "id": 2,
            "title": "Department Budget Distribution",
            "type": "pie",
            "dataPoints": 6
          }
        ],
        "confidence": 0.85
      }
    },
    {
      "id": 4,
      "type": "sentiment",
      "data": {
        "overall": "positive",
        "confidence": 0.87,
        "breakdown": {"positive": 0.65, "neutral": 0.25, "negative": 0.10},
        "highlights": [
          {
            "text":
                "We are pleased to announce the successful completion of the project ahead of schedule.",
            "sentiment": "positive",
            "confidence": 0.94
          },
          {
            "text":
                "The team demonstrated exceptional performance and dedication throughout the engagement.",
            "sentiment": "positive",
            "confidence": 0.91
          },
          {
            "text":
                "Some minor delays were encountered due to external factors beyond our control.",
            "sentiment": "negative",
            "confidence": 0.78
          }
        ]
      }
    },
    {
      "id": 5,
      "type": "category",
      "data": {
        "suggestions": [
          {
            "category": "Financial Report",
            "confidence": 0.92,
            "description":
                "Contains financial data, revenue figures, and budget information"
          },
          {
            "category": "Business Contract",
            "confidence": 0.78,
            "description":
                "Includes contractual terms, agreements, and legal clauses"
          },
          {
            "category": "Performance Review",
            "confidence": 0.65,
            "description": "Contains employee metrics and evaluation criteria"
          }
        ],
        "confidence": 0.92,
        "manualOverride": false
      }
    },
    {
      "id": 6,
      "type": "trends",
      "data": {
        "charts": [
          {
            "id": 1,
            "title": "Document Processing Volume",
            "description":
                "Monthly document processing trends over the last 6 months",
            "type": "bar",
            "data": [
              {"label": "Jul", "value": 45},
              {"label": "Aug", "value": 52},
              {"label": "Sep", "value": 38},
              {"label": "Oct", "value": 67},
              {"label": "Nov", "value": 73},
              {"label": "Dec", "value": 89}
            ]
          }
        ],
        "confidence": 0.88
      }
    }
  ];

  final List<String> _documentOptions = [
    'All Documents',
    'Financial_Report_Q4.pdf',
    'Contract_ABC_Corp.pdf',
    'Meeting_Notes_Dec.pdf',
    'Invoice_12345.pdf',
    'Legal_Agreement.pdf'
  ];

  final List<String> _dateRangeOptions = [
    'Last 7 days',
    'Last 30 days',
    'Last 3 months',
    'Last 6 months',
    'Last year',
    'Custom range'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _loadInsights();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInsights() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate AI processing time
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshInsights() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate refresh with updated AI models
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Insights'),
        elevation: 1,
        backgroundColor: theme.cardColor,
        actions: [
          IconButton(
            onPressed: _refreshInsights,
            icon: _isRefreshing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary),
                    ),
                  )
                : CustomIconWidget(
                    iconName: 'refresh',
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
            tooltip: 'Refresh insights',
          ),
          IconButton(
            onPressed: () => _showFilterOptions(context),
            icon: CustomIconWidget(
              iconName: 'filter_list',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            tooltip: 'Filter insights',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Insights'),
          ],
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor:
              theme.colorScheme.onSurface.withValues(alpha: 0.6),
          indicatorColor: theme.colorScheme.primary,
        ),
      ),
      body: Column(
        children: [
          // Sticky Header with Filters
          Container(
            color: theme.cardColor,
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                // Document Selector
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'description',
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showDocumentSelector(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: theme.colorScheme.outline
                                    .withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedDocument,
                                  style: theme.textTheme.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              CustomIconWidget(
                                iconName: 'arrow_drop_down',
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),

                // Date Range Filter
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'date_range',
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showDateRangeSelector(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: theme.colorScheme.outline
                                    .withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedDateRange,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              CustomIconWidget(
                                iconName: 'arrow_drop_down',
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInsightsTab(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsTab(ThemeData theme) {
    if (_isLoading) {
      return _buildLoadingState(theme);
    }

    if (_mockInsightsData.isEmpty) {
      return _buildEmptyState(theme);
    }

    return RefreshIndicator(
      onRefresh: _refreshInsights,
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        children: [
          // Summary Card
          SummaryCardWidget(
            summaryData: _mockInsightsData
                .firstWhere((item) => item['type'] == 'summary')['data'],
            onExpand: () {
              // Handle expand action
            },
          ),

          // Entity Recognition Card
          EntityRecognitionCardWidget(
            entityData: _mockInsightsData
                .firstWhere((item) => item['type'] == 'entities')['data'],
            onEntityTap: (category, entity) {
              _handleEntitySearch(category, entity);
            },
          ),

          // Tables & Charts Card
          TablesChartsCardWidget(
            tablesChartsData: _mockInsightsData
                .firstWhere((item) => item['type'] == 'tables_charts')['data'],
            onTableTap: (table) {
              _showFullScreenTable(context, table);
            },
            onChartTap: (chart) {
              _showFullScreenChart(context, chart);
            },
          ),

          // Sentiment Analysis Card
          SentimentAnalysisCardWidget(
            sentimentData: _mockInsightsData
                .firstWhere((item) => item['type'] == 'sentiment')['data'],
            onHighlightTap: (text) {
              _navigateToHighlightedText(text);
            },
          ),

          // Category Classification Card
          CategoryClassificationCardWidget(
            categoryData: _mockInsightsData
                .firstWhere((item) => item['type'] == 'category')['data'],
            onCategoryOverride: (category) {
              _handleCategoryOverride(category);
            },
          ),

          // Trend Visualization Card
          TrendVisualizationCardWidget(
            trendData: _mockInsightsData
                .firstWhere((item) => item['type'] == 'trends')['data'],
            onChartTap: (chart) {
              _showFullScreenChart(context, chart);
            },
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 15.w,
            height: 15.w,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor:
                  AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Analyzing Documents...',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Our AI is processing your documents to generate insights',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'insights',
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              size: 80,
            ),
            SizedBox(height: 3.h),
            Text(
              'No Insights Available',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Process documents to generate AI-powered insights including summaries, entity recognition, sentiment analysis, and trend visualization.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/import-scan-screen');
                },
                icon: CustomIconWidget(
                  iconName: 'add_circle',
                  color: theme.colorScheme.onPrimary,
                  size: 20,
                ),
                label: const Text('Process Documents for Insights'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDocumentSelector(BuildContext context) {
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
              'Select Document',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 2.h),
            ..._documentOptions.map((document) => ListTile(
                  leading: CustomIconWidget(
                    iconName:
                        document == 'All Documents' ? 'folder' : 'description',
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  title: Text(document),
                  trailing: _selectedDocument == document
                      ? CustomIconWidget(
                          iconName: 'check',
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedDocument = document;
                    });
                    Navigator.of(context).pop();
                    _loadInsights();
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showDateRangeSelector(BuildContext context) {
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
              'Select Date Range',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 2.h),
            ..._dateRangeOptions.map((range) => ListTile(
                  leading: CustomIconWidget(
                    iconName: 'date_range',
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  title: Text(range),
                  trailing: _selectedDateRange == range
                      ? CustomIconWidget(
                          iconName: 'check',
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedDateRange = range;
                    });
                    Navigator.of(context).pop();
                    _loadInsights();
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
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
              'Filter Options',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'high_quality',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('High Confidence Only'),
              subtitle: const Text('Show insights with 90%+ confidence'),
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  // Handle filter change
                },
              ),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'category',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('Filter by Category'),
              subtitle: const Text('Show specific insight types'),
              onTap: () {
                // Show category filter
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'sort',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('Sort by Confidence'),
              subtitle: const Text('Order insights by accuracy'),
              onTap: () {
                // Handle sort
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleEntitySearch(String category, String entity) {
    // Navigate to search with entity filter
    Navigator.pushNamed(context, '/library-screen');
  }

  void _showFullScreenTable(BuildContext context, Map<String, dynamic> table) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: Text(table['title'] as String? ?? 'Table'),
            actions: [
              IconButton(
                onPressed: () {
                  // Export as CSV
                },
                icon: CustomIconWidget(
                  iconName: 'file_download',
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 24,
                ),
                tooltip: 'Export CSV',
              ),
            ],
          ),
          body: const Center(
            child: Text('Full-screen table view would be implemented here'),
          ),
        ),
      ),
    );
  }

  void _showFullScreenChart(BuildContext context, Map<String, dynamic> chart) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: Text(chart['title'] as String? ?? 'Chart'),
            actions: [
              IconButton(
                onPressed: () {
                  // Export chart
                },
                icon: CustomIconWidget(
                  iconName: 'share',
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 24,
                ),
                tooltip: 'Share',
              ),
            ],
          ),
          body: const Center(
            child: Text(
                'Full-screen chart view with zoom and pan would be implemented here'),
          ),
        ),
      ),
    );
  }

  void _navigateToHighlightedText(String text) {
    // Navigate to document viewer with highlighted text
    Navigator.pushNamed(context, '/document-viewer-screen');
  }

  void _handleCategoryOverride(String category) {
    // Handle manual category override
    setState(() {
      // Update category data
    });
  }
}
