import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:stephen_farmer/core/network/api_service/api_client.dart';
import 'package:stephen_farmer/core/network/api_service/api_endpoints.dart';
import 'package:stephen_farmer/core/utils/camera_utils.dart';

import '../../domain/repo/post_report_repo.dart';

class PostRepositoryImpl implements PostRepository {
  final ImagePicker _picker;
  final ApiClient _apiClient;

  PostRepositoryImpl(this._picker, {ApiClient? apiClient})
    : _apiClient = apiClient ?? Get.find<ApiClient>();

  @override
  Future<File?> pickImage(PhotoSource source) async {
    if (source == PhotoSource.camera && !await CameraUtils.isCameraAvailable()) {
      return null;
    }

    final ImageSource imgSource = source == PhotoSource.camera
        ? ImageSource.camera
        : ImageSource.gallery;

    final XFile? x = await _picker.pickImage(
      source: imgSource,
      imageQuality: 85,
      maxWidth: 2000,
    );

    if (x == null) return null;
    return File(x.path);
  }

  @override
  Future<void> createPost({
    required String projectId,
    required String description,
    required File? imageFile,
  }) async {
    final images = <MultipartFile>[];
    if (imageFile != null) {
      images.add(await MultipartFile.fromFile(imageFile.path));
    }

    final formData = FormData.fromMap({
      'projectId': projectId,
      'description': description,
      'images': images,
    });

    await _apiClient.post(UpdateEndpoints.create, data: formData);
  }
}
