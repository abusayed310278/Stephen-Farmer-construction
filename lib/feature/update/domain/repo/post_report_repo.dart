import 'dart:io';

enum PhotoSource { camera, gallery }

abstract class PostRepository {
  Future<File?> pickImage(PhotoSource source);

  /// future এ API call যোগ করবেন—এখন placeholder
  Future<void> createPost({
    required String projectId,
    required String description,
    required File? imageFile,
  });
}
