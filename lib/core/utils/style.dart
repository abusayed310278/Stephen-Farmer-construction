import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle textMedium({Color? color}) {
    return TextStyle(
      color: color ?? Colors.white, // default white
      fontSize: 24,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle samiMedium({Color? color}) {
    return TextStyle(
      color: color ?? Colors.white, // default white
      fontSize: 16,
      fontWeight: FontWeight.w400,
    );
  }
}
