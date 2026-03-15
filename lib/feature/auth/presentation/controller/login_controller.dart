import 'dart:io';

import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:stephen_farmer/app_ground_view.dart';
import 'package:stephen_farmer/feature/auth/presentation/view/login_screen_view.dart';

import '../../../../core/network/api_service/api_endpoints.dart';
import '../../../../core/network/api_service/token_meneger.dart';
import '../../data/model/login_model.dart';
import '../../domain/repo/auth_repo.dart';

class LoginController extends GetxController {
  final AuthRepository repository;

  LoginController(this.repository);

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool rememberMe = false.obs;
  final RxString role = ''.obs; // category: "interior" / "construction"
  final RxString userRole = ''.obs; // role: "client" / "manager"
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString userAvatar = ''.obs;
  final RxBool isUpdatingProfile = false.obs;

  // Text controllers
  final RxString email = ''.obs;
  final RxString password = ''.obs;

  void setRoleFromApi(String apiRole) {
    role.value = apiRole;
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // Toggle remember me
  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  Future<void> setRememberMe(bool value, {required String category}) async {
    rememberMe.value = value;
    if (!value) {
      await TokenManager.saveRememberedLogin(
        enabled: false,
        scopeKey: category,
      );
    }
  }

  // Update email
  void updateEmail(String value) {
    email.value = value;
  }

  // Update password
  void updatePassword(String value) {
    password.value = value;
  }

  String get categoryKey => role.value.trim().toLowerCase();
  String get roleKey => userRole.value.trim().toLowerCase();
  String get displayName => userName.value.trim();
  String get displayEmail => userEmail.value.trim();
  String get displayAvatar => _resolveMediaUrl(userAvatar.value.trim());
  String get normalizedRoleKey => _normalizeRole(roleKey);
  String get scopeKey => '${categoryKey}_$normalizedRoleKey';

  bool get isInterior => categoryKey == 'interior';
  bool get isConstruction => categoryKey == 'construction';
  bool get isClient => roleKey == 'client' || roleKey == 'user';
  bool get isManager => roleKey == 'manager';
  bool get isInteriorUser => scopeKey == 'interior_user';
  bool get isInteriorManager => scopeKey == 'interior_manager';
  bool get isConstructionUser => scopeKey == 'construction_user';
  bool get isConstructionManager => scopeKey == 'construction_manager';

  bool hasScope(String scope) => scopeKey == scope.trim().toLowerCase();

  bool hasAnyScope(List<String> scopes) {
    return scopes.map((e) => e.trim().toLowerCase()).contains(scopeKey);
  }

  bool hasAccess({String? category, String? userRole}) {
    final categoryMatch = category == null
        ? true
        : categoryKey == category.trim().toLowerCase();
    final roleMatch = userRole == null
        ? true
        : normalizedRoleKey == _normalizeRole(userRole);
    return categoryMatch && roleMatch;
  }

  bool hasAnyAccess({List<String>? categories, List<String>? userRoles}) {
    final categoryMatch = categories == null || categories.isEmpty
        ? true
        : categories.map((e) => e.trim().toLowerCase()).contains(categoryKey);
    final roleMatch = userRoles == null || userRoles.isEmpty
        ? true
        : userRoles.map(_normalizeRole).contains(normalizedRoleKey);
    return categoryMatch && roleMatch;
  }

  String _normalizeRole(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'client') return 'user';
    return normalized;
  }

  Future<bool> restoreSession() async {
    final loggedIn = await TokenManager.isLoggedIn();
    if (!loggedIn) return false;

    final savedCategory =
        (await TokenManager.getCategory())?.trim().toLowerCase() ?? '';
    final savedUserRole =
        (await TokenManager.getRole())?.trim().toLowerCase() ?? '';
    final savedUserName = (await TokenManager.getUserName())?.trim() ?? '';
    final savedUserEmail = (await TokenManager.getUserEmail())?.trim() ?? '';
    final savedUserAvatar = (await TokenManager.getUserAvatar())?.trim() ?? '';

    if (savedCategory.isEmpty || savedUserRole.isEmpty) {
      return false;
    }

    role.value = savedCategory;
    userRole.value = savedUserRole;
    userName.value = savedUserName;
    userEmail.value = savedUserEmail;
    userAvatar.value = savedUserAvatar;
    return true;
  }

