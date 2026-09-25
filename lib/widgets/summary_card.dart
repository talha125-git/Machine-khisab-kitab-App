import 'package:flutter/material.dart';
import '../models/kitab.dart';
import '../theme/app_theme.dart';

class SummaryCard extends StatefulWidget {
  final Kitab kitab;

  const SummaryCard({super.key, required this.kitab});

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> {
  bool _showAmounts = true;

  @override
  Widget build(BuildContext context) {
    final stats = widget.kitab.stats;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131B2E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF263554) : const Color(0xFFCBD5E1),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Icon(
                      Icons.bar_chart_rounded,
                      color: AppTheme.accentCyan,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'SUMMARY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showAmounts = !_showAmounts;
                      });
                    },
                    icon: Icon(
                      _showAmounts
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppTheme.textMuted,
                      size: 18,
                    ),
                    tooltip: _showAmounts ? 'Hide Amounts' : 'Show Amounts',
                    visualDensity: VisualDensity.compact,
                  ),
                  if (widget.kitab.completed) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.emeraldGreen.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.emeraldGreen.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 11,
                            color: AppTheme.emeraldGreen,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Completed',
                            style: TextStyle(
                              color: AppTheme.emeraldGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 4 Stat Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 450;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isNarrow ? 2 : 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: isNarrow ? 2.6 : 2.2,
                children: [
                  // Total Income
                  _buildStatTile(
                    title: 'Total Income',
                    value: _showAmounts
                        ? '₨ ${Kitab.formatPKR(stats.totalIncome)}'
                        : '•••••••',
                    bgColor: const Color(0xFFFEF3C7).withValues(alpha: 0.08),
                    borderColor: const Color(
                      0xFFF59E0B,
                    ).withValues(alpha: 0.35),
                    textColor: const Color(0xFFFBBF24),
                  ),

                  // Avg / Day
                  _buildStatTile(
                    title: 'Avg / Day',
                    value: _showAmounts
                        ? '₨ ${Kitab.formatPKR(stats.avgIncome)}'
                        : '•••••••',
                    bgColor: const Color(0xFFD1FAE5).withValues(alpha: 0.08),
                    borderColor: const Color(
                      0xFF10B981,
                    ).withValues(alpha: 0.35),
                    textColor: const Color(0xFF34D399),
                  ),

                  // Days Filled
                  _buildStatTile(
                    title: 'Days Filled',
                    value: '${stats.daysCompleted} / 15',
                    bgColor: const Color(0xFFFEE2E2).withValues(alpha: 0.08),
                    borderColor: const Color(
                      0xFFEF4444,
                    ).withValues(alpha: 0.35),
                    textColor: const Color(0xFFF87171),
                  ),

                  // Remaining
                  _buildStatTile(
                    title: 'Remaining',
                    value: '${stats.daysRemaining}',
                    bgColor: const Color(0xFFDBEAFE).withValues(alpha: 0.08),
                    borderColor: const Color(
                      0xFF3B82F6,
                    ).withValues(alpha: 0.35),
                    textColor: const Color(0xFF60A5FA),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),

          // Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress',
                style: TextStyle(fontSize: 11, color: AppTheme.textSubtle),
              ),
              Text(
                '${stats.progress.round()}%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accentCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 5,
              child: LinearProgressIndicator(
                value: stats.progress / 100.0,
                backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(
                  stats.progress >= 100
                      ? AppTheme.emeraldGreen
                      : AppTheme.primaryBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: AppTheme.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
