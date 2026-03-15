import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stephen_farmer/core/common/role_bg_color.dart';
import 'package:stephen_farmer/core/utils/images.dart';
import 'package:stephen_farmer/feature/auth/presentation/controller/login_controller.dart';

import '../../domain/entities/document_project_entity.dart';

class RecentDocumentItemCard extends StatelessWidget {
  const RecentDocumentItemCard({
    super.key,
    required this.item,
    this.isInteriorTheme,
    this.onTap,
    this.onDownload,
  });

  final RecentDocumentEntity item;
  final bool? isInteriorTheme;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    final resolvedInterior =
        isInteriorTheme ??
        RoleBgColor.isInterior(Get.find<LoginController>().role.value);

    final bgColor = resolvedInterior
        ? const Color(0xFFE0DFDD)
        : const Color(0xFFF2F1EE);
    final borderColor = resolvedInterior
        ? const Color(0xFFBFC3C5)
        : const Color(0xFFCFD4D8);
    final iconBg = resolvedInterior
        ? const Color(0xFFE6E5DD)
        : const Color(0xFFF6F5F1);
    final primaryText = const Color(0xFF161D1E);
    final secondaryText = const Color(0xFF4A5256);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 25,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(AssetsImages.invoices2, fit: BoxFit.fill),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 168,
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          color: primaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        SizedBox(
                          width: 69,
                          child: Text(
                            item.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              color: secondaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              height: 1,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: GoogleFonts.manrope(
                            color: secondaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 1,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 69,
                          child: Text(
                            item.dateLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              color: secondaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              height: 1,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onDownload,
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: Image.asset(
                    AssetsImages.download,
                    height: 24,
                    width: 24,
                    fit: BoxFit.contain,
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
