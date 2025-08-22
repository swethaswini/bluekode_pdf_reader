import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom AppBar widget implementing Professional Minimalism design
/// for enterprise document processing applications.
///
/// Features:
/// - Clean, purposeful interface with minimal visual noise
/// - Contextual actions based on current screen
/// - Consistent blue accent theming
/// - Optimized for mobile document workflows
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title to display in the app bar
  final String title;

  /// Whether to show the back button (optional)
  final bool showBackButton;

  /// Custom leading widget (optional)
  final Widget? leading;

  /// List of action widgets (optional)
  final List<Widget>? actions;

  /// Whether to center the title (optional, defaults to true)
  final bool centerTitle;

  /// Custom background color (optional)
  final Color? backgroundColor;

  /// App bar variant for different contexts
  final CustomAppBarVariant variant;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
    this.variant = CustomAppBarVariant.standard,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: Text(
        title,
        style: _getTitleStyle(theme, variant),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? _getBackgroundColor(theme, variant),
      foregroundColor: _getForegroundColor(theme, variant),
      elevation: _getElevation(variant),
      shadowColor: theme.shadowColor,
      surfaceTintColor: Colors.transparent,
      leading: _buildLeading(context, theme),
      actions: _buildActions(context, theme),
      automaticallyImplyLeading: showBackButton && leading == null,
      iconTheme: IconThemeData(
        color: _getForegroundColor(theme, variant),
        size: 24,
      ),
    );
  }

  /// Build leading widget based on context
  Widget? _buildLeading(BuildContext context, ThemeData theme) {
    if (leading != null) return leading;

    if (!showBackButton) return null;

    // Custom back button with proper navigation
    if (Navigator.of(context).canPop()) {
      return IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Back',
      );
    }

    return null;
  }

  /// Build actions based on current route and variant
  List<Widget>? _buildActions(BuildContext context, ThemeData theme) {
    if (actions != null) return actions;

    final currentRoute = ModalRoute.of(context)?.settings.name;
    final colorScheme = theme.colorScheme;

    switch (currentRoute) {
      case '/library-screen':
        return [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _handleSearch(context),
            tooltip: 'Search documents',
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _handleSort(context),
            tooltip: 'Sort documents',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleLibraryAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'grid_view',
                child: Row(
                  children: [
                    Icon(Icons.grid_view),
                    SizedBox(width: 12),
                    Text('Grid View'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'list_view',
                child: Row(
                  children: [
                    Icon(Icons.list),
                    SizedBox(width: 12),
                    Text('List View'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ];

      case '/document-viewer-screen':
        return [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _handleShare(context),
            tooltip: 'Share document',
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () => _handleBookmark(context),
            tooltip: 'Bookmark',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleDocumentAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 12),
                    Text('Export'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'print',
                child: Row(
                  children: [
                    Icon(Icons.print),
                    SizedBox(width: 12),
                    Text('Print'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ];

      case '/insights-screen':
        return [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _handleRefresh(context),
            tooltip: 'Refresh insights',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _handleFilter(context),
            tooltip: 'Filter insights',
          ),
        ];

      case '/ask-screen':
        return [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _handleHistory(context),
            tooltip: 'Chat history',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () => _handleClearChat(context),
            tooltip: 'Clear chat',
          ),
        ];

      default:
        return null;
    }
  }

  /// Get title style based on variant
  TextStyle _getTitleStyle(ThemeData theme, CustomAppBarVariant variant) {
    final baseStyle = GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.02,
    );

    switch (variant) {
      case CustomAppBarVariant.standard:
        return baseStyle.copyWith(color: theme.colorScheme.onSurface);
      case CustomAppBarVariant.primary:
        return baseStyle.copyWith(color: theme.colorScheme.onPrimary);
      case CustomAppBarVariant.transparent:
        return baseStyle.copyWith(color: theme.colorScheme.onSurface);
    }
  }

  /// Get background color based on variant
  Color _getBackgroundColor(ThemeData theme, CustomAppBarVariant variant) {
    switch (variant) {
      case CustomAppBarVariant.standard:
        return theme.cardColor;
      case CustomAppBarVariant.primary:
        return theme.colorScheme.primary;
      case CustomAppBarVariant.transparent:
        return Colors.transparent;
    }
  }

  /// Get foreground color based on variant
  Color _getForegroundColor(ThemeData theme, CustomAppBarVariant variant) {
    switch (variant) {
      case CustomAppBarVariant.standard:
        return theme.colorScheme.onSurface;
      case CustomAppBarVariant.primary:
        return theme.colorScheme.onPrimary;
      case CustomAppBarVariant.transparent:
        return theme.colorScheme.onSurface;
    }
  }

  /// Get elevation based on variant
  double _getElevation(CustomAppBarVariant variant) {
    switch (variant) {
      case CustomAppBarVariant.standard:
        return 1.0;
      case CustomAppBarVariant.primary:
        return 2.0;
      case CustomAppBarVariant.transparent:
        return 0.0;
    }
  }

  // Action handlers
  void _handleSearch(BuildContext context) {
    // Implement search functionality
    showSearch(
      context: context,
      delegate: DocumentSearchDelegate(),
    );
  }

  void _handleSort(BuildContext context) {
    // Show sort options bottom sheet
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const SortOptionsBottomSheet(),
    );
  }

  void _handleLibraryAction(BuildContext context, String action) {
    switch (action) {
      case 'grid_view':
        // Switch to grid view
        break;
      case 'list_view':
        // Switch to list view
        break;
      case 'settings':
        // Navigate to settings
        break;
    }
  }

  void _handleShare(BuildContext context) {
    // Implement share functionality
  }

  void _handleBookmark(BuildContext context) {
    // Implement bookmark functionality
  }

  void _handleDocumentAction(BuildContext context, String action) {
    switch (action) {
      case 'export':
        // Export document
        break;
      case 'print':
        // Print document
        break;
      case 'delete':
        // Delete document with confirmation
        _showDeleteConfirmation(context);
        break;
    }
  }

  void _handleRefresh(BuildContext context) {
    // Refresh insights
  }

  void _handleFilter(BuildContext context) {
    // Show filter options
  }

  void _handleHistory(BuildContext context) {
    // Show chat history
  }

  void _handleClearChat(BuildContext context) {
    // Clear chat with confirmation
    _showClearChatConfirmation(context);
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text(
            'Are you sure you want to delete this document? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Perform delete action
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showClearChatConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear the chat history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Perform clear action
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Enum for different app bar variants
enum CustomAppBarVariant {
  /// Standard app bar with card background
  standard,

  /// Primary colored app bar
  primary,

  /// Transparent app bar for overlay scenarios
  transparent,
}

/// Custom search delegate for document search
class DocumentSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Implement search results
    return const Center(
      child: Text('Search results will appear here'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Implement search suggestions
    return const Center(
      child: Text('Search suggestions will appear here'),
    );
  }
}

/// Bottom sheet for sort options
class SortOptionsBottomSheet extends StatelessWidget {
  const SortOptionsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sort by',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Date Modified'),
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            leading: const Icon(Icons.sort_by_alpha),
            title: const Text('Name'),
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Type'),
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Size'),
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
