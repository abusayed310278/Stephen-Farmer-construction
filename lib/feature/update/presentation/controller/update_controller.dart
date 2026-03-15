import 'dart:io';

import 'package:get/get.dart';

import '../../../../core/network/api_service/api_client.dart';
import '../../../auth/presentation/controller/login_controller.dart';
import '../../data/model/update_model.dart';
import '../../domain/usecase/update_usecase.dart';

class UpdateController extends GetxController {
  UpdateController({ApiClient? apiClient, UpdateUseCase? useCase})
    : _apiClient = apiClient ?? Get.find<ApiClient>(),
      _useCase = useCase ?? UpdateUseCase();

  final ApiClient _apiClient;
  final UpdateUseCase _useCase;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isProjectMenuOpen = false.obs;
  final RxBool isCategoryMenuOpen = false.obs;
  final RxBool isCreatingUpdate = false.obs;

  final RxInt selectedProjectIndex = 0.obs;
  final RxString selectedCategory = 'All'.obs;

  final RxList<UpdateProjectModel> projects = <UpdateProjectModel>[].obs;
  final RxList<String> categoryFilters = <String>[].obs;
  final RxList<UpdateModel> updateList = <UpdateModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    refreshAll();
  }

  bool get shouldShowCategoryDropdown =>
      _useCase.shouldShowCategoryDropdown(categoryFilters);

  bool get shouldShowProjectDropdown => projects.isNotEmpty;

  bool get hasProjects => projects.isNotEmpty;

  UpdateProjectModel? get selectedProject {
    if (projects.isEmpty) return null;
    final idx = _safeProjectIndex;
    return projects[idx];
  }

  String get selectedProjectId => selectedProject?.id ?? '';

  List<UpdateModel> get filteredUpdates {
    return _useCase.filterUpdates(
      updates: updateList.toList(),
      selectedCategory: selectedCategory.value,
    );
  }

  Future<void> refreshAll() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final fetchedProjects = await _useCase.fetchProjects(_apiClient);
      projects.assignAll(
        fetchedProjects.where((p) => p.id.trim().isNotEmpty).toList(),
      );
      _normalizeProjectSelection();

      if (selectedProjectId.isNotEmpty) {
        await _fetchUpdatesForSelectedProject();
      } else {
        updateList.clear();
        _refreshCategoryFilters();
      }
    } catch (_) {
      errorMessage.value = 'Failed to load updates. Please try again.';
      projects.clear();
      updateList.clear();
      _refreshCategoryFilters();
    } finally {
      isLoading.value = false;
    }
  }

  void toggleProjectMenu() {
    if (!shouldShowProjectDropdown) return;
    isProjectMenuOpen.value = !isProjectMenuOpen.value;
  }

  Future<void> selectProject(int index) async {
    if (index < 0 || index >= projects.length) return;
    if (selectedProjectIndex.value == index) {
      isProjectMenuOpen.value = false;
      return;
    }

    selectedProjectIndex.value = index;
    isProjectMenuOpen.value = false;
    await _fetchUpdatesForSelectedProject();
  }

  void toggleCategoryMenu() {
    if (!shouldShowCategoryDropdown) return;
    isCategoryMenuOpen.value = !isCategoryMenuOpen.value;
  }

  void selectCategory(String value) {
    if (!categoryFilters.contains(value)) return;
    selectedCategory.value = value;
    isCategoryMenuOpen.value = false;
  }

  Future<void> toggleLike(UpdateModel item) async {
    final index = updateList.indexWhere((e) => e.id == item.id);
    if (index < 0) return;

    final previous = updateList[index];
    final nextLiked = !previous.isLiked;
    final nextLikes = nextLiked
        ? previous.likeCount + 1
        : (previous.likeCount > 0 ? previous.likeCount - 1 : 0);
    updateList[index] = previous.copyWith(
      isLiked: nextLiked,
      likeCount: nextLikes,
    );

    try {
      final response = await _useCase.toggleLike(
        apiClient: _apiClient,
        updateId: item.id,
      );
      updateList[index] = updateList[index].copyWith(
        likeCount: response.likeCount,
      );
    } catch (_) {
      updateList[index] = previous;
      Get.snackbar('Error', 'Failed to update like status');
    }
  }

  Future<void> shareUpdate(UpdateModel item) async {
    final index = updateList.indexWhere((e) => e.id == item.id);
    if (index < 0) return;

    final previous = updateList[index];
    updateList[index] = previous.copyWith(shareCount: previous.shareCount + 1);

    try {
      final count = await _useCase.shareUpdate(
        apiClient: _apiClient,
        updateId: item.id,
      );
      updateList[index] = updateList[index].copyWith(shareCount: count);
    } catch (_) {
      updateList[index] = previous;
      Get.snackbar('Error', 'Failed to share update');
    }
  }

  Future<List<UpdateCommentModel>> fetchComments(String updateId) async {
    try {
      return await _useCase.getComments(
        apiClient: _apiClient,
        updateId: updateId,
      );
    } catch (_) {
      Get.snackbar('Error', 'Failed to load comments');
      return <UpdateCommentModel>[];
    }
  }

  Future<UpdateCommentModel?> addComment({
    required String updateId,
    required String comment,
  }) async {
    final text = comment.trim();
    if (text.isEmpty) return null;

    try {
      final created = await _useCase.addComment(
        apiClient: _apiClient,
        updateId: updateId,
        comment: text,
      );
      final normalized = _normalizeNewComment(created, typedText: text);

      final index = updateList.indexWhere((e) => e.id == updateId);
      if (index >= 0) {
        final item = updateList[index];
        updateList[index] = item.copyWith(commentCount: item.commentCount + 1);
      }

      return normalized;
    } catch (_) {
      Get.snackbar('Error', 'Failed to add comment');
      return null;
    }
  }

  UpdateCommentModel _normalizeNewComment(
    UpdateCommentModel created, {
    required String typedText,
  }) {
    final currentUserName = _currentUserName();
    final currentUserAvatar = _currentUserAvatar();
    final rawName = created.userName.trim();
    final resolvedName = rawName.isEmpty || rawName.toLowerCase() == 'user'
        ? currentUserName
        : rawName;
    final resolvedText = created.text.trim().isEmpty ? typedText : created.text;
    final rawAvatar = created.userAvatar?.trim() ?? '';

    return created.copyWith(
      userName: resolvedName.isEmpty ? 'User' : resolvedName,
      text: resolvedText,
      userAvatar: rawAvatar.isEmpty ? currentUserAvatar : rawAvatar,
    );
  }

  String _currentUserName() {
    if (!Get.isRegistered<LoginController>()) return '';
    final auth = Get.find<LoginController>();
    final name = auth.displayName.trim();
    return name;
  }

  String _currentUserAvatar() {
    if (!Get.isRegistered<LoginController>()) return '';
    final auth = Get.find<LoginController>();
    return auth.displayAvatar.trim();
  }

  Future<bool> createUpdate({
    required String description,
    required List<File> images,
  }) async {
    final projectId = selectedProjectId;
    if (projectId.isEmpty) {
      Get.snackbar('Error', 'Select a project before posting update');
      return false;
    }

    final text = description.trim();
    if (text.isEmpty) {
      Get.snackbar('Error', 'Description is required');
      return false;
    }

    try {
      isCreatingUpdate.value = true;
      await _useCase.createUpdate(
        apiClient: _apiClient,
        projectId: projectId,
        description: text,
        images: images,
      );
      await _fetchUpdatesForSelectedProject();
      return true;
    } catch (_) {
      Get.snackbar('Error', 'Failed to create update');
      return false;
    } finally {
      isCreatingUpdate.value = false;
    }
  }

  Future<void> _fetchUpdatesForSelectedProject() async {
    final projectId = selectedProjectId;
    if (projectId.isEmpty) {
      updateList.clear();
      _refreshCategoryFilters();
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      final updates = await _useCase.fetchProjectUpdates(
        apiClient: _apiClient,
        projectId: projectId,
      );
      updateList.assignAll(updates);
      _refreshCategoryFilters();
    } catch (_) {
      updateList.clear();
      _refreshCategoryFilters();
      errorMessage.value = 'Failed to load updates. Please try again.';
      Get.snackbar('Error', 'Failed to load updates');
    } finally {
      isLoading.value = false;
    }
  }

  void _refreshCategoryFilters() {
    final nextFilters = _useCase.buildCategoryFilters(updateList.toList());
    categoryFilters.assignAll(nextFilters);

    selectedCategory.value = _useCase.resolveSelectedCategory(
      categoryFilters: categoryFilters,
      currentSelected: selectedCategory.value,
    );

    if (!shouldShowCategoryDropdown) {
      isCategoryMenuOpen.value = false;
    }
  }

  int get _safeProjectIndex {
    if (projects.isEmpty) return 0;
    final idx = selectedProjectIndex.value;
    if (idx < 0) return 0;
    if (idx >= projects.length) return projects.length - 1;
    return idx;
  }

  void _normalizeProjectSelection() {
    selectedProjectIndex.value = _safeProjectIndex;
    if (!shouldShowProjectDropdown) {
      isProjectMenuOpen.value = false;
    }
  }
}
