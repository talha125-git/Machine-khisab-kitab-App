import 'package:flutter/material.dart';
import '../models/kitab.dart';
import '../theme/app_theme.dart';
import '../services/pdf_service.dart';

class AllKitabsScreen extends StatefulWidget {
  final List<Kitab> kitabs;
  final String? activeKitabId;
  final Function(String id) onSelectKitab;
  final VoidCallback onCreateNew;
  final Function(String id) onDeleteKitab;
  final VoidCallback onRefresh;

  const AllKitabsScreen({
    super.key,
    required this.kitabs,
    required this.activeKitabId,
    required this.onSelectKitab,
    required this.onCreateNew,
    required this.onDeleteKitab,
    required this.onRefresh,
  });

  @override
  State<AllKitabsScreen> createState() => _AllKitabsScreenState();
}

class _AllKitabsScreenState extends State<AllKitabsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDelete(BuildContext context, Kitab kitab) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Kitab'),
        content: Text(
          'Are you sure you want to permanently delete "${kitab.title}"?\n\nThis cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
            onPressed: () {
              Navigator.pop(ctx);
              widget.onDeleteKitab(kitab.id);
            },
            child: const Text('Yes, Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredKitabs = widget.kitabs.where((k) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final numStr = 'kitab #${k.number}'.toLowerCase();
      final title = k.title.toLowerCase();
      final dates = '${k.startDate} ${k.endDate}'.toLowerCase();
      return numStr.contains(query) || title.contains(query) || dates.contains(query);
    }).toList();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            // Page Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Kitabs (${widget.kitabs.length})',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'تمام کتب — Manage & Switch Ledgers',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.accentCyan,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: widget.onCreateNew,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('New Kitab'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Bar
            if (widget.kitabs.length > 2) ...[
              TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by Kitab number or date...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Kitabs List
            if (filteredKitabs.isEmpty)
              Container(
                margin: const EdgeInsets.only(top: 40),
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131D33) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF243353) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.auto_stories_outlined,
                      size: 56,
                      color: AppTheme.textSubtle.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.kitabs.isEmpty
                          ? 'No kitabs recorded yet.'
                          : 'No matching kitabs found.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create a 15-day cycle to start recording your machine income.',
                      style: TextStyle(fontSize: 13, color: AppTheme.textSubtle),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: widget.onCreateNew,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Create First Kitab'),
                    ),
                  ],
                ),
              )
            else
              ...filteredKitabs.map((k) {
                final isActive = k.id == widget.activeKitabId;
                final stats = k.stats;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isActive
                        ? (isDark ? const Color(0xFF1A2B4C) : const Color(0xFFE0F2FE))
                        : (isDark ? const Color(0xFF131D31) : Colors.white),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isActive
                          ? AppTheme.accentCyan
                          : (isDark ? const Color(0xFF233352) : const Color(0xFFCBD5E1)),
                      width: isActive ? 1.6 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => widget.onSelectKitab(k.id),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: Title, badges, delete
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '#${k.number}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppTheme.accentCyan,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Kitab #${k.number}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                                          ),
                                        ),
                                        if (isActive) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'Active',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.accentCyan,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${Kitab.formatKitabDate(k.startDate)} → ${Kitab.formatKitabDate(k.endDate)}',
                                      style: const TextStyle(fontSize: 12, color: AppTheme.textSubtle),
                                    ),
                                  ],
                                ),
                              ),

                              if (k.completed)
                                Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.emeraldGreen.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle, size: 12, color: AppTheme.emeraldGreen),
                                      SizedBox(width: 4),
                                      Text(
                                        'Completed',
                                        style: TextStyle(
                                          color: AppTheme.emeraldGreen,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              IconButton(
                                icon: const Icon(Icons.picture_as_pdf_outlined, size: 18, color: AppTheme.accentCyan),
                                tooltip: 'Export PDF',
                                onPressed: () => PdfService.generateAndShareKitabPDF(k),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.dangerRed),
                                tooltip: 'Delete Kitab',
                                onPressed: () => _confirmDelete(context, k),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Stats Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Days Completed: ${stats.daysCompleted} / 15',
                                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                              ),
                              Text(
                                '₨ ${Kitab.formatPKR(stats.totalIncome)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.goldAmber,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: SizedBox(
                              height: 6,
                              child: LinearProgressIndicator(
                                value: stats.progress / 100.0,
                                backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  stats.progress >= 100 ? AppTheme.emeraldGreen : AppTheme.primaryBlue,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Open hint
                          Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isActive ? 'Currently Viewing Ledger' : 'Tap to open ledger',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isActive ? AppTheme.accentCyan : AppTheme.textSubtle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 13,
                                  color: isActive ? AppTheme.accentCyan : AppTheme.textSubtle,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
