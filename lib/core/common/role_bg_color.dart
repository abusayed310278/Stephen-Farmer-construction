import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RoleBgColor {
  static const LinearGradient interiorGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xffE6E1DB), Color(0xFF847C69)],
  );

  static const BoxDecoration interiorDecoration = BoxDecoration(gradient: interiorGradient);

  static bool isInterior(String role) {
    final r = role.toLowerCase().trim();

    return r.contains("interior");
  }

  static BoxDecoration? decoration(String role) {
    if (isInterior(role)) {
      return interiorDecoration;
    }

    return null;
  }

  static Color scaffoldColor(String role) {
    return isInterior(role) ? interiorGradient.colors.first : Colors.black;
  }

  static SystemUiOverlayStyle overlayStyle(String role) {
    final interior = isInterior(role);
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: interior ? Brightness.dark : Brightness.light,
      statusBarBrightness: interior ? Brightness.light : Brightness.dark,
    );
  }
}
