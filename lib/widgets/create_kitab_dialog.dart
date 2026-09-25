import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class CreateKitabDialog extends StatefulWidget {
  final int nextNumber;
  final Function(DateTime startDate) onCreated;

  const CreateKitabDialog({
    super.key,
    required this.nextNumber,
    required this.onCreated,
  });

  @override
  State<CreateKitabDialog> createState() => _CreateKitabDialogState();
}

class _CreateKitabDialogState extends State<CreateKitabDialog> {
  DateTime _startDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final endDate = _startDate.add(const Duration(days: 14));
    final startStr = DateFormat('MMMM d').format(_startDate);
    final endStr = DateFormat('MMMM d, y').format(endDate);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: const Color(0xFF131D33),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryBlue.withValues(alpha: 0.15),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: AppTheme.accentCyan,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),

            // Urdu Title
            const Text(
              'نیا کتاب',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textWhite,
              ),
            ),
            const SizedBox(height: 4),

            // Subtitle
            Text(
              'Create New Kitab #${widget.nextNumber}',
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 20),

            // Date Selection Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'START DATE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSubtle,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: AppTheme.primaryBlue,
                                surface: Color(0xFF111827),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          _startDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF162035),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF2B3A5A)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('EEEE, MMM d, y').format(_startDate),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textWhite,
                            ),
                          ),
                          const Icon(Icons.calendar_today_rounded, color: AppTheme.accentCyan, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      children: [
                        const TextSpan(text: 'This kitab will cover '),
                        TextSpan(
                          text: startStr,
                          style: const TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.w600),
                        ),
                        const TextSpan(text: ' to '),
                        TextSpan(
                          text: endStr,
                          style: const TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.w600),
                        ),
                        const TextSpan(text: ' (15-day cycle).'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onCreated(_startDate);
                    },
                    child: const Text('Create Kitab'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
