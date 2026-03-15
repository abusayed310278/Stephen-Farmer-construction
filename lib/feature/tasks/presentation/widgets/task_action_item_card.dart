import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/task_project_entity.dart';

class TaskActionItemCard extends StatelessWidget {
  const TaskActionItemCard({
    super.key,
    required this.item,
    required this.isInterior,
    this.onTap,
    this.showQuickActions = false,
    this.onApprove,
    this.onReject,
  });

  final TaskItemEntity item;
  final bool isInterior;
  final VoidCallback? onTap;
  final bool showQuickActions;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final bool highPriority = item.priority.trim().toLowerCase() == 'high';
    final cardColor = isInterior
        ? const Color(0xFFD5D2CA)
        : const Color(0xFF111A1E);
    final borderColor = isInterior
        ? const Color(0xFF77716A)
        : const Color(0xFF4A5960);
    final titleColor = isInterior ? const Color(0xFF1E1E1E) : Colors.white;
    const subtitleColor = Color(0xFF8E8E93);
    final priorityChipColor = highPriority
        ? isInterior
              ? const Color(0xFFF19A98)
              : const Color(0x80FF383C)
        : isInterior
        ? const Color(0xFF9A6F00)
        : const Color(0xFF8A6400);
    final priorityChipPadding = isInterior && highPriority
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 4);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      color: titleColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFB07E2A),
                  size: 28,
                ),
              ],
            ),
            Text(
              item.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                color: subtitleColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: priorityChipPadding,
              decoration: BoxDecoration(
                color: priorityChipColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                item.priority.toUpperCase(),
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 22 / 12,
                  letterSpacing: 0,
                ),
              ),
            ),
            if (showQuickActions) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: ElevatedButton(
                        onPressed: onApprove,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB5946E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Text(
                          'Approve',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: OutlinedButton(
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFB84B4B)),
                          foregroundColor: const Color(0xFFFFCACA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Text(
                          'Reject',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
