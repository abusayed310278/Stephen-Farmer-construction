import 'dart:io';

class PostDraftModel {
  final String description;
  final File? imageFile;

  const PostDraftModel({required this.description, required this.imageFile});

  PostDraftModel copyWith({String? description, File? imageFile}) {
    return PostDraftModel(
      description: description ?? this.description,
      imageFile: imageFile ?? this.imageFile,
    );
  }

  bool get canPost => description.trim().isNotEmpty;
}
