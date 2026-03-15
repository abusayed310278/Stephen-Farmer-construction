import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Transition config class
class PageTransitionConfig {
  final Transition transition;
  final Duration duration;
  final Curve curve;

  const PageTransitionConfig({
    this.transition = Transition.rightToLeft,
    this.duration = const Duration(milliseconds: 350),
    this.curve = Curves.easeInOut,
  });
}

// Default config
const defaultTransition = PageTransitionConfig();

// Helper function
Future<T?>? navigateTo<T>(
    Widget Function() page, [
      PageTransitionConfig config = defaultTransition,
    ]) {
  return Get.to(
    page,
    transition: config.transition,
    duration: config.duration,
    curve: config.curve,
  );
}
Future<T?>? offToPage<T>(
    Widget Function() page,
    [PageTransitionConfig config = defaultTransition]
    ) {
  return Get.off(
    page,
    transition: config.transition,
    duration: config.duration,
    curve: config.curve,
  );
}


Future<T?>? navigateOff<T>(
    Widget Function() page, [
      PageTransitionConfig config = defaultTransition,
    ]) {
  return Get.off(
    page,
    transition: config.transition,
    duration: config.duration,
    curve: config.curve,
  );
}

Future<T?>? navigateOffAll<T>(
    Widget Function() page, [
      PageTransitionConfig config = defaultTransition,
    ]) {
  return Get.offAll(
    page,
    transition: config.transition,
    duration: config.duration,
    curve: config.curve,
  );
}
