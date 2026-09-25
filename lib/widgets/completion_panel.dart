import 'package:flutter/material.dart';
import '../models/kitab.dart';
import '../theme/app_theme.dart';

class CompletionPanel extends StatefulWidget {
  final Kitab kitab;
  final Function(Map<String, dynamic> data) onSaveMoney;

  const CompletionPanel({
    super.key,
    required this.kitab,
    required this.onSaveMoney,
  });

  @override
  State<CompletionPanel> createState() => _CompletionPanelState();
}

class _CompletionPanelState extends State<CompletionPanel> {
  late TextEditingController _spendController;
  late TextEditingController _handOverController;
  late TextEditingController _iHaveController;
  late bool _moneySaved;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _spendController = TextEditingController(text: widget.kitab.spendMoney ?? '');
    _handOverController = TextEditingController(text: widget.kitab.handOver ?? widget.kitab.moneyLeft ?? '');
    _iHaveController = TextEditingController(text: widget.kitab.iHave ?? widget.kitab.masara ?? '');
    _moneySaved = widget.kitab.moneySaved;
  }

  @override
  void didUpdateWidget(covariant CompletionPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.kitab != widget.kitab) {
      _spendController.text = widget.kitab.spendMoney ?? '';
      _handOverController.text = widget.kitab.handOver ?? widget.kitab.moneyLeft ?? '';
      _iHaveController.text = widget.kitab.iHave ?? widget.kitab.masara ?? '';
      _moneySaved = widget.kitab.moneySaved;
    }
  }

  @override
  void dispose() {
    _spendController.dispose();
    _handOverController.dispose();
    _iHaveController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    setState(() {
      _isSaving = true;
    });

    await widget.onSaveMoney({
      'spendMoney': _spendController.text.trim(),
      'handOver': _handOverController.text.trim(),
      'iHave': _iHaveController.text.trim(),
      'moneyLeft': _handOverController.text.trim(),
      'masara': _iHaveController.text.trim(),
      'moneySaved': true,
    });

    if (mounted) {
      setState(() {
        _moneySaved = true;
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = widget.kitab.stats;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131C31) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF233554) : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 3 Small Money Boxes: Spend, Hand Over, I Have
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: [
                  // Spend
                  Expanded(
                    child: _buildMoneyBox(
                      isDark: isDark,
                      title: '💸 Spend',
                      controller: _spendController,
                      savedValue: widget.kitab.spendMoney,
                      borderColor: const Color(0xFF0EA5E9).withValues(alpha: 0.4),
                      bgColor: isDark
                          ? const Color(0xFF0C4A6E).withValues(alpha: 0.2)
                          : const Color(0xFFF0F9FF),
                      valueColor: const Color(0xFFF87171),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Hand over
                  Expanded(
                    child: _buildMoneyBox(
                      isDark: isDark,
                      title: '🤝 Hand Over',
                      controller: _handOverController,
                      savedValue: widget.kitab.handOver ?? widget.kitab.moneyLeft,
                      borderColor: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                      bgColor: isDark
                          ? const Color(0xFF1E3A8A).withValues(alpha: 0.2)
                          : const Color(0xFFEFF6FF),
                      valueColor: const Color(0xFF34D399),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // I have
                  Expanded(
                    child: _buildMoneyBox(
                      isDark: isDark,
                      title: '💼 I Have',
                      controller: _iHaveController,
                      savedValue: widget.kitab.iHave ?? widget.kitab.masara,
                      borderColor: const Color(0xFFA855F7).withValues(alpha: 0.4),
                      bgColor: isDark
                          ? const Color(0xFF581C87).withValues(alpha: 0.2)
                          : const Color(0xFFFAF5FF),
                      valueColor: const Color(0xFFC084FC),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Completion Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.emeraldGreen.withValues(alpha: 0.15),
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: AppTheme.goldAmber,
              size: 40,
            ),
          ),
          const SizedBox(height: 10),

          Text(
            'Kitab Completed!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.textWhite : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'All 15 days have been recorded. This kitab is now finalized.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppTheme.textSubtle),
          ),
          const SizedBox(height: 14),

          // Total Earnings
          Text(
            '₨ ${Kitab.formatPKR(stats.totalIncome)}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppTheme.goldAmber,
              letterSpacing: 0.5,
            ),
          ),
          const Text(
            'Total Earnings',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 16),

          // Save / Edit Money Button
          Align(
            alignment: Alignment.centerRight,
            child: _moneySaved
                ? OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _moneySaved = false;
                      });
                    },
                    icon: const Icon(Icons.edit_outlined, size: 14),
                    label: const Text('Edit Numbers'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.textSubtle.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: _isSaving ? null : _handleSave,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check_circle_outline, size: 16),
                    label: Text(_isSaving ? 'Saving...' : 'Save Final Numbers'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.emeraldGreen,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyBox({
    required bool isDark,
    required String title,
    required TextEditingController controller,
    required String? savedValue,
    required Color borderColor,
    required Color bgColor,
    required Color valueColor,
  }) {
    final numVal = double.tryParse(savedValue?.replaceAll(',', '') ?? '0') ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.textMuted : AppTheme.textDarkMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          if (_moneySaved)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '₨ ${Kitab.formatPKR(numVal)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            )
          else
            SizedBox(
              height: 36,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.textDark,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  hintText: '0',
                  hintStyle: const TextStyle(color: AppTheme.textSubtle),
                  fillColor: isDark
                      ? const Color(0xFF0F172A).withValues(alpha: 0.6)
                      : Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
