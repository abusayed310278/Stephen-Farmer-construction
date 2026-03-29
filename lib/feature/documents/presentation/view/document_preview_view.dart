import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:stephen_farmer/core/network/api_service/api_client.dart';
import 'package:stephen_farmer/core/network/api_service/api_endpoints.dart';
import 'package:stephen_farmer/core/network/api_service/token_meneger.dart';
import 'package:stephen_farmer/core/common/role_bg_color.dart';
import 'package:stephen_farmer/feature/auth/presentation/controller/login_controller.dart';
import 'package:stephen_farmer/feature/documents/domain/entities/document_project_entity.dart';

class DocumentPreviewView extends StatefulWidget {
  const DocumentPreviewView({super.key, required this.item});

  final RecentDocumentEntity item;

  @override
  State<DocumentPreviewView> createState() => _DocumentPreviewViewState();
}

class _DocumentPreviewViewState extends State<DocumentPreviewView> {
  late final Future<Uint8List> _pdfBytesFuture;

  RecentDocumentEntity get item => widget.item;

  String get _documentUrl => item.fileUrl?.trim() ?? '';

  @override
  void initState() {
    super.initState();
    _pdfBytesFuture = _isPdfDocument(_documentUrl, item.mimeType, item.title)
        ? _loadPdfBytes()
        : Future<Uint8List>.value(Uint8List(0));
  }

  @override
  Widget build(BuildContext context) {
    final role = Get.find<LoginController>().role.value;
    final isInterior = RoleBgColor.isInterior(role);
    final bgColor = RoleBgColor.scaffoldColor(role);
    final titleColor = isInterior ? const Color(0xFF040404) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: titleColor,
        title: Text(
          'Document',
          style: GoogleFonts.manrope(
            color: titleColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: GoogleFonts.manrope(
                  color: titleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.category} • ${item.dateLabel}',
                style: GoogleFonts.manrope(
                  color: isInterior
                      ? const Color(0xFF46413A)
                      : const Color(0xFFD5DDE1),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(child: _buildPreview(context, isInterior)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context, bool isInterior) {
    final isPdf = _isPdfDocument(_documentUrl, item.mimeType, item.title);
    final isImage = _isImageDocument(_documentUrl, item.mimeType, item.title);

    if (!isPdf && !isImage && _documentUrl.isEmpty) {
      return _messageBox(
        isInterior: isInterior,
        text: 'No document URL found for this file.',
      );
    }

    if (isPdf) {
      return _previewContainer(
        isInterior: isInterior,
        child: FutureBuilder<Uint8List>(
          future: _pdfBytesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return _messageBox(
                isInterior: isInterior,
                text: 'Failed to load the selected PDF document.',
              );
            }

            return SfPdfViewer.memory(
              snapshot.data!,
              canShowScrollHead: true,
              canShowScrollStatus: true,
              pageLayoutMode: PdfPageLayoutMode.single,
            );
          },
        ),
      );
    }

    if (isImage) {
      return _previewContainer(
        isInterior: isInterior,
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          child: Image.network(
            _documentUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (_, __, ___) {
              return _messageBox(
                isInterior: isInterior,
                text: 'Failed to load the selected document preview.',
              );
            },
          ),
        ),
      );
    }

    return _messageBox(
      isInterior: isInterior,
      text: 'Preview not available for this file type.\nURL: $_documentUrl',
    );
  }

  Widget _previewContainer({required bool isInterior, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isInterior ? const Color(0xFFBFC3C5) : const Color(0xFF2D3840),
        ),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(10), child: child),
    );
  }

  bool _isPdfDocument(String url, String? mimeType, String title) {
    final mime = (mimeType ?? '').toLowerCase();
    if (mime == 'application/pdf') return true;
    return _pathLooksLike(url, '.pdf') || title.toLowerCase().endsWith('.pdf');
  }

  Future<Uint8List> _loadPdfBytes() async {
    if (_documentUrl.isNotEmpty) {
      try {
        final urlBytes = await _loadPdfFromUrl(_documentUrl);
        if (urlBytes.isNotEmpty) {
          return urlBytes;
        }
      } catch (_) {
        // Fall back to the authenticated content endpoint below.
      }
    }

    final documentId = item.id.trim();
    if (documentId.isEmpty) {
      throw Exception('Document ID is missing.');
    }

    final apiClient = Get.find<ApiClient>();
    final response = await apiClient.dio.get<dynamic>(
      DocumentEndpoints.getContent(documentId),
      options: Options(responseType: ResponseType.bytes),
    );
    final bytes = _extractBytes(response.data);
    if (bytes.isEmpty) {
      throw Exception('Document content response was empty.');
    }
    return bytes;
  }

  Future<Uint8List> _loadPdfFromUrl(String rawUrl) async {
    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null || !uri.hasScheme) {
      throw Exception('Invalid document URL.');
    }

    final token = await TokenManager.getToken();
    final response = await Dio().get<dynamic>(
      uri.toString(),
      options: Options(
        responseType: ResponseType.bytes,
        headers: _authHeadersFor(uri, token),
        followRedirects: true,
      ),
    );

    final bytes = _extractBytes(response.data);
    if (bytes.isEmpty) {
      throw Exception('Document URL response was empty.');
    }
    return bytes;
  }

  bool _isImageDocument(String url, String? mimeType, String title) {
    final mime = (mimeType ?? '').toLowerCase();
    if (mime.startsWith('image/')) return true;
    final lowerTitle = title.toLowerCase();
    return _pathLooksLike(url, '.png') ||
        _pathLooksLike(url, '.jpg') ||
        _pathLooksLike(url, '.jpeg') ||
        _pathLooksLike(url, '.webp') ||
        _pathLooksLike(url, '.gif') ||
        lowerTitle.endsWith('.png') ||
        lowerTitle.endsWith('.jpg') ||
        lowerTitle.endsWith('.jpeg') ||
        lowerTitle.endsWith('.webp') ||
        lowerTitle.endsWith('.gif');
  }

  bool _pathLooksLike(String raw, String extension) {
    final value = raw.trim();
    if (value.isEmpty) return false;

    final uri = Uri.tryParse(value);
    final path = (uri?.path.isNotEmpty == true ? uri!.path : value)
        .toLowerCase();
    return path.endsWith(extension);
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
    final trimmedToken = token?.trim() ?? '';
    if (trimmedToken.isEmpty) return null;

    final apiHost = Uri.tryParse(_apiOrigin())?.host ?? '';
    if (apiHost.isEmpty || uri.host != apiHost) return null;

    return <String, String>{'Authorization': 'Bearer $trimmedToken'};
  }

  Uint8List _extractBytes(dynamic data) {
    if (data is Uint8List) {
      return data;
    }
    if (data is List<int>) {
      return Uint8List.fromList(data);
    }
    if (data is List) {
      return Uint8List.fromList(data.whereType<int>().toList(growable: false));
    }
    throw Exception('Unexpected document content format.');
  }

  Widget _messageBox({required bool isInterior, required String text}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isInterior ? const Color(0xFFE0DFDD) : const Color(0xFF111A22),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isInterior ? const Color(0xFFBFC3C5) : const Color(0xFF2D3840),
        ),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            color: isInterior
                ? const Color(0xFF46413A)
                : const Color(0xFFD5DDE1),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
