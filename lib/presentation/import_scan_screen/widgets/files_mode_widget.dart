
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilesModeWidget extends StatefulWidget {
  final Function(List<String> filePaths) onFilesSelected;
  final Function(String error) onError;

  const FilesModeWidget({
    super.key,
    required this.onFilesSelected,
    required this.onError,
  });

  @override
  State<FilesModeWidget> createState() => _FilesModeWidgetState();
}

class _FilesModeWidgetState extends State<FilesModeWidget> {
  List<PlatformFile> _selectedFiles = [];
  bool _isSelecting = false;

  final List<Map<String, dynamic>> _supportedFormats = [
    {
      'name': 'PDF Documents',
      'extensions': ['pdf'],
      'icon': 'picture_as_pdf',
      'color': const Color(0xFFE53E3E),
    },
    {
      'name': 'Images',
      'extensions': ['jpg', 'jpeg', 'png', 'tiff', 'bmp'],
      'icon': 'image',
      'color': const Color(0xFF38A169),
    },
    {
      'name': 'Documents',
      'extensions': ['doc', 'docx', 'txt', 'rtf'],
      'icon': 'description',
      'color': const Color(0xFF3182CE),
    },
  ];

  Future<void> _selectFiles() async {
    if (_isSelecting) return;

    setState(() {
      _isSelecting = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'jpg',
          'jpeg',
          'png',
          'tiff',
          'bmp',
          'doc',
          'docx',
          'txt',
          'rtf'
        ],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFiles = result.files;
        });

        List<String> filePaths = [];
        for (var file in result.files) {
          if (kIsWeb) {
            // For web, we'll use the file name as path since we have bytes
            filePaths.add(file.name);
          } else {
            if (file.path != null) {
              filePaths.add(file.path!);
            }
          }
        }

        if (filePaths.isNotEmpty) {
          widget.onFilesSelected(filePaths);
        }
      }
    } catch (e) {
      widget.onError('Failed to select files: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isSelecting = false;
        });
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });

    List<String> filePaths = [];
    for (var file in _selectedFiles) {
      if (kIsWeb) {
        filePaths.add(file.name);
      } else {
        if (file.path != null) {
          filePaths.add(file.path!);
        }
      }
    }
    widget.onFilesSelected(filePaths);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'picture_as_pdf';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'tiff':
      case 'bmp':
        return 'image';
      case 'doc':
      case 'docx':
      case 'txt':
      case 'rtf':
        return 'description';
      default:
        return 'insert_drive_file';
    }
  }

  Color _getFileColor(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return const Color(0xFFE53E3E);
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'tiff':
      case 'bmp':
        return const Color(0xFF38A169);
      case 'doc':
      case 'docx':
      case 'txt':
      case 'rtf':
        return const Color(0xFF3182CE);
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
            'Select Files',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Choose PDF documents or images to process',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 3.h),

          // Supported Formats
          Text(
            'Supported Formats',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),

          // Format Cards
          Wrap(
            spacing: 3.w,
            runSpacing: 2.h,
            children: _supportedFormats.map((format) {
              return Container(
                width: 28.w,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color:
                            (format['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: format['icon'],
                        color: format['color'],
                        size: 24,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      format['name'],
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 4.h),

          // Select Files Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSelecting ? null : _selectFiles,
              icon: _isSelecting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                      ),
                    )
                  : CustomIconWidget(
                      iconName: 'folder_open',
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      size: 20,
                    ),
              label: Text(_isSelecting ? 'Selecting...' : 'Browse Files'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Selected Files
          if (_selectedFiles.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Selected Files (${_selectedFiles.length})',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedFiles.clear();
                    });
                    widget.onFilesSelected([]);
                  },
                  child: Text('Clear All'),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Expanded(
              child: ListView.separated(
                itemCount: _selectedFiles.length,
                separatorBuilder: (context, index) => SizedBox(height: 1.h),
                itemBuilder: (context, index) {
                  final file = _selectedFiles[index];
                  final extension = file.extension ?? '';

                  return Container(
                    padding: EdgeInsets.all(3.w),
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
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color:
                                _getFileColor(extension).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomIconWidget(
                            iconName: _getFileIcon(extension),
                            color: _getFileColor(extension),
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                file.name,
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                _formatFileSize(file.size),
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeFile(index),
                          icon: CustomIconWidget(
                            iconName: 'close',
                            color: AppTheme.lightTheme.colorScheme.error,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'folder_open',
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.3),
                      size: 64,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'No files selected',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Tap "Browse Files" to select documents',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