  Future<void> loadRememberedLoginData({required String category}) async {
    final enabled = await TokenManager.isRememberMeEnabled(scopeKey: category);
    if (!enabled) {
      rememberMe.value = false;
      email.value = '';
      password.value = '';
      return;
    }

    rememberMe.value = true;
    email.value =
        (await TokenManager.getRememberedEmail(scopeKey: category)) ?? '';
    password.value =
        (await TokenManager.getRememberedPassword(scopeKey: category)) ?? '';
  }

  Future<void> loginUser({
    required String email,
    required String password,
    required String category, // "interior" / "construction"
  }) async {
    if (email.trim().isEmpty || password.isEmpty || category.trim().isEmpty) {
      Get.snackbar("Error", "Email, password and category are required");
      return;
    }

    try {
      isLoading.value = true;
      final normalizedCategory = category.trim().toLowerCase();
      role.value = normalizedCategory;

      final request = LoginRequest(
        email: email,
        password: password,
        category: normalizedCategory,
      );

      final response = await repository.login(request);

      if (response.success && response.data != null) {
        await TokenManager.accessToken(response.data!.accessToken);
        await TokenManager.refreshToken(response.data!.refreshToken);
        role.value = response.data!.category.trim().toLowerCase();
        userRole.value = response.data!.role.trim().toLowerCase();
        userName.value = response.data!.name.trim();
        userEmail.value = response.data!.email.trim();
        userAvatar.value = (response.data!.avatar ?? '').trim();
        await TokenManager.saveCategory(role.value);
        await TokenManager.saveRole(userRole.value);
        await TokenManager.saveUserName(userName.value);
        await TokenManager.saveUserEmail(userEmail.value);
        await TokenManager.saveUserAvatar(userAvatar.value);
        await TokenManager.saveRememberedLogin(
          enabled: rememberMe.value,
          scopeKey: normalizedCategory,
          email: email.trim(),
          password: password,
        );
        await refreshProfile();

        Get.offAll(() => const AppGroundView());
      } else {
        Get.snackbar("Login Failed", response.message);
      }
    } catch (e) {
      Get.snackbar("Error", _friendlyLoginError(e));
    } finally {
      isLoading.value = false;
    }
  }

  String _friendlyLoginError(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final apiMessage = _extractApiMessage(error.response?.data);

      if (statusCode == 400 || statusCode == 401) {
        return apiMessage ?? "Invalid email or password.";
      }
      if (statusCode == 404) {
        return "Login service is unavailable right now. Please try again.";
      }
      if (statusCode != null && statusCode >= 500) {
        return "Server error. Please try again shortly.";
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return "Request timed out. Please check your connection and try again.";
        case DioExceptionType.connectionError:
          return "No internet connection. Please check your network.";
        case DioExceptionType.cancel:
          return "Request was cancelled.";
        default:
          return apiMessage ?? "Unable to sign in. Please try again.";
      }
    }

