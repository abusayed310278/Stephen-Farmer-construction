import 'package:flutter/material.dart';

class ScopeStyles {
  static Color textColor(String scopeKey) => switch (scopeKey) {
        'interior_user' => Colors.black,
        'interior_manager' => Colors.black87,
        'construction_user' => Colors.white,
        'construction_manager' => const Color(0xFFFFD27A),
        _ => Colors.white,
      };
}
