import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/images.dart';
import 'login_screen_view.dart';
import '../widgets/WorkspaceCard.dart';

class RoleSelectScreenView extends StatelessWidget {
  const RoleSelectScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Welcome Text
                SizedBox(
                  width: 230,
                  height: 29,
                  child: Text(
                    'Welcome',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'ClashDisplay',
                      color: Color(0xFFFFFFFF),
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 251,
                  height: 19,
                  child: Text(
                    'Select your workplace to continue',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                      letterSpacing: 0,
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // BUILD STUDIO Card
                WorkspaceCard(
                  image: AssetsImages.constructionIgm,
                  imageHeight: 38,
                  imageWidth: 104,
                  subtitle: 'Construction Management',
                  onTap: () {
                    Get.to(() => LoginScreenView(category: "construction"));
                  },
                ),

                const SizedBox(height: 24),

                // NF Card
                WorkspaceCard(
                  image: AssetsImages.interiorImg,
                  imageHeight: 60,
                  imageWidth: 64,
                  subtitle: 'Interior Design',
                  onTap: () {
                    Get.to(() => LoginScreenView(category: "interior"));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
