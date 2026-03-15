import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stephen_farmer/core/network/api_service/api_endpoints.dart';
import 'package:stephen_farmer/core/network/api_service/token_meneger.dart';

class CategoryDropdownWidget<T> extends StatefulWidget {
  final List<T> items;
  final int selectedIndex;
  final bool isMenuOpen;
  final bool isInteriorTheme;
  final VoidCallback onToggle;
  final ValueChanged<int> onSelect;
  final String Function(T item) titleBuilder;
  final String Function(T item) subtitleBuilder;
  final String? Function(T item) thumbnailBuilder;
  final String fallbackAsset;

  final Color? backgroundColor;
  final Color? borderColor;
  final Color? titleColor;
  final Color? subtitleColor;
  final Color? chevronColor;
  final double borderRadius;
  final EdgeInsets rowPadding;
  final double thumbnailWidth;
  final double thumbnailHeight;
  final double thumbnailBorderRadius;
  final double titleFontSize;
  final FontWeight titleFontWeight;
  final double subtitleFontSize;
  final FontWeight subtitleFontWeight;
  final TextStyle? titleTextStyle;
  final TextStyle? subtitleTextStyle;
  final double? subtitleWidth;
  final double? subtitleHeight;
  final double chevronSize;
  final double maxMenuHeight;
  final double? minHeight;
  final bool alwaysShowChevron;
  final double titleSubtitleSpacing;

  const CategoryDropdownWidget({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.isMenuOpen,
    this.isInteriorTheme = false,
    required this.onToggle,
    required this.onSelect,
    required this.titleBuilder,
    required this.subtitleBuilder,
    required this.thumbnailBuilder,
    required this.fallbackAsset,
    this.backgroundColor,
    this.borderColor,
    this.titleColor,
    this.subtitleColor,
    this.chevronColor,
    this.borderRadius = 10,
    this.rowPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
    this.thumbnailWidth = 79,
    this.thumbnailHeight = 40,
    this.thumbnailBorderRadius = 6,
    this.titleFontSize = 14,
    this.titleFontWeight = FontWeight.w600,
    this.subtitleFontSize = 12,
    this.subtitleFontWeight = FontWeight.w400,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.subtitleWidth,
    this.subtitleHeight,
    this.chevronSize = 20,
    this.maxMenuHeight = 220,
    this.minHeight = 57,
    this.alwaysShowChevron = false,
    this.titleSubtitleSpacing = 2,
  });

  @override
  State<CategoryDropdownWidget<T>> createState() =>
      _CategoryDropdownWidgetState<T>();
}

