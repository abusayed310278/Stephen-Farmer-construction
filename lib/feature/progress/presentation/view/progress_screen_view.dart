import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:stephen_farmer/core/common/widgets/category_dropdown_widget.dart';
import 'package:stephen_farmer/core/common/role_bg_color.dart';
import 'package:stephen_farmer/core/utils/images.dart';
import 'package:stephen_farmer/feature/auth/presentation/controller/login_controller.dart';

import '../controller/progress_controller.dart';
import 'update_progrees_screen_view.dart';
import '../widgets/progress_overview_card.dart';
import '../widgets/progress_stat_card.dart';
import '../widgets/progress_task_item_card.dart';

class ProgressScreenView extends GetView<ProgressController> {
  const ProgressScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final authController = Get.find<LoginController>();
      final project = controller.selectedProject;
      final role = authController.role.value;
      final bool isManager = authController.normalizedRoleKey == 'manager';
      final bool isInterior = RoleBgColor.isInterior(role);
      const Color progressTitleColor = Colors.white;

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: RoleBgColor.overlayStyle(role),
        child: Scaffold(
          backgroundColor: RoleBgColor.scaffoldColor(role),
          body: Container(
            decoration: RoleBgColor.decoration(role),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      height: 22,
                      child: Text(
                        'Active Project',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'ClashDisplay',
                          color: Color(0xFFFFFFFF),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 22 / 16,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (controller.isLoading.value && !controller.hasProjects)
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (project == null)
                      Flexible(
                        child: Center(
                          child: Text(
                            controller.errorMessage.value.isEmpty
                                ? 'No progress data available'
                                : controller.errorMessage.value,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isInterior
                                  ? const Color(0xFF1D1D1D)
                                  : Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    else ...[
                      CategoryDropdownWidget(
                        items: controller.projects,
                        selectedIndex: controller.selectedProjectIndex.value,
                        isMenuOpen: controller.isProjectMenuOpen.value,
                        isInteriorTheme: isInterior,
                        onToggle: controller.toggleProjectMenu,
                        onSelect: controller.selectProject,
                        titleBuilder: (item) => item.name,
                        subtitleBuilder: (item) => item.address,
                        thumbnailBuilder: (item) =>
                            item.thumbnailUrl ?? item.heroImageUrl,
                        fallbackAsset: AssetsImages.constructionIgm,
                        titleSubtitleSpacing: 4,
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: controller.refreshProjects,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            children: [
                              ProgressOverviewCard(project: project),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  ProgressStatCard(
                                    iconAsset: AssetsImages.calendar,
                                    label: 'Day',
                                    value:
                                        '${project.dayCurrent}/${project.dayTotal}',
                                  ),
                                  const SizedBox(width: 8),
                                  ProgressStatCard(
                                    iconAsset: AssetsImages.task,
                                    label: 'Tasks',
                                    value:
                                        '${project.tasksCompleted}/${project.tasksTotal}',
                                  ),
                                  const SizedBox(width: 8),
                                  ProgressStatCard(
                                    icon: Icons.image_rounded,
                                    label: 'Photos',
                                    value: '${project.photosTotal}',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: SizedBox(
                                      width: 110,
                                      height: 22,
                                      child: Text(
                                        'Progress',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'ClashDisplay',
                                          color: progressTitleColor,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w500,
                                          height: 22 / 24,
                                          letterSpacing: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (isManager)
                                    InkWell(
                                      onTap: () {
                                        Get.to(
                                          () =>
                                              const UpdateProgreesScreenView(),
                                        );
                                      },
                                      child: const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Icon(
                                          Icons.add_circle_outline,
                                          size: 20,
                                          color: Color(0xFFD7C5A4),
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(height: 8),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: project.updates.length,
                                itemBuilder: (context, index) {
                                  final update = project.updates[index];
                                  return ProgressTaskItemCard(
                                    task: update,
                                    isInteriorTheme: isInterior,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
