import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future CustomDialog({
  required String title,
  required String content,
  required String buttonTitle,
  void Function()? onTap,
}) {
  return Get.defaultDialog(
    title: "",
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset("assets/images/dialaogicong.png", height: 72, width: 72),
        Padding(padding: const EdgeInsets.symmetric(vertical: 15),
          child: Text(title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ),

        InkWell(
          onTap: onTap,
          child: Container(width: 100,
            height: 35, decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Colors.red,),
            child: Center(
              child: Text("$buttonTitle,", style: TextStyle(color: Colors.white, fontSize: 18),),
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    ),
  );
}
