import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stephen_farmer/core/utils/images.dart';
import 'package:stephen_farmer/feature/auth/domain/repo/auth_repo.dart';

import '../../../../core/common/role_bg_color.dart';
import 'login_screen_view.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({
    super.key,
    required this.category,
    required this.email,
    required this.otp,
  });

  final String category;
  final String email;
  final String otp;

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _friendlyError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? data['error'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
      return 'Unable to reset password.';
    }
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final bool isInterior = RoleBgColor.isInterior(widget.category);
    final authRepo = Get.find<AuthRepository>();

    final Color titleColor = isInterior
        ? const Color(0xFF000000)
        : const Color(0xFFE0DACD);
    final Color bodyColor = isInterior
        ? const Color(0xFF000000)
        : const Color(0xFFE0DACD);
    final Color borderColor = isInterior
        ? const Color(0xFF2B2B2B)
        : const Color(0xFFFFFFFF);
    final Color inputTextColor = isInterior
        ? const Color(0xFF000000)
        : const Color(0xFFFFFFFF);
    final Color ctaBgColor = isInterior
        ? const Color(0xFF000000)
        : const Color(0xFFE0DACD);
    final Color ctaTextColor = isInterior
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF000000);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: RoleBgColor.overlayStyle(widget.category),
      child: Scaffold(
        backgroundColor: RoleBgColor.scaffoldColor(widget.category),
        body: Container(
          decoration: RoleBgColor.decoration(widget.category),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const SizedBox(height: 90),
                  Center(
                    child: isInterior
                        ? Image.asset(
                            AssetsImages.interiorImg,
                            height: 141,
                            width: 150,
                          )
                        : Image.asset(
                            AssetsImages.constructionIgm,
                            height: 64,
                            width: 166,
                          ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 325,
                    height: 29,
                    child: Text(
                      'Reset Password',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'ClashDisplay',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        letterSpacing: 0,
                        color: titleColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 38),
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Password',
                          style: GoogleFonts.manrope(
                            color: bodyColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _PasswordField(
                          controller: _newPasswordController,
                          obscure: _obscureNew,
                          onToggle: () =>
                              setState(() => _obscureNew = !_obscureNew),
                          borderColor: borderColor,
                          textColor: inputTextColor,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Re-Enter Password',
                          style: GoogleFonts.manrope(
                            color: bodyColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _PasswordField(
                          controller: _confirmPasswordController,
                          obscure: _obscureConfirm,
                          onToggle: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                          borderColor: borderColor,
                          textColor: inputTextColor,
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isSubmitting
                                ? null
                                : () async {
                                    final newPassword = _newPasswordController
                                        .text
                                        .trim();
                                    final confirmPassword =
                                        _confirmPasswordController.text.trim();
                                    if (newPassword.isEmpty ||
                                        confirmPassword.isEmpty) {
                                      Get.snackbar(
                                        'Validation',
                                        'Please enter both password fields.',
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                      return;
                                    }
                                    if (newPassword != confirmPassword) {
                                      Get.snackbar(
                                        'Validation',
                                        'Passwords do not match.',
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                      return;
                                    }

                                    setState(() => _isSubmitting = true);
                                    try {
                                      await authRepo.resetPassword(
                                        email: widget.email,
                                        otp: widget.otp,
                                        newPassword: newPassword,
                                        confirmPassword: confirmPassword,
                                      );
                                      if (!mounted) return;
                                      Get.snackbar(
                                        'Success',
                                        'Password reset successful.',
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                      Get.offAll(
                                        () => LoginScreenView(
                                          category: widget.category,
                                        ),
                                      );
                                    } catch (e) {
                                      Get.snackbar(
                                        'Error',
                                        _friendlyError(e),
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    } finally {
                                      if (mounted) {
                                        setState(() => _isSubmitting = false);
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ctaBgColor,
                              foregroundColor: ctaTextColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isSubmitting
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        ctaTextColor,
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    width: 71,
                                    height: 19,
                                    child: Text(
                                      'Continue',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'ClashDisplay',
                                        color: ctaTextColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        height: 1.2,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
    required this.borderColor,
    required this.textColor,
  });

  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final Color borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(color: textColor),
        cursorColor: textColor,
        decoration: InputDecoration(
          hintText: '***************',
          hintStyle: TextStyle(
            color: textColor.withValues(alpha: 0.8),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          suffixIcon: IconButton(
            onPressed: onToggle,
            icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
              color: textColor,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              width: 1,
              color: borderColor.withValues(alpha: 0.7),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              width: 1,
              color: borderColor.withValues(alpha: 0.7),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(width: 1.5, color: borderColor),
          ),
        ),
      ),
    );
  }
}
