import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:stephen_farmer/core/network/api_service/api_client.dart';
import 'package:stephen_farmer/core/network/api_service/api_endpoints.dart';
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

  @override
  void initState() {
    super.initState();
    final url = item.fileUrl?.trim() ?? '';
    _pdfBytesFuture = _isPdfDocument(url, item.mimeType)
        ? _loadPdfBytes(url)
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
    final url = item.fileUrl?.trim() ?? '';
    if (url.isEmpty) {
      return _messageBox(
        isInterior: isInterior,
        text: 'No document URL found for this file.',
      );
    }

    if (_isPdfDocument(url, item.mimeType)) {
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

    if (_isImageDocument(url, item.mimeType)) {
      return _previewContainer(
        isInterior: isInterior,
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          child: Image.network(
            url,
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
      text: 'Preview not available for this file type.\nURL: $url',
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

  bool _isPdfDocument(String url, String? mimeType) {
    final mime = (mimeType ?? '').toLowerCase();
    if (mime == 'application/pdf') return true;

    final lower = url.toLowerCase();
    return lower.endsWith('.pdf');
  }

  Future<Uint8List> _loadPdfBytes(String url) async {
    final documentId = item.id.trim();
    if (documentId.isEmpty) {
      throw Exception('Document ID is missing.');
    }

    final apiClient = Get.find<ApiClient>();
    final response = await apiClient.dio.get<List<int>>(
      DocumentEndpoints.getContent(documentId),
      options: Options(responseType: ResponseType.bytes),
    );
    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      throw Exception('Document content response was empty.');
    }
    return Uint8List.fromList(bytes);
  }

  bool _isImageDocument(String url, String? mimeType) {
    final mime = (mimeType ?? '').toLowerCase();
    if (mime.startsWith('image/')) return true;

    final lower = url.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
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
