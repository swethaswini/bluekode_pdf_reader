import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CloudModeWidget extends StatefulWidget {
  final Function(List<String> filePaths) onFilesSelected;
  final Function(String error) onError;

  const CloudModeWidget({
    super.key,
    required this.onFilesSelected,
    required this.onError,
  });

  @override
  State<CloudModeWidget> createState() => _CloudModeWidgetState();
}

class _CloudModeWidgetState extends State<CloudModeWidget> {
  String? _selectedService;
  bool _isConnecting = false;
  List<Map<String, dynamic>> _selectedFiles = [];

  final List<Map<String, dynamic>> _cloudServices = [
    {
      'name': 'Google Drive',
      'icon': 'cloud',
      'color': const Color(0xFF4285F4),
      'connected': true,
      'id': 'google_drive',
    },
    {
      'name': 'Dropbox',
      'icon': 'cloud_upload',
      'color': const Color(0xFF0061FF),
      'connected': false,
      'id': 'dropbox',
    },
    {
      'name': 'OneDrive',
      'icon': 'cloud_download',
      'color': const Color(0xFF0078D4),
      'connected': true,
      'id': 'onedrive',
    },
  ];

  final List<Map<String, dynamic>> _mockFiles = [
    {
      'name': 'Contract_Agreement_2024.pdf',
      'size': '2.4 MB',
      'type': 'pdf',
      'modified': '2 hours ago',
      'thumbnail':
          'https://images.unsplash.com/photo-1568667256549-094345857637?w=100&h=100&fit=crop',
      'selected': false,
    },
    {
      'name': 'Invoice_Template.pdf',
      'size': '1.8 MB',
      'type': 'pdf',
      'modified': '1 day ago',
      'thumbnail':
          'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=100&h=100&fit=crop',
      'selected': false,
    },
    {
      'name': 'Business_Report_Q4.pdf',
      'size': '5.2 MB',
      'type': 'pdf',
      'modified': '3 days ago',
      'thumbnail':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
      'selected': false,
    },
    {
      'name': 'Scanned_Document_001.jpg',
      'size': '3.1 MB',
      'type': 'image',
      'modified': '1 week ago',
      'thumbnail':
          'https://images.unsplash.com/photo-1586953208448-b95a79798f07?w=100&h=100&fit=crop',
      'selected': false,
    },
    {
      'name': 'Legal_Document.pdf',
      'size': '4.7 MB',
      'type': 'pdf',
      'modified': '2 weeks ago',
      'thumbnail':
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=100&h=100&fit=crop',
      'selected': false,
    },
  ];

  Future<void> _connectToService(String serviceId) async {
    setState(() {
      _isConnecting = true;
    });

    // Simulate connection process
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isConnecting = false;
      final serviceIndex =
          _cloudServices.indexWhere((s) => s['id'] == serviceId);
      if (serviceIndex != -1) {
        _cloudServices[serviceIndex]['connected'] = true;
      }
    });
  }

  void _selectService(String serviceId) {
    final service = _cloudServices.firstWhere((s) => s['id'] == serviceId);
    if (service['connected']) {
      setState(() {
        _selectedService = serviceId;
      });
    } else {
      _connectToService(serviceId);
    }
  }

  void _toggleFileSelection(int index) {
    setState(() {
      _mockFiles[index]['selected'] = !_mockFiles[index]['selected'];
    });

    _selectedFiles =
        _mockFiles.where((file) => file['selected'] == true).toList();

    List<String> filePaths =
        _selectedFiles.map((file) => file['name'] as String).toList();
    widget.onFilesSelected(filePaths);
  }

  String _getFileIcon(String type) {
    switch (type) {
      case 'pdf':
        return 'picture_as_pdf';
      case 'image':
        return 'image';
      default:
        return 'insert_drive_file';
    }
  }

  Color _getFileColor(String type) {
    switch (type) {
      case 'pdf':
        return const Color(0xFFE53E3E);
      case 'image':
        return const Color(0xFF38A169);
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70.h,
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Cloud Storage',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Import documents from your cloud storage',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 3.h),

          // Cloud Services
          if (_selectedService == null) ...[
            Text(
              'Select Cloud Service',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: ListView.separated(
                itemCount: _cloudServices.length,
                separatorBuilder: (context, index) => SizedBox(height: 2.h),
                itemBuilder: (context, index) {
                  final service = _cloudServices[index];
                  final isConnected = service['connected'] as bool;

                  return GestureDetector(
                    onTap: _isConnecting
                        ? null
                        : () => _selectService(service['id']),
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: (service['color'] as Color)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: CustomIconWidget(
                              iconName: service['icon'],
                              color: service['color'],
                              size: 32,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service['name'],
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isConnected
                                            ? AppTheme
                                                .lightTheme.colorScheme.tertiary
                                            : AppTheme
                                                .lightTheme.colorScheme.outline,
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      isConnected
                                          ? 'Connected'
                                          : 'Not connected',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: isConnected
                                            ? AppTheme
                                                .lightTheme.colorScheme.tertiary
                                            : AppTheme.lightTheme.colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (_isConnecting &&
                              service['id'] == _selectedService)
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.lightTheme.colorScheme.primary,
                              ),
                            )
                          else
                            CustomIconWidget(
                              iconName:
                                  isConnected ? 'arrow_forward_ios' : 'link',
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            // File Browser
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedService = null;
                      _selectedFiles.clear();
                    });
                    widget.onFilesSelected([]);
                  },
                  icon: CustomIconWidget(
                    iconName: 'arrow_back',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    _cloudServices
                        .firstWhere((s) => s['id'] == _selectedService)['name'],
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_selectedFiles.isNotEmpty)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${_selectedFiles.length} selected',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 2.h),

            Expanded(
              child: ListView.separated(
                itemCount: _mockFiles.length,
                separatorBuilder: (context, index) => SizedBox(height: 1.h),
                itemBuilder: (context, index) {
                  final file = _mockFiles[index];
                  final isSelected = file['selected'] as bool;

                  return GestureDetector(
                    onTap: () => _toggleFileSelection(index),
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.1)
                            : AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // File Thumbnail
                          Container(
                            width: 12.w,
                            height: 12.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: _getFileColor(file['type'])
                                  .withValues(alpha: 0.1),
                            ),
                            child: file['type'] == 'image'
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CustomImageWidget(
                                      imageUrl: file['thumbnail'],
                                      width: 12.w,
                                      height: 12.w,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Center(
                                    child: CustomIconWidget(
                                      iconName: _getFileIcon(file['type']),
                                      color: _getFileColor(file['type']),
                                      size: 24,
                                    ),
                                  ),
                          ),
                          SizedBox(width: 3.w),

                          // File Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  file['name'],
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 0.5.h),
                                Row(
                                  children: [
                                    Text(
                                      file['size'],
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                    Text(
                                      ' • ',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                    Text(
                                      file['modified'],
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Selection Indicator
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : AppTheme.lightTheme.colorScheme.outline,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? CustomIconWidget(
                                    iconName: 'check',
                                    color: AppTheme
                                        .lightTheme.colorScheme.onPrimary,
                                    size: 16,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
