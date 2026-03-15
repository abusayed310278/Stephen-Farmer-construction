import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stephen_farmer/core/common/widgets/category_dropdown_widget.dart';
import 'package:stephen_farmer/core/common/role_bg_color.dart';
import 'package:stephen_farmer/core/utils/images.dart';
import 'package:stephen_farmer/feature/auth/presentation/controller/login_controller.dart';
import 'package:stephen_farmer/feature/financials/domain/entities/financials_project_entity.dart';

import '../controller/financials_controller.dart';
import '../widgets/financials_budget_metric_card.dart';
import '../widgets/financials_payment_schedule_item_card.dart';
import '../widgets/financials_remaining_balance_card.dart';

class FinancialsScreenView extends GetView<FinancialsController> {
  const FinancialsScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final project = controller.selectedProject;
      final role = Get.find<LoginController>().role.value;
      final bool isInterior = RoleBgColor.isInterior(role);
      final Color titleColor = isInterior
          ? const Color(0xFF1D1D1D)
          : Colors.white;
      final Color sectionColor = isInterior
          ? const Color(0xFF45413C)
          : Colors.white;

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: RoleBgColor.overlayStyle(role),
        child: Scaffold(
          backgroundColor: RoleBgColor.scaffoldColor(role),
          body: Container(
            decoration: RoleBgColor.decoration(role),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Financials',
                        style: GoogleFonts.manrope(
                          color: titleColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (controller.isLoading.value && project == null)
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (project == null)
                      Expanded(
                        child: Center(
                          child: Text(
                            controller.errorMessage.value.isEmpty
                                ? 'No financial data available'
                                : controller.errorMessage.value,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isInterior
                                  ? const Color(0xFF464646)
                                  : Colors.white70,
                              fontSize: 13,
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
                        thumbnailBuilder: (item) => item.thumbnailUrl,
                        fallbackAsset: AssetsImages.constructionIgm,
                      ),
                      // _buildProjectSelector(isInterior),
                      const SizedBox(height: 12),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: controller.refreshProjects,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            children: [
                              _buildMetricRow(project),
                              const SizedBox(height: 16),
                              FinancialsRemainingBalanceCard(
                                amountText: _formatAed(
                                  project.remainingBalance,
                                ),
                                paidPercent: project.paidPercent,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Payment Schedule',
                                style: TextStyle(
                                  fontFamily: 'ClashDisplay',
                                  color: titleColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  height: 1,
                                  letterSpacing: 0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ..._buildScheduleSections(project, sectionColor),
                              if (controller.errorMessage.value.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    bottom: 10,
                                  ),
                                  child: Text(
                                    controller.errorMessage.value,
                                    style: const TextStyle(
                                      color: Color(0xFFFF7A7A),
                                      fontSize: 12,
                                    ),
                                  ),
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

  /*   Widget _buildProjectSelector(bool isInterior) {
    return CategoryDropdownWidget(
      items: controller.projects,
      selectedIndex: controller.selectedProjectIndex.value,
      isMenuOpen: controller.isProjectMenuOpen.value,
      isInteriorTheme: isInterior,
      onToggle: controller.toggleProjectMenu,
      onSelect: controller.selectProject,
      titleBuilder: (item) => item.projectName,
      subtitleBuilder: (item) => item.projectAddress,
      thumbnailBuilder: (item) => item.thumbnailUrl,
      fallbackAsset: AssetsImages.constructionIgm,
    );
  } */

  Widget _buildMetricRow(FinancialsProjectEntity project) {
    return Row(
      children: [
        FinancialsBudgetMetricCard(
          title: 'Total Budget',
          amountText: _formatAed(project.totalBudget),
          subtitle: 'incl. AED 1,130 Variations',
        ),
        const SizedBox(width: 15),
        FinancialsBudgetMetricCard(
          title: 'Paid to Date',
          amountText: _formatAed(project.paidToDate),
          subtitle: '${project.paidPercent}% of total',
        ),
      ],
    );
  }

  List<Widget> _buildScheduleSections(
    FinancialsProjectEntity project,
    Color sectionColor,
  ) {
    final widgets = <Widget>[];

    for (final section in project.scheduleSections) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            section.title,
            style: GoogleFonts.manrope(
              color: sectionColor,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
      );
      widgets.addAll(
        section.items.map(
          (item) => FinancialsPaymentScheduleItemCard(item: item),
        ),
      );
      widgets.add(const SizedBox(height: 2));
    }

    return widgets;
  }
}

String _formatAed(int amount) {
  final formatted = amount.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
  return 'AED $formatted';
}
