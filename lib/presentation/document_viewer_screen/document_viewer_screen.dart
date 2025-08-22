import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/document_page_widget.dart';
import './widgets/document_search_widget.dart';
import './widgets/document_toolbar_widget.dart';
import './widgets/page_indicator_widget.dart';
import './widgets/view_mode_selector_widget.dart';

/// Document Viewer Screen with dual-mode PDF viewing and OCR text overlay
class DocumentViewerScreen extends StatefulWidget {
  const DocumentViewerScreen({super.key});

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  // Document data
  int _currentPage = 1;
  bool _isTextMode = false;
  bool _isSearchVisible = false;
  bool _isProcessing = false;
  List<int> _searchResults = [];
  int _currentSearchIndex = -1;

  // Mock document data
  final List<Map<String, dynamic>> _documentPages = [
    {
      "pageNumber": 1,
      "imageUrl":
          "https://images.pexels.com/photos/4386321/pexels-photo-4386321.jpeg?auto=compress&cs=tinysrgb&w=800",
      "ocrText":
          "QUARTERLY BUSINESS REPORT\n\nExecutive Summary\n\nThis quarter has shown remarkable growth in our digital transformation initiatives. Our revenue increased by 23% compared to the previous quarter, driven primarily by our new cloud-based solutions and enhanced customer engagement strategies.\n\nKey Performance Indicators:\n• Revenue Growth: 23%\n• Customer Satisfaction: 94%\n• Market Share: 18%\n• Employee Retention: 89%\n\nThe implementation of AI-driven analytics has significantly improved our decision-making processes and operational efficiency.",
      "confidenceData": {
        "QUARTERLY": 0.98,
        "BUSINESS": 0.97,
        "REPORT": 0.99,
        "Executive": 0.95,
        "Summary": 0.96,
        "quarter": 0.92,
        "growth": 0.88,
        "digital": 0.94,
        "transformation": 0.91,
        "initiatives": 0.87,
        "revenue": 0.96,
        "increased": 0.93,
        "compared": 0.89,
        "previous": 0.85,
        "driven": 0.90,
        "cloud-based": 0.82,
        "solutions": 0.94,
        "customer": 0.97,
        "engagement": 0.88,
        "strategies": 0.86,
      }
    },
    {
      "pageNumber": 2,
      "imageUrl":
          "https://images.pexels.com/photos/590016/pexels-photo-590016.jpg?auto=compress&cs=tinysrgb&w=800",
      "ocrText":
          "FINANCIAL ANALYSIS\n\nRevenue Breakdown by Department:\n\n1. Sales Department: \$2.4M (40%)\n2. Marketing Department: \$1.8M (30%)\n3. Product Development: \$1.2M (20%)\n4. Customer Support: \$0.6M (10%)\n\nExpense Categories:\n• Personnel Costs: \$3.2M\n• Technology Infrastructure: \$1.1M\n• Marketing & Advertising: \$0.8M\n• Office Operations: \$0.5M\n• Research & Development: \$0.4M\n\nNet Profit Margin: 15.2%\nOperating Cash Flow: \$1.8M\nReturn on Investment: 22.5%",
      "confidenceData": {
        "FINANCIAL": 0.99,
        "ANALYSIS": 0.98,
        "Revenue": 0.97,
        "Breakdown": 0.94,
        "Department": 0.96,
        "Sales": 0.98,
        "Marketing": 0.97,
        "Product": 0.95,
        "Development": 0.93,
        "Customer": 0.97,
        "Support": 0.95,
        "Expense": 0.96,
        "Categories": 0.94,
        "Personnel": 0.91,
        "Costs": 0.95,
        "Technology": 0.93,
        "Infrastructure": 0.89,
        "Advertising": 0.92,
        "Office": 0.96,
        "Operations": 0.94,
        "Research": 0.95,
      }
    },
    {
      "pageNumber": 3,
      "imageUrl":
          "https://images.pexels.com/photos/590022/pexels-photo-590022.jpg?auto=compress&cs=tinysrgb&w=800",
      "ocrText":
          "MARKET TRENDS & PROJECTIONS\n\nIndustry Analysis:\nThe digital services market continues to expand rapidly, with an estimated growth rate of 12% annually. Our competitive positioning remains strong due to our innovative approach and customer-centric solutions.\n\nFuture Projections (Next 12 Months):\n• Expected Revenue Growth: 28-32%\n• New Market Penetration: 3 regions\n• Product Line Expansion: 2 new offerings\n• Team Growth: 45 new hires\n\nRisk Assessment:\n• Market volatility: Medium risk\n• Competition intensity: High risk\n• Technology disruption: Low risk\n• Regulatory changes: Medium risk\n\nRecommendations:\n1. Increase investment in R&D by 15%\n2. Expand sales team in target markets\n3. Strengthen partnerships with key vendors\n4. Implement advanced cybersecurity measures",
      "confidenceData": {
        "MARKET": 0.98,
        "TRENDS": 0.96,
        "PROJECTIONS": 0.94,
        "Industry": 0.97,
        "Analysis": 0.98,
        "digital": 0.95,
        "services": 0.96,
        "market": 0.97,
        "continues": 0.92,
        "expand": 0.94,
        "rapidly": 0.89,
        "estimated": 0.91,
        "growth": 0.95,
        "rate": 0.96,
        "annually": 0.88,
        "competitive": 0.93,
        "positioning": 0.87,
        "remains": 0.90,
        "strong": 0.95,
        "innovative": 0.91,
        "approach": 0.93,
        "customer-centric": 0.85,
        "solutions": 0.96,
      }
    },
  ];

