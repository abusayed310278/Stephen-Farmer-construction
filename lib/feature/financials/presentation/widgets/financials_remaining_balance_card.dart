import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FinancialsRemainingBalanceCard extends StatelessWidget {
  const FinancialsRemainingBalanceCard({
    super.key,
    required this.amountText,
    required this.paidPercent,
  });

  final String amountText;
  final int paidPercent;

  @override
  Widget build(BuildContext context) {
    final safePercent = paidPercent.clamp(0, 100);

    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD8D5CD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Remaining Balance',
                  style: GoogleFonts.manrope(
                    color: const Color(0xFF161D1E),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  amountText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'ClashDisplay',
                    color: const Color(0xFF161D1E),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),

          /* Container(
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            height: 65,
            width: 65,
            child: CircularProgressIndicator(
              value: safePercent / 100,
              strokeWidth: 4,

              strokeCap: StrokeCap.round,
              // backgroundColor: const Color(0xFFBFB8AA),
              color: const Color(0xFFC08A2B),
              valueColor: AlwaysStoppedAnimation<Color>(safePercent >= 100 ? const Color(0xFF34C759) : const Color(0xFFC08A2B)),
            ),
          ), */
          Container(
            height: 65,
            width: 65,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 65,
                  width: 65,
                  child: CircularProgressIndicator(
                    value: safePercent / 100,
                    strokeWidth: 5,
                    strokeCap: StrokeCap.round,
                    //backgroundColor: const Color(0xFFBFB8AA),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      safePercent >= 100
                          ? const Color(0xFF34C759)
                          : const Color(0xFFC08A2B),
                    ),
                  ),
                ),
                Text(
                  "${safePercent.toInt()}%",
                  style: TextStyle(
                    fontFamily: 'ClashDisplay',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    letterSpacing: 0,
                    color: safePercent >= 100
                        ? const Color(0xFF34C759)
                        : const Color(0xFFA77935),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
