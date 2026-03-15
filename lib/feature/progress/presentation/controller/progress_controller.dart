import 'package:get/get.dart';
import '../../domain/entities/progress_entity.dart';
import '../../domain/usecase/get_progress_projects_usecase.dart';
import '../../domain/usecase/submit_progress_usecase.dart';

class ProgressController extends GetxController {
  ProgressController({
    GetProgressProjectsUseCase? getProjectsUseCase,
    SubmitProgressUseCase? submitProgressUseCase,
  }) : _getProjectsUseCase =
           getProjectsUseCase ?? Get.find<GetProgressProjectsUseCase>(),
       _submitProgressUseCase =
           submitProgressUseCase ?? Get.find<SubmitProgressUseCase>();

  final GetProgressProjectsUseCase _getProjectsUseCase;
  final SubmitProgressUseCase _submitProgressUseCase;

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString submitErrorMessage = ''.obs;
  final RxList<ProjectProgressEntity> projects = <ProjectProgressEntity>[].obs;
  final RxInt selectedProjectIndex = 0.obs;
  final RxBool isProjectMenuOpen = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshProjects();
  }

  bool get hasProjects => projects.isNotEmpty;

  bool get shouldShowProjectDropdown => projects.isNotEmpty;

  ProjectProgressEntity? get selectedProject {
    if (!hasProjects) return null;
    final int safeIndex = _safeSelectedIndex();
    return projects[safeIndex];
  }

  Future<void> refreshProjects() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await _getProjectsUseCase.call();
      projects.assignAll(result);
      _normalizeSelectedProject();
    } catch (_) {
      errorMessage.value = 'Failed to load progress data. Please try again.';
      projects.clear();
      _normalizeSelectedProject();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> submitProgress({
    String? projectId,
    required String progressName,
    required int percent,
    required String note,
  }) async {
    try {
      isSubmitting.value = true;
      submitErrorMessage.value = '';

      final resolvedProjectId = (projectId ?? '').trim().isNotEmpty
          ? projectId!.trim()
          : selectedProject?.id ?? '';
      if (resolvedProjectId.trim().isEmpty) {
        submitErrorMessage.value = 'Select a project first.';
        return false;
      }

      await _submitProgressUseCase.call(
        projectId: resolvedProjectId,
        progressName: progressName,
        percent: percent,
        note: note,
      );

      await refreshProjects();
      return true;
    } catch (_) {
      submitErrorMessage.value = 'Failed to submit progress. Please try again.';
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void toggleProjectMenu() {
    if (!shouldShowProjectDropdown) return;
    isProjectMenuOpen.value = !isProjectMenuOpen.value;
  }

  void selectProject(int index) {
    if (index < 0 || index >= projects.length) return;
    selectedProjectIndex.value = index;
    isProjectMenuOpen.value = false;
  }

  int _safeSelectedIndex() {
    if (!hasProjects) return 0;
    final int index = selectedProjectIndex.value;
    if (index < 0) return 0;
    if (index >= projects.length) return projects.length - 1;
    return index;
  }

  void _normalizeSelectedProject() {
    selectedProjectIndex.value = _safeSelectedIndex();
    if (!shouldShowProjectDropdown) {
      isProjectMenuOpen.value = false;
    }
  }
}
