import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/repo/post_repostory_impl.dart';
import '../../domain/repo/post_report_repo.dart';
import '../controller/add_update_post_controller.dart';
import 'package:stephen_farmer/core/utils/camera_utils.dart';

class AddUpdateScreenView extends StatefulWidget {
  final String projectId;
  final VoidCallback? onPostSuccess;
  final bool isInteriorTheme;

  const AddUpdateScreenView({
    super.key,
    required this.projectId,
    this.onPostSuccess,
    this.isInteriorTheme = false,
  });

  @override
  State<AddUpdateScreenView> createState() => _AddUpdateScreenViewState();
}

class _AddUpdateScreenViewState extends State<AddUpdateScreenView> {
  final TextEditingController _descriptionController = TextEditingController();
  late final AddUpdateController _controller;

  @override
  void initState() {
    super.initState();

    // Repo + RepoImpl + Controller wiring
    final repo = PostRepositoryImpl(ImagePicker());
    _controller = AddUpdateController(repo: repo);

    _controller.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _showPickSheet() async {
    final sheetBg = widget.isInteriorTheme
        ? const Color(0xFFF2EEE7)
        : const Color(0xFF132028);
    final sheetText = widget.isInteriorTheme ? Colors.black : Colors.white;
    final muted = widget.isInteriorTheme ? Colors.black54 : Colors.white70;

    await showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder<bool>(
              future: CameraUtils.isCameraAvailable(),
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return ListTile(
                    leading: Icon(Icons.photo_camera, color: sheetText),
                    title: Text('Camera', style: TextStyle(color: sheetText)),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await _controller.pickPhoto(
                        PhotoSource.camera,
                      ); // ✅ controller call
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: sheetText),
              title: Text('Gallery', style: TextStyle(color: sheetText)),
              onTap: () async {
                Navigator.pop(ctx);
                await _controller.pickPhoto(
                  PhotoSource.gallery,
                ); // ✅ controller call
              },
            ),
            if (_controller.draft.imageFile != null)
              ListTile(
                leading: Icon(Icons.delete_outline, color: muted),
                title: Text('Remove', style: TextStyle(color: muted)),
                onTap: () {
                  Navigator.pop(ctx);
                  _controller.removePhoto(); // ✅ controller call
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _onPost() async {
    // description controller -> controller draft sync
    _controller.setDescription(_descriptionController.text);

    await _controller.submit(
      projectId: widget.projectId,
    ); // ✅ controller -> repo.createPost()

    if (!mounted) return;

    if (_controller.error == null) {
      widget.onPostSuccess?.call();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Posted!')));
      Navigator.of(context).maybePop();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_controller.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInterior = widget.isInteriorTheme;
    final bg = isInterior ? const Color(0xFFB8B2A7) : const Color(0xFF08151C);
    final card = isInterior ? const Color(0xFFD5D0C6) : const Color(0xFF132028);
    const accent = Color(0xFFD7C5A4);
    const postButtonBg = Color(0xFFAF8C6A);
    final titleColor = isInterior ? const Color(0xFF111111) : Colors.white;
    final descriptionBoxColor = isInterior
        ? const Color(0xFFF1F1F1)
        : const Color(0xFF1B2630).withValues(alpha: 0.72);
    final descriptionBorder = isInterior
        ? const Color(0xFFE3E3E3)
        : const Color(0xFF808080).withValues(alpha: 0.35);
    final hintColor = isInterior
        ? const Color.fromRGBO(128, 128, 128, 0.55)
        : const Color.fromRGBO(128, 128, 128, 0.55);
    final cameraBadgeColor = isInterior
        ? const Color(0xFFE2DED5)
        : Colors.white.withValues(alpha: 0.08);
    final cameraIconColor = isInterior
        ? const Color(0xFFD7C5A4)
        : Colors.white70;

    final isPosting = _controller.isLoading;
    final canPost = _controller.draft.canPost;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 26,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TextButton(
                          onPressed: isPosting
                              ? null
                              : () => Navigator.of(context).maybePop(),
                          style: TextButton.styleFrom(
                            foregroundColor: accent,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(56, 36),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'ClashDisplay',
                              color: accent,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 1,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'New Post',
                          style: GoogleFonts.manrope(
                            color: titleColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            height: 1,
                            letterSpacing: 0,
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 68,
                          height: 36,
                          child: ElevatedButton(
                            onPressed: (isPosting || !canPost) ? null : _onPost,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: postButtonBg,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: postButtonBg.withValues(
                                alpha: 0.6,
                              ),
                              disabledForegroundColor: Colors.white70,
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(1000),
                              ),
                              elevation: 0,
                            ),
                            child: isPosting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Post',
                                    style: TextStyle(
                                      fontFamily: 'ClashDisplay',
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      height: 1,
                                      letterSpacing: 0,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ✅ Image area (preview if selected)
                    CustomPaint(
                      painter: const _DashedRRectPainter(
                        color: accent,
                        borderRadius: 22,
                        strokeWidth: 2,
                        dashWidth: 8,
                        dashSpace: 6,
                      ),
                      child: Container(
                        height: 230,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: card.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: _controller.draft.imageFile == null
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: isPosting ? null : _showPickSheet,
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: cameraBadgeColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.add_rounded,
                                          color: cameraIconColor,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      'Add site photo',
                                      style: GoogleFonts.manrope(
                                        color: titleColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        height: 1,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: Image.file(
                                  _controller.draft.imageFile!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: descriptionBoxColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: descriptionBorder),
                      ),
                      child: TextField(
                        controller: _descriptionController,
                        onChanged:
                            _controller.setDescription, // ✅ controller call
                        maxLines: 5,
                        minLines: 5,
                        style: GoogleFonts.manrope(
                          color: isInterior
                              ? const Color(0xFF1A1A1A)
                              : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter description...',
                          hintStyle: GoogleFonts.manrope(
                            color: hintColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1,
                            letterSpacing: 0,
                          ),
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                      ),
                    ),

                    if (_controller.error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _controller.error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({
    required this.color,
    required this.borderRadius,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });

  final Color color;
  final double borderRadius;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rect = Offset.zero & size;
    final rRect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(borderRadius),
    );
    final path = Path()..addRRect(rRect);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final nextDistance = math.min(distance + dashWidth, metric.length);
        canvas.drawPath(metric.extractPath(distance, nextDistance), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace;
  }
}
