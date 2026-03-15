import 'dart:io';

import 'package:get/get.dart';

import '../../domain/entities/document_project_entity.dart';
import '../../domain/usecase/get_document_projects_usecase.dart';
import '../../domain/usecase/upload_project_document_usecase.dart';

class DocumentController extends GetxController {
  DocumentController({
    GetDocumentProjectsUseCase? getProjectsUseCase,
    UploadProjectDocumentUseCase? uploadProjectDocumentUseCase,
  }) : _getProjectsUseCase =
           getProjectsUseCase ?? Get.find<GetDocumentProjectsUseCase>(),
       _uploadProjectDocumentUseCase =
           uploadProjectDocumentUseCase ??
           Get.find<UploadProjectDocumentUseCase>();

  final GetDocumentProjectsUseCase _getProjectsUseCase;
  final UploadProjectDocumentUseCase _uploadProjectDocumentUseCase;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<DocumentProjectEntity> projects = <DocumentProjectEntity>[].obs;
  final RxInt selectedProjectIndex = 0.obs;
  final RxBool isProjectMenuOpen = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshProjects();
  }

  DocumentProjectEntity? get selectedProject {
    if (projects.isEmpty) return null;
    return projects[_safeIndex];
  }

  int get _safeIndex {
    if (projects.isEmpty) return 0;
    final current = selectedProjectIndex.value;
    if (current < 0) return 0;
    if (current >= projects.length) return projects.length - 1;
    return current;
  }

  Future<void> refreshProjects() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final data = await _getProjectsUseCase.call();
      projects.assignAll(data);
      _normalizeState();
    } catch (_) {
      errorMessage.value = 'Failed to load documents. Please try again.';
      projects.clear();
      _normalizeState();
    } finally {
      isLoading.value = false;
    }
  }

  void toggleProjectMenu() {
    isProjectMenuOpen.value = !isProjectMenuOpen.value;
  }

  void selectProject(int index) {
    if (index < 0 || index >= projects.length) return;
    selectedProjectIndex.value = index;
    isProjectMenuOpen.value = false;
  }

  Future<bool> uploadDocument({
    required File file,
    required String title,
    required String category,
  }) async {
    final current = selectedProject;
    if (current == null || current.projectId.trim().isEmpty) {
      errorMessage.value = 'No project selected.';
      return false;
    }
    if (title.trim().isEmpty || category.trim().isEmpty) {
      errorMessage.value = 'Document title and category are required.';
      return false;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _uploadProjectDocumentUseCase.call(
        projectId: current.projectId,
        document: file,
        title: title.trim(),
        category: category.trim(),
      );
      await refreshProjects();
      return true;
    } catch (_) {
      errorMessage.value = 'Failed to upload document. Please try again.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _normalizeState() {
    selectedProjectIndex.value = _safeIndex;
    if (projects.length <= 1) {
      isProjectMenuOpen.value = false;
    }
  }
}
