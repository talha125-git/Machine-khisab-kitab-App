import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum FooterTab {
  currentKitab,
  allKitabs,
  newKitab,
  settings,
}

class AppFooter extends StatelessWidget {
  final FooterTab activeTab;
  final int kitabsCount;
  final bool hasActiveKitab;
  final Function(FooterTab tab) onTabSelected;

  const AppFooter({
    super.key,
    required this.activeTab,
    required this.kitabsCount,
    required this.hasActiveKitab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C1322) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF1E2A42) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              // 1. Current Kitab / Ledger
              Expanded(
                child: _buildNavItem(
                  context: context,
                  tab: FooterTab.currentKitab,
                  icon: Icons.menu_book_outlined,
                  activeIcon: Icons.menu_book_rounded,
                  label: 'Kitab',
                  isSelected: activeTab == FooterTab.currentKitab,
                ),
              ),

              // 2. All Kitabs List
              Expanded(
                child: _buildNavItem(
                  context: context,
                  tab: FooterTab.allKitabs,
                  icon: Icons.auto_stories_outlined,
                  activeIcon: Icons.auto_stories_rounded,
                  label: 'All Kitabs',
                  badgeCount: kitabsCount,
                  isSelected: activeTab == FooterTab.allKitabs,
                ),
              ),

              // 3. + New Kitab Quick Action
              Expanded(
                child: _buildNewKitabItem(
                  context: context,
                  isDark: isDark,
                  onTap: () => onTabSelected(FooterTab.newKitab),
                ),
              ),

              // 4. Settings
              Expanded(
                child: _buildNavItem(
                  context: context,
                  tab: FooterTab.settings,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  label: 'Settings',
                  isSelected: activeTab == FooterTab.settings,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required FooterTab tab,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    int? badgeCount,
    bool enabled = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final color = !enabled
        ? (isDark
            ? AppTheme.textSubtle.withValues(alpha: 0.4)
            : AppTheme.textDarkSubtle.withValues(alpha: 0.3))
        : isSelected
            ? (isDark ? AppTheme.accentCyan : AppTheme.primaryBlue)
            : (isDark ? AppTheme.textMuted : AppTheme.textDarkMuted);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: enabled ? () => onTabSelected(tab) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                            ? AppTheme.primaryBlue.withValues(alpha: 0.22)
                            : AppTheme.primaryBlue.withValues(alpha: 0.12))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    size: 22,
                    color: color,
                  ),
                ),
                if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    top: -2,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF0EA5E9)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(minWidth: 16),
                      child: Text(
                        '$badgeCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewKitabItem({
    required BuildContext context,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF0EA5E9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '+ New',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.accentCyan : AppTheme.primaryBlue,
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
