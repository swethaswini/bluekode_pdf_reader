import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/document_card_widget.dart';
import './widgets/document_context_menu_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/import_options_bottom_sheet_widget.dart';
import './widgets/search_bar_widget.dart';
import 'widgets/document_card_widget.dart';
import 'widgets/document_context_menu_widget.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/filter_bottom_sheet_widget.dart';
import 'widgets/filter_chip_widget.dart';
import 'widgets/import_options_bottom_sheet_widget.dart';
import 'widgets/search_bar_widget.dart';

/// Library Screen - Primary document management hub
/// Features document grid/list view, search, filtering, and import options
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with TickerProviderStateMixin {
  // State variables
  bool _isGridView = true;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String _searchQuery = '';
  Map<String, dynamic> _activeFilters = {};
  List<Map<String, dynamic>> _documents = [];
  List<Map<String, dynamic>> _filteredDocuments = [];
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  // Mock data for documents
  final List<Map<String, dynamic>> _mockDocuments = [
    {
      "id": "doc_001",
      "title": "Invoice_2024_Q1_Report.pdf",
      "thumbnail":
          "https://images.pexels.com/photos/4386431/pexels-photo-4386431.jpeg?auto=compress&cs=tinysrgb&w=800",
      "status": "processed",
      "confidence": 98,
      "lastModified": DateTime.now().subtract(const Duration(hours: 2)),
      "size": "2.4 MB",
      "pages": 12,
      "type": "invoice",
      "tags": ["Business", "Tax"],
    },
    {
      "id": "doc_002",
      "title": "Contract_Agreement_Final.pdf",
      "thumbnail":
          "https://images.pexels.com/photos/4386370/pexels-photo-4386370.jpeg?auto=compress&cs=tinysrgb&w=800",
      "status": "processing",
      "confidence": 85,
      "lastModified": DateTime.now().subtract(const Duration(days: 1)),
      "size": "1.8 MB",
      "pages": 8,
      "type": "contract",
      "tags": ["Legal", "Important"],
    },
    {
      "id": "doc_003",
      "title": "Receipt_Electronics_Store.pdf",
      "thumbnail":
          "https://images.pexels.com/photos/4386339/pexels-photo-4386339.jpeg?auto=compress&cs=tinysrgb&w=800",
      "status": "processed",
      "confidence": 94,
      "lastModified": DateTime.now().subtract(const Duration(days: 3)),
      "size": "0.9 MB",
      "pages": 2,
      "type": "receipt",
      "tags": ["Personal"],
    },
    {
      "id": "doc_004",
      "title": "Medical_Report_Annual.pdf",
      "thumbnail":
          "https://images.pexels.com/photos/4386431/pexels-photo-4386431.jpeg?auto=compress&cs=tinysrgb&w=800",
      "status": "failed",
      "confidence": 67,
      "lastModified": DateTime.now().subtract(const Duration(days: 5)),
      "size": "3.2 MB",
      "pages": 15,
      "type": "report",
      "tags": ["Personal", "Important"],
    },
    {
      "id": "doc_005",
      "title": "Tax_Documents_2024.pdf",
      "thumbnail":
          "https://images.pexels.com/photos/4386370/pexels-photo-4386370.jpeg?auto=compress&cs=tinysrgb&w=800",
      "status": "processed",
      "confidence": 99,
      "lastModified": DateTime.now().subtract(const Duration(days: 7)),
      "size": "4.1 MB",
      "pages": 25,
      "type": "other",
      "tags": ["Tax", "Business", "Important"],
    },
    {
      "id": "doc_006",
      "title": "Insurance_Policy_Details.pdf",
      "thumbnail":
          "https://images.pexels.com/photos/4386339/pexels-photo-4386339.jpeg?auto=compress&cs=tinysrgb&w=800",
      "status": "processed",
      "confidence": 92,
      "lastModified": DateTime.now().subtract(const Duration(days: 10)),
      "size": "1.5 MB",
      "pages": 6,
      "type": "other",
      "tags": ["Personal", "Legal"],
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeScreen();
    _setupScrollListener();
    _setupAnimations();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _initializeScreen() {
    _documents = List.from(_mockDocuments);
    _filteredDocuments = List.from(_documents);
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      // Hide FAB when scrolling down, show when scrolling up
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_fabAnimationController.status != AnimationStatus.reverse) {
          _fabAnimationController.reverse();
        }
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (_fabAnimationController.status != AnimationStatus.forward) {
          _fabAnimationController.forward();
        }
      }
    });
  }

  void _setupAnimations() {
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
    _fabAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'Library',
        showBackButton: false,
        variant: CustomAppBarVariant.standard,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Column(
          children: [
            // Search bar and filters
            _buildSearchSection(),

            // Active filters
            if (_activeFilters.isNotEmpty) _buildActiveFilters(),

            // Document grid/list
            Expanded(
              child: _filteredDocuments.isEmpty
                  ? _buildEmptyState()
                  : _buildDocumentGrid(),
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          onPressed: _showImportOptions,
          child: CustomIconWidget(
            iconName: 'add',
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            size: 24.sp,
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBarFactory.forLibrary(
        onTap: _handleBottomNavigation,
      ),
    );
  }

  Widget _buildSearchSection() {
    return SearchBarWidget(
      hintText: 'Search documents and content...',
      onChanged: _handleSearch,
      onFilterTap: _showFilterBottomSheet,
      onViewToggle: _toggleView,
      isGridView: _isGridView,
    );
  }

  Widget _buildActiveFilters() {
    final List<Widget> filterChips = [];

    _activeFilters.forEach((key, value) {
      if (value != null) {
        if (value is List && (value).isNotEmpty) {
          for (final item in value) {
            filterChips.add(
              FilterChipWidget(
                label: '\$key: \$item',
                onRemove: () => _removeFilter(key, item),
              ),
            );
          }
        } else if (value is String && value.isNotEmpty) {
          filterChips.add(
            FilterChipWidget(
              label: '\$key: \$value',
              onRemove: () => _removeFilter(key, null),
            ),
          );
        }
      }
    });

    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: filterChips,
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      onImportTap: _handleFileImport,
      onScanTap: _handleCameraScan,
    );
  }

  Widget _buildDocumentGrid() {
    return _isGridView ? _buildGridView() : _buildListView();
  }

  Widget _buildGridView() {
    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
      ),
      itemCount: _filteredDocuments.length,
      itemBuilder: (context, index) {
        final document = _filteredDocuments[index];
        return DocumentCardWidget(
          document: document,
          onTap: () => _navigateToDocumentViewer(document),
          onLongPress: () => _showDocumentContextMenu(context, document),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16.w),
      itemCount: _filteredDocuments.length,
      itemBuilder: (context, index) {
        final document = _filteredDocuments[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          child: DocumentCardWidget(
            document: document,
            onTap: () => _navigateToDocumentViewer(document),
            onLongPress: () => _showDocumentContextMenu(context, document),
          ),
        );
      },
    );
  }

  // Event handlers
  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate network refresh
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
      // In real app, this would fetch updated documents from server
      _documents = List.from(_mockDocuments);
      _applyFilters();
    });

    HapticFeedback.mediumImpact();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        currentFilters: _activeFilters,
        onFiltersChanged: _handleFiltersChanged,
      ),
    );
  }

  void _handleFiltersChanged(Map<String, dynamic> filters) {
    setState(() {
      _activeFilters = filters;
      _applyFilters();
    });
  }

  void _removeFilter(String key, dynamic value) {
    setState(() {
      if (value != null && _activeFilters[key] is List) {
        (_activeFilters[key] as List).remove(value);
        if ((_activeFilters[key] as List).isEmpty) {
          _activeFilters.remove(key);
        }
      } else {
        _activeFilters.remove(key);
      }
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_documents);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((doc) {
        final title = (doc['title'] as String? ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();
        return title.contains(query);
      }).toList();
    }

    // Apply status filter
    if (_activeFilters['status'] != null &&
        (_activeFilters['status'] as List).isNotEmpty) {
      final statuses = _activeFilters['status'] as List<String>;
      filtered = filtered.where((doc) {
        return statuses.contains(doc['status']);
      }).toList();
    }

    // Apply document type filter
    if (_activeFilters['documentType'] != null &&
        (_activeFilters['documentType'] as List).isNotEmpty) {
      final types = _activeFilters['documentType'] as List<String>;
      filtered = filtered.where((doc) {
        return types.contains(doc['type']);
      }).toList();
    }

    // Apply tags filter
    if (_activeFilters['tags'] != null &&
        (_activeFilters['tags'] as List).isNotEmpty) {
      final filterTags = _activeFilters['tags'] as List<String>;
      filtered = filtered.where((doc) {
        final docTags = (doc['tags'] as List<String>?) ?? [];
        return filterTags.any((tag) => docTags.contains(tag));
      }).toList();
    }

    // Apply date range filter
    if (_activeFilters['dateRange'] != null) {
      final dateRange = _activeFilters['dateRange'] as String;
      final now = DateTime.now();
      DateTime? startDate;

      switch (dateRange) {
        case 'today':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'thisWeek':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          break;
        case 'thisMonth':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'last3Months':
          startDate = DateTime(now.year, now.month - 3, now.day);
          break;
      }

      if (startDate != null) {
        filtered = filtered.where((doc) {
          final docDate = doc['lastModified'] as DateTime?;
          return docDate != null && docDate.isAfter(startDate!);
        }).toList();
      }
    }

    setState(() {
      _filteredDocuments = filtered;
    });
  }

  void _showImportOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ImportOptionsBottomSheetWidget(
        onCameraTap: _handleCameraScan,
        onGalleryTap: _handleGalleryImport,
        onFileTap: _handleFileImport,
        onCloudTap: _handleCloudImport,
      ),
    );
  }

  void _showDocumentContextMenu(
      BuildContext context, Map<String, dynamic> document) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => DocumentContextMenuWidget(
        document: document,
        onShare: () => _handleShare(document),
        onExport: () => _handleExport(document),
        onDelete: () => _handleDelete(document),
        onAddTags: () => _handleAddTags(document),
        onReprocess: () => _handleReprocess(document),
      ),
    );
  }

  void _navigateToDocumentViewer(Map<String, dynamic> document) {
    Navigator.pushNamed(
      context,
      '/document-viewer-screen',
      arguments: document,
    );
  }

  void _handleBottomNavigation(int index) {
    final routes = [
      '/library-screen',
      '/import-scan-screen',
      '/document-viewer-screen',
      '/insights-screen',
      '/ask-screen',
    ];

    if (index < routes.length) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }

  // Import handlers
  void _handleCameraScan() {
    Navigator.pushNamed(context, '/import-scan-screen');
  }

  void _handleGalleryImport() {
    // TODO: Implement gallery import
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gallery import coming soon')),
    );
  }

  void _handleFileImport() {
    // TODO: Implement file import
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File import coming soon')),
    );
  }

  void _handleCloudImport() {
    // TODO: Implement cloud import
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cloud import coming soon')),
    );
  }

  // Document action handlers
  void _handleShare(Map<String, dynamic> document) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing ${document['title']}')),
    );
  }

  void _handleExport(Map<String, dynamic> document) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting ${document['title']}')),
    );
  }

  void _handleDelete(Map<String, dynamic> document) {
    Navigator.of(context).pop();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content:
            Text('Are you sure you want to delete "${document['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _documents.removeWhere((doc) => doc['id'] == document['id']);
                _applyFilters();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Document deleted')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleAddTags(Map<String, dynamic> document) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Adding tags to ${document['title']}')),
    );
  }

  void _handleReprocess(Map<String, dynamic> document) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reprocessing ${document['title']}')),
    );
  }
}