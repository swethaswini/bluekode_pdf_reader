import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/chat_input_widget.dart';
import './widgets/document_selector_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/message_bubble_widget.dart';
import './widgets/suggestion_chips_widget.dart';
import './widgets/typing_indicator_widget.dart';

class AskScreen extends StatefulWidget {
  const AskScreen({super.key});

  @override
  State<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends State<AskScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _selectedDocuments = [];
  bool _isLoading = false;
  bool _isListening = false;
  bool _showSuggestions = true;
  int _currentBottomIndex = 4;

  // Mock conversation history for demonstration
  final List<Map<String, dynamic>> _mockConversationHistory = [
    {
      'id': '1',
      'message': 'What are the key findings in the quarterly report?',
      'isUser': true,
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'id': '2',
      'message':
          'Based on the quarterly report, the key findings include:\n\n• Revenue increased by 15% compared to last quarter\n• Customer acquisition grew by 23%\n• Operating expenses decreased by 8%\n• Net profit margin improved to 12.5%\n\nThe report also highlights strong performance in the digital transformation initiatives and successful cost optimization strategies.',
      'isUser': false,
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'citedSources': ['Q3_Report.pdf', 'Financial_Summary.pdf'],
    },
  ];

  // Mock available documents
  final List<Map<String, dynamic>> _availableDocuments = [
    {
      'id': '1',
      'name': 'Q3_Report.pdf',
      'type': 'pdf',
      'size': '2.4 MB',
      'lastModified': DateTime.now().subtract(const Duration(days: 3)),
    },
    {
      'id': '2',
      'name': 'Financial_Summary.pdf',
      'type': 'pdf',
      'size': '1.8 MB',
      'lastModified': DateTime.now().subtract(const Duration(days: 5)),
    },
    {
      'id': '3',
      'name': 'Market_Analysis.pdf',
      'type': 'pdf',
      'size': '3.2 MB',
      'lastModified': DateTime.now().subtract(const Duration(days: 7)),
    },
    {
      'id': '4',
      'name': 'Project_Proposal.pdf',
      'type': 'pdf',
      'size': '1.5 MB',
      'lastModified': DateTime.now().subtract(const Duration(days: 10)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadConversationHistory();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadConversationHistory() {
    setState(() {
      _messages = List.from(_mockConversationHistory);
      _showSuggestions = _messages.isEmpty;
    });

    if (_messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSendMessage(String message) {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'message': message,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
      _isLoading = true;
      _showSuggestions = false;
    });

    _scrollToBottom();
    _simulateAIResponse(message);
  }

  void _simulateAIResponse(String userMessage) {
    // Simulate AI processing delay
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      String aiResponse = _generateAIResponse(userMessage);
      List<String> sources = _generateSources();

      setState(() {
        _messages.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'message': aiResponse,
          'isUser': false,
          'timestamp': DateTime.now(),
          'citedSources': sources,
        });
        _isLoading = false;
      });

      _scrollToBottom();
    });
  }

  String _generateAIResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('summarize') ||
        lowerMessage.contains('summary')) {
      return 'Here\'s a comprehensive summary of the selected documents:\n\n• The main focus is on quarterly performance metrics\n• Key achievements include revenue growth and cost optimization\n• Strategic initiatives are showing positive results\n• Market position has strengthened significantly\n\nThe documents indicate a strong trajectory for continued growth and operational excellence.';
    } else if (lowerMessage.contains('date') || lowerMessage.contains('when')) {
      return 'I found the following important dates in your documents:\n\n• Q3 2024: July 1 - September 30, 2024\n• Report submission: October 15, 2024\n• Board meeting: October 22, 2024\n• Next review cycle: January 15, 2025\n\nThese dates are critical for understanding the timeline of events and upcoming milestones.';
    } else if (lowerMessage.contains('contact') ||
        lowerMessage.contains('email') ||
        lowerMessage.contains('phone')) {
      return 'Here are the contact details extracted from your documents:\n\n• John Smith, CFO: john.smith@company.com, (555) 123-4567\n• Sarah Johnson, VP Marketing: sarah.j@company.com, (555) 234-5678\n• Michael Brown, Operations: m.brown@company.com, (555) 345-6789\n\nAll contacts are verified and current as of the document creation date.';
    } else if (lowerMessage.contains('financial') ||
        lowerMessage.contains('money') ||
        lowerMessage.contains('revenue')) {
      return 'Financial highlights from your documents:\n\n• Total Revenue: \$2.4M (↑15% QoQ)\n• Operating Expenses: \$1.8M (↓8% QoQ)\n• Net Profit: \$600K (↑35% QoQ)\n• Cash Flow: \$450K positive\n• ROI: 12.5% (industry avg: 8.2%)\n\nThe financial performance shows strong growth across all key metrics.';
    } else {
      return 'Based on your question about the documents, I can provide the following insights:\n\n• The content covers multiple aspects of business operations\n• Key performance indicators show positive trends\n• Strategic objectives are being met effectively\n• There are actionable recommendations for future improvements\n\nWould you like me to elaborate on any specific aspect or provide more detailed analysis?';
    }
  }

  List<String> _generateSources() {
    if (_selectedDocuments.isNotEmpty) {
      return _selectedDocuments
          .map((doc) => doc['name'] as String)
          .take(2)
          .toList();
    }
    return ['Q3_Report.pdf', 'Financial_Summary.pdf'];
  }

  void _handleVoiceInput() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() {
    setState(() {
      _isListening = true;
    });

    HapticFeedback.mediumImpact();

    // Simulate voice recognition
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      setState(() {
        _isListening = false;
        _textController.text = 'What are the key findings in this report?';
      });

      Fluttertoast.showToast(
        msg: 'Voice input captured successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    });
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
    });

    HapticFeedback.lightImpact();
  }

  void _handleSuggestionTap(String suggestion) {
    _textController.text = suggestion;
    _handleSendMessage(suggestion);
  }

  void _handleExampleTap(String example) {
    _textController.text = example;
  }

  void _selectDocuments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDocumentSelectionSheet(),
    );
  }

  Widget _buildDocumentSelectionSheet() {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(4.w)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Select Documents',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 6.w,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(4.w),
              itemCount: _availableDocuments.length,
              itemBuilder: (context, index) {
                final document = _availableDocuments[index];
                final isSelected = _selectedDocuments
                    .any((doc) => doc['id'] == document['id']);

                return GestureDetector(
                  onTap: () => _toggleDocumentSelection(document),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 2.h),
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1)
                          : AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(2.w),
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
                        CustomIconWidget(
                          iconName: 'description',
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                          size: 6.w,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                document['name'] as String,
                                style: AppTheme.lightTheme.textTheme.titleSmall
                                    ?.copyWith(
                                  color: isSelected
                                      ? AppTheme.lightTheme.colorScheme.primary
                                      : AppTheme
                                          .lightTheme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                '${document['size']} • ${_formatDate(document['lastModified'] as DateTime)}',
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
                        if (isSelected)
                          CustomIconWidget(
                            iconName: 'check_circle',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 5.w,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _toggleDocumentSelection(Map<String, dynamic> document) {
    setState(() {
      final isSelected =
          _selectedDocuments.any((doc) => doc['id'] == document['id']);
      if (isSelected) {
        _selectedDocuments.removeWhere((doc) => doc['id'] == document['id']);
      } else {
        _selectedDocuments.add(document);
      }
    });
  }

  void _removeDocument(String documentId) {
    setState(() {
      _selectedDocuments.removeWhere((doc) => doc['id'] == documentId);
    });
  }

  void _handleSourceTap(String source) {
    Fluttertoast.showToast(
      msg: 'Opening $source...',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    // Navigate to document viewer
    Navigator.pushNamed(context, '/document-viewer-screen');
  }

  void _handleCopyMessage(String message) {
    Clipboard.setData(ClipboardData(text: message));
    Fluttertoast.showToast(
      msg: 'Message copied to clipboard',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handleShareMessage(String message) {
    Fluttertoast.showToast(
      msg: 'Sharing message...',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handleSaveToNotes(String message) {
    Fluttertoast.showToast(
      msg: 'Message saved to notes',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text(
            'Are you sure you want to clear the chat history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
                _showSuggestions = true;
              });
              Fluttertoast.showToast(
                msg: 'Chat history cleared',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Ask AI',
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'history',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
            onPressed: () {
              Fluttertoast.showToast(
                msg: 'Chat history',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'clear_all',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
            onPressed: _clearChat,
          ),
        ],
      ),
      body: Column(
        children: [
          DocumentSelectorWidget(
            selectedDocuments: _selectedDocuments,
            onSelectDocuments: _selectDocuments,
            onRemoveDocument: _removeDocument,
          ),
          if (_showSuggestions && _messages.isEmpty)
            SuggestionChipsWidget(
              onSuggestionTap: _handleSuggestionTap,
              isVisible: _showSuggestions,
            ),
          _messages.isEmpty
              ? EmptyStateWidget(onExampleTap: _handleExampleTap)
              : Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.only(bottom: 2.h),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return MessageBubbleWidget(
                        message: message['message'] as String,
                        isUser: message['isUser'] as bool,
                        timestamp: message['timestamp'] as DateTime,
                        citedSources: message['citedSources'] as List<String>?,
                        onCopy: () =>
                            _handleCopyMessage(message['message'] as String),
                        onShare: () =>
                            _handleShareMessage(message['message'] as String),
                        onSaveToNotes: () =>
                            _handleSaveToNotes(message['message'] as String),
                        onSourceTap: _handleSourceTap,
                      );
                    },
                  ),
                ),
          TypingIndicatorWidget(isVisible: _isLoading),
          ChatInputWidget(
            textController: _textController,
            onSendMessage: _handleSendMessage,
            onVoiceInput: _handleVoiceInput,
            isLoading: _isLoading,
            isListening: _isListening,
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomIndex,
        onTap: (index) {
          setState(() {
            _currentBottomIndex = index;
          });

          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/library-screen');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/import-scan-screen');
              break;
            case 2:
              Navigator.pushReplacementNamed(
                  context, '/document-viewer-screen');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/insights-screen');
              break;
            case 4:
              // Already on Ask screen
              break;
          }
        },
      ),
    );
  }
}
