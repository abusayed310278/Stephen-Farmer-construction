import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stephen_farmer/core/network/api_service/api_endpoints.dart';
import 'package:stephen_farmer/core/network/api_service/token_meneger.dart';
import 'package:stephen_farmer/core/utils/images.dart';

import '../../domain/entities/progress_entity.dart';

class ProgressOverviewCard extends StatelessWidget {
  const ProgressOverviewCard({super.key, required this.project});

  final ProjectProgressEntity project;

  @override
  Widget build(BuildContext context) {
    final fallbackAsset = AssetsImages.constructionIgm;
    final heroImageUrl = _resolveMediaUrl(project.heroImageUrl);
    final startedLabel = _formatDateLabel(
      project.startedDate,
      longMonth: false,
    );
    final handoverLabel = _formatDateLabel(
      project.handoverDate,
      longMonth: true,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          color: const Color(0xFF111A1E),
          border: Border.all(
            color: const Color(0xFFB9A77D).withValues(alpha: 0.2),
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _AuthorizedHeroImage(
              imageUrl: heroImageUrl,
              fallbackAsset: fallbackAsset,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3D2AA),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Active Project',
                  style: TextStyle(
                    fontFamily: 'ClashDisplay',
                    color: Color(0xFF151515),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 66,
              left: 16,
              right: 16,
              child: Text(
                project.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: 'ClashDisplay',
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Overall completion',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 19 / 14,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${project.overallCompletion}%',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'ClashDisplay',
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: project.overallCompletion.clamp(0, 100) / 100,
                      minHeight: 9,
                      backgroundColor: Colors.white,
                      color: const Color(0xFFE3D2AA),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Started: $startedLabel',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            color: Color(0xFFD4D4D4),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'EST. Handover: $handoverLabel',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.manrope(
                            color: Color(0xFFD4D4D4),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _resolveMediaUrl(String raw) {
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
    if (value.startsWith('/')) {
      return '$origin$value';
    }
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
}

class _AuthorizedHeroImage extends StatefulWidget {
  const _AuthorizedHeroImage({
    required this.imageUrl,
    required this.fallbackAsset,
  });

  final String imageUrl;
  final String fallbackAsset;

  @override
  State<_AuthorizedHeroImage> createState() => _AuthorizedHeroImageState();
}

class _AuthorizedHeroImageState extends State<_AuthorizedHeroImage> {
  late final Future<String?> _tokenFuture;

  @override
  void initState() {
    super.initState();
    _tokenFuture = TokenManager.getToken();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl.trim().isEmpty) {
      return Image.asset(widget.fallbackAsset, fit: BoxFit.cover);
    }

    return FutureBuilder<String?>(
      future: _tokenFuture,
      builder: (context, snapshot) {
        final token = snapshot.data?.trim() ?? '';
        final headers = token.isEmpty
            ? null
            : <String, String>{'Authorization': 'Bearer $token'};

        return Image.network(
          widget.imageUrl,
          fit: BoxFit.cover,
          headers: headers,
          errorBuilder: (_, __, ___) =>
              Image.asset(widget.fallbackAsset, fit: BoxFit.cover),
        );
      },
    );
  }
}

String _formatDateLabel(String raw, {required bool longMonth}) {
  final value = raw.trim();
  if (value.isEmpty) return raw;

  final parsed = DateTime.tryParse(value);
  if (parsed == null) return raw;

  const shortMonths = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  const longMonths = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final months = longMonth ? longMonths : shortMonths;
  final month = months[parsed.month - 1];
  return '$month ${parsed.day}';
}
