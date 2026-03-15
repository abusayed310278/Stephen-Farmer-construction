import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stephen_farmer/core/utils/images.dart';

import '../../domain/entities/document_project_entity.dart';

class DocumentCategoryCard extends StatelessWidget {
  const DocumentCategoryCard({
    super.key,
    required this.item,
    this.onTap,
    this.isInteriorTheme = false,
  });

  final DocumentCategoryEntity item;
  final VoidCallback? onTap;
  final bool isInteriorTheme;

  @override
  Widget build(BuildContext context) {
    final cardColor = isInteriorTheme
        ? const Color(0xFFD4D1C8)
        : const Color(0xFFDFDACD);
    final cardBorder = isInteriorTheme
        ? const Color(0xFFBFC3C5)
        : const Color(0xFFFFFFFF);
    final iconBg = isInteriorTheme
        ? const Color(0xFFE6E5DD)
        : const Color(0xFFF3F2EE);
    final titleColor = isInteriorTheme
        ? const Color(0xFF161D1E)
        : const Color(0xFF161D1E);
    final metaColor = isInteriorTheme
        ? const Color(0xFF161D1E)
        : const Color(0xFF4A5256);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cardBorder, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    _resolveIconAsset(item.type),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 144,
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'ClashDisplay',
                    color: titleColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 144,
                child: Text(
                  '${item.fileCount} files',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    color: metaColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _resolveIconAsset(String type) {
  switch (type.trim().toLowerCase()) {
    case 'drawings':
      return AssetsImages.drawings;
    case 'invoices':
      return AssetsImages.invoices;
    case 'reports':
      return AssetsImages.reports;
    case 'contracts':
      return AssetsImages.contracts;
    default:
      return AssetsImages.invoices2;
  }
}
