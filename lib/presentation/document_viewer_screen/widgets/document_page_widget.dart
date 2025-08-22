import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/custom_image_widget.dart';

/// Widget for displaying individual document pages with zoom and pan capabilities
class DocumentPageWidget extends StatefulWidget {
  final String imageUrl;
  final int pageNumber;
  final bool isTextMode;
  final String? ocrText;
  final Map<String, double>? confidenceData;
  final Function(String, int)? onTextEdit;
  final Function(String)? onTextSelect;

  const DocumentPageWidget({
    super.key,
    required this.imageUrl,
    required this.pageNumber,
    this.isTextMode = false,
    this.ocrText,
    this.confidenceData,
    this.onTextEdit,
    this.onTextSelect,
  });

  @override
  State<DocumentPageWidget> createState() => _DocumentPageWidgetState();
}

class _DocumentPageWidgetState extends State<DocumentPageWidget> {
  final TransformationController _transformationController =
      TransformationController();
  bool _isEditing = false;
  String _editingText = '';
  int _editingIndex = -1;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: widget.isTextMode ? _buildTextView() : _buildPageView(),
    );
  }

  Widget _buildPageView() {
    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: 0.5,
      maxScale: 4.0,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: CustomImageWidget(
          imageUrl: widget.imageUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildTextView() {
    if (widget.ocrText == null || widget.ocrText!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'text_fields',
              size: 48,
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.5),
            ),
            SizedBox(height: 2.h),
            Text(
              'No text extracted for this page',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 1.h),
            ElevatedButton(
              onPressed: () => _reprocessPage(),
              child: Text('Reprocess Page'),
            ),
          ],
        ),
      );
    }

    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: 0.8,
      maxScale: 2.0,
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: _buildSelectableText(),
      ),
    );
  }

  Widget _buildSelectableText() {
    final textSpans = _buildTextSpansWithConfidence();

    return SelectableText.rich(
      TextSpan(children: textSpans),
      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
        height: 1.6,
        fontSize: 14.sp,
      ),
      onSelectionChanged: (selection, cause) {
        if (selection.baseOffset != selection.extentOffset) {
          final selectedText = widget.ocrText!.substring(
            selection.baseOffset,
            selection.extentOffset,
          );
          widget.onTextSelect?.call(selectedText);
        }
      },
      contextMenuBuilder: (context, editableTextState) {
        return _buildContextMenu(context, editableTextState);
      },
    );
  }

  List<TextSpan> _buildTextSpansWithConfidence() {
    final text = widget.ocrText!;
    final words = text.split(' ');
    final spans = <TextSpan>[];

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final confidence = widget.confidenceData?[word] ?? 1.0;

      spans.add(TextSpan(
        text: word + (i < words.length - 1 ? ' ' : ''),
        style: TextStyle(
          backgroundColor: _getConfidenceColor(confidence),
          color: AppTheme.lightTheme.colorScheme.onSurface,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () => _handleWordTap(word, i),
      ));
    }

    return spans;
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.95) {
      return Colors.transparent;
    } else if (confidence >= 0.85) {
      return Colors.yellow.withValues(alpha: 0.3);
    } else {
      return Colors.red.withValues(alpha: 0.3);
    }
  }

  void _handleWordTap(String word, int index) {
    setState(() {
      _isEditing = true;
      _editingText = word;
      _editingIndex = index;
    });
    _showEditDialog(word, index);
  }

  void _showEditDialog(String word, int index) {
    final controller = TextEditingController(text: word);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Text'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Correct text',
            hintText: 'Enter the correct text',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onTextEdit?.call(controller.text, index);
              Navigator.of(context).pop();
              setState(() {
                _isEditing = false;
                _editingIndex = -1;
              });
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildContextMenu(
      BuildContext context, EditableTextState editableTextState) {
    return AdaptiveTextSelectionToolbar(
      anchors: editableTextState.contextMenuAnchors,
      children: [
        TextSelectionToolbarTextButton(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          onPressed: () {
            final selection = editableTextState.textEditingValue.selection;
            final selectedText =
                editableTextState.textEditingValue.text.substring(
              selection.baseOffset,
              selection.extentOffset,
            );
            Clipboard.setData(ClipboardData(text: selectedText));
            editableTextState.hideToolbar();
          },
          child: Text('Copy'),
        ),
        TextSelectionToolbarTextButton(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          onPressed: () {
            // Define functionality would go here
            editableTextState.hideToolbar();
          },
          child: Text('Define'),
        ),
        TextSelectionToolbarTextButton(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          onPressed: () {
            // Translate functionality would go here
            editableTextState.hideToolbar();
          },
          child: Text('Translate'),
        ),
        TextSelectionToolbarTextButton(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          onPressed: () {
            // Add note functionality would go here
            editableTextState.hideToolbar();
          },
          child: Text('Add Note'),
        ),
      ],
    );
  }

  void _reprocessPage() {
    // Implement page reprocessing logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reprocessing page ${widget.pageNumber}...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}