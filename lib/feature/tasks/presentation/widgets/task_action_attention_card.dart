import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskActionAttentionCard extends StatelessWidget {
  const TaskActionAttentionCard({
    super.key,
    required this.count,
    required this.message,
    required this.isInterior,
  });

  final int count;
  final String message;
  final bool isInterior;

  @override
  Widget build(BuildContext context) {
    final cardColor = isInterior
        ? const Color(0xFFD5D2CA)
        : const Color(0xFF111A1E);
    final borderColor = isInterior
        ? const Color(0xFF77716A)
        : const Color(0xFF4A5960);
    final titleColor = isInterior ? const Color(0xFF1F1F1F) : Colors.white;
    const bodyColor = Color(0xFF8E8E93);
    final iconBg = isInterior
        ? const Color(0xFFE7E1D3)
        : const Color(0xFF2A2F33);
    const iconAccent = Color(0xFFC08A2B);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconBg,
              border: Border.all(color: iconAccent, width: 1.4),
            ),
            child: Center(
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: iconAccent, width: 1.6),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '!',
                  style: TextStyle(
                    color: iconAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count actions needed',
                  style: TextStyle(
                    fontFamily: 'ClashDisplay',
                    color: titleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.manrope(
                    color: bodyColor,
                    fontSize: 12,
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
