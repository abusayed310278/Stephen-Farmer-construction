import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomShowMessage {
  /// Success Snackbar
  static void success({
    String? title,
    required String message,
    Color color = Colors.green,
    IconData icon = Icons.check_circle,
  }) {
    _showSnackbar(title: title, message: message, color: color, icon: icon);
  }

  /// Error Snackbar
  static void error({
    String? title,
    required String message,
    Color color = Colors.red,
    IconData icon = Icons.cancel,
  }) {
    _showSnackbar(title: title, message: message, color: color, icon: icon);
  }

  /// Internal method
  static void _showSnackbar({
    String? title,
    required String message,
    required Color color,
    required IconData icon,
  }) {
    Get.snackbar(
      '',
      '',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white.withOpacity(0.95),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(12),
      borderRadius: 12,
      borderColor: Colors.transparent,
      borderWidth: 0,
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 400),
      // Stronger, more visible shadow
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25), // darker shadow
          blurRadius: 12, // more blur
          spreadRadius: 1, // spread a bit
          offset: const Offset(0, 6), // slight vertical offset
        ),
      ],
      titleText: const SizedBox.shrink(),
      messageText: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon inside colored circle
          Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          // Title & message column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(
                    title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 16),
                  ),
                Text(
                  message,
                  style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                      fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
