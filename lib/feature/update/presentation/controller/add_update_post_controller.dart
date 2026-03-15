import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../data/model/post_update_model.dart';
import '../../domain/repo/post_report_repo.dart';

class AddUpdateController extends ChangeNotifier {
  final PostRepository repo;

  AddUpdateController({required this.repo});

  PostDraftModel _draft = const PostDraftModel(
    description: '',
    imageFile: null,
  );
  PostDraftModel get draft => _draft;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void setDescription(String value) {
    _draft = _draft.copyWith(description: value);
    notifyListeners();
  }

  Future<void> pickPhoto(PhotoSource source) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final File? file = await repo.pickImage(source);
      if (file != null) {
        _draft = _draft.copyWith(imageFile: file);
      }
    } catch (_) {
      _error = 'Failed to pick image';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void removePhoto() {
    _draft = _draft.copyWith(imageFile: null);
    notifyListeners();
  }

  Future<void> submit({required String projectId}) async {
    _error = null;

    final hasDesc = _draft.description.trim().isNotEmpty;

    if (!hasDesc) {
      _error = 'Description is required';
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await repo.createPost(
        projectId: projectId,
        description: _draft.description.trim(),
        imageFile: _draft.imageFile,
      );
    } catch (_) {
      _error = 'Failed to create post';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
