import 'package:flutter/widgets.dart';
import 'package:get/get.dart';


class AppIconWidget extends StatelessWidget {
  const AppIconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: Image.asset('assets/icons/appIcon.png', width: 100, height: 100)),
        const SizedBox(height: 10),

        Obx(
          () => Text(
            '',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,

            ),
          ),
        ),
      ],
    );
  }
}
