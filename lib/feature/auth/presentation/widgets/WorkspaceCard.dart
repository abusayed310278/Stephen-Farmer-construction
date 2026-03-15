import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkspaceCard extends StatelessWidget {
  final String image;
  final String subtitle;
  final VoidCallback onTap;
  final double? imageHeight; // 👈 optional height
  final double? imageWidth; // 👈 optional width
  final Color? imageColor; // 👈 optional color

  const WorkspaceCard({
    super.key,
    required this.image,
    required this.subtitle,
    required this.onTap,
    this.imageHeight,
    this.imageWidth,
    this.imageColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          //color: const Color(0xFF1A1A1A),
          // 50% color
          //color: Color(0xff1F1F1F),
          //color: Color(0xFF3D3D3D),
          //  color: Color(0xFF1E1E1E),
          color: Color(0xFF1F1F1F),

          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color(0xFF6D6F73), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Title
            Center(
              child: Image.asset(image, height: imageHeight ?? 34, width: imageWidth ?? 104, color: imageColor),
            ),
            const SizedBox(height: 12),

            // Subtitle
            Center(
              child: SizedBox(
                width: 295,
                height: 17,
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Go to Project Button
            InkWell(
              onTap: onTap,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  //border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Go to Project',
                        style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 25),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
