import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stephen_farmer/core/utils/images.dart';
import 'package:stephen_farmer/feature/auth/domain/repo/auth_repo.dart';

import '../../../../core/common/role_bg_color.dart';
import 'login_screen_view.dart';
import 'otp_screen_view.dart';

class ForgetPasswordView extends StatefulWidget {
  final String category;
  final String email;

  const ForgetPasswordView({
    super.key,
    required this.category,
    required this.email,
  });

  @override
  State<ForgetPasswordView> createState() => _ForgetPasswordViewState();
}

class _ForgetPasswordViewState extends State<ForgetPasswordView> {
  bool _isSubmitting = false;

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final local = parts[0];
    final masked = local.length <= 3
        ? '${local[0]}***'
        : '${local.substring(0, 3)}***';
    return '$masked@${parts[1]}';
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
      return 'Failed to send verification code.';
    }
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final bool isInterior = RoleBgColor.isInterior(widget.category);
    final authRepo = Get.find<AuthRepository>();
    final maskedEmail = _maskEmail(widget.email);

    final Color titleColor = isInterior
        ? const Color(0xFF000000)
        : const Color(0xFFE0DACD);
    final Color bodyColor = isInterior
        ? const Color(0xFF000000)
        : const Color(0xFFE0DACD);
    final Color borderColor = isInterior
        ? const Color(0xFF2B2B2B)
        : Colors.white;
    final Color iconTileColor = isInterior
        ? const Color(0xFF000000)
        : const Color(0xFFE0DACD);
    const Color iconColor = Color(0xFFFFFFFF);
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
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
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
                  Center(
                    child: SizedBox(
                      width: 325,
                      height: 29,
                      child: Text(
                        "Forgot Password",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'ClashDisplay',
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                          letterSpacing: 0,
                          color: titleColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 38,
                          child: Text(
                            "Select which contact details should we use to reset your password",
                            style: GoogleFonts.manrope(
                              color: bodyColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                              letterSpacing: 0,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          height: 88,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(width: 1.5, color: borderColor),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: iconTileColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.mail_outline_rounded,
                                  color: iconColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Via Email:',
                                      style: GoogleFonts.manrope(
                                        color: bodyColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        height: 1.2,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      maskedEmail,
                                      style: GoogleFonts.manrope(
                                        color: bodyColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        height: 1.2,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 36),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isSubmitting
                                ? null
                                : () async {
                                    setState(() => _isSubmitting = true);
                                    try {
                                      await authRepo.forgotPassword(
                                        email: widget.email,
                                      );
                                      if (!mounted) return;
                                      Get.to(
                                        () => OtpScreenView(
                                          category: widget.category,
                                          email: widget.email,
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
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 207,
                    height: 17,
                    child: Center(
                      child: Text.rich(
                        TextSpan(
                          text: 'Remember Password? ',
                          style: GoogleFonts.poppins(
                            color: bodyColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                            letterSpacing: 0,
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign In',
                              style: GoogleFonts.poppins(
                                color: bodyColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.2,
                                letterSpacing: 0,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Get.off(
                                    () => LoginScreenView(
                                      category: widget.category,
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
