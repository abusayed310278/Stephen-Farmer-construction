import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskSectionHeaderRow extends StatelessWidget {
  const TaskSectionHeaderRow({
    super.key,
    required this.title,
    required this.pendingCount,
    required this.isInterior,
    this.showLeadingIcon = false,
  });

  final String title;
  final int pendingCount;
  final bool isInterior;
  final bool showLeadingIcon;

  @override
  Widget build(BuildContext context) {
    final titleColor = Colors.white;
    final badgeColor = isInterior
        ? const Color(0xFF7C715E)
        : const Color(0xFF1B262D);

    return Row(
      children: [
        if (showLeadingIcon)
          SizedBox(
            width: 24,
            height: 24,
            child: Icon(
              Icons.person_outline_rounded,
              color: titleColor,
              size: 24,
            ),
          ),
        if (showLeadingIcon) const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'ClashDisplay',
              color: titleColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 22 / 16,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$pendingCount PENDING',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 22 / 12,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
