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

  // ✅ add this
  final bool isOnDarkBg;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixWidget,
    this.isPassword = false,
    this.isEmail = false,
    this.isStrongPassword = false,
    this.keyboardType = TextInputType.text,
    this.isOnDarkBg = false, // default light
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;
  Timer? _debounce;

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r"^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$");
    return emailRegex.hasMatch(email);
  }

  bool isStrongPassword(String pass) {
    final strongPassRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%^&*]).{6,}$');
    return strongPassRegex.hasMatch(pass);
  }

  void validateField(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 3), () {
      if (widget.isEmail && value.isNotEmpty && !isValidEmail(value)) {
        if (!Get.isSnackbarOpen) {
          Get.snackbar(
            "Invalid Email",
            "Please enter a valid email format",
            backgroundColor: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
        }
      }

      if (widget.isStrongPassword && value.isNotEmpty && !isStrongPassword(value)) {
        if (!Get.isSnackbarOpen) {
          Get.snackbar(
            "Weak Password",
            "Password must contain:\n• Uppercase\n• Lowercase\n• Number\n• Special Character",
            backgroundColor: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
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
  @override
  Widget build(BuildContext context) {
    final Color textColor = widget.isOnDarkBg ? Colors.white : Colors.black;
    final Color hintColor = widget.isOnDarkBg ? Colors.white70 : Colors.black54;
    final Color borderColor = widget.isOnDarkBg ? Colors.white : Colors.black;
    final Color cursorColor = widget.isOnDarkBg ? Colors.white : Colors.black;
    final Color iconColor = widget.isOnDarkBg ? Colors.white70 : const Color(0xFFB1B3B4);

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      height: 50,
      child: IconTheme(
        // ✅ just add this
        data: IconThemeData(color: iconColor),
        child: TextField(
          onTapOutside: (event) => FocusScope.of(context).unfocus(),
          cursorHeight: 22,
          cursorColor: cursorColor,
          style: TextStyle(color: textColor),
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscure : false,
          keyboardType: widget.isEmail ? TextInputType.emailAddress : widget.keyboardType,
          onChanged: validateField,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: hintColor),

            // ✅ prefix icon (remove inner IconTheme now)
            prefixIcon: widget.prefixWidget != null
                ? Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: widget.prefixWidget!)
                : null,

            prefixIconConstraints: const BoxConstraints(minHeight: 20, minWidth: 20),

            // ✅ suffix icon (remove color from Icon)
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                    color: widget.isOnDarkBg ? Colors.white : Colors.black,
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(width: 1.2, color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(width: 1.0, color: borderColor.withOpacity(0.7)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(width: 1.5, color: borderColor),
            ),
          ),
        ),
      ),
    );
  }
}
