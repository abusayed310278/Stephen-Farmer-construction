import 'package:flutter/material.dart';

class AppDecorations {
  static const BoxDecoration interiorGradientBg = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xffE6E1DB),
        Color(0xff847C69),
      ],
    ),
  );

  static const BoxDecoration constructionBlackBg = BoxDecoration(
    color: Colors.black,
  );
}
