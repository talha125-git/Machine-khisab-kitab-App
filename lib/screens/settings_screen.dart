import 'package:flutter/material.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  final AppUser user;
  final VoidCallback onLogout;
  final VoidCallback onRefresh;

  const SettingsScreen({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onRefresh,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to sign out from your Khisab Kitab account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
            onPressed: () {
              Navigator.pop(ctx);
              widget.onLogout();
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            // Page Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings & Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'ترتیبات — Preferences & Server Connection',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.accentCyan,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 1. Theme Switcher Section
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131D33) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF243353) : const Color(0xFFCBD5E1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          color: AppTheme.accentCyan,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'APP THEME',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                              color: isDark ? AppTheme.textSubtle : AppTheme.textDarkSubtle,
                            ),
                          ),
                          Text(
                            isDark ? 'Dark Theme (Default)' : 'Bluish Light (Web Style)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Two visual selectable theme cards
                  Row(
                    children: [
                      // Dark Theme Card (Default)
                      Expanded(
                        child: _buildThemeCard(
                          title: 'Dark Ledger',
                          subtitle: 'Default Theme',
                          icon: Icons.nightlight_round,
                          isSelected: isDark,
                          bgColor: const Color(0xFF0F172A),
                          borderColor: isDark ? AppTheme.accentCyan : const Color(0xFF334155),
                          textColor: Colors.white,
                          onTap: () => setAppThemeMode(ThemeMode.dark),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Light Theme Card (Bluish Web)
                      Expanded(
                        child: _buildThemeCard(
                          title: 'Bluish Web',
                          subtitle: 'Light Theme',
                          icon: Icons.wb_sunny_rounded,
                          isSelected: !isDark,
                          bgColor: const Color(0xFFEBF5FB),
                          borderColor: !isDark ? AppTheme.primaryBlue : const Color(0xFFCBD5E1),
                          textColor: const Color(0xFF0F172A),
                          onTap: () => setAppThemeMode(ThemeMode.light),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. User Profile Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131D33) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF243353) : const Color(0xFFCBD5E1),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
                    child: Text(
                      widget.user.username.isNotEmpty ? widget.user.username[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentCyan,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.username,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.user.email,
                          style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.emeraldGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.emeraldGreen.withValues(alpha: 0.4)),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        color: AppTheme.emeraldGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Actions: Refresh & Logout
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131D33) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF243353) : const Color(0xFFCBD5E1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACTIONS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: isDark ? AppTheme.textSubtle : AppTheme.textDarkSubtle,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.sync_rounded, color: AppTheme.accentCyan, size: 20),
                    ),
                    title: Text(
                      'Re-sync Kitabs from MongoDB',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                      ),
                    ),
                    subtitle: const Text('Fetch latest entries and recalculate stats', style: TextStyle(fontSize: 12, color: AppTheme.textSubtle)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSubtle),
                    onTap: () {
                      widget.onRefresh();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kitabs re-synced with MongoDB.')),
                      );
                    },
                  ),

                  const Divider(color: Color(0xFF1E293B), height: 16),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.dangerRed.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.logout_rounded, color: AppTheme.dangerRed, size: 20),
                    ),
                    title: const Text(
                      'Log Out',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.dangerRed),
                    ),
                    subtitle: const Text('Sign out from your account', style: TextStyle(fontSize: 12, color: AppTheme.textSubtle)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.dangerRed),
                    onTap: _confirmLogout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isSelected ? 2.0 : 1.0),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: borderColor.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: isSelected ? AppTheme.accentCyan : AppTheme.textSubtle, size: 22),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: AppTheme.accentCyan, size: 18),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? AppTheme.accentCyan : AppTheme.textSubtle,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
