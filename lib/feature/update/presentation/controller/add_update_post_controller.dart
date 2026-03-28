import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../data/model/post_update_model.dart';
import '../../domain/repo/post_report_repo.dart';

class AddUpdateController extends ChangeNotifier {
  final PostRepository repo;

  AddUpdateController({required this.repo});

  PostDraftModel _draft = const PostDraftModel(
    description: '',
    imageFiles: <File>[],
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
      final List<File> files = await repo.pickImages(source);
      if (files.isNotEmpty) {
        final merged = <File>[
          ..._draft.imageFiles,
          ...files.where(
            (file) => !_draft.imageFiles.any(
              (existing) => existing.path == file.path,
            ),
          ),
        ];
        _draft = _draft.copyWith(imageFiles: merged);
      }
    } catch (_) {
      _error = 'Failed to pick image';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void removePhotoAt(int index) {
    if (index < 0 || index >= _draft.imageFiles.length) return;
    final updated = List<File>.from(_draft.imageFiles)..removeAt(index);
    _draft = _draft.copyWith(imageFiles: updated);
    notifyListeners();
  }

  void clearPhotos() {
    _draft = _draft.copyWith(imageFiles: const <File>[]);
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
        imageFiles: _draft.imageFiles,
      );
    } catch (_) {
      _error = 'Failed to create post';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
