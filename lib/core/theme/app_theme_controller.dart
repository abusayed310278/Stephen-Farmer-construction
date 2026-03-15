import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stephen_farmer/core/common/role_mapper.dart';
import 'package:stephen_farmer/feature/auth/presentation/controller/login_controller.dart';

class AppThemeController extends GetxController {
  final auth = Get.find<LoginController>();

  bool get isInteriorTheme => RoleMapper.themeFromRole(auth.role.value) == AppThemeType.interior;

  Color get scaffoldBg => isInteriorTheme ? Colors.amber : const Color(0xFF0F1416);

  Gradient get interiorGradient =>
      const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xffE6E1DB), Color(0xff847C69)]);

  Color get textPrimary => isInteriorTheme ? Colors.black : Colors.white;
  Color get textSecondary => isInteriorTheme ? Colors.black54 : Colors.white70;

  Color get border => isInteriorTheme ? Colors.black26 : Colors.white24;
  Color get divider => isInteriorTheme ? Colors.black12 : Colors.white24;

  Color get bottomBarBg => const Color(0xFF0F0F10);
  Color get selected => const Color(0xFFD19A2A);
  Color get unselected => Colors.white;
}
