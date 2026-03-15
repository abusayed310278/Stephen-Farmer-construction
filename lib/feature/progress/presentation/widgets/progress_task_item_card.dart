import 'package:flutter/material.dart';

import '../../domain/entities/progress_entity.dart';

class ProgressTaskItemCard extends StatelessWidget {
  const ProgressTaskItemCard({
    super.key,
    required this.task,
    this.isInteriorTheme = false,
  });

  final ProgressTaskEntity task;
  final bool isInteriorTheme;

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = task.status.toLowerCase() == 'completed';
    final Color statusColor = isCompleted
        ? const Color(0xFF009A0A)
        : (isInteriorTheme ? const Color(0xFFE3D2AA) : const Color(0xFFAAB5BA));
    final Color titleColor = isInteriorTheme
        ? const Color(0xFFFFFFFF)
        : Colors.white;
    const Color percentColor = Colors.white;
    final Color cardColor = isInteriorTheme
        ? Colors.transparent
        : const Color(0xFF111A1E);
    final Color progressBackground = isInteriorTheme
        ? const Color(0xFFFFFFFF)
        : Colors.white;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3D2AA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : Icons.access_time_rounded,
                  size: 18,
                  color: const Color(0xFF141414),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
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
                    Text(
                      task.status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'ClashDisplay',
                        color: statusColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${task.progressPercent}%',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      color: percentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: task.progressPercent.clamp(0, 100) / 100,
              minHeight: 8,
              backgroundColor: progressBackground,
              color: const Color(0xFFE3D2AA),
            ),
          ),
        ],
      ),
    );
  }
}
