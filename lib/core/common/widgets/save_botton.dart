import 'package:flutter/material.dart';

Widget bottomWidget({required String text, VoidCallback? onTap}) {
  return InkWell(
    //splashColor: ,
    onTap: onTap,
    child: Container(
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    ),
  );
}
