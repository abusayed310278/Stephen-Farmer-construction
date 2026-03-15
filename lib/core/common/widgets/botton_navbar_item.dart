
import 'package:flutter/material.dart';


class CustomNavItem extends StatelessWidget {
  final String iconData;
  final String label;
  final bool isSelected;

  const CustomNavItem({
    super.key,
    required this.iconData,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return /* Container(
      height: 66,
      width: 66,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.appColor : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ), */ Container(
      height: 66,
      width: 66,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: isSelected
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,

                stops: [40.0, 0.8],
                colors: [Color(0xFF9B6DFF), Color(0xFFE8E6EE)],
              )
            : null,
        color: isSelected ? null : Colors.transparent,
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconData,
            height: 22,
            width: 22,
            color: isSelected ? Colors.white : Colors.black,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
