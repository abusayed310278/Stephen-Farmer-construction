
import 'package:flutter/material.dart';

import '../../../../core/utils/images.dart';

class CategoryPreviewData {
  final String category;
  final String title;
  final String description;
  final String? thumbnailUrl;

  const CategoryPreviewData({
    required this.category,
    required this.title,
    required this.description,
    this.thumbnailUrl,
  });
}

class UpdateCategoryDropdownCard extends StatelessWidget {
  const UpdateCategoryDropdownCard({
    super.key,
    required this.isInterior,
    required this.items,
    required this.selectedItem,
    required this.isMenuOpen,
    required this.previewBuilder,
    required this.onToggle,
    required this.onSelect,
  });

  final bool isInterior;
  final List<String> items;
  final String selectedItem;
  final bool isMenuOpen;
  final CategoryPreviewData Function(String item) previewBuilder;
  final VoidCallback onToggle;
  final ValueChanged<String> onSelect;
  static const Map<String, String> _categoryThumbnailUrls = {
    "foundation": "https://images.unsplash.com/photo-1591825729269-caeb344f6df2?w=600&auto=format&fit=crop",
    "electrical": "https://images.unsplash.com/photo-1621905252507-b35492cc74b4?w=600&auto=format&fit=crop",
    "interior": "https://images.unsplash.com/photo-1616594039964-3f74d7c6a99c?w=600&auto=format&fit=crop",
    "plumbing": "https://images.unsplash.com/photo-1585704032915-c3400ca199e7?w=600&auto=format&fit=crop",
    "finishing": "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600&auto=format&fit=crop",
    "exterior": "https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=600&auto=format&fit=crop",
    "landscaping": "https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=600&auto=format&fit=crop",
    "hvac": "https://images.unsplash.com/photo-1581093458791-9f3c3900df4b?w=600&auto=format&fit=crop",
    "safety": "https://images.unsplash.com/photo-1581092921461-eab62e97a780?w=600&auto=format&fit=crop",
    "roofing": "https://images.unsplash.com/photo-1600047509782-20d39509f26d?w=600&auto=format&fit=crop",
    "default": "https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=600&auto=format&fit=crop",
  };

  @override
  Widget build(BuildContext context) {
    final cardTextColor = isInterior ? const Color(0xFF131313) : Colors.white;
    final cardSubTextColor = isInterior ? const Color(0xA6131313) : const Color(0xFF8A979D);
    final cardBackground = isInterior ? const Color(0xFFE9E1D5) : const Color(0xFF111A1E);
    final cardBorder = isInterior ? const Color(0xFF7A7468) : const Color(0xFF344248);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(width: 1.2, color: cardBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                highlightColor: Colors.transparent,

                splashColor: Colors.transparent,
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: _buildProjectRow(
                    item: selectedItem,
                    showChevron: true,
                    cardTextColor: cardTextColor,
                    cardSubTextColor: cardSubTextColor,
                  ),
                ),
              ),
            ),
            if (isMenuOpen) ...[
              Divider(height: 1, thickness: 1, color: cardBorder),
              for (final item in items.where((e) => e != selectedItem))
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onSelect(item),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
                      child: _buildProjectRow(
                        item: item,
                        showChevron: false,
                        cardTextColor: cardTextColor,
                        cardSubTextColor: cardSubTextColor,
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProjectRow({
    required String item,
    required bool showChevron,
    required Color cardTextColor,
    required Color cardSubTextColor,
  }) {
    final preview = previewBuilder(item);
    final titleText = preview.title.trim().isEmpty ? item : preview.title;

    return Row(
      children: [
        _buildPreviewImage(preview),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titleText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: cardTextColor, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                preview.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: cardSubTextColor, fontSize: 12),
              ),
            ],
          ),
        ),
        if (showChevron)
          Icon(isMenuOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: cardTextColor, size: 24),
      ],
    );
  }

  Widget _buildPreviewImage(CategoryPreviewData preview) {
    final fallbackAsset = isInterior ? AssetsImages.interiorImg : AssetsImages.constructionIgm;
    final thumbnail = preview.thumbnailUrl?.trim() ?? "";
    final networkUrl = thumbnail.isNotEmpty
        ? thumbnail
        : (_categoryThumbnailUrls[preview.category.trim().toLowerCase()] ?? _categoryThumbnailUrls["default"]!);

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 45,
        width: 74,
        color: isInterior ? const Color(0xFFD9CCB9) : const Color(0xFF2A3438),
        child: Image.network(
          networkUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(fallbackAsset, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
