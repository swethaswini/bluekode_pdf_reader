import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ChatInputWidget extends StatefulWidget {
  final TextEditingController textController;
  final Function(String) onSendMessage;
  final VoidCallback onVoiceInput;
  final bool isLoading;
  final bool isListening;

  const ChatInputWidget({
    super.key,
    required this.textController,
    required this.onSendMessage,
    required this.onVoiceInput,
    this.isLoading = false,
    this.isListening = false,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.textController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.textController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(6.w),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.textController,
                        decoration: InputDecoration(
                          hintText: widget.isListening
                              ? 'Listening...'
                              : 'Ask a question about your documents...',
                          hintStyle: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 2.h,
                          ),
                        ),
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        enabled: !widget.isLoading && !widget.isListening,
                        onSubmitted: _hasText ? (value) => _handleSend() : null,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.isLoading ? null : widget.onVoiceInput,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        margin: EdgeInsets.only(right: 1.w),
                        decoration: BoxDecoration(
                          color: widget.isListening
                              ? AppTheme.lightTheme.colorScheme.error
                                  .withValues(alpha: 0.1)
                              : AppTheme.lightTheme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(3.w),
                        ),
                        child: widget.isListening
                            ? _buildListeningAnimation()
                            : CustomIconWidget(
                                iconName: 'mic',
                                color: AppTheme.lightTheme.colorScheme.primary,
                                size: 5.w,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 2.w),
            GestureDetector(
              onTap: (_hasText && !widget.isLoading) ? _handleSend : null,
              child: Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: (_hasText && !widget.isLoading)
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6.w),
                ),
                child: widget.isLoading
                    ? _buildLoadingIndicator()
                    : CustomIconWidget(
                        iconName: 'send',
                        color: (_hasText && !widget.isLoading)
                            ? AppTheme.lightTheme.colorScheme.onPrimary
                            : AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                        size: 5.w,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListeningAnimation() {
    return SizedBox(
      width: 5.w,
      height: 5.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 5.w,
            height: 5.w,
            decoration: BoxDecoration(
              color:
                  AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2.5.w),
            ),
          ),
          CustomIconWidget(
            iconName: 'mic',
            color: AppTheme.lightTheme.colorScheme.error,
            size: 3.w,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 5.w,
      height: 5.w,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          AppTheme.lightTheme.colorScheme.onPrimary,
        ),
      ),
    );
  }

  void _handleSend() {
    final text = widget.textController.text.trim();
    if (text.isNotEmpty && !widget.isLoading) {
      widget.onSendMessage(text);
      widget.textController.clear();
      HapticFeedback.lightImpact();
    }
  }
}