import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stephen_farmer/core/common/role_bg_color.dart';
import 'package:stephen_farmer/feature/auth/presentation/controller/login_controller.dart';
import 'package:stephen_farmer/feature/documents/domain/entities/document_project_entity.dart';

class DocumentPreviewView extends StatelessWidget {
  const DocumentPreviewView({super.key, required this.item});

  final RecentDocumentEntity item;

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

    if (!_isImageDocument(url, item.mimeType)) {
      return _messageBox(
        isInterior: isInterior,
        text:
            'Preview not available for this file type.\nURL: $url',
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isInterior ? const Color(0xFFBFC3C5) : const Color(0xFF2D3840),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
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
      ),
    );
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
            color: isInterior ? const Color(0xFF46413A) : const Color(0xFFD5DDE1),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
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
}
