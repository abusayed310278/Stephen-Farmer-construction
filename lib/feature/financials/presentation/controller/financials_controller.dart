import 'package:get/get.dart';

import '../../domain/entities/financials_project_entity.dart';
import '../../domain/usecase/get_financials_projects_usecase.dart';

class FinancialsController extends GetxController {
  FinancialsController({GetFinancialsProjectsUseCase? getProjectsUseCase})
    : _getProjectsUseCase =
          getProjectsUseCase ?? Get.find<GetFinancialsProjectsUseCase>();

  final GetFinancialsProjectsUseCase _getProjectsUseCase;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<FinancialsProjectEntity> projects =
      <FinancialsProjectEntity>[].obs;
  final RxInt selectedProjectIndex = 0.obs;
  final RxBool isProjectMenuOpen = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshProjects();
  }

  FinancialsProjectEntity? get selectedProject {
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
      errorMessage.value = 'Failed to load financial data. Please try again.';
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

  void _normalizeState() {
    selectedProjectIndex.value = _safeIndex;
    if (projects.length <= 1) {
      isProjectMenuOpen.value = false;
    }
  }
}
