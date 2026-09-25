import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum FooterTab {
  currentKitab,
  allKitabs,
  newKitab,
  pdfReport,
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
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.06),
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Current Kitab / Ledger
              _buildNavItem(
                context: context,
                tab: FooterTab.currentKitab,
                icon: Icons.menu_book_rounded,
                activeIcon: Icons.menu_book,
                label: 'Kitab',
                isSelected: activeTab == FooterTab.currentKitab,
              ),

              // 2. All Kitabs List
              _buildNavItem(
                context: context,
                tab: FooterTab.allKitabs,
                icon: Icons.auto_stories_outlined,
                activeIcon: Icons.auto_stories_rounded,
                label: 'All Kitabs',
                badgeCount: kitabsCount,
                isSelected: activeTab == FooterTab.allKitabs,
              ),

              // 3. Center Action: + New Kitab
              _buildCenterNewButton(),

              // 4. PDF Report
              _buildNavItem(
                context: context,
                tab: FooterTab.pdfReport,
                icon: Icons.picture_as_pdf_outlined,
                activeIcon: Icons.picture_as_pdf_rounded,
                label: 'PDF Report',
                isSelected: activeTab == FooterTab.pdfReport,
                enabled: hasActiveKitab,
              ),

              // 5. Settings
              _buildNavItem(
                context: context,
                tab: FooterTab.settings,
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings_rounded,
                label: 'Settings',
                isSelected: activeTab == FooterTab.settings,
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
      borderRadius: BorderRadius.circular(12),
      onTap: enabled ? () => onTabSelected(tab) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryBlue.withValues(alpha: 0.18)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
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
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(minWidth: 16),
                      child: Text(
                        '$badgeCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
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
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterNewButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => onTabSelected(FooterTab.newKitab),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF0284C7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 20),
            SizedBox(width: 4),
            Text(
              'New',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
