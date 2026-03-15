import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stephen_farmer/core/colors/app_color.dart';
import 'package:stephen_farmer/core/common/role_bg_color.dart';
import 'package:stephen_farmer/core/common/widgets/category_dropdown_widget.dart';
import 'package:stephen_farmer/core/network/api_service/api_endpoints.dart';
import 'package:stephen_farmer/core/network/api_service/token_meneger.dart';
import 'package:stephen_farmer/core/utils/images.dart';
import 'package:stephen_farmer/feature/auth/presentation/controller/login_controller.dart';
import 'package:stephen_farmer/feature/notifications/presentation/controller/notification_controller.dart';
import 'package:stephen_farmer/feature/notifications/presentation/view/notification_screen_view.dart';
import 'package:stephen_farmer/feature/profile/presentation/view/profile_screen_view.dart';
import 'package:stephen_farmer/feature/update/data/model/update_model.dart';
import 'package:stephen_farmer/feature/update/presentation/controller/update_controller.dart';
import 'package:stephen_farmer/feature/update/presentation/view/add_update_screen_view.dart';
import 'package:stephen_farmer/feature/update/presentation/view/update_comments_view.dart';
import 'package:stephen_farmer/feature/update/presentation/widgets/update_card.dart';

class UpdateScreenView extends StatelessWidget {
  final String loginCategory;
  static const MethodChannel _nativeShareChannel = MethodChannel(
    'app.share/native',
  );

  const UpdateScreenView({super.key, required this.loginCategory});

