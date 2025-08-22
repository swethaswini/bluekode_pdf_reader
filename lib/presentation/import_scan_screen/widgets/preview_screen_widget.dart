import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PreviewScreenWidget extends StatefulWidget {
  final String imagePath;
  final Function() onRetake;
  final Function() onEnhance;
  final Function(Map<String, dynamic> options) onProcess;

  const PreviewScreenWidget({
    super.key,
    required this.imagePath,
    required this.onRetake,
    required this.onEnhance,
    required this.onProcess,
  });

  @override
  State<PreviewScreenWidget> createState() => _PreviewScreenWidgetState();
}

class _PreviewScreenWidgetState extends State<PreviewScreenWidget> {
  bool _isEnhanced = false;
  bool _showCropHandles = true;
  String _selectedQuality = 'Balanced';
  String _selectedLanguage = 'English';

  final List<String> _qualityOptions = ['Fast', 'Balanced', 'High Accuracy'];
  final List<String> _languageOptions = [
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese'
  ];

  void _showProcessingOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProcessingOptionsModal(
        selectedQuality: _selectedQuality,
        selectedLanguage: _selectedLanguage,
        onQualityChanged: (quality) {
          setState(() {
            _selectedQuality = quality;
          });
        },
        onLanguageChanged: (language) {
          setState(() {
            _selectedLanguage = language;
          });
        },
        onProcess: () {
          widget.onProcess({
            'quality': _selectedQuality,
            'language': _selectedLanguage,
            'enhanced': _isEnhanced,
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100.h,
      color: AppTheme.lightTheme.colorScheme.surface,
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 2.h,
              left: 4.w,
              right: 4.w,
              bottom: 2.h,
            ),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Preview Document',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: _isEnhanced
                        ? AppTheme.lightTheme.colorScheme.tertiary
                            .withValues(alpha: 0.1)
                        : AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: _isEnhanced ? 'auto_awesome' : 'image',
                        color: _isEnhanced
                            ? AppTheme.lightTheme.colorScheme.tertiary
                            : AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        _isEnhanced ? 'Enhanced' : 'Original',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: _isEnhanced
                              ? AppTheme.lightTheme.colorScheme.tertiary
                              : AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Document Preview
          Expanded(
            child: Container(
              margin: EdgeInsets.all(4.w),
              child: Stack(
                children: [
                  // Document Image
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.lightTheme.shadowColor
                              .withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CustomImageWidget(
                        imageUrl:
                            'https://images.unsplash.com/photo-1568667256549-094345857637?w=800&h=1000&fit=crop',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Crop Handles
                  if (_showCropHandles) ...[
                    // Top-left handle
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _CropHandle(),
                    ),
                    // Top-right handle
                    Positioned(
                      top: 10,
                      right: 10,
                      child: _CropHandle(),
                    ),
                    // Bottom-left handle
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: _CropHandle(),
                    ),
                    // Bottom-right handle
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: _CropHandle(),
                    ),
                  ],

                  // Enhancement Indicator
                  if (_isEnhanced)
                    Positioned(
                      top: 2.h,
                      right: 2.h,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: 'auto_awesome',
                          color: AppTheme.lightTheme.colorScheme.onTertiary,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Bottom Toolbar
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Retake Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onRetake,
                      icon: CustomIconWidget(
                        iconName: 'refresh',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 20,
                      ),
                      label: const Text('Retake'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),

                  // Enhance Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isEnhanced = !_isEnhanced;
                        });
                        widget.onEnhance();
                      },
                      icon: CustomIconWidget(
                        iconName: _isEnhanced ? 'auto_awesome' : 'tune',
                        color: _isEnhanced
                            ? AppTheme.lightTheme.colorScheme.tertiary
                            : AppTheme.lightTheme.colorScheme.primary,
                        size: 20,
                      ),
                      label: Text(_isEnhanced ? 'Enhanced' : 'Enhance'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _isEnhanced
                            ? AppTheme.lightTheme.colorScheme.tertiary
                            : AppTheme.lightTheme.colorScheme.primary,
                        side: BorderSide(
                          color: _isEnhanced
                              ? AppTheme.lightTheme.colorScheme.tertiary
                              : AppTheme.lightTheme.colorScheme.primary,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),

                  // Process Button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _showProcessingOptions,
                      icon: CustomIconWidget(
                        iconName: 'play_arrow',
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        size: 20,
                      ),
                      label: const Text('Process'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CropHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.onPrimary,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.shadowColor.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomIconWidget(
        iconName: 'drag_indicator',
        color: AppTheme.lightTheme.colorScheme.onPrimary,
        size: 12,
      ),
    );
  }
}

class _ProcessingOptionsModal extends StatefulWidget {
  final String selectedQuality;
  final String selectedLanguage;
  final Function(String) onQualityChanged;
  final Function(String) onLanguageChanged;
  final VoidCallback onProcess;

  const _ProcessingOptionsModal({
    required this.selectedQuality,
    required this.selectedLanguage,
    required this.onQualityChanged,
    required this.onLanguageChanged,
    required this.onProcess,
  });

  @override
  State<_ProcessingOptionsModal> createState() =>
      _ProcessingOptionsModalState();
}

class _ProcessingOptionsModalState extends State<_ProcessingOptionsModal> {
  final List<Map<String, dynamic>> _qualityOptions = [
    {
      'name': 'Fast',
      'description': 'Quick processing with good accuracy',
      'time': '~30 seconds',
      'icon': 'speed',
    },
    {
      'name': 'Balanced',
      'description': 'Optimal balance of speed and accuracy',
      'time': '~60 seconds',
      'icon': 'balance',
    },
    {
      'name': 'High Accuracy',
      'description': 'Maximum accuracy with detailed analysis',
      'time': '~120 seconds',
      'icon': 'precision_manufacturing',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 12.w,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Processing Options',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quality Selection
                  Text(
                    'Processing Quality',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),

                  ..._qualityOptions.map((option) {
                    final isSelected = widget.selectedQuality == option['name'];
                    return Container(
                      margin: EdgeInsets.only(bottom: 2.h),
                      child: GestureDetector(
                        onTap: () => widget.onQualityChanged(option['name']),
                        child: Container(
                          padding: EdgeInsets.all(4.w),
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
                              Container(
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  color: AppTheme.lightTheme.colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: CustomIconWidget(
                                  iconName: option['icon'],
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      option['name'],
                                      style: AppTheme
                                          .lightTheme.textTheme.titleSmall
                                          ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      option['description'],
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.onSurface
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      option['time'],
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                CustomIconWidget(
                                  iconName: 'check_circle',
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  SizedBox(height: 3.h),

                  // Language Selection
                  Text(
                    'Language Pack',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),

                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: DropdownButton<String>(
                      value: widget.selectedLanguage,
                      isExpanded: true,
                      underline: const SizedBox(),
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                      items: [
                        'English',
                        'Spanish',
                        'French',
                        'German',
                        'Chinese'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          widget.onLanguageChanged(newValue);
                        }
                      },
                    ),
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),

          // Process Button
          Container(
            padding: EdgeInsets.all(4.w),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onProcess();
                  },
                  icon: CustomIconWidget(
                    iconName: 'play_arrow',
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    size: 20,
                  ),
                  label: const Text('Start Processing'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
