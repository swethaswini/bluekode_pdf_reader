import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Widget for searching within document content
class DocumentSearchWidget extends StatefulWidget {
  final String documentText;
  final Function(List<int>)? onSearchResults;
  final Function(int)? onResultSelected;

  const DocumentSearchWidget({
    super.key,
    required this.documentText,
    this.onSearchResults,
    this.onResultSelected,
  });

  @override
  State<DocumentSearchWidget> createState() => _DocumentSearchWidgetState();
}

class _DocumentSearchWidgetState extends State<DocumentSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<int> _searchResults = [];
  int _currentResultIndex = -1;
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.shadowColor,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSearchHeader(),
          SizedBox(height: 2.h),
          _buildSearchField(),
          if (_searchResults.isNotEmpty) ...[
            SizedBox(height: 2.h),
            _buildSearchNavigation(),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Row(
      children: [
        CustomIconWidget(
          iconName: 'search',
          size: 24,
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
        SizedBox(width: 3.w),
        Text(
          'Search in Document',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Spacer(),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: CustomIconWidget(
            iconName: 'close',
            size: 24,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      decoration: InputDecoration(
        hintText: 'Search for text...',
        prefixIcon: Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: 'search',
            size: 20,
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.6),
          ),
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                onPressed: _clearSearch,
                icon: CustomIconWidget(
                  iconName: 'clear',
                  size: 20,
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.lightTheme.colorScheme.outline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.lightTheme.colorScheme.primary,
            width: 2,
          ),
        ),
      ),
      onChanged: _performSearch,
      onSubmitted: (_) => _performSearch(_searchController.text),
    );
  }

  Widget _buildSearchNavigation() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Text(
            _searchResults.isEmpty
                ? 'No results'
                : '${_currentResultIndex + 1} of ${_searchResults.length}',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
          Spacer(),
          IconButton(
            onPressed: _searchResults.isEmpty ? null : _previousResult,
            icon: CustomIconWidget(
              iconName: 'keyboard_arrow_up',
              size: 24,
              color: _searchResults.isEmpty
                  ? AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.3)
                  : AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          SizedBox(width: 2.w),
          IconButton(
            onPressed: _searchResults.isEmpty ? null : _nextResult,
            icon: CustomIconWidget(
              iconName: 'keyboard_arrow_down',
              size: 24,
              color: _searchResults.isEmpty
                  ? AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.3)
                  : AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _currentResultIndex = -1;
        _isSearching = false;
      });
      widget.onSearchResults?.call([]);
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Perform case-insensitive search
    final results = <int>[];
    final lowerQuery = query.toLowerCase();
    final lowerText = widget.documentText.toLowerCase();

    int startIndex = 0;
    while (true) {
      final index = lowerText.indexOf(lowerQuery, startIndex);
      if (index == -1) break;
      results.add(index);
      startIndex = index + 1;
    }

    setState(() {
      _searchResults = results;
      _currentResultIndex = results.isNotEmpty ? 0 : -1;
      _isSearching = false;
    });

    widget.onSearchResults?.call(results);
    if (results.isNotEmpty) {
      widget.onResultSelected?.call(results[0]);
    }
  }

  void _previousResult() {
    if (_searchResults.isEmpty) return;

    setState(() {
      _currentResultIndex = _currentResultIndex > 0
          ? _currentResultIndex - 1
          : _searchResults.length - 1;
    });

    widget.onResultSelected?.call(_searchResults[_currentResultIndex]);
  }

  void _nextResult() {
    if (_searchResults.isEmpty) return;

    setState(() {
      _currentResultIndex = _currentResultIndex < _searchResults.length - 1
          ? _currentResultIndex + 1
          : 0;
    });

    widget.onResultSelected?.call(_searchResults[_currentResultIndex]);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults.clear();
      _currentResultIndex = -1;
      _isSearching = false;
    });
    widget.onSearchResults?.call([]);
  }
}
