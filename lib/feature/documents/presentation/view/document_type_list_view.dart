import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stephen_farmer/core/common/role_bg_color.dart';
import 'package:stephen_farmer/core/network/api_service/api_endpoints.dart';
import 'package:stephen_farmer/core/network/api_service/token_meneger.dart';
import 'package:stephen_farmer/feature/auth/presentation/controller/login_controller.dart';
import 'package:stephen_farmer/feature/documents/domain/entities/document_project_entity.dart';
import 'package:stephen_farmer/feature/documents/presentation/view/document_preview_view.dart';
import 'package:stephen_farmer/feature/documents/presentation/widgets/recent_document_item_card.dart';

class DocumentTypeListView extends StatelessWidget {
  const DocumentTypeListView({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<RecentDocumentEntity> items;

  @override
  Widget build(BuildContext context) {
    final role = Get.find<LoginController>().role.value;
    final isInterior = RoleBgColor.isInterior(role);
    final titleColor = isInterior ? const Color(0xFF040404) : Colors.white;
    final displayTitle = _sanitizeTitle(title);
    final pageColor = isInterior ? const Color(0xFFB0ACA0) : Colors.black;
    final bool showBackButton =
        defaultTargetPlatform == TargetPlatform.android;

    return Scaffold(
      backgroundColor: pageColor,
      body: SafeArea(
        child: Container(
          color: pageColor,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Column(
              children: [
                SizedBox(
                  height: 44,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 44,
                        child: showBackButton
                            ? IconButton(
                                onPressed: Get.back,
                                icon: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 20,
                                  color: titleColor,
                                ),
                              )
                            : null,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            displayTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              color: titleColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              height: 1,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Text(
                            'No $displayTitle documents found.',
                            style: GoogleFonts.manrope(
                              color: isInterior
                                  ? const Color(0xFF46413A)
                                  : const Color(0xFFD5DDE1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return RecentDocumentItemCard(
                              item: items[index],
                              onTap: () => Get.to(
                                () => DocumentPreviewView(item: items[index]),
                              ),
                              onDownload: () => _downloadDocument(items[index]),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _sanitizeTitle(String raw) {
    return raw
        .replaceAll('ø', 'o')
        .replaceAll('Ø', 'O')
        .replaceAll(RegExp(r'[\u0338\u2044\u2215]'), '')
        .trim();
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
    final candidate =
        uri.pathSegments.isNotEmpty ? uri.pathSegments.last : item.title;
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