  Widget _emptyState({required bool isInterior, required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isInterior ? const Color(0xFF1D1D1D) : Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _createUpdateCard({
    required bool isInterior,
    required UpdateController controller,
  }) {
    final cardHeight = isInterior ? 68.0 : 72.0;
    final cardRadius = isInterior ? 8.0 : 10.0;
    final cardPadding = isInterior
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
        : const EdgeInsets.all(10);
    final badgeSize = isInterior ? 32.0 : 40.0;
    final badgeIconSize = isInterior ? 15.0 : 18.0;
    final titleColor = isInterior ? const Color(0xFF181818) : Colors.white;
    final subtitleColor = isInterior
        ? const Color(0xFF5F5A52)
        : const Color(0xFF8E8E93);
    final cardColor = isInterior ? const Color(0xFFF4F4F2) : Colors.transparent;
    final borderColor = isInterior
        ? const Color(0xFF9F9583)
        : const Color(0xFF2B4756);
    final badgeColor = isInterior
        ? const Color(0xFFF0ECE3)
        : const Color(0xFF2D3232);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(cardRadius),
        onTap: () {
          if (controller.selectedProjectId.isEmpty) {
            Get.snackbar('Error', 'Select a project first');
            return;
          }
          Get.to(
            () => AddUpdateScreenView(
              projectId: controller.selectedProjectId,
              onPostSuccess: controller.refreshAll,
              isInteriorTheme: isInterior,
            ),
          );
        },
        child: Container(
          height: cardHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(cardRadius),
            border: Border.all(color: borderColor),
          ),
          child: Padding(
            padding: cardPadding,
            child: Row(
              children: [
                Container(
                  width: badgeSize,
                  height: badgeSize,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.photo_camera_rounded,
                      size: badgeIconSize,
                      color: isInterior
                          ? const Color(0xFFD0B47A)
                          : const Color(0xFFD7C5A4),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Update',
                            style: GoogleFonts.manrope(
                              color: titleColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1,
                            ),
                          ),
                          Text(
                            'Share progress from the site',
                            style: GoogleFonts.manrope(
                              color: subtitleColor,
                              fontSize: isInterior ? 11 : 12,
                              fontWeight: FontWeight.w400,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: Icon(
                          Icons.add_circle_outline,
                          size: 24,
                          color: AppColor.appColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdateController());
    final authController = Get.find<LoginController>();
    final notificationController = Get.find<NotificationController>();

    return Obx(() {
      final isInterior = loginCategory.toLowerCase() == 'interior';
      final isManager = authController.normalizedRoleKey == 'manager';

      final projectItems = controller.projects.toList();
      final selectedProjectIndex = controller.selectedProjectIndex.value;
      final safeProjectSelectedIndex = projectItems.isEmpty
          ? 0
          : selectedProjectIndex.clamp(0, projectItems.length - 1);
      final isProjectMenuOpen = controller.isProjectMenuOpen.value;

      final categoryItems = controller.categoryFilters.toList();
      final selectedCategoryIndex = categoryItems.indexOf(
        controller.selectedCategory.value,
      );
      final safeCategorySelectedIndex = selectedCategoryIndex < 0
          ? 0
          : selectedCategoryIndex;
      final isCategoryMenuOpen = controller.isCategoryMenuOpen.value;

      final filteredList = controller.filteredUpdates;
      final notificationIconColor = isInterior
          ? const Color(0xFF1D1D1D)
          : const Color(0xFFC9B089);
      final profileAvatar = authController.displayAvatar;

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: RoleBgColor.overlayStyle(loginCategory),
        child: Scaffold(
          backgroundColor: RoleBgColor.scaffoldColor(loginCategory),
          body: Container(
            decoration: RoleBgColor.decoration(loginCategory),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        isInterior
                            ? Image.asset(
                                AssetsImages.interiorImg,
                                height: 50,
                                width: 54,
                              )
                            : Image.asset(
                                AssetsImages.constructionIgm,
                                height: 32,
                                width: 87,
                              ),
                        const SizedBox(width: 10),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Notifications',
                          onPressed: () =>
                              Get.to(() => const NotificationScreenView()),
                          icon: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                Icons.notifications_rounded,
                                color: notificationIconColor,
                                size: 24,
                              ),
                              if (notificationController.unreadCount > 0)
                                Positioned(
                                  right: -7,
                                  top: -7,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 2,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE53935),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: isInterior
                                            ? const Color(0xFFF3EFE7)
                                            : const Color(0xFF0B1218),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        notificationController.unreadCount > 99
                                            ? '99+'
                                            : notificationController.unreadCount
                                                  .toString(),
                                        style: GoogleFonts.manrope(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          height: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.to(() => const ProfileScreenView()),
                          child: _AuthAwareAvatar(
                            radius: 18,
                            imageUrl: profileAvatar,
                            backgroundColor: isInterior
                                ? const Color(0xFFE8DFD2)
                                : const Color(0xFF182127),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Active Project',
                      style: TextStyle(
                        fontFamily: 'ClashDisplay',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 22 / 16,
                        color: isInterior ? Colors.black : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (controller.isLoading.value && projectItems.isEmpty)
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (projectItems.isEmpty)
                      Expanded(
                        child: _emptyState(
                          isInterior: isInterior,
                          message: controller.errorMessage.value.isEmpty
                              ? 'No project available'
                              : controller.errorMessage.value,
                        ),
                      )
                    else
                      Expanded(
                        child: Column(
                          children: [
                            CategoryDropdownWidget<UpdateProjectModel>(
                              items: projectItems,
                              selectedIndex: safeProjectSelectedIndex,
                              isMenuOpen: isProjectMenuOpen,
                              isInteriorTheme: isInterior,
                              onToggle: controller.toggleProjectMenu,
                              onSelect: controller.selectProject,
                              titleBuilder: (item) => item.name,
                              subtitleBuilder: (item) => item.address,
                              thumbnailBuilder: (item) => item.thumbnailUrl,
                              fallbackAsset: AssetsImages.constructionIgm,
                              thumbnailWidth: 70,
                              thumbnailHeight: 39,
                              thumbnailBorderRadius: 4,
                              subtitleColor: isInterior
                                  ? const Color(0xFF6E6860)
                                  : const Color(0xFF8E8E93),
                              titleTextStyle: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1,
                              ),
                              subtitleTextStyle: GoogleFonts.manrope(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                height: 1,
                              ),
                            ),
                            if (controller.shouldShowCategoryDropdown) ...[
                              const SizedBox(height: 10),
                              CategoryDropdownWidget<String>(
                                items: categoryItems,
                                selectedIndex: safeCategorySelectedIndex,
                                isMenuOpen: isCategoryMenuOpen,
                                isInteriorTheme: isInterior,
                                onToggle: controller.toggleCategoryMenu,
                                onSelect: (index) => controller.selectCategory(
                                  categoryItems[index],
                                ),
                                titleBuilder: (item) => item,
                                subtitleBuilder: (item) =>
                                    'Filter updates by $item',
                                thumbnailBuilder: (_) => null,
                                fallbackAsset: AssetsImages.constructionIgm,
                                thumbnailWidth: 0,
                                thumbnailHeight: 0,
                                rowPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                minHeight: 46,
                              ),
                            ],
                            if (isManager) ...[
                              const SizedBox(height: 10),
                              _createUpdateCard(
                                isInterior: isInterior,
                                controller: controller,
                              ),
                            ],
                            const SizedBox(height: 10),
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: controller.refreshAll,
                                child: ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  children: [
                                    if (controller.isLoading.value &&
                                        controller.updateList.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 24),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                    else if (controller
                                            .errorMessage
                                            .value
                                            .isNotEmpty &&
                                        controller.updateList.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 24),
                                        child: Center(
                                          child: Text(
                                            controller.errorMessage.value,
                                            style: TextStyle(
                                              color: isInterior
                                                  ? const Color(0xFF464646)
                                                  : Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      )
                                    else if (filteredList.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 24),
                                        child: Center(
                                          child: Text(
                                            'No updates found',
                                            style: TextStyle(
                                              color: isInterior
                                                  ? const Color(0xFF464646)
                                                  : Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      ...filteredList.map(
                                        (item) => UpdatePostCard(
                                          item: item,
                                          isInteriorTheme: isInterior,
                                          onLike: () =>
                                              controller.toggleLike(item),
                                          onShare: () => _shareUpdate(
                                            context: context,
                                            controller: controller,
                                            item: item,
                                          ),
                                          onComment: () => _showCommentsSheet(
                                            context: context,
                                            controller: controller,
                                            updateId: item.id,
                                            isInterior: isInterior,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Future<void> _showCommentsSheet({
    required BuildContext context,
    required UpdateController controller,
    required String updateId,
    required bool isInterior,
  }) async {
    await Get.to(
      () => UpdateCommentsView(
        controller: controller,
        updateId: updateId,
        isInterior: isInterior,
      ),
    );
  }

  Future<void> _shareUpdate({
    required BuildContext context,
    required UpdateController controller,
    required UpdateModel item,
  }) async {
    await controller.shareUpdate(item);

    if (!context.mounted) return;

    final lines = <String>[
      item.title.trim().isEmpty ? 'Project Update' : item.title.trim(),
      if (item.description.trim().isNotEmpty) item.description.trim(),
      if (item.thumbnailUrl?.trim().isNotEmpty ?? false)
        item.thumbnailUrl!.trim(),
    ];
    final shareText = lines.join('\n');
    final shareSubject = item.title.trim().isEmpty
        ? 'Project Update'
        : item.title.trim();

    try {
      final box = context.findRenderObject() as RenderBox?;
      await Share.share(
        shareText,
        subject: shareSubject,
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      );
    } on MissingPluginException {
      if (!context.mounted) return;
      final handled = await _shareViaNativeChannel(
        shareText: shareText,
        subject: shareSubject,
      );
      if (!handled && context.mounted) {
        await _showShareFallbackSheet(context: context, shareText: shareText);
      }
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: shareText));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Share unavailable (${e.runtimeType}). Copied to clipboard.',
          ),
        ),
      );
    }
  }

  Future<bool> _shareViaNativeChannel({
    required String shareText,
    required String subject,
  }) async {
    try {
      final result = await _nativeShareChannel.invokeMethod<bool>('shareText', {
        'text': shareText,
        'subject': subject,
      });
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _showShareFallbackSheet({
    required BuildContext context,
    required String shareText,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF23222D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share',
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Native share is unavailable on this build. You can copy the text now.',
                  style: GoogleFonts.manrope(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: shareText));
                      if (!sheetContext.mounted) return;
                      Navigator.of(sheetContext).pop();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Share text copied to clipboard'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFAF8C6A),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Copy Share Text',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}

class _AuthAwareAvatar extends StatefulWidget {
  const _AuthAwareAvatar({
    required this.radius,
    required this.imageUrl,
    required this.backgroundColor,
  });

  final double radius;
  final String imageUrl;
  final Color backgroundColor;

  @override
  State<_AuthAwareAvatar> createState() => _AuthAwareAvatarState();
}

class _AuthAwareAvatarState extends State<_AuthAwareAvatar> {
  late final Future<String?> _tokenFuture;

  @override
  void initState() {
    super.initState();
    _tokenFuture = TokenManager.getToken();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = _resolveAvatarUrl(widget.imageUrl);

    return FutureBuilder<String?>(
      future: _tokenFuture,
      builder: (context, snapshot) {
        final headers = _buildHeadersFor(resolvedUrl, snapshot.data);

        return CircleAvatar(
          radius: widget.radius,
          backgroundColor: widget.backgroundColor,
          child: ClipOval(
            child: resolvedUrl.isEmpty
                ? Image.asset(
                    AssetsImages.placeholder,
                    width: widget.radius * 2,
                    height: widget.radius * 2,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    resolvedUrl,
                    width: widget.radius * 2,
                    height: widget.radius * 2,
                    fit: BoxFit.cover,
                    headers: headers,
                    errorBuilder: (_, __, ___) => Image.asset(
                      AssetsImages.placeholder,
                      width: widget.radius * 2,
                      height: widget.radius * 2,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        );
      },
    );
  }

  String _resolveAvatarUrl(String raw) {
    final value = raw.trim().replaceAll('\\', '/');
    if (value.isEmpty || value.toLowerCase() == 'null') {
      return '';
    }

    final lower = value.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('//')) {
      return 'https:$value';
    }

    final origin = _apiOrigin();
    if (origin.isEmpty) return value;
    if (value.startsWith('/')) return '$origin$value';
    return '$origin/$value';
  }

  String _apiOrigin() {
    final trimmed = baseUrl.trim();
    if (trimmed.isEmpty) return '';
    final normalized = trimmed.replaceFirst(RegExp(r'/api/v\d+/?$'), '');
    final uri = Uri.tryParse(normalized);
    if (uri == null || uri.host.isEmpty) return normalized;

    var host = uri.host;
    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        (host == 'localhost' || host == '127.0.0.1')) {
      host = '10.0.2.2';
    }

    return Uri(
      scheme: uri.scheme,
      host: host,
      port: uri.hasPort ? uri.port : null,
    ).toString();
  }

  Map<String, String>? _buildHeadersFor(String url, String? token) {
    final t = token?.trim() ?? '';
    if (t.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return null;
    final apiHost = Uri.tryParse(_apiOrigin())?.host ?? '';
    if (apiHost.isEmpty || uri.host != apiHost) return null;
    return <String, String>{'Authorization': 'Bearer $t'};
  }
}
