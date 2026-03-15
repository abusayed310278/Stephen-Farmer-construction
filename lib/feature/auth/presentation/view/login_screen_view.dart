import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stephen_farmer/core/common/role_bg_color.dart';
import 'package:stephen_farmer/core/common/widgets/custom_text_field.dart';
import 'package:stephen_farmer/core/utils/images.dart';
import 'package:stephen_farmer/core/utils/style.dart';
import 'package:stephen_farmer/feature/auth/presentation/controller/login_controller.dart';

import 'forget_password_view.dart';

class LoginScreenView extends StatefulWidget {
  final String category;

  const LoginScreenView({super.key, required this.category});

  @override
  State<LoginScreenView> createState() => _LoginScreenViewState();
}

class _LoginScreenViewState extends State<LoginScreenView> {
  late final LoginController controller;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<LoginController>();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    _loadRemembered();
  }

  Future<void> _loadRemembered() async {
    await controller.loadRememberedLoginData(category: widget.category);
    if (!mounted) return;

    emailController.text = controller.email.value;
    passwordController.text = controller.password.value;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isInterior = RoleBgColor.isInterior(widget.category);
    final bool showBackButton = defaultTargetPlatform == TargetPlatform.android;
    final Color signInContentColor = isInterior
        ? Colors.white
        : const Color(0xFF1E1E1E);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: RoleBgColor.overlayStyle(widget.category),
      child: Scaffold(
        backgroundColor: RoleBgColor.scaffoldColor(widget.category),
        body: Container(
          decoration: RoleBgColor.decoration(widget.category),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      if (showBackButton)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => Get.back(),
                            tooltip: "Back",
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                              color: isInterior ? Colors.black : Colors.white,
                            ),
                          ),
                        ),

                      const SizedBox(height: 28),

                      Center(
                        child: isInterior
                            ? Image.asset(
                                AssetsImages.interiorImg,
                                height: 141,
                                width: 150,
                              )
                            : Padding(
                                padding: const EdgeInsets.only(bottom: 50),
                                child: Image.asset(
                                  AssetsImages.constructionIgm,
                                  height: 64,
                                  width: 166,
                                ),
                              ),
                      ),

                      Center(
                        child: SizedBox(
                          width: 230,
                          height: 29,
                          child: Text(
                            'Welcome back',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'ClashDisplay',
                              color: isInterior
                                  ? Colors.black
                                  : const Color(0xFFE0DACD),
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Center(
                        child: SizedBox(
                          width: 230,
                          height: 19,
                          child: Text(
                            'Please Login to your Account',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.manrope(
                              color: isInterior
                                  ? Colors.black
                                  : const Color(0xFFE0DACD),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      Text(
                        "Email Address",
                        style: AppTextStyles.samiMedium(
                          color: isInterior ? Colors.black : Colors.white,
                        ),
                      ),

                      const SizedBox(height: 10),

                      CustomTextField(
                        controller: emailController,
                        hintText: "Email Address",
                        isOnDarkBg: !isInterior,
                      ),

                      const SizedBox(height: 15),

                      Text(
                        "Password",
                        style: AppTextStyles.samiMedium(
                          color: isInterior ? Colors.black : Colors.white,
                        ),
                      ),

                      const SizedBox(height: 10),

                      CustomTextField(
                        controller: passwordController,
                        hintText: "Password",
                        isPassword: true,
                        isOnDarkBg: !isInterior,
                      ),

                      const SizedBox(height: 20),

                      Obx(
                        () => Row(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Checkbox(
                                    value: controller.rememberMe.value,
                                    onChanged: (value) {
                                      controller.setRememberMe(
                                        value ?? false,
                                        category: widget.category,
                                      );
                                    },
                                    side: BorderSide(
                                      color: Colors.grey.shade600,
                                    ),
                                    checkColor: Colors.black,
                                    activeColor: Colors.white,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Remember me',
                                  style: TextStyle(
                                    color: isInterior
                                        ? Colors.black
                                        : Colors.grey.shade300,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                final value = emailController.text.trim();
                                if (value.isEmpty) {
                                  Get.snackbar(
                                    'Validation',
                                    'Please enter your email first.',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                  return;
                                }
                                Get.to(
                                  () => ForgetPasswordView(
                                    category: widget.category,
                                    email: value,
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Forgot your password?',
                                style: TextStyle(
                                  color: isInterior
                                      ? Colors.black54
                                      : Colors.grey.shade400,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              controller.loginUser(
                                email: emailController.text,
                                password: passwordController.text,
                                category: widget.category,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isInterior
                                  ? Colors.black
                                  : Colors.white.withValues(alpha: 0.9),
                              foregroundColor: signInContentColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isInterior
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.login_outlined,
                                        size: 20,
                                        color: signInContentColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Sign in',
                                        style: TextStyle(
                                          fontFamily: 'ClashDisplay',
                                          color: signInContentColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          height: 1.2,
                                          letterSpacing: 0,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
