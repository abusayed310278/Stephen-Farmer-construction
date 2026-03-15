import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/financials_project_entity.dart';

class FinancialsPaymentScheduleItemCard extends StatelessWidget {
  const FinancialsPaymentScheduleItemCard({super.key, required this.item});

  final PaymentScheduleItemEntity item;

  @override
  Widget build(BuildContext context) {
    final statusText = item.isPaid ? 'Paid' : 'Due Now';
    final statusColor = item.isPaid
        ? const Color(0xFF7D9975)
        : const Color(0xFFC08A2B);
    final iconColor = item.isPaid
        ? const Color(0xFF8AA481)
        : const Color(0xFFC08A2B);
    final iconBackgroundColor = item.isPaid
        ? const Color(0xFFCFD7C2)
        : const Color(0x40A77935);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border.all(
          color: item.isPaid
              ? const Color(0xFF7D9975).withValues(alpha: 0.55)
              : const Color(0xFFC08A2B).withValues(alpha: 0.55),

          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            padding: const EdgeInsets.fromLTRB(2, 4, 2, 4),
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: iconColor.withValues(alpha: 0.55)),
            ),
            child: Icon(
              item.isPaid ? Icons.check_rounded : Icons.access_time_rounded,
              size: 20,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFF161D1E),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDisplayDate(item.dateLabel),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFF161D1E),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatAed(item.amount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFF161D1E),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    color: item.isPaid
                        ? const Color(0xFF798B56)
                        : statusColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatAed(int amount) {
  final formatted = amount.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
  return 'AED $formatted';
}

String _formatDisplayDate(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return value;

  final parsed = DateTime.tryParse(value);
  if (parsed != null) return _formatMmmDyyyy(parsed);

  return value;
}

String _formatMmmDyyyy(DateTime dt) {
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final month = months[dt.month - 1];
  return '$month ${dt.day}, ${dt.year}';
}
