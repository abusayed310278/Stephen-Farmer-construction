import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stephen_farmer/core/common/role_bg_color.dart';
import 'package:stephen_farmer/core/common/widgets/category_dropdown_widget.dart';
import 'package:stephen_farmer/core/network/api_service/api_endpoints.dart';
import 'package:stephen_farmer/core/network/api_service/token_meneger.dart';
import 'package:stephen_farmer/core/utils/images.dart';
import 'package:stephen_farmer/feature/auth/presentation/controller/login_controller.dart';
import 'package:stephen_farmer/feature/documents/domain/entities/document_project_entity.dart';

import '../controller/document_controller.dart';
import '../widgets/document_category_card.dart';
import '../widgets/recent_document_item_card.dart';
import 'document_preview_view.dart';

class DocumentScreenView extends GetView<DocumentController> {
  const DocumentScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final project = controller.selectedProject;
      final role = Get.find<LoginController>().role.value;
      final isInterior = RoleBgColor.isInterior(role);
      final titleColor = isInterior ? const Color(0xFF040404) : Colors.white;
      final subtitleColor = isInterior
          ? const Color(0xFF46413A)
          : const Color(0xFFD5DDE1);

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: RoleBgColor.overlayStyle(role),
        child: Scaffold(
          backgroundColor: RoleBgColor.scaffoldColor(role),
          body: Container(
            decoration: RoleBgColor.decoration(role),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Documents',
                        style: GoogleFonts.manrope(
                          color: titleColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1,
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
                                ? 'No document data available'
                                : controller.errorMessage.value,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isInterior
                                  ? const Color(0xFF464646)
                                  : Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else ...[
                      _buildProjectSelector(isInterior),
                      const SizedBox(height: 12),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: controller.refreshProjects,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            children: [
                              _buildSectionHeader(
                                title: 'Documents',
                                subtitle: 'All project files organized by type',
                                titleColor: titleColor,
                                subtitleColor: subtitleColor,
                              ),
                              const SizedBox(height: 10),
                              _buildCategoryGrid(
                                categories: project.categories,
                                isInterior: isInterior,
                              ),
                              const SizedBox(height: 12),
                              _buildSectionHeader(
                                title: 'Recent Documents',
                                subtitle: 'Latest Uploads',
                                titleColor: titleColor,
                                subtitleColor: subtitleColor,
                              ),
                              const SizedBox(height: 8),
                              ...project.recentDocuments.map(
                                (item) => RecentDocumentItemCard(
                                  item: item,
                                  isInteriorTheme: isInterior,
                                  onTap: () => Get.to(
                                    () => DocumentPreviewView(item: item),
                                  ),
                                  onDownload: () => _downloadDocument(item),
                                ),
                              ),
                              if (controller.errorMessage.value.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
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

  Widget _buildProjectSelector(bool isInterior) {
    return CategoryDropdownWidget<DocumentProjectEntity>(
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
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'ClashDisplay',
            color: titleColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: GoogleFonts.manrope(
            color: subtitleColor,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid({
    required List<DocumentCategoryEntity> categories,
    required bool isInterior,
  }) {
    final visibleCategories = categories.take(4).toList();

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visibleCategories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        mainAxisExtent: 130,
      ),
      itemBuilder: (_, index) {
        final category = visibleCategories[index];
        return DocumentCategoryCard(
          item: category,
          isInteriorTheme: isInterior,
          onTap: null,
        );
      },
    );
  }

  Future<void> _downloadDocument(RecentDocumentEntity item) async {
    final resolved = _resolveDownloadUrl(item.fileUrl ?? '');
    if (resolved.isEmpty) {
      Get.snackbar('Error', 'No download URL found for this document.');
      return;
    }

    final uri = Uri.tryParse(resolved);
    if (uri == null || !uri.hasScheme) {
      Get.snackbar('Error', 'Invalid download URL.');
      return;
    }

    try {
      final token = await TokenManager.getToken();
      final filePath = '${Directory.systemTemp.path}/${_safeFileName(item, uri)}';

      await Dio().download(
        uri.toString(),
        filePath,
        options: Options(
          headers: _authHeadersFor(uri, token),
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
      );
      Get.snackbar('Downloaded', 'Document downloaded successfully.');
    } catch (_) {
      Get.snackbar('Error', 'Failed to download document.');
    }
  }

  String _guessExtension(String path, String? mimeType) {
    final lowerPath = path.toLowerCase();
    if (lowerPath.endsWith('.pdf')) return '.pdf';
    if (lowerPath.endsWith('.png')) return '.png';
    if (lowerPath.endsWith('.jpg') || lowerPath.endsWith('.jpeg')) return '.jpg';
    if (lowerPath.endsWith('.webp')) return '.webp';
    if (lowerPath.endsWith('.gif')) return '.gif';

    final mime = (mimeType ?? '').toLowerCase();
    if (mime == 'application/pdf') return '.pdf';
    if (mime == 'image/png') return '.png';
    if (mime == 'image/jpeg' || mime == 'image/jpg') return '.jpg';
    if (mime == 'image/webp') return '.webp';
    if (mime == 'image/gif') return '.gif';
    return '';
  }

  String _resolveDownloadUrl(String raw) {
    final value = raw.trim().replaceAll('\\', '/');
    if (value.isEmpty || value.toLowerCase() == 'null') return '';
    final lower = value.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) return value;
    if (value.startsWith('//')) return 'https:$value';
    final origin = _apiOrigin();
    if (origin.isEmpty) return '';
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

  Map<String, String>? _authHeadersFor(Uri uri, String? token) {
    final t = token?.trim() ?? '';
    if (t.isEmpty) return null;
    final apiHost = Uri.tryParse(_apiOrigin())?.host ?? '';
    if (apiHost.isEmpty || uri.host != apiHost) return null;
    return <String, String>{'Authorization': 'Bearer $t'};
  }

  String _safeFileName(RecentDocumentEntity item, Uri uri) {
    final ext = _guessExtension(uri.path, item.mimeType);
    final candidate = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : item.title;
    var safe = candidate
        .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();
    if (safe.isEmpty) {
      safe = 'document_${DateTime.now().millisecondsSinceEpoch}$ext';
    }
    if (safe.length > 80) {
      safe = safe.substring(0, 80);
    }
    if (!safe.contains('.') && ext.isNotEmpty) {
      safe = '$safe$ext';
    }
    return safe;
  }

}
