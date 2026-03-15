import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stephen_farmer/core/common/widgets/category_dropdown_widget.dart';
import 'package:stephen_farmer/core/common/role_bg_color.dart';
import 'package:stephen_farmer/core/utils/images.dart';
import 'package:stephen_farmer/feature/auth/presentation/controller/login_controller.dart';

import '../../domain/entities/task_project_entity.dart';
import '../controller/task_controller.dart';
import 'task_details_screen_view.dart';
import '../widgets/task_action_attention_card.dart';
import '../widgets/task_action_item_card.dart';
import '../widgets/task_section_header_row.dart';

class TaskScreenView extends GetView<TaskController> {
  const TaskScreenView({super.key});

  void _openTaskDetails(
    TaskItemEntity item, {
    bool waitingForApproval = false,
  }) {
    Get.to(
      () => TaskDetailsScreenView(
        item: item,
        waitingForApproval: waitingForApproval,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final authController = Get.find<LoginController>();
      final project = controller.selectedProject;
      final role = authController.role.value;
      final bool isManager = authController.normalizedRoleKey == 'manager';
      final isInterior = RoleBgColor.isInterior(role);
      final List<TaskItemEntity> managerVisibleItems =
          isManager && project != null
          ? _resolveVisibleManagerItems(project)
          : <TaskItemEntity>[];
      final int managerSelectedIndex =
          controller.selectedManagerTaskIndex.value;
      final TaskItemEntity? selectedManagerItem =
          managerSelectedIndex >= 0 &&
              managerSelectedIndex < managerVisibleItems.length
          ? managerVisibleItems[managerSelectedIndex]
          : null;
      final Color approvalFooterColor = isInterior
          ? RoleBgColor.interiorGradient.colors.last
          : Colors.black;

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: RoleBgColor.overlayStyle(role),
        child: Scaffold(
          backgroundColor: RoleBgColor.scaffoldColor(role),
          bottomNavigationBar: isManager && project != null
              ? Container(
                  color: approvalFooterColor,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
                      child: SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: selectedManagerItem == null
                              ? null
                              : () => _openTaskDetails(
                                  selectedManagerItem,
                                  waitingForApproval: true,
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB5946E),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: SizedBox(
                            width: 140,
                            height: 20,
                            child: Center(
                              child: Text(
                                'Request for Approval',
                                style: GoogleFonts.manrope(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : null,
          body: Container(
            decoration: RoleBgColor.decoration(role),
            // color: isInterior ? null : const Color(0xFF0B1419),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Project',
                      style: TextStyle(
                        fontFamily: 'ClashDisplay',
                        color: isInterior
                            ? const Color(0xFF1D1D1D)
                            : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 22 / 16,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (controller.isLoading.value && project == null)
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (project == null)
                      Expanded(
                        child: Center(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 24,
                            ),
                            decoration: BoxDecoration(
                              color: isInterior
                                  ? const Color(0xFFD5D2CA)
                                  : const Color(0xFF111A1E),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isInterior
                                    ? const Color(0xFF77716A)
                                    : const Color(0xFFB9A77D),
                              ),
                            ),
                            child: Text(
                              controller.errorMessage.value.isEmpty
                                  ? 'No task data available'
                                  : controller.errorMessage.value,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isInterior
                                    ? const Color(0xFF2E2E2E)
                                    : Colors.white70,
                                fontSize: 14,
                              ),
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
                        titleBuilder: (item) => item.projectName,
                        subtitleBuilder: (item) => item.projectAddress,
                        thumbnailBuilder: _projectThumbnail,
                        fallbackAsset: AssetsImages.constructionIgm,
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: controller.refreshProjects,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            children: isManager
                                ? _buildManagerContent(project, isInterior)
                                : _buildUserContent(project, isInterior),
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

  List<Widget> _buildUserContent(TaskProjectEntity project, bool isInterior) {
    return [
      TaskActionAttentionCard(
        count: project.actionsNeededCount,
        message: project.actionsNeededMessage,
        isInterior: isInterior,
      ),
      const SizedBox(height: 12),
      for (final section in project.sections) ...[
        TaskSectionHeaderRow(
          title: section.title,
          pendingCount: section.pendingCount,
          isInterior: isInterior,
          showLeadingIcon: section.title.trim().toLowerCase() == 'your actions',
        ),
        const SizedBox(height: 8),
        ...section.items.map(
          (item) => TaskActionItemCard(
            item: item,
            isInterior: isInterior,
            onTap: () => _openTaskDetails(item),
            showQuickActions: false,
          ),
        ),
        const SizedBox(height: 12),
      ],
      if (controller.errorMessage.value.isNotEmpty &&
          controller.projects.isEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            controller.errorMessage.value,
            style: const TextStyle(color: Color(0xFF8C2323), fontSize: 12),
          ),
        ),
    ];
  }

  List<Widget> _buildManagerContent(
    TaskProjectEntity project,
    bool isInterior,
  ) {
    final phaseItems = _resolvePhaseItems(project);
    final bool showFinished = controller.managerPhaseTab.value == 1;
    final List<TaskItemEntity> visibleItems = showFinished
        ? phaseItems.finished
        : phaseItems.active;

    final Color titleColor = isInterior
        ? const Color(0xFF2A241D)
        : Colors.white;
    final Color mutedTextColor = isInterior
        ? const Color(0xFF585858)
        : const Color(0xFF90A0A6);

    return [
      _TaskPhaseToggleRow(
        activeCount: phaseItems.active.length,
        finishedCount: phaseItems.finished.length,
        selectedTab: controller.managerPhaseTab.value,
        onTabChanged: controller.setManagerPhaseTab,
        isInterior: isInterior,
      ),
      const SizedBox(height: 14),
      SizedBox(
        width: 343,
        height: 22,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            showFinished ? 'Finished Phases' : 'Active Phases',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'ClashDisplay',
              color: titleColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 22 / 16,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
      const SizedBox(height: 10),
      if (visibleItems.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: isInterior
                ? const Color(0xFFD5D2CA)
                : const Color(0xFF111A1E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isInterior
                  ? const Color(0xFF77716A)
                  : const Color(0xFF39474D),
            ),
          ),
          child: Text(
            showFinished
                ? 'No finished phases yet'
                : 'No active phases right now',
            style: TextStyle(color: mutedTextColor, fontSize: 13),
          ),
        )
      else
        ...visibleItems.asMap().entries.map(
          (entry) => _TaskPhaseItemCard(
            isSelected: controller.selectedManagerTaskIndex.value == entry.key,
            item: entry.value,
            isInterior: isInterior,
            showFinishedBadge: showFinished,
            onTap: () => controller.selectManagerTask(entry.key),
          ),
        ),
      if (controller.errorMessage.value.isNotEmpty &&
          controller.projects.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 8),
          child: Text(
            controller.errorMessage.value,
            style: const TextStyle(color: Color(0xFF8C2323), fontSize: 12),
          ),
        ),
    ];
  }

  _PhaseItems _resolvePhaseItems(TaskProjectEntity project) {
    final List<TaskItemEntity> active = <TaskItemEntity>[];
    final List<TaskItemEntity> finished = <TaskItemEntity>[];

    // Preferred API mapping:
    // when backend returns phaseStatus/status on each item,
    // use that directly for active/finished split.
    bool usedStatusSplit = false;
    for (final section in project.sections) {
      for (final item in section.items) {
        if (item.isFinished) {
          finished.add(item);
          usedStatusSplit = true;
        } else if (item.isActive) {
          active.add(item);
          usedStatusSplit = true;
        }
      }
    }
    if (usedStatusSplit) {
      return _PhaseItems(active: active, finished: finished);
    }

    bool usedExplicitSplit = false;

    for (final section in project.sections) {
      final normalized = section.title.trim().toLowerCase();
      final isFinishedSection = _hasAnyKeyword(normalized, const [
        'finish',
        'finished',
        'complete',
        'completed',
        'done',
      ]);
      final isActiveSection = _hasAnyKeyword(normalized, const [
        'active',
        'pending',
        'in progress',
        'ongoing',
      ]);

      if (isFinishedSection) {
        finished.addAll(section.items);
        usedExplicitSplit = true;
      } else if (isActiveSection) {
        active.addAll(section.items);
        usedExplicitSplit = true;
      }
    }

    if (!usedExplicitSplit) {
      for (final section in project.sections) {
        final int splitIndex = section.pendingCount
            .clamp(0, section.items.length)
            .toInt();
        active.addAll(section.items.take(splitIndex));
        finished.addAll(section.items.skip(splitIndex));
      }
    }

    if (active.isEmpty && finished.isEmpty) {
      for (final section in project.sections) {
        active.addAll(section.items);
      }
    }

    return _PhaseItems(active: active, finished: finished);
  }

  String? _projectThumbnail(TaskProjectEntity project) {
    final direct = (project.thumbnailUrl ?? '').trim();
    if (direct.isNotEmpty && direct.toLowerCase() != 'null') {
      return direct;
    }

    for (final section in project.sections) {
      for (final item in section.items) {
        for (final image in item.imageUrls) {
          final candidate = image.trim();
          if (candidate.isNotEmpty && candidate.toLowerCase() != 'null') {
            return candidate;
          }
        }
      }
    }

    return null;
  }

  bool _hasAnyKeyword(String source, List<String> keywords) {
    for (final keyword in keywords) {
      if (source.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  List<TaskItemEntity> _resolveVisibleManagerItems(TaskProjectEntity project) {
    final phaseItems = _resolvePhaseItems(project);
    final bool showFinished = controller.managerPhaseTab.value == 1;
    return showFinished ? phaseItems.finished : phaseItems.active;
  }
}

class _TaskPhaseToggleRow extends StatelessWidget {
  const _TaskPhaseToggleRow({
    required this.activeCount,
    required this.finishedCount,
    required this.selectedTab,
    required this.onTabChanged,
    required this.isInterior,
  });

  final int activeCount;
  final int finishedCount;
  final int selectedTab;
  final ValueChanged<int> onTabChanged;
  final bool isInterior;

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = isInterior
        ? const Color(0xFFF5F2EC)
        : Colors.white;
    final Color unselectedColor = isInterior
        ? const Color(0xFFB5AEA4)
        : const Color(0xFF8B989E);
    final Color underlineColor = isInterior
        ? const Color(0xFFD7B46A)
        : const Color(0xFFD09A2F);

    return Row(
      children: [
        _TaskPhaseToggleItem(
          label: 'Active ($activeCount)',
          isSelected: selectedTab == 0,
          selectedColor: selectedColor,
          unselectedColor: unselectedColor,
          underlineColor: underlineColor,
          onTap: () => onTabChanged(0),
        ),
        const SizedBox(width: 14),
        _TaskPhaseToggleItem(
          label: 'Finished ($finishedCount)',
          isSelected: selectedTab == 1,
          selectedColor: selectedColor,
          unselectedColor: unselectedColor,
          underlineColor: underlineColor,
          onTap: () => onTabChanged(1),
        ),
      ],
    );
  }
}

class _TaskPhaseToggleItem extends StatelessWidget {
  const _TaskPhaseToggleItem({
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.underlineColor,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final Color underlineColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'ClashDisplay',
                color: isSelected ? selectedColor : unselectedColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 22 / 14,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 70,
              height: 2,
              color: isSelected ? underlineColor : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskPhaseItemCard extends StatelessWidget {
  const _TaskPhaseItemCard({
    required this.isSelected,
    required this.item,
    required this.isInterior,
    required this.showFinishedBadge,
    this.onTap,
  });

  final bool isSelected;
  final TaskItemEntity item;
  final bool isInterior;
  final bool showFinishedBadge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool useInteriorFinishedStyle = isInterior && showFinishedBadge;
    final bool useInteriorActiveStyle = isInterior && !showFinishedBadge;
    final Color cardColor = isSelected
        ? const Color(0xFFAD7D39)
        : useInteriorFinishedStyle
        ? const Color(0xFFF4F4F4)
        : useInteriorActiveStyle
        ? const Color(0xFF8A806F)
        : isInterior
        ? const Color(0xFFD5D2CA)
        : const Color(0xFF111A1E);
    final Color borderColor = isSelected
        ? const Color(0xFFAD7D39)
        : useInteriorFinishedStyle
        ? const Color(0xFF8E8A82)
        : useInteriorActiveStyle
        ? const Color(0xFF8A806F)
        : isInterior
        ? const Color(0xFF77716A)
        : const Color(0xFF3A474D);
    final Color titleColor = isSelected
        ? Colors.white
        : useInteriorFinishedStyle
        ? const Color(0xFF1E1E1E)
        : useInteriorActiveStyle
        ? Colors.white
        : isInterior
        ? const Color(0xFF1E1E1E)
        : Colors.white;
    final Color subtitleColor = isSelected
        ? const Color(0xFFF4E8D6)
        : useInteriorFinishedStyle
        ? const Color(0xFF8E8E93)
        : useInteriorActiveStyle
        ? const Color(0xFFB8BEC7)
        : isInterior
        ? const Color(0xFF373737)
        : const Color(0xFF8E8E93);
    final Color arrowColor = isSelected
        ? const Color(0xFFF0DBC0)
        : useInteriorFinishedStyle
        ? const Color(0xFFD7BE8A)
        : useInteriorActiveStyle
        ? const Color(0xFFE0CFAB)
        : isInterior
        ? const Color(0xFF8A6B37)
        : const Color(0xFFD2A463);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: 265,
                    height: 20,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'ClashDisplay',
                          color: titleColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: arrowColor, size: 24),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 265,
              height: 19,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    color: subtitleColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
            if (showFinishedBadge) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C9B2F),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: useInteriorFinishedStyle
                          ? Colors.black
                          : Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Finished',
                      style: GoogleFonts.manrope(
                        color: useInteriorFinishedStyle
                            ? Colors.black
                            : Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 1,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PhaseItems {
  const _PhaseItems({required this.active, required this.finished});

  final List<TaskItemEntity> active;
  final List<TaskItemEntity> finished;
}
