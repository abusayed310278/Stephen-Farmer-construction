import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Widget? prefixWidget;
  final bool isPassword;
  final bool isEmail;
  final bool isStrongPassword;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixWidget,
    this.isPassword = false,
    this.isEmail = false,
    this.isStrongPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;
  Timer? _debounce;

  // ------------------- EMAIL VALIDATION -------------------
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r"^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$");
    return emailRegex.hasMatch(email);
  }

  // ---------------- STRONG PASSWORD -----------------
  bool isStrongPassword(String pass) {
    final strongPassRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%^&*]).{6,}$',
    );
    return strongPassRegex.hasMatch(pass);
  }

  // ---------------- VALIDATION LOGIC -----------------
  void validateField(String value) {
    _debounce?.cancel(); // Cancel previous debounce
    _debounce = Timer(const Duration(seconds: 3), () {
      // EMAIL
      if (widget.isEmail && value.isNotEmpty && !isValidEmail(value)) {
        if (!Get.isSnackbarOpen) {
          Get.snackbar(
            "Invalid Email",
            "Please enter a valid email format",
            backgroundColor: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 3),
          );
        }
      }

      // STRONG PASSWORD
      if (widget.isStrongPassword &&
          value.isNotEmpty &&
          !isStrongPassword(value)) {
        if (!Get.isSnackbarOpen) {
          Get.snackbar(
            "Weak Password",
            "Password must contain:\n• Uppercase\n• Lowercase\n• Number\n• Special Character",
            backgroundColor: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 3),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: TextField(
        cursorHeight: 18,
        // textCapitalization: TextCapitalization.words,
        controller: widget.controller,
        obscureText: widget.isPassword ? _obscure : false,
        keyboardType:
            widget.isEmail ? TextInputType.emailAddress : widget.keyboardType,
        onChanged: validateField,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            fontSize: 16,
            color: Color(0xFF929292),
            fontWeight: FontWeight.w600,
          ),
          /*       prefixIcon: widget.prefixWidget != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: widget.prefixWidget!,
                )
              : null, */
          prefixIcon: widget.prefixWidget != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: widget.prefixWidget!,
                )
              : null,
          prefixIconConstraints: const BoxConstraints(
            minHeight: 20,
            minWidth: 20,
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                    color: const Color(0xFFB1B3B4),
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 1),
          ),
        ),
      ),
    );
  }
}
