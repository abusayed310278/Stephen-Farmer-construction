import 'package:flutter/material.dart';

class UpdatePostCard extends StatelessWidget {
  const UpdatePostCard({super.key, this.isInteriorTheme = false});

  final bool isInteriorTheme;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isInteriorTheme
        ? Colors.transparent
        : Colors.transparent;
    final borderColor = isInteriorTheme
        ? Colors.transparent
        : Colors.white.withValues(alpha: .08);
    final primaryTextColor = isInteriorTheme
        ? const Color(0xFF1B1B1B)
        : Colors.white;
    final secondaryTextColor = isInteriorTheme
        ? const Color(0xFF6F6B62)
        : Colors.white.withValues(alpha: .55);
    final contentTextColor = isInteriorTheme
        ? const Color(0xFF1D1D1D)
        : Colors.white.withValues(alpha: .85);
    final metaStatColor = isInteriorTheme
        ? const Color(0xFFF3EEDD)
        : Colors.white.withValues(alpha: .65);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(
                  "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=200&fit=crop",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Rain Altmann",
                      style: TextStyle(
                        color: primaryTextColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "SITE MANAGER  ·  2H AGO",
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: .4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.more_horiz, color: secondaryTextColor),
            ],
          ),

          const SizedBox(height: 10),

          // Post text
          Text(
            "Foundation work completed today. The concrete has been poured and cured, ready for next phrase of framing starting monday.",
            style: TextStyle(
              color: contentTextColor,
              fontSize: 13.5,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 12),

          // Image Grid (screenshot-like)
          SizedBox(
            height: 250,
            child: Row(
              children: [
                // Left big image
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      "https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=900&auto=format&fit=crop",
                      fit: BoxFit.cover,
                      height: double.infinity,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Right column: top big + bottom 3 small
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            "https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=900&auto=format&fit=crop",
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  "https://images.unsplash.com/photo-1497366216548-37526070297c?w=600&auto=format&fit=crop",
                                  fit: BoxFit.cover,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  "https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=600&auto=format&fit=crop",
                                  fit: BoxFit.cover,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=600&auto=format&fit=crop",
                                  fit: BoxFit.cover,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Reactions row
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.red, size: 16),
              const SizedBox(width: 6),
              Text(
                "3",
                style: TextStyle(
                  color: isInteriorTheme
                      ? const Color(0xFFF3EEDD)
                      : Colors.white.withValues(alpha: .75),
                  fontSize: 12.5,
                ),
              ),
              const Spacer(),
              Text(
                "3 Comments",
                style: TextStyle(color: metaStatColor, fontSize: 12.5),
              ),
              const SizedBox(width: 12),
              Text(
                "2 Shares",
                style: TextStyle(color: metaStatColor, fontSize: 12.5),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Divider(
            color: isInteriorTheme
                ? const Color(0xCCCDC1A7)
                : Colors.white.withValues(alpha: .10),
            height: 1,
          ),
          const SizedBox(height: 6),

          // Action buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ActionBtn(
                icon: Icons.favorite_border,
                label: "Heart",
                onTap: () {},
                isInteriorTheme: isInteriorTheme,
              ),
              _ActionBtn(
                icon: Icons.mode_comment_outlined,
                label: "Comment",
                onTap: () {},
                isInteriorTheme: isInteriorTheme,
              ),
              _ActionBtn(
                icon: Icons.share_outlined,
                label: "Share",
                onTap: () {},
                isInteriorTheme: isInteriorTheme,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isInteriorTheme;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isInteriorTheme = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(
              icon,
              color: isInteriorTheme
                  ? const Color(0xFFD8C79A)
                  : Colors.white.withValues(alpha: .75),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isInteriorTheme
                    ? const Color(0xFFD8C79A)
                    : Colors.white.withValues(alpha: .75),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}