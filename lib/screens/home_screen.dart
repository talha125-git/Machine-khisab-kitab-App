import 'package:flutter/material.dart';
import '../models/kitab.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/create_kitab_dialog.dart';
import '../widgets/app_footer.dart';
import 'kitab_detail_screen.dart';
import 'all_kitabs_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppUser user;
  final VoidCallback onLogout;

  const HomeScreen({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Kitab> _kitabs = [];
  String? _activeKitabId;
  bool _isLoading = true;
  FooterTab _currentFooterTab = FooterTab.currentKitab;

  @override
  void initState() {
    super.initState();
    _loadKitabs();
  }

  Future<void> _loadKitabs() async {
    setState(() {
      _isLoading = true;
    });

    final kitabs = await ApiService.getKitabs(userId: widget.user.id);

    setState(() {
      _kitabs = kitabs;
      _isLoading = false;
      if (kitabs.isNotEmpty) {
        if (_activeKitabId == null || !kitabs.any((k) => k.id == _activeKitabId)) {
          _activeKitabId = kitabs.first.id;
        }
      } else {
        _activeKitabId = null;
      }
    });
  }

  void _showCreateModal() {
    showDialog(
      context: context,
      builder: (ctx) => CreateKitabDialog(
        nextNumber: _kitabs.length + 1,
        onCreated: (startDate) async {
          final newKitab = Kitab.createNew(
            start: startDate,
            existingCount: _kitabs.length,
            username: widget.user.username,
            userId: widget.user.id,
          );

          // Optimistic local update
          setState(() {
            _kitabs.insert(0, newKitab);
            _activeKitabId = newKitab.id;
            _currentFooterTab = FooterTab.currentKitab;
          });

          // API call
          final saved = await ApiService.createKitab(kitab: newKitab, userId: widget.user.id);
          if (saved != null) {
            setState(() {
              final idx = _kitabs.indexWhere((k) => k.id == newKitab.id);
              if (idx != -1) {
                _kitabs[idx] = saved;
              }
            });
          }
        },
      ),
    );
  }

  void _handleDeleteKitab(String id) async {
    // Optimistic removal
    setState(() {
      _kitabs.removeWhere((k) => k.id == id);
      if (_activeKitabId == id) {
        _activeKitabId = _kitabs.isNotEmpty ? _kitabs.first.id : null;
      }
    });

    await ApiService.deleteKitab(kitabId: id, userId: widget.user.id);
  }

  void _handleUpdateKitab(Kitab updatedKitab) async {
    setState(() {
      final idx = _kitabs.indexWhere((k) => k.id == updatedKitab.id);
      if (idx != -1) {
        _kitabs[idx] = updatedKitab;
      }
    });

    await ApiService.updateKitab(kitab: updatedKitab, userId: widget.user.id);
  }

  void _handleResetKitab(Kitab kitab) async {
    final resetDays = kitab.days.map((d) {
      d.income = '';
      d.notes = '';
      d.saved = false;
      return d;
    }).toList();

    final updated = Kitab(
      id: kitab.id,
      userId: kitab.userId,
      username: kitab.username,
      title: kitab.title,
      number: kitab.number,
      startDate: kitab.startDate,
      endDate: kitab.endDate,
      days: resetDays,
      completed: false,
      createdAt: kitab.createdAt,
      spendMoney: null,
      handOver: null,
      iHave: null,
      moneyLeft: null,
      masara: null,
      moneySaved: false,
    );

    _handleUpdateKitab(updated);
  }

  void _handleFooterTab(FooterTab tab) {
    switch (tab) {
      case FooterTab.currentKitab:
        setState(() {
          _currentFooterTab = FooterTab.currentKitab;
        });
        break;
      case FooterTab.allKitabs:
        setState(() {
          _currentFooterTab = FooterTab.allKitabs;
        });
        break;
      case FooterTab.newKitab:
        _showCreateModal();
        break;
      case FooterTab.settings:
        setState(() {
          _currentFooterTab = FooterTab.settings;
        });
        break;
    }
  }

  String get _appBarTitle {
    switch (_currentFooterTab) {
      case FooterTab.allKitabs:
        return 'All Kitabs';
      case FooterTab.settings:
        return 'Settings';
      case FooterTab.currentKitab:
      case FooterTab.newKitab:
        return widget.user.username.isNotEmpty ? widget.user.username : 'Khisab Kitab';
    }
  }

  String get _appBarSubtitle {
    switch (_currentFooterTab) {
      case FooterTab.allKitabs:
        return 'تمام کتب — Manage & Switch Cycles';
      case FooterTab.settings:
        return 'ترتیبات — App Preferences & Theme';
      case FooterTab.currentKitab:
      case FooterTab.newKitab:
        return 'Machine Number Data';
    }
  }

  Widget _buildCurrentPage(Kitab? activeKitab) {
    switch (_currentFooterTab) {
      case FooterTab.allKitabs:
        return AllKitabsScreen(
          kitabs: _kitabs,
          activeKitabId: _activeKitabId,
          onSelectKitab: (id) {
            setState(() {
              _activeKitabId = id;
              _currentFooterTab = FooterTab.currentKitab;
            });
          },
          onCreateNew: _showCreateModal,
          onDeleteKitab: _handleDeleteKitab,
          onRefresh: _loadKitabs,
        );
      case FooterTab.settings:
        return SettingsScreen(
          user: widget.user,
          onLogout: () async {
            await AuthService.logout();
            widget.onLogout();
          },
          onRefresh: _loadKitabs,
        );
      case FooterTab.currentKitab:
      case FooterTab.newKitab:
        return activeKitab != null
            ? KitabDetailScreen(
                key: ValueKey(activeKitab.id),
                kitab: activeKitab,
                userId: widget.user.id,
                onUpdateKitab: _handleUpdateKitab,
                onResetKitab: () => _handleResetKitab(activeKitab),
              )
            : _buildEmptyState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeKitab = _kitabs.where((k) => k.id == _activeKitabId).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _appBarTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              _appBarSubtitle,
              style: const TextStyle(fontSize: 10, color: AppTheme.textSubtle),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Refresh Kitabs',
            onPressed: _loadKitabs,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppTheme.accentCyan),
                  SizedBox(height: 16),
                  Text('Loading your kitabs...', style: TextStyle(color: AppTheme.textMuted)),
                ],
              ),
            )
          : _buildCurrentPage(activeKitab),
      bottomNavigationBar: AppFooter(
        activeTab: _currentFooterTab,
        kitabsCount: _kitabs.length,
        hasActiveKitab: activeKitab != null,
        onTabSelected: _handleFooterTab,
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141F38) : Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark ? const Color(0xFF26375E) : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: AppTheme.accentCyan,
                size: 44,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Khisab Kitab',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.textWhite : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'حساب کتاب — مشین وار ڈیٹا',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.accentCyan,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: const Text(
                'Track your 15-day machine income cycles with a traditional ledger-style interface. Create your first kitab to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _showCreateModal,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Create First Kitab'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 36),

            // Feature Badges
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFeatureBadge(
                    icon: Icons.calendar_month_rounded,
                    title: '15-Day Cycles',
                    isDark: isDark,
                  ),
                  _buildFeatureBadge(
                    icon: Icons.savings_outlined,
                    title: 'Track Income',
                    isDark: isDark,
                  ),
                  _buildFeatureBadge(
                    icon: Icons.analytics_outlined,
                    title: 'View Reports',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBadge({
    required IconData icon,
    required String title,
    required bool isDark,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141F38) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF26375E) : const Color(0xFFCBD5E1),
            ),
          ),
          child: Icon(icon, color: AppTheme.accentCyan, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
