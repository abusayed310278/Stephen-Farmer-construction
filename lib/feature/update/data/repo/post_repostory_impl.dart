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
  Future<List<File>> pickImages(PhotoSource source) async {
    if (source == PhotoSource.camera &&
        !await CameraUtils.isCameraAvailable()) {
      return const <File>[];
    }

    if (source == PhotoSource.gallery) {
      final List<XFile> files = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 2000,
      );
      return files.map((file) => File(file.path)).toList();
    }

    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 2000,
    );

    if (file == null) return const <File>[];
    return <File>[File(file.path)];
  }

  @override
  Future<void> createPost({
    required String projectId,
    required String description,
    required List<File> imageFiles,
  }) async {
    final images = <MultipartFile>[];
    for (final imageFile in imageFiles) {
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
