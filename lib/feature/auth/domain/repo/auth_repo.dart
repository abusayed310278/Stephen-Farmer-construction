import 'dart:io';

import '../../data/model/login_model.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(LoginRequest request);
  Future<void> forgotPassword({required String email});
  Future<void> verifyOtp({required String email, required String otp});
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  });
  Future<void> logout({String? refreshToken});
  Future<UserProfileData> getProfile();
  Future<UserProfileData> updateProfile({
    required String name,
    required String email,
    File? avatarFile,
  });
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });
}