class _CategoryDropdownWidgetState<T> extends State<CategoryDropdownWidget<T>> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _triggerKey = GlobalKey();
  OverlayEntry? _menuOverlayEntry;
  bool _overlayRebuildScheduled = false;

  @override
  void initState() {
    super.initState();
    _syncMenuOverlay();
  }

  @override
  void didUpdateWidget(covariant CategoryDropdownWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncMenuOverlay();
    if (_menuOverlayEntry != null && widget.isMenuOpen) {
      _scheduleOverlayRebuild();
    }
  }

  @override
  void dispose() {
    _removeMenuOverlay();
    super.dispose();
  }

  void _syncMenuOverlay() {
    final bool hasItems = widget.items.isNotEmpty;
    final bool shouldShowMenu = widget.isMenuOpen && hasItems;
    if (shouldShowMenu) {
      if (_menuOverlayEntry == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _menuOverlayEntry != null) return;
          final bool stillHasItems = widget.items.isNotEmpty;
          if (widget.isMenuOpen && stillHasItems) {
            _insertMenuOverlay();
          }
        });
      }
      return;
    }
    _removeMenuOverlay();
  }

  void _insertMenuOverlay() {
    final overlay = Overlay.of(context, rootOverlay: true);
    _menuOverlayEntry = OverlayEntry(builder: _buildMenuOverlay);
    overlay.insert(_menuOverlayEntry!);
  }

  void _removeMenuOverlay() {
    _menuOverlayEntry?.remove();
    _menuOverlayEntry = null;
  }

  void _scheduleOverlayRebuild() {
    if (_overlayRebuildScheduled) return;
    _overlayRebuildScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _overlayRebuildScheduled = false;
      if (!mounted) return;
      if (_menuOverlayEntry != null && widget.isMenuOpen) {
        _menuOverlayEntry!.markNeedsBuild();
      }
    });
  }

  Widget _buildMenuOverlay(BuildContext context) {
    if (!mounted) return const SizedBox.shrink();
    final int safeSelectedIndex = widget.selectedIndex.clamp(
      0,
      widget.items.length - 1,
    );
    final Color resolvedBackgroundColor =
        widget.backgroundColor ??
        (widget.isInteriorTheme
            ? const Color(0xFFF3EFE7)
            : const Color(0xFF111A1E));
    final Color resolvedBorderColor =
        widget.borderColor ??
        (widget.isInteriorTheme
            ? const Color(0xFF6B6458)
            : const Color(0xFFD7C5A4));
    final Color resolvedTitleColor =
        widget.titleColor ??
        (widget.isInteriorTheme ? const Color(0xFF131313) : Colors.white);
    final Color resolvedSubtitleColor =
        widget.subtitleColor ??
        (widget.isInteriorTheme
            ? const Color(0xFF5C554C)
            : const Color(0xFF8A979D));
    final Color resolvedChevronColor =
        widget.chevronColor ??
        (widget.isInteriorTheme
            ? const Color(0xFF584A2D)
            : const Color(0xFFD2A75D));
    final RenderBox? triggerBox =
        _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    final Size triggerSize = triggerBox?.size ?? Size.zero;

    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: widget.onToggle,
            child: const SizedBox.expand(),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, triggerSize.height + 4),
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: triggerSize.width,
                child: Container(
                  decoration: BoxDecoration(
                    color: resolvedBackgroundColor,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: Border.all(color: resolvedBorderColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: widget.maxMenuHeight,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (int i = 0; i < widget.items.length; i++)
                              if (widget.items.length == 1 ||
                                  i != safeSelectedIndex)
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => widget.onSelect(i),
                                    child: Padding(
                                      padding: widget.rowPadding,
                                      child: _DropdownRow<T>(
                                        item: widget.items[i],
                                        showChevron: false,
                                        isMenuOpen: false,
                                        titleBuilder: widget.titleBuilder,
                                        subtitleBuilder: widget.subtitleBuilder,
                                        thumbnailBuilder:
                                            widget.thumbnailBuilder,
                                        fallbackAsset: widget.fallbackAsset,
                                        titleColor: resolvedTitleColor,
                                        subtitleColor: resolvedSubtitleColor,
                                        chevronColor: resolvedChevronColor,
                                        thumbnailWidth: widget.thumbnailWidth,
                                        thumbnailHeight: widget.thumbnailHeight,
                                        thumbnailBorderRadius:
                                            widget.thumbnailBorderRadius,
                                        titleFontSize: widget.titleFontSize,
                                        titleFontWeight: widget.titleFontWeight,
                                        subtitleFontSize:
                                            widget.subtitleFontSize,
                                        subtitleFontWeight:
                                            widget.subtitleFontWeight,
                                        titleTextStyle: widget.titleTextStyle,
                                        subtitleTextStyle:
                                            widget.subtitleTextStyle,
                                        subtitleWidth: widget.subtitleWidth,
                                        subtitleHeight: widget.subtitleHeight,
                                        chevronSize: widget.chevronSize,
                                        titleSubtitleSpacing:
                                            widget.titleSubtitleSpacing,
                                      ),
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    final int safeSelectedIndex = widget.selectedIndex.clamp(
      0,
      widget.items.length - 1,
    );
    final T selectedItem = widget.items[safeSelectedIndex];
    final bool canExpand = widget.items.length > 1;
    final bool showChevron =
        canExpand || widget.alwaysShowChevron || widget.isInteriorTheme;
    final resolvedBackgroundColor =
        widget.backgroundColor ??
        (widget.isInteriorTheme
            ? const Color(0xFFF3EFE7)
            : const Color(0xFF111A1E));
    final resolvedBorderColor =
        widget.borderColor ??
        (widget.isInteriorTheme
            ? const Color(0xFF6B6458)
            : const Color(0xFFD7C5A4));
    final resolvedTitleColor =
        widget.titleColor ??
        (widget.isInteriorTheme ? const Color(0xFF131313) : Colors.white);
    final resolvedSubtitleColor =
        widget.subtitleColor ??
        (widget.isInteriorTheme
            ? const Color(0xFF5C554C)
            : const Color(0xFF8A979D));
    final resolvedChevronColor =
        widget.chevronColor ??
        (widget.isInteriorTheme
            ? const Color(0xFF584A2D)
            : const Color(0xFFD2A75D));

    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        key: _triggerKey,
        constraints: widget.minHeight == null
            ? null
            : BoxConstraints(minHeight: widget.minHeight!),
        decoration: BoxDecoration(
          color: resolvedBackgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: resolvedBorderColor),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: widget.onToggle,
              child: Padding(
                padding: widget.rowPadding,
                child: _DropdownRow<T>(
                  item: selectedItem,
                  showChevron: showChevron,
                  isMenuOpen: widget.isMenuOpen,
                  titleBuilder: widget.titleBuilder,
                  subtitleBuilder: widget.subtitleBuilder,
                  thumbnailBuilder: widget.thumbnailBuilder,
                  fallbackAsset: widget.fallbackAsset,
                  titleColor: resolvedTitleColor,
                  subtitleColor: resolvedSubtitleColor,
                  chevronColor: resolvedChevronColor,
                  thumbnailWidth: widget.thumbnailWidth,
                  thumbnailHeight: widget.thumbnailHeight,
                  thumbnailBorderRadius: widget.thumbnailBorderRadius,
                  titleFontSize: widget.titleFontSize,
                  titleFontWeight: widget.titleFontWeight,
                  subtitleFontSize: widget.subtitleFontSize,
                  subtitleFontWeight: widget.subtitleFontWeight,
                  titleTextStyle: widget.titleTextStyle,
                  subtitleTextStyle: widget.subtitleTextStyle,
                  subtitleWidth: widget.subtitleWidth,
                  subtitleHeight: widget.subtitleHeight,
                  chevronSize: widget.chevronSize,
                  titleSubtitleSpacing: widget.titleSubtitleSpacing,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownRow<T> extends StatelessWidget {
  const _DropdownRow({
    required this.item,
    required this.showChevron,
    required this.isMenuOpen,
    required this.titleBuilder,
    required this.subtitleBuilder,
    required this.thumbnailBuilder,
    required this.fallbackAsset,
    required this.titleColor,
    required this.subtitleColor,
    required this.chevronColor,
    required this.thumbnailWidth,
    required this.thumbnailHeight,
    required this.thumbnailBorderRadius,
    required this.titleFontSize,
    required this.titleFontWeight,
    required this.subtitleFontSize,
    required this.subtitleFontWeight,
    required this.titleTextStyle,
    required this.subtitleTextStyle,
    required this.subtitleWidth,
    required this.subtitleHeight,
    required this.chevronSize,
    required this.titleSubtitleSpacing,
  });

  final T item;
  final bool showChevron;
  final bool isMenuOpen;
  final String Function(T item) titleBuilder;
  final String Function(T item) subtitleBuilder;
  final String? Function(T item) thumbnailBuilder;
  final String fallbackAsset;
  final Color titleColor;
  final Color subtitleColor;
  final Color chevronColor;
  final double thumbnailWidth;
  final double thumbnailHeight;
  final double thumbnailBorderRadius;
  final double titleFontSize;
  final FontWeight titleFontWeight;
  final double subtitleFontSize;
  final FontWeight subtitleFontWeight;
  final TextStyle? titleTextStyle;
  final TextStyle? subtitleTextStyle;
  final double? subtitleWidth;
  final double? subtitleHeight;
  final double chevronSize;
  final double titleSubtitleSpacing;

  @override
  Widget build(BuildContext context) {
    final thumb = _resolveThumbnailUrl(thumbnailBuilder(item));

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(thumbnailBorderRadius),
          child: SizedBox(
            height: thumbnailHeight,
            width: thumbnailWidth,
            child: thumb.isNotEmpty
                ? _AuthorizedNetworkImage(
                    imageUrl: thumb,
                    fallbackAsset: fallbackAsset,
                  )
                : Image.asset(fallbackAsset, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titleBuilder(item),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    (titleTextStyle ??
                            TextStyle(
                              color: titleColor,
                              fontSize: titleFontSize,
                              fontWeight: titleFontWeight,
                            ))
                        .copyWith(color: titleColor),
              ),
              SizedBox(height: titleSubtitleSpacing),
              SizedBox(
                width: subtitleWidth,
                height: subtitleHeight,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    subtitleBuilder(item),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        (subtitleTextStyle ??
                                TextStyle(
                                  color: subtitleColor,
                                  fontSize: subtitleFontSize,
                                  fontWeight: subtitleFontWeight,
                                ))
                            .copyWith(color: subtitleColor),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showChevron)
          Icon(
            isMenuOpen
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            color: chevronColor,
            size: chevronSize,
          ),
      ],
    );
  }

  String _resolveThumbnailUrl(String? raw) {
    final value = (raw ?? '').trim().replaceAll('\\', '/');
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

class _AuthorizedNetworkImage extends StatefulWidget {
  const _AuthorizedNetworkImage({
    required this.imageUrl,
    required this.fallbackAsset,
  });

  final String imageUrl;
  final String fallbackAsset;

  @override
  State<_AuthorizedNetworkImage> createState() =>
      _AuthorizedNetworkImageState();
}

class _AuthorizedNetworkImageState extends State<_AuthorizedNetworkImage> {
  late final Future<String?> _tokenFuture;

  @override
  void initState() {
    super.initState();
    _tokenFuture = TokenManager.getToken();
  }

  @override
  Widget build(BuildContext context) {
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