  String get _documentTitle => "Q3 Business Report.pdf";
  int get _totalPages => _documentPages.length;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              ViewModeSelectorWidget(
                isTextMode: _isTextMode,
                onModeChanged: _handleModeChange,
              ),
              Expanded(
                child: _buildDocumentViewer(),
              ),
              _buildPageIndicator(),
            ],
          ),
          if (_isSearchVisible) _buildSearchOverlay(),
          _buildFloatingActionButton(),
        ],
      ),
      bottomNavigationBar: DocumentToolbarWidget(
        onShare: _handleShare,
        onExport: _handleExport,
        onSearch: _toggleSearch,
        onInsights: _navigateToInsights,
        onReprocess: _handleReprocess,
        isProcessing: _isProcessing,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.cardColor,
      elevation: 1,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: CustomIconWidget(
          iconName: 'arrow_back_ios_new',
          size: 24,
          color: AppTheme.lightTheme.colorScheme.onSurface,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _documentTitle,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Page $_currentPage of $_totalPages',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _handleBookmark,
          icon: CustomIconWidget(
            iconName: 'bookmark_border',
            size: 24,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          icon: CustomIconWidget(
            iconName: 'more_vert',
            size: 24,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'export_pdf',
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'picture_as_pdf',
                    size: 20,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                  SizedBox(width: 3.w),
                  Text('Export as PDF'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'export_text',
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'text_snippet',
                    size: 20,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                  SizedBox(width: 3.w),
                  Text('Export as Text'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'print',
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'print',
                    size: 20,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                  SizedBox(width: 3.w),
                  Text('Print'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'delete',
                    size: 20,
                    color: Colors.red,
                  ),
                  SizedBox(width: 3.w),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentViewer() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: _handlePageChanged,
      itemCount: _totalPages,
      itemBuilder: (context, index) {
        final pageData = _documentPages[index];
        return DocumentPageWidget(
          imageUrl: pageData['imageUrl'],
          pageNumber: pageData['pageNumber'],
          isTextMode: _isTextMode,
          ocrText: pageData['ocrText'],
          confidenceData: pageData['confidenceData'],
          onTextEdit: _handleTextEdit,
          onTextSelect: _handleTextSelect,
        );
      },
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Center(
        child: PageIndicatorWidget(
          currentPage: _currentPage,
          totalPages: _totalPages,
          onPageChanged: _jumpToPage,
          showPageNumbers: true,
        ),
      ),
    );
  }

  Widget _buildSearchOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: DocumentSearchWidget(
        documentText: _getAllDocumentText(),
        onSearchResults: _handleSearchResults,
        onResultSelected: _handleSearchResultSelected,
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Positioned(
      bottom: 20.h,
      right: 4.w,
      child: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          onPressed: _showReprocessOptions,
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          child: CustomIconWidget(
            iconName: _isProcessing ? 'hourglass_empty' : 'auto_fix_high',
            size: 24,
            color: AppTheme.lightTheme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  void _handleModeChange(bool isTextMode) {
    setState(() {
      _isTextMode = isTextMode;
    });

    HapticFeedback.lightImpact();
  }

  void _handlePageChanged(int page) {
    setState(() {
      _currentPage = page + 1;
    });
  }

  void _jumpToPage(int page) {
    _pageController.animateToPage(
      page - 1,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handleTextEdit(String newText, int wordIndex) {
    // Update the OCR text with corrected text
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Text correction saved'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleTextSelect(String selectedText) {
    Clipboard.setData(ClipboardData(text: selectedText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Text copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
    });
  }

  void _handleSearchResults(List<int> results) {
    setState(() {
      _searchResults = results;
      _currentSearchIndex = results.isNotEmpty ? 0 : -1;
    });
  }

  void _handleSearchResultSelected(int resultIndex) {
    // Navigate to the page containing this search result
    // This would require mapping text positions to pages
  }

  void _handleShare() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildShareBottomSheet(),
    );
  }

  void _handleExport() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildExportBottomSheet(),
    );
  }

  void _handleBookmark() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Document bookmarked'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export_pdf':
        _exportAsPDF();
        break;
      case 'export_text':
        _exportAsText();
        break;
      case 'print':
        _printDocument();
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  void _navigateToInsights() {
    Navigator.pushNamed(context, '/insights-screen');
  }

  void _handleReprocess() {
    setState(() {
      _isProcessing = true;
    });

    // Simulate reprocessing
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document reprocessed successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _showReprocessOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildReprocessBottomSheet(),
    );
  }

  Widget _buildShareBottomSheet() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share Document',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          ListTile(
            leading: CustomIconWidget(
              iconName: 'email',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            title: Text('Email'),
            onTap: () {
              Navigator.pop(context);
              _shareViaEmail();
            },
          ),
          ListTile(
            leading: CustomIconWidget(
              iconName: 'link',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            title: Text('Copy Link'),
            onTap: () {
              Navigator.pop(context);
              _copyShareLink();
            },
          ),
          ListTile(
            leading: CustomIconWidget(
              iconName: 'share',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            title: Text('More Options'),
            onTap: () {
              Navigator.pop(context);
              _showSystemShare();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExportBottomSheet() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Export Document',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          ListTile(
            leading: CustomIconWidget(
              iconName: 'picture_as_pdf',
              size: 24,
              color: Colors.red,
            ),
            title: Text('PDF with Text Layer'),
            subtitle: Text('Searchable PDF with OCR text'),
            onTap: () {
              Navigator.pop(context);
              _exportAsPDF();
            },
          ),
          ListTile(
            leading: CustomIconWidget(
              iconName: 'text_snippet',
              size: 24,
              color: Colors.blue,
            ),
            title: Text('Plain Text'),
            subtitle: Text('Extract all text content'),
            onTap: () {
              Navigator.pop(context);
              _exportAsText();
            },
          ),
          ListTile(
            leading: CustomIconWidget(
              iconName: 'table_chart',
              size: 24,
              color: Colors.green,
            ),
            title: Text('Structured Data'),
            subtitle: Text('Tables and data in CSV format'),
            onTap: () {
              Navigator.pop(context);
              _exportAsCSV();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReprocessBottomSheet() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reprocess Options',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          ListTile(
            leading: CustomIconWidget(
              iconName: 'refresh',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            title: Text('Reprocess Current Page'),
            subtitle: Text('Improve OCR accuracy for this page'),
            onTap: () {
              Navigator.pop(context);
              _reprocessCurrentPage();
            },
          ),
          ListTile(
            leading: CustomIconWidget(
              iconName: 'auto_fix_high',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            title: Text('Reprocess Entire Document'),
            subtitle: Text('Re-run OCR on all pages'),
            onTap: () {
              Navigator.pop(context);
              _reprocessEntireDocument();
            },
          ),
          ListTile(
            leading: CustomIconWidget(
              iconName: 'cloud_upload',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            title: Text('Cloud Enhanced Processing'),
            subtitle: Text('Use cloud AI for better accuracy'),
            onTap: () {
              Navigator.pop(context);
              _cloudReprocess();
            },
          ),
        ],
      ),
    );
  }

  String _getAllDocumentText() {
    return _documentPages.map((page) => page['ocrText'] as String).join('\n\n');
  }

  void _shareViaEmail() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening email app...')),
    );
  }

  void _copyShareLink() {
    Clipboard.setData(
        ClipboardData(text: 'https://bluekode.app/doc/q3-report'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Link copied to clipboard')),
    );
  }

  void _showSystemShare() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening system share...')),
    );
  }

  void _exportAsPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting as PDF...')),
    );
  }

  void _exportAsText() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting as text file...')),
    );
  }

  void _exportAsCSV() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting structured data...')),
    );
  }

  void _printDocument() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Preparing document for printing...')),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Document'),
        content: Text(
            'Are you sure you want to delete this document? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteDocument();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteDocument() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Document deleted')),
    );
  }

  void _reprocessCurrentPage() {
    setState(() {
      _isProcessing = true;
    });

    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Page $_currentPage reprocessed')),
        );
      }
    });
  }

  void _reprocessEntireDocument() {
    setState(() {
      _isProcessing = true;
    });

    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document reprocessed successfully')),
        );
      }
    });
  }

  void _cloudReprocess() {
    setState(() {
      _isProcessing = true;
    });

    Future.delayed(Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cloud processing completed')),
        );
      }
    });
  }
}
