import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stephen_farmer/core/utils/images.dart';
import 'package:stephen_farmer/feature/auth/domain/repo/auth_repo.dart';

import '../../../../core/common/role_bg_color.dart';
import 'reset_password_view.dart';

class OtpScreenView extends StatefulWidget {
  const OtpScreenView({super.key, required this.category, required this.email});

  final String category;
  final String email;

  @override
  State<OtpScreenView> createState() => _OtpScreenViewState();
}

class _OtpScreenViewState extends State<OtpScreenView> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isSubmitting = false;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String _otp() => _controllers.map((e) => e.text).join();

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      _controllers[index].text = value.substring(value.length - 1);
      _controllers[index].selection = const TextSelection.collapsed(offset: 1);
    }
    if (value.isNotEmpty && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
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
      return 'Invalid verification code.';
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
                      'OTP',
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
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 76,
                    child: Text(
                      'We have sent the verification code to your email address',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        color: bodyColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        4,
                        (index) => _OtpInputBox(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          isInterior: isInterior,
                          onChanged: (v) => _onChanged(index, v),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 22,
                    child: Text.rich(
                      TextSpan(
                        text: 'Didn’t get the code ? ',
                        style: GoogleFonts.manrope(
                          color: bodyColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1,
                          letterSpacing: -0.3,
                        ),
                        children: [
                          TextSpan(
                            text: 'Resend it',
                            style: GoogleFonts.manrope(
                              color: bodyColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 1,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                              final otp = _otp();
                              if (otp.length != 4) {
                                Get.snackbar(
                                  'Validation',
                                  'Please enter the 4-digit code.',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                                return;
                              }
                              setState(() => _isSubmitting = true);
                              try {
                                await authRepo.verifyOtp(
                                  email: widget.email,
                                  otp: otp,
                                );
                                if (!mounted) return;
                                Get.to(
                                  () => ResetPasswordView(
                                    category: widget.category,
                                    email: widget.email,
                                    otp: otp,
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
          ),
        ),
      ),
    );
  }
}

class _OtpInputBox extends StatelessWidget {
  const _OtpInputBox({
    required this.controller,
    required this.focusNode,
    required this.isInterior,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isInterior;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = isInterior
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFFFFFFF);
    const Color valueColor = Color(0xFF757575);

    return Container(
      width: 72,
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: SizedBox(
        width: 17,
        height: 30,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          maxLength: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'ClashDisplay',
            color: valueColor,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1,
            letterSpacing: 0,
          ),
          onChanged: onChanged,
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            isCollapsed: true,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ),
    );
  }
}
