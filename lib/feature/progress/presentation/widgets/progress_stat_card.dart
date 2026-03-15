import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stephen_farmer/core/colors/app_color.dart';

class ProgressStatCard extends StatelessWidget {
  const ProgressStatCard({
    super.key,
    this.icon,
    this.iconAsset,
    required this.label,
    required this.value,
  }) : assert(icon != null || iconAsset != null);

  final IconData? icon;
  final String? iconAsset;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 109,
        width: 109,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColor.appColor, width: 1.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconAsset != null)
              Image.asset(
                iconAsset!,
                width: 28,
                height: 28,
                color: Colors.amber.shade100,
                errorBuilder: (_, __, ___) => Icon(
                  icon ?? Icons.image_not_supported_outlined,
                  color: Colors.amber.shade100,
                  size: 28,
                ),
              )
            else
              Icon(
                icon ?? Icons.image_not_supported_outlined,
                color: Colors.amber.shade100,
                size: 28,
              ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                color: const Color(0xFFD4D4D4),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'ClashDisplay',
                color: Colors.white,
                fontSize: 20,
                height: 1,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
