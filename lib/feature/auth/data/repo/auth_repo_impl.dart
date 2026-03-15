import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_service/api_client.dart';
import '../../../../core/network/api_service/api_endpoints.dart';
import '../../domain/repo/auth_repo.dart';
import '../model/login_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient apiClient;

  AuthRepositoryImpl(this.apiClient);

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final Response response = await apiClient.post(
        AuthEndpoints.login,
        data: request.toJson(),
      );

      if (response.data is Map<String, dynamic>) {
        return LoginResponse.fromJson(response.data);
      } else {
        throw Exception("Invalid response format");
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout({String? refreshToken}) async {
    try {
      await apiClient.post(
        AuthEndpoints.logout,
        data: refreshToken == null || refreshToken.trim().isEmpty
            ? {}
            : {"refreshToken": refreshToken},
      );
    } catch (_) {
      // Local logout will still proceed from controller.
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await apiClient.post(
      AuthEndpoints.forgotPassword,
      data: {"email": email.trim()},
    );
  }

  @override
  Future<void> verifyOtp({required String email, required String otp}) async {
    await apiClient.post(
      AuthEndpoints.verifyOtp,
      data: {"email": email.trim(), "otp": otp.trim()},
    );
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await apiClient.post(
      AuthEndpoints.resetPassword,
      data: {
        "email": email.trim(),
        "otp": otp.trim(),
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
      },
    );
  }

  @override
  Future<UserProfileData> getProfile() async {
    final response = await apiClient.get(UserProfileEndpoints.getProfile);
    final map = _extractMap(response.data);
    return UserProfileData.fromJson(map);
  }

  @override
  Future<UserProfileData> updateProfile({
    required String name,
    required String email,
    File? avatarFile,
  }) async {
    final payload = <String, dynamic>{
      'name': name.trim(),
      'email': email.trim(),
    };

    dynamic data = payload;
    if (avatarFile != null) {
      data = FormData.fromMap({
        ...payload,
        'avatar': await MultipartFile.fromFile(avatarFile.path),
      });
    }

    final response = await apiClient.put(
      UserProfileEndpoints.updateProfile,
      data: data,
    );
    final map = _extractMap(response.data);
    return UserProfileData.fromJson(map);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await apiClient.put(
      UserProfileEndpoints.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }

  Map<String, dynamic> _extractMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return payload;
    }
    return const <String, dynamic>{};
  }
}
