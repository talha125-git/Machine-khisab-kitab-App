import 'dart:math';
import 'package:flutter/material.dart';
import '../models/kitab.dart';
import '../theme/app_theme.dart';
import '../widgets/day_card.dart';
import '../widgets/summary_card.dart';
import '../widgets/completion_panel.dart';
import '../services/pdf_service.dart';

class KitabDetailScreen extends StatefulWidget {
  final Kitab kitab;
  final String userId;
  final Function(Kitab updatedKitab) onUpdateKitab;
  final VoidCallback onResetKitab;

  const KitabDetailScreen({
    super.key,
    required this.kitab,
    required this.userId,
    required this.onUpdateKitab,
    required this.onResetKitab,
  });

  @override
  State<KitabDetailScreen> createState() => _KitabDetailScreenState();
}

class _KitabDetailScreenState extends State<KitabDetailScreen> {
  late Kitab _kitab;
  int _manualVisibleCount = 0;
  bool _isEditingPage = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _kitab = widget.kitab;
  }

  @override
  void didUpdateWidget(covariant KitabDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.kitab.id != widget.kitab.id) {
      _kitab = widget.kitab;
      _manualVisibleCount = 0;
      _isEditingPage = false;
    } else {
      _kitab = widget.kitab;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int get _lastSavedIndex {
    int last = 0;
    for (int i = 0; i < _kitab.days.length; i++) {
      if (_kitab.days[i].saved) {
        last = i + 1;
      }
    }
    return last;
  }

  int get _visibleCount {
    final count = max(_lastSavedIndex, _manualVisibleCount);
    return min(15, count == 0 ? 1 : count);
  }

  bool get _isReadOnly => _kitab.completed && !_isEditingPage;

  void _handleSaveDay(int dayIndex, Map<String, dynamic> data) {
    if (data['saved'] == false) {
      _manualVisibleCount = max(_manualVisibleCount, dayIndex + 1);
    }

    final updatedDays = List<DayEntry>.from(_kitab.days);
    final target = updatedDays[dayIndex];
    target.income = data['income'] ?? '';
    target.notes = data['notes'] ?? '';
    target.saved = data['saved'] == true;

    final updated = Kitab(
      id: _kitab.id,
      userId: _kitab.userId,
      username: _kitab.username,
      title: _kitab.title,
      number: _kitab.number,
      startDate: _kitab.startDate,
      endDate: _kitab.endDate,
      days: updatedDays,
      completed: updatedDays.where((d) => d.saved && d.income.trim().isNotEmpty).length == 15,
      createdAt: _kitab.createdAt,
      spendMoney: _kitab.spendMoney,
      handOver: _kitab.handOver,
      iHave: _kitab.iHave,
      moneyLeft: _kitab.moneyLeft,
      masara: _kitab.masara,
      moneySaved: _kitab.moneySaved,
    );

    setState(() {
      _kitab = updated;
    });

    widget.onUpdateKitab(updated);
  }

  void _handleSaveMoney(Map<String, dynamic> data) {
    final updated = Kitab(
      id: _kitab.id,
      userId: _kitab.userId,
      username: _kitab.username,
      title: _kitab.title,
      number: _kitab.number,
      startDate: _kitab.startDate,
      endDate: _kitab.endDate,
      days: _kitab.days,
      completed: _kitab.completed,
      createdAt: _kitab.createdAt,
      spendMoney: data['spendMoney'],
      handOver: data['handOver'],
      iHave: data['iHave'],
      moneyLeft: data['moneyLeft'],
      masara: data['masara'],
      moneySaved: data['moneySaved'] == true,
    );

    setState(() {
      _kitab = updated;
    });

    widget.onUpdateKitab(updated);
  }

  void _handleTodayEnter() {
    setState(() {
      _manualVisibleCount = min(15, _visibleCount + 1);
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Kitab Data'),
        content: const Text(
          'Are you sure you want to clear this kitab? All recorded income data for this period will be reset to zero.',
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
              widget.onResetKitab();
            },
            child: const Text('Yes, Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            // Top Header: Title & Action buttons
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kitab #${_kitab.number}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textWhite,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'From ${Kitab.formatKitabDate(_kitab.startDate)} to ${Kitab.formatKitabDate(_kitab.endDate)}',
                              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),

                      // Action buttons: Download PDF, Edit Page, Reset
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // Download PDF
                          OutlinedButton.icon(
                            onPressed: () => PdfService.generateAndShareKitabPDF(_kitab),
                            icon: const Icon(Icons.picture_as_pdf_outlined, size: 16, color: AppTheme.accentCyan),
                            label: const Text('PDF', style: TextStyle(color: AppTheme.accentCyan)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              side: BorderSide(color: AppTheme.accentCyan.withValues(alpha: 0.4)),
                            ),
                          ),

                          // Edit page toggle (when completed)
                          if (_kitab.completed)
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isEditingPage = !_isEditingPage;
                                });
                              },
                              icon: Icon(
                                _isEditingPage ? Icons.check_circle_outline : Icons.edit_note_rounded,
                                size: 16,
                                color: _isEditingPage ? AppTheme.goldAmber : AppTheme.textMuted,
                              ),
                              label: Text(
                                _isEditingPage ? 'Done Editing' : 'Edit Page',
                                style: TextStyle(
                                  color: _isEditingPage ? AppTheme.goldAmber : AppTheme.textMuted,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                side: BorderSide(
                                  color: _isEditingPage
                                      ? AppTheme.goldAmber.withValues(alpha: 0.6)
                                      : const Color(0xFF374151),
                                ),
                              ),
                            ),

                          // Reset button
                          if (!_isReadOnly)
                            OutlinedButton.icon(
                              onPressed: _confirmReset,
                              icon: const Icon(Icons.restart_alt_rounded, size: 16, color: AppTheme.dangerRed),
                              label: const Text('Reset', style: TextStyle(color: AppTheme.dangerRed)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                side: BorderSide(color: AppTheme.dangerRed.withValues(alpha: 0.4)),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Summary Card
            SummaryCard(kitab: _kitab),

            // Action Buttons: Today Enter & Delete Empty Days
            if (!_isReadOnly) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    if (_visibleCount < 15)
                      ElevatedButton.icon(
                        onPressed: _handleTodayEnter,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Today Enter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E2D4A),
                          foregroundColor: AppTheme.accentCyan,
                          side: const BorderSide(color: Color(0xFF2E4166)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    const SizedBox(width: 10),
                    if (_visibleCount > _lastSavedIndex)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _manualVisibleCount = 0;
                          });
                        },
                        icon: const Icon(Icons.delete_sweep_outlined, size: 18, color: AppTheme.dangerRed),
                        label: const Text(
                          'Delete Empty Days',
                          style: TextStyle(color: AppTheme.dangerRed),
                        ),
                      ),
                  ],
                ),
              ),
            ],

            // Day Cards (Responsive: 1 column on mobile, 2 columns on tablet/desktop)
            LayoutBuilder(
              builder: (context, constraints) {
                final visibleDays = _kitab.days.sublist(0, _visibleCount);

                if (constraints.maxWidth > 650) {
                  // Two-column layout
                  return Wrap(
                    spacing: 12,
                    runSpacing: 0,
                    children: List.generate(visibleDays.length, (idx) {
                      final itemWidth = (constraints.maxWidth - 12) / 2;
                      return SizedBox(
                        width: itemWidth,
                        child: DayCard(
                          day: visibleDays[idx],
                          index: idx,
                          readOnly: _isReadOnly,
                          onSave: _handleSaveDay,
                        ),
                      );
                    }),
                  );
                } else {
                  // Single column
                  return Column(
                    children: List.generate(visibleDays.length, (idx) {
                      return DayCard(
                        day: visibleDays[idx],
                        index: idx,
                        readOnly: _isReadOnly,
                        onSave: _handleSaveDay,
                      );
                    }),
                  );
                }
              },
            ),

            // Completion Panel
            if (_kitab.completed)
              CompletionPanel(
                kitab: _kitab,
                onSaveMoney: _handleSaveMoney,
              ),
          ],
        ),
      ),
    );
  }
}
