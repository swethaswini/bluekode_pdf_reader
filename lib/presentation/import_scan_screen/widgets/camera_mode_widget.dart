import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CameraModeWidget extends StatefulWidget {
  final Function(String imagePath) onImageCaptured;
  final Function(String error) onError;

  const CameraModeWidget({
    super.key,
    required this.onImageCaptured,
    required this.onError,
  });

  @override
  State<CameraModeWidget> createState() => _CameraModeWidgetState();
}

class _CameraModeWidgetState extends State<CameraModeWidget> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isFlashOn = false;
  String _selectedAspectRatio = 'Auto';
  bool _isCapturing = false;
  bool _documentDetected = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    return (await Permission.camera.request()).isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      if (!await _requestCameraPermission()) {
        widget.onError('Camera permission denied');
        return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        widget.onError('No cameras available');
        return;
      }

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first);

      _cameraController = CameraController(
          camera, kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high);

      await _cameraController!.initialize();
      await _applySettings();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      widget.onError('Failed to initialize camera: ${e.toString()}');
    }
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
    } catch (e) {
      // Ignore focus mode errors
    }

    if (!kIsWeb) {
      try {
        await _cameraController!.setFlashMode(FlashMode.auto);
      } catch (e) {
        // Ignore flash mode errors on unsupported devices
      }
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile photo = await _cameraController!.takePicture();
      widget.onImageCaptured(photo.path);
    } catch (e) {
      widget.onError('Failed to capture photo: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || kIsWeb) return;

    try {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });

      await _cameraController!
          .setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
    } catch (e) {
      // Ignore flash errors on unsupported devices
      setState(() {
        _isFlashOn = false;
      });
    }
  }

  void _simulateDocumentDetection() {
    // Simulate document edge detection for demo purposes
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _documentDetected = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        width: double.infinity,
        height: 70.h,
        color: AppTheme.lightTheme.colorScheme.surface,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              SizedBox(height: 2.h),
              Text(
                'Initializing camera...',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 70.h,
      child: Stack(
        children: [
          // Camera Preview
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CameraPreview(_cameraController!),
            ),
          ),

          // Document Detection Overlay
          if (_documentDetected)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    width: 3,
                  ),
                ),
                child: CustomPaint(
                  painter: DocumentOverlayPainter(
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ),
            ),

          // Top Controls
          Positioned(
            top: 2.h,
            left: 4.w,
            right: 4.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Flash Toggle
                if (!kIsWeb)
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface
                          .withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: _toggleFlash,
                      icon: CustomIconWidget(
                        iconName: _isFlashOn ? 'flash_on' : 'flash_off',
                        color: _isFlashOn
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurface,
                        size: 24,
                      ),
                    ),
                  ),

                // Aspect Ratio Selector
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface
                        .withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedAspectRatio,
                    underline: const SizedBox(),
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                    items: ['Auto', 'A4', 'Letter'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedAspectRatio = newValue;
                        });
                      }
                    },
                  ),
                ),

                // Gallery Access
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface
                        .withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () {
                      // Navigate to gallery or show gallery picker
                    },
                    icon: CustomIconWidget(
                      iconName: 'photo_library',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Document Detection Status
          if (_documentDetected)
            Positioned(
              top: 8.h,
              left: 4.w,
              right: 4.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'check_circle',
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Document detected',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Controls
          Positioned(
            bottom: 2.h,
            left: 4.w,
            right: 4.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Auto-capture indicator
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface
                        .withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'auto_awesome',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Auto',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Capture Button
                GestureDetector(
                  onTap: _isCapturing ? null : _capturePhoto,
                  child: Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.lightTheme.colorScheme.primary,
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        width: 4,
                      ),
                    ),
                    child: _isCapturing
                        ? Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : CustomIconWidget(
                            iconName: 'camera_alt',
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                            size: 32,
                          ),
                  ),
                ),

                // Settings
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface
                        .withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () {
                      // Show camera settings
                    },
                    icon: CustomIconWidget(
                      iconName: 'settings',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DocumentOverlayPainter extends CustomPainter {
  final Color color;

  DocumentOverlayPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final cornerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Draw corner indicators
    final cornerSize = 20.0;

    // Top-left corner
    canvas.drawLine(
      Offset(20, 20),
      Offset(20 + cornerSize, 20),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(20, 20),
      Offset(20, 20 + cornerSize),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(size.width - 20, 20),
      Offset(size.width - 20 - cornerSize, 20),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width - 20, 20),
      Offset(size.width - 20, 20 + cornerSize),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(20, size.height - 20),
      Offset(20 + cornerSize, size.height - 20),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(20, size.height - 20),
      Offset(20, size.height - 20 - cornerSize),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(size.width - 20, size.height - 20),
      Offset(size.width - 20 - cornerSize, size.height - 20),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width - 20, size.height - 20),
      Offset(size.width - 20, size.height - 20 - cornerSize),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
