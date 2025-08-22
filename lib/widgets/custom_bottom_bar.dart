import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom BottomNavigationBar widget implementing Professional Minimalism design
/// for enterprise document processing applications.
///
/// Features:
/// - Adaptive tab persistence with intelligent highlighting
/// - Contextual navigation based on document workflow
/// - Consistent blue accent theming across platforms
/// - Optimized for mobile document processing tasks
class CustomBottomBar extends StatelessWidget {
  /// Current selected index
  final int currentIndex;

  /// Callback when tab is tapped
  final ValueChanged<int> onTap;

  /// Bottom bar variant for different contexts
  final CustomBottomBarVariant variant;

  /// Whether to show labels (optional, defaults to true)
  final bool showLabels;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.variant = CustomBottomBarVariant.standard,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: _getBackgroundColor(theme, variant),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: _getHeight(variant),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildNavigationItems(context, theme),
          ),
        ),
      ),
    );
  }

  /// Build navigation items based on available routes
  List<Widget> _buildNavigationItems(BuildContext context, ThemeData theme) {
    final items = _getNavigationItems();

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isSelected = currentIndex == index;

      return Expanded(
        child: _NavigationItem(
          item: item,
          isSelected: isSelected,
          onTap: () => _handleNavigation(context, index, item.route),
          theme: theme,
          variant: variant,
          showLabel: showLabels,
        ),
      );
    }).toList();
  }

  /// Get navigation items for document processing workflow
  List<_NavigationItemData> _getNavigationItems() {
    return [
      _NavigationItemData(
        icon: Icons.folder_outlined,
        selectedIcon: Icons.folder,
        label: 'Library',
        route: '/library-screen',
      ),
      _NavigationItemData(
        icon: Icons.document_scanner_outlined,
        selectedIcon: Icons.document_scanner,
        label: 'Scan',
        route: '/import-scan-screen',
      ),
      _NavigationItemData(
        icon: Icons.description_outlined,
        selectedIcon: Icons.description,
        label: 'Viewer',
        route: '/document-viewer-screen',
      ),
      _NavigationItemData(
        icon: Icons.insights_outlined,
        selectedIcon: Icons.insights,
        label: 'Insights',
        route: '/insights-screen',
      ),
      _NavigationItemData(
        icon: Icons.chat_outlined,
        selectedIcon: Icons.chat,
        label: 'Ask',
        route: '/ask-screen',
      ),
    ];
  }

  /// Handle navigation with proper route management
  void _handleNavigation(BuildContext context, int index, String route) {
    if (currentIndex == index) return;

    onTap(index);

    // Navigate to the selected route
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  /// Get background color based on variant
  Color _getBackgroundColor(ThemeData theme, CustomBottomBarVariant variant) {
    switch (variant) {
      case CustomBottomBarVariant.standard:
        return theme.cardColor;
      case CustomBottomBarVariant.floating:
        return theme.cardColor;
      case CustomBottomBarVariant.transparent:
        return theme.cardColor.withValues(alpha: 0.95);
    }
  }

  /// Get height based on variant
  double _getHeight(CustomBottomBarVariant variant) {
    switch (variant) {
      case CustomBottomBarVariant.standard:
        return 64;
      case CustomBottomBarVariant.floating:
        return 72;
      case CustomBottomBarVariant.transparent:
        return 64;
    }
  }
}

/// Individual navigation item widget
class _NavigationItem extends StatelessWidget {
  final _NavigationItemData item;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;
  final CustomBottomBarVariant variant;
  final bool showLabel;

  const _NavigationItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.theme,
    required this.variant,
    required this.showLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    final selectedColor = colorScheme.primary;
    final unselectedColor = colorScheme.onSurface.withValues(alpha: 0.6);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with selection indicator
              Container(
                padding: const EdgeInsets.all(8),
                decoration: isSelected
                    ? BoxDecoration(
                        color: selectedColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  size: 24,
                  color: isSelected ? selectedColor : unselectedColor,
                ),
              ),

              // Label
              if (showLabel) ...[
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? selectedColor : unselectedColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Data class for navigation items
class _NavigationItemData {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  const _NavigationItemData({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}

/// Enum for different bottom bar variants
enum CustomBottomBarVariant {
  /// Standard bottom navigation bar
  standard,

  /// Floating bottom navigation bar with rounded corners
  floating,

  /// Semi-transparent bottom navigation bar
  transparent,
}

/// Factory method to create bottom bar for specific screens
class CustomBottomBarFactory {
  /// Create bottom bar for library screen
  static CustomBottomBar forLibrary({
    required ValueChanged<int> onTap,
  }) {
    return CustomBottomBar(
      currentIndex: 0,
      onTap: onTap,
      variant: CustomBottomBarVariant.standard,
    );
  }

  /// Create bottom bar for scan screen
  static CustomBottomBar forScan({
    required ValueChanged<int> onTap,
  }) {
    return CustomBottomBar(
      currentIndex: 1,
      onTap: onTap,
      variant: CustomBottomBarVariant.standard,
    );
  }

  /// Create bottom bar for document viewer
  static CustomBottomBar forViewer({
    required ValueChanged<int> onTap,
  }) {
    return CustomBottomBar(
      currentIndex: 2,
      onTap: onTap,
      variant: CustomBottomBarVariant.transparent,
    );
  }

  /// Create bottom bar for insights screen
  static CustomBottomBar forInsights({
    required ValueChanged<int> onTap,
  }) {
    return CustomBottomBar(
      currentIndex: 3,
      onTap: onTap,
      variant: CustomBottomBarVariant.standard,
    );
  }

  /// Create bottom bar for ask screen
  static CustomBottomBar forAsk({
    required ValueChanged<int> onTap,
  }) {
    return CustomBottomBar(
      currentIndex: 4,
      onTap: onTap,
      variant: CustomBottomBarVariant.standard,
    );
  }
}

/// Extension to get current index from route
extension RouteToIndex on String {
  int get bottomBarIndex {
    switch (this) {
      case '/library-screen':
        return 0;
      case '/import-scan-screen':
        return 1;
      case '/document-viewer-screen':
        return 2;
      case '/insights-screen':
        return 3;
      case '/ask-screen':
        return 4;
      default:
        return 0;
    }
  }
}