    return "Unable to sign in. Please try again.";
  }

  String? _extractApiMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data["message"] ?? data["error"];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }
    return null;
  }

  Future<void> logoutUser() async {
    final String currentCategory =
        role.value.isNotEmpty ? role.value : "construction";
    try {
      final String? refreshToken = await TokenManager.getRefreshToken();
      await repository.logout(refreshToken: refreshToken);
    } finally {
      await TokenManager.clearToken();
      role.value = '';
      userRole.value = '';
      userName.value = '';
      userEmail.value = '';
      userAvatar.value = '';
      email.value = '';
      password.value = '';
      rememberMe.value = false;

      Get.offAll(() => LoginScreenView(category: currentCategory));
    }
  }

  Future<void> refreshProfile() async {
    try {
      final profile = await repository.getProfile();
      await _applyProfile(profile);
    } catch (_) {}
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    File? avatarFile,
  }) async {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();

    if (trimmedName.isEmpty) {
      Get.snackbar('Error', 'Name is required');
      return false;
    }
    if (trimmedEmail.isEmpty) {
      Get.snackbar('Error', 'Email is required');
      return false;
    }

    try {
      isUpdatingProfile.value = true;
      final updated = await repository.updateProfile(
        name: trimmedName,
        email: trimmedEmail,
        avatarFile: avatarFile,
      );
      await _applyProfile(updated);
      return true;
    } catch (e) {
      Get.snackbar('Error', _friendlyLoginError(e));
      return false;
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  Future<bool> changeUserPassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (currentPassword.trim().isEmpty ||
        newPassword.trim().isEmpty ||
        confirmPassword.trim().isEmpty) {
      Get.snackbar('Error', 'All password fields are required');
      return false;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar('Error', 'New password and confirm password do not match');
      return false;
    }

    try {
      await repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      return true;
    } catch (e) {
      Get.snackbar('Error', _friendlyLoginError(e));
      return false;
    }
  }

  Future<void> _applyProfile(UserProfileData profile) async {
    if (profile.name.trim().isNotEmpty) {
      userName.value = profile.name.trim();
      await TokenManager.saveUserName(userName.value);
    }
    if (profile.email.trim().isNotEmpty) {
      userEmail.value = profile.email.trim();
      await TokenManager.saveUserEmail(userEmail.value);
    }

    final avatar = profile.avatar?.trim() ?? '';
    userAvatar.value = avatar;
    await TokenManager.saveUserAvatar(avatar);

    if (profile.role.trim().isNotEmpty) {
      userRole.value = profile.role.trim().toLowerCase();
      await TokenManager.saveRole(userRole.value);
    }

    if (profile.category.trim().isNotEmpty) {
      role.value = profile.category.trim().toLowerCase();
      await TokenManager.saveCategory(role.value);
    }
  }

  String _resolveMediaUrl(String raw) {
    final value = raw.trim().replaceAll('\\', '/');
    if (value.isEmpty || value.toLowerCase() == 'null') {
      return '';
    }

    // Handle serialized object strings from backend, e.g.
    // "{public_id: ..., url: https://...}"
    if (value.startsWith('{') && value.contains('url:')) {
      final match = RegExp(r'url:\s*([^,}]+)').firstMatch(value);
      final extracted = match?.group(1)?.trim() ?? '';
      if (extracted.isEmpty) return '';
      return _resolveMediaUrl(extracted);
    }

    // Guard against malformed encoded map string becoming an invalid path.
    if (value.startsWith('%7B') || value.startsWith('{')) {
      return '';
    }

    final lower = value.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('//')) {
      return 'https:$value';
    }

    final origin = _apiOrigin();
    if (origin.isEmpty) return value;
    if (value.startsWith('/')) {
      return '$origin$value';
    }
    return '$origin/$value';
  }

  String _apiOrigin() {
    final trimmed = baseUrl.trim();
    if (trimmed.isEmpty) return '';
    final normalized = trimmed.replaceFirst(RegExp(r'/api/v\d+/?$'), '');
    final uri = Uri.tryParse(normalized);
    if (uri == null || uri.host.isEmpty) return normalized;

    var host = uri.host;
    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        (host == 'localhost' || host == '127.0.0.1')) {
      host = '10.0.2.2';
    }

    return Uri(
      scheme: uri.scheme,
      host: host,
      port: uri.hasPort ? uri.port : null,
    ).toString();
  }

  // Login function
  Future<void> login() async {
    if (email.value.isEmpty || password.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter email and password',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar(
        'Success',
        'Login successful',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navigate to home
      Get.offAll(() => const AppGroundView());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Login failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
