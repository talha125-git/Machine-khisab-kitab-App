import 'package:flutter/material.dart';
import '../models/kitab.dart';
import '../theme/app_theme.dart';

class DayCard extends StatefulWidget {
  final DayEntry day;
  final int index;
  final bool readOnly;
  final Function(int index, Map<String, dynamic> data) onSave;

  const DayCard({
    super.key,
    required this.day,
    required this.index,
    required this.readOnly,
    required this.onSave,
  });

  @override
  State<DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<DayCard> {
  late TextEditingController _incomeController;
  late TextEditingController _notesController;
  late bool _isEditing;
  bool _justSaved = false;

  @override
  void initState() {
    super.initState();
    _incomeController = TextEditingController(text: widget.day.income);
    _notesController = TextEditingController(text: widget.day.notes);
    _isEditing = !widget.day.saved;
  }

  @override
  void didUpdateWidget(covariant DayCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.day != widget.day) {
      _incomeController.text = widget.day.income;
      _notesController.text = widget.day.notes;
      _isEditing = !widget.day.saved;
    }
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSave() {
    widget.onSave(widget.index, {
      'income': _incomeController.text.trim(),
      'notes': _notesController.text.trim(),
      'saved': true,
    });
    setState(() {
      _isEditing = false;
      _justSaved = true;
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _justSaved = false;
        });
      }
    });
  }

  void _confirmEmpty() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Empty Day Data'),
        content: Text(
          'Are you sure you want to empty the data for Day ${widget.day.dayNumber} (${Kitab.formatDate(widget.day.date)})?\n\nThis will clear all recorded income and notes for this day.',
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
              setState(() {
                _incomeController.text = '';
                _notesController.text = '';
                _isEditing = true;
              });
              widget.onSave(widget.index, {
                'income': '',
                'notes': '',
                'saved': false,
              });
            },
            child: const Text('Yes, Empty'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFriday = Kitab.isFriday(widget.day.date);
    final dayName = Kitab.getDayName(widget.day.date);
    final dateDisplay = Kitab.formatDate(widget.day.date);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: widget.day.saved
            ? (isDark ? const Color(0xFF111827) : Colors.white)
            : (isDark ? const Color(0xFF161F33) : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _justSaved
              ? AppTheme.emeraldGreen
              : isFriday
                  ? AppTheme.goldAmber.withValues(alpha: 0.6)
                  : widget.day.saved
                      ? (isDark ? const Color(0xFF24324D) : const Color(0xFFCBD5E1))
                      : (isDark ? const Color(0xFF2D3C5E) : const Color(0xFFE2E8F0)),
          width: isFriday || _justSaved ? 1.6 : 1.0,
        ),
        boxShadow: [
          if (_justSaved)
            BoxShadow(
              color: AppTheme.emeraldGreen.withValues(alpha: 0.2),
              blurRadius: 12,
              spreadRadius: 1,
            )
          else if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Day badge, date, Friday tag, and saved income
            Row(
              children: [
                // Day number badge
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: widget.day.saved
                        ? AppTheme.primaryBlue.withValues(alpha: 0.15)
                        : (isDark ? const Color(0xFF1F293D) : const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: widget.day.saved
                          ? AppTheme.primaryBlue.withValues(alpha: 0.4)
                          : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                    ),
                  ),
                  child: Text(
                    '${widget.day.dayNumber}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: widget.day.saved
                          ? AppTheme.accentCyan
                          : (isDark ? AppTheme.textMuted : AppTheme.textDarkMuted),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Date and Day Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateDisplay,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            dayName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isFriday ? FontWeight.w700 : FontWeight.w400,
                              color: isFriday ? AppTheme.goldAmber : AppTheme.textSubtle,
                            ),
                          ),
                          if (isFriday) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppTheme.goldAmber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Jummah 🕌',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.goldAmber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Income Display (when saved and not editing)
                if (widget.day.saved && !_isEditing)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Income',
                        style: TextStyle(fontSize: 10, color: AppTheme.textSubtle),
                      ),
                      Text(
                        '₨ ${widget.day.income.trim().isNotEmpty ? Kitab.formatPKR(widget.day.incomeValue) : '0'}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? const Color(0xFF67E8F9) : const Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            // Content Section: Form or Details
            if (_isEditing && !widget.readOnly) ...[
              const SizedBox(height: 12),
              // Income Input
              TextField(
                controller: _incomeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Income (PKR ₨)',
                  hintText: 'e.g. 5000',
                  prefixIcon: const Icon(Icons.attach_money_rounded, color: AppTheme.accentCyan, size: 18),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),

              // Notes Input
              TextField(
                controller: _notesController,
                maxLength: 100,
                decoration: InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'e.g. Machine earnings / fuel expense',
                  prefixIcon: const Icon(Icons.note_alt_outlined, color: AppTheme.textMuted, size: 18),
                  counterText: '',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _handleSave,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: Text(widget.day.saved ? 'Update Entry' : 'Save Entry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ] else ...[
              // Read-only / Saved details view
              if (widget.day.notes.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.notes_rounded, size: 14, color: AppTheme.textSubtle),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.day.notes,
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // Actions (Edit, Empty) when not read-only
              if (!widget.readOnly) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: _confirmEmpty,
                      icon: const Icon(Icons.delete_outline, size: 15, color: AppTheme.dangerRed),
                      label: const Text(
                        'Empty',
                        style: TextStyle(fontSize: 12, color: AppTheme.dangerRed),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                      icon: const Icon(Icons.edit_outlined, size: 14, color: AppTheme.accentCyan),
                      label: const Text(
                        'Edit',
                        style: TextStyle(fontSize: 12, color: AppTheme.accentCyan),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        visualDensity: VisualDensity.compact,
                        side: BorderSide(color: AppTheme.accentCyan.withValues(alpha: 0.4)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
