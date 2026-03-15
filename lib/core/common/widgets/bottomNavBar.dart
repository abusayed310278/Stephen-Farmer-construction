import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stephen_farmer/core/utils/images.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool includeFinancials;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.includeFinancials = true,
  });

  static const List<_NavItemData> _items = [
    _NavItemData(label: 'Update', iconPath: AssetsImages.navHome),
    _NavItemData(label: 'Progress', iconPath: AssetsImages.navProgress),
    _NavItemData(label: 'Financials', iconPath: AssetsImages.navFinancials),
    _NavItemData(label: 'Tasks', iconPath: AssetsImages.navTask),
    _NavItemData(label: 'Documents', iconPath: AssetsImages.navDocument),
  ];

  @override
  Widget build(BuildContext context) {
    const Color selectedColor = Color(0xFFA77935);
    const Color unselectedColor = Colors.white;
    final List<_NavItemData> visibleItems = includeFinancials
        ? _items
        : [_items[0], _items[1], _items[3], _items[4]];

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: const BoxDecoration(
          color: Color(0xFF0F161C),
          border: Border(top: BorderSide(color: Color(0xFF1E272E), width: 1)),
        ),
        child: Row(
          children: List.generate(visibleItems.length, (index) {
            final bool isSelected = index == currentIndex;
            final _NavItemData item = visibleItems[index];

            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onTap(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        item.iconPath,
                        height: 24,
                        width: 24,
                        fit: BoxFit.contain,
                        color: isSelected ? selectedColor : unselectedColor,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: GoogleFonts.manrope(
                          color: isSelected ? selectedColor : unselectedColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final String iconPath;

  const _NavItemData({required this.label, required this.iconPath});
}
