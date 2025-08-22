import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/camera_mode_widget.dart';
import './widgets/cloud_mode_widget.dart';
import './widgets/files_mode_widget.dart';
import './widgets/preview_screen_widget.dart';

class ImportScanScreen extends StatefulWidget {
  const ImportScanScreen({super.key});

  @override
  State<ImportScanScreen> createState() => _ImportScanScreenState();
}

class _ImportScanScreenState extends State<ImportScanScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentBottomIndex = 1; // Import/Scan tab is active
  String? _capturedImagePath;
  List<String> _selectedFiles = [];
  bool _showPreview = false;
  bool _isProcessing = false;
  int _processingProgress = 0;

  final List<Map<String, dynamic>> _tabData = [
    {
      'title': 'Camera',
      'icon': 'camera_alt',
      'description': 'Capture documents with your camera',
    },
    {
      'title': 'Files',
      'icon': 'folder',
      'description': 'Import from device storage',
    },
    {
      'title': 'Cloud',
      'icon': 'cloud',
      'description': 'Import from cloud storage',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleImageCaptured(String imagePath) {
    setState(() {
      _capturedImagePath = imagePath;
      _showPreview = true;
    });
  }

  void _handleFilesSelected(List<String> filePaths) {
    setState(() {
      _selectedFiles = filePaths;
    });

    if (filePaths.isNotEmpty) {
      _showProcessingDialog();
    }
  }

  void _handleError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
      ),
    );
  }

  void _handleRetake() {
    setState(() {
      _capturedImagePath = null;
      _showPreview = false;
    });
  }

  void _handleEnhance() {
    // Simulate enhancement process
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Document enhanced successfully'),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
      ),
    );
  }

  void _handleProcess(Map<String, dynamic> options) {
    setState(() {
      _showPreview = false;
      _isProcessing = true;
      _processingProgress = 0;
    });

    _startProcessing(options);
  }

  void _startProcessing(Map<String, dynamic> options) {
    _showProcessingDialog();

    // Simulate processing with progress updates
    _simulateProcessing().then((_) {
      if (mounted) {
        Navigator.of(context).pop(); // Close processing dialog
        _navigateToLibrary();
      }
    });
  }

  Future<void> _simulateProcessing() async {
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _processingProgress = i;
        });
      }
    }
  }

  void _showProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Processing Animation
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    value: _processingProgress / 100,
                    color: AppTheme.lightTheme.colorScheme.primary,
                    strokeWidth: 3,
                  ),
                ),
              ),
              SizedBox(height: 3.h),

              Text(
                'Processing Document',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),

              Text(
                _getProcessingMessage(_processingProgress),
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),

              // Progress Bar
              LinearProgressIndicator(
                value: _processingProgress / 100,
                backgroundColor: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 1.h),

              Text(
                '${_processingProgress}% Complete',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getProcessingMessage(int progress) {
    if (progress < 20) return 'Analyzing document structure...';
    if (progress < 40) return 'Extracting text content...';
    if (progress < 60) return 'Recognizing tables and charts...';
    if (progress < 80) return 'Applying language processing...';
    if (progress < 100) return 'Finalizing document...';
    return 'Processing complete!';
  }

  void _navigateToLibrary() {
    Navigator.pushReplacementNamed(context, '/library-screen');
  }

  void _handleBottomNavigation(int index) {
    setState(() {
      _currentBottomIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/library-screen');
        break;
      case 1:
        // Already on import/scan screen
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/document-viewer-screen');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/insights-screen');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/ask-screen');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showPreview && _capturedImagePath != null) {
      return PreviewScreenWidget(
        imagePath: _capturedImagePath!,
        onRetake: _handleRetake,
        onEnhance: _handleEnhance,
        onProcess: _handleProcess,
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'Import & Scan',
        showBackButton: false,
        variant: CustomAppBarVariant.standard,
      ),
      body: Column(
        children: [
          // Tab Header
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: EdgeInsets.all(1.w),
              labelColor: AppTheme.lightTheme.colorScheme.onPrimary,
              unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
              labelStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle:
                  AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w400,
              ),
              tabs: _tabData.map((tab) {
                return Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: tab['icon'],
                        color: _tabController.index == _tabData.indexOf(tab)
                            ? AppTheme.lightTheme.colorScheme.onPrimary
                            : AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Flexible(
                        child: Text(
                          tab['title'],
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Camera Mode
                CameraModeWidget(
                  onImageCaptured: _handleImageCaptured,
                  onError: _handleError,
                ),

                // Files Mode
                FilesModeWidget(
                  onFilesSelected: _handleFilesSelected,
                  onError: _handleError,
                ),

                // Cloud Mode
                CloudModeWidget(
                  onFilesSelected: _handleFilesSelected,
                  onError: _handleError,
                ),
              ],
            ),
          ),

          // Processing Status
          if (_selectedFiles.isNotEmpty && !_isProcessing)
            Container(
              margin: EdgeInsets.all(4.w),
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 24,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_selectedFiles.length} file${_selectedFiles.length > 1 ? 's' : ''} selected',
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Ready for processing',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _startProcessing({}),
                    child: const Text('Process'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomIndex,
        onTap: _handleBottomNavigation,
        variant: CustomBottomBarVariant.standard,
      ),
    );
  }
}
