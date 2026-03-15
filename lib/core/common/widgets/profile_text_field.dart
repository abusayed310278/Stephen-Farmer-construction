import 'package:flutter/material.dart';

class CustomProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final bool enabled;
  final IconData? prefixIcon;

  const CustomProfileTextField({
    super.key,
    required this.controller,
    required this.label,
    this.enabled = true,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400,),
      decoration: InputDecoration(
        fillColor: Colors.transparent,
        filled: false,
        //labelText: label,
       // labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.white70) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF283280), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF283280), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF283280), width: 2),
        ),
      ),
    );
  }
}
