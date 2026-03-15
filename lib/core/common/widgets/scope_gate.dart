import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:stephen_farmer/feature/auth/presentation/controller/login_controller.dart';

class ScopeGate extends StatelessWidget {
  final String? scope;
  final List<String>? anyScopes;
  final Widget child;
  final Widget fallback;

  const ScopeGate({super.key, this.scope, this.anyScopes, required this.child, this.fallback = const SizedBox.shrink()})
    : assert(scope != null || anyScopes != null, 'Provide either scope or anyScopes.');

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<LoginController>();

    return Obx(() {
      final allowed = scope != null ? auth.hasScope(scope!) : auth.hasAnyScope(anyScopes!);
      return allowed ? child : fallback;
    });
  }
}
