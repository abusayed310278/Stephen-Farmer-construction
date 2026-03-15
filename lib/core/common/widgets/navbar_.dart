/*

import 'package:flutter/material.dart';

Widget _buildBottomNavBar() {
  return Container(
    height: 80,
    decoration: BoxDecoration(
      color: const Color(0xFF1E2660),
      borderRadius: BorderRadius.circular(50),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _onItemTapped(0),
            child: CustomNavItem(
              iconData: Icons.nightlight_round,
              label: 'Sleep',
              isSelected: _selectedIndex == 0,
            ),
          ),
          GestureDetector(
            onTap: () => _onItemTapped(1),
            child: CustomNavItem(
              iconData: Icons.nightlight_outlined,
              label: "Night",
              isSelected: _selectedIndex == 1,
            ),
          ),
          GestureDetector(
            onTap: () => _onItemTapped(2),
            child: CustomNavItem(
              iconData: Icons.star,
              label: "Dream",
              isSelected: _selectedIndex == 2,
            ),
          ),
          GestureDetector(
            onTap: () => _onItemTapped(3),
            child: CustomNavItem(
              iconData: Icons.alarm,
              label: "Alarm",
              isSelected: _selectedIndex == 3,
            ),
          ),
        ],
      ),
    ),
  );
}*/
