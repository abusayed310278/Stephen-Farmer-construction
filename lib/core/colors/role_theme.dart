/* import 'package:flutter/material.dart';

import 'user_role.dart';

extension RoleTheme on UserRole {

  bool get isInterior =>
      this == UserRole.interiorUser ||
      this == UserRole.interiorManager;

  Color get backgroundColor =>
      isInterior ? Colors.transparent : Colors.black;

  Color get textColor =>
      isInterior ? Colors.black : Colors.white;

  Color get borderColor => textColor;

  Color get iconColor =>
      isInterior ? Colors.black87 : Colors.white70;

  Gradient? get gradient => isInterior
      ? const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xffE6E1DB), Color(0xff847C69)],
        )
      : null;
} */