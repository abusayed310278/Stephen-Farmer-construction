import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stephen_farmer/core/common/role_bg_color.dart';
import 'package:stephen_farmer/core/network/api_service/api_endpoints.dart';
import 'package:stephen_farmer/core/network/api_service/token_meneger.dart';
import 'package:stephen_farmer/core/utils/images.dart';
import 'package:stephen_farmer/feature/auth/presentation/controller/login_controller.dart';
import 'package:stephen_farmer/feature/chat/domain/entities/chat_entity.dart';
import 'package:stephen_farmer/feature/chat/presentation/controller/chat_controller.dart';
import 'package:stephen_farmer/feature/tasks/presentation/controller/task_controller.dart';

import '../../domain/entities/task_project_entity.dart';

class TaskDetailsScreenView extends StatefulWidget {
  const TaskDetailsScreenView({
    super.key,
    required this.item,
    this.waitingForApproval = false,
  });

  final TaskItemEntity item;
  final bool waitingForApproval;

  @override
  State<TaskDetailsScreenView> createState() => _TaskDetailsScreenViewState();
}

class _TaskDetailsScreenViewState extends State<TaskDetailsScreenView> {
  late final ChatController _chatController;
  late final TaskController _taskController;
  late final LoginController _authController;
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();

  bool _isOpeningChat = false;
  bool _isSendingMessage = false;
  bool _isApproving = false;
  bool _isRejecting = false;
  String _chatError = '';

  @override
  void initState() {
    super.initState();
    _chatController = Get.find<ChatController>();
    _taskController = Get.find<TaskController>();
    _authController = Get.find<LoginController>();
    _openTaskChat();
  }

  Future<void> _openTaskChat() async {
    final taskId = widget.item.id.trim();
    if (taskId.isEmpty) {
      setState(() => _chatError = 'Task chat is unavailable for this item.');
      return;
    }

    setState(() {
      _isOpeningChat = true;
      _chatError = '';
    });

    try {
      await _chatController.openTaskChat(taskId);
      if (!mounted) return;
      setState(() => _chatError = '');
    } catch (_) {
      if (!mounted) return;
      setState(() => _chatError = 'Failed to open task messages.');
    } finally {
      if (mounted) {
        setState(() => _isOpeningChat = false);
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSendingMessage) return;

    setState(() => _isSendingMessage = true);
    try {
      await _chatController.sendMessage(text);
      _messageController.clear();
    } catch (_) {
      if (!mounted) return;
      setState(() => _chatError = 'Failed to send message.');
    } finally {
      if (mounted) {
        setState(() => _isSendingMessage = false);
      }
    }
  }

  Future<void> _approveAndComplete() async {
    if (_isApproving || widget.waitingForApproval) return;
    final taskId = widget.item.id.trim();
    if (taskId.isEmpty) {
      Get.snackbar('Error', 'Task id is missing.');
      return;
    }
    final roleKey = _authController.roleKey;
    final isClientUser = roleKey == 'client';
    if (isClientUser && !widget.item.isAwaitingApproval) {
      Get.snackbar(
        'Info',
        'This task is not waiting for approval yet.',
      );
      return;
    }
    if (!isClientUser && widget.item.isFinished) {
      Get.snackbar('Info', 'This task is already completed.');
      return;
    }

    setState(() => _isApproving = true);
    try {
      final result = isClientUser
          ? await _taskController.approveTask(taskId)
          : await _taskController.updateTaskStatus(
              taskId,
              payload: const <String, dynamic>{'status': 'completed'},
            );
      if (!mounted) return;
      if (result == null) {
        final message = _taskController.errorMessage.value.trim().isEmpty
            ? 'Task request failed. Please try again.'
            : _taskController.errorMessage.value;
        Get.snackbar('Error', message);
        return;
      }
      Get.back();
      final successMessage = isClientUser
          ? 'Task accepted successfully.'
          : 'Task marked completed and sent for approval.';
      Get.snackbar('Success', successMessage);
    } finally {
      if (mounted) {
        setState(() => _isApproving = false);
      }
    }
  }

  Future<void> _rejectTask() async {
    if (_isRejecting || widget.waitingForApproval) return;
    final taskId = widget.item.id.trim();
    if (taskId.isEmpty) {
      Get.snackbar('Error', 'Task id is missing.');
      return;
    }
    if (_authController.roleKey != 'client') {
      Get.snackbar('Info', 'Only client can reject tasks.');
      return;
    }
    if (!widget.item.isAwaitingApproval) {
      Get.snackbar('Info', 'This task is not waiting for approval yet.');
      return;
    }

    final reason = await _showRejectReasonDialog();
    if (reason == null || reason.trim().isEmpty) return;

    setState(() => _isRejecting = true);
    try {
      final result = await _taskController.rejectTask(
        taskId,
        payload: <String, dynamic>{'reason': reason.trim()},
      );
      if (!mounted) return;
      if (result == null) {
        final message = _taskController.errorMessage.value.trim().isEmpty
            ? 'Task request failed. Please try again.'
            : _taskController.errorMessage.value;
        Get.snackbar('Error', message);
        return;
      }
      Get.back();
      Get.snackbar('Success', 'Task rejected successfully.');
    } finally {
      if (mounted) {
        setState(() => _isRejecting = false);
      }
    }
  }

  Future<String?> _showRejectReasonDialog() async {
    final controller = TextEditingController();
    String? result;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
        title: const Text('Reject Task'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Enter rejection reason',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) {
                  return;
                }
                result = text;
                Navigator.of(context).pop();
              },
            child: const Text('Reject'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return result;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<LoginController>();
    final role = authController.role.value;
    final bool isInterior = RoleBgColor.isInterior(role);
    final roleKey = authController.roleKey;
    final List<String> photoUrls = _resolveTaskPhotoUrls();

    final Color bgColor = isInterior
        ? const Color(0xFFE4DED2)
        : const Color(0xFF0F161C);
    final Color titleColor = isInterior
        ? const Color(0xFF1E1E1E)
        : Colors.white;
    final bool showBackButton = defaultTargetPlatform == TargetPlatform.android;
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showBackButton) ...[
                      Row(
                        children: [
                          IconButton(
                            onPressed: Get.back,
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: titleColor,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    _PriorityChip(priority: widget.item.priority),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: 335,
                      child: Text(
                        widget.item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'ClashDisplay',
                          color: titleColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          height: 1,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 335,
                      height: 32,
                      child: Text(
                        widget.item.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          color: isInterior
                              ? const Color(0xFF1F1F1F)
                              : const Color(0xFF8E8E93),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: 335,
                      height: 20,
                      child: Text(
                        'See Photos (${photoUrls.length})',
                        style: TextStyle(
                          fontFamily: 'ClashDisplay',
                          color: titleColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (photoUrls.isEmpty)
                      Container(
                        height: 194,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isInterior
                              ? const Color(0xFFF5F2EC)
                              : const Color(0xFF1A232A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'No photos available',
                            style: GoogleFonts.manrope(
                              color: isInterior
                                  ? const Color(0xFF5B5347)
                                  : const Color(0xFF9EA9AD),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 194,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: photoUrls.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, index) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _AuthorizedImage(
                              imageUrl: photoUrls[index],
                              width: 219,
                              height: 194,
                              fallbackAsset: AssetsImages.constructionIgm,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 335,
                      height: 20,
                      child: Text(
                        'Messages',
                        style: TextStyle(
                          fontFamily: 'ClashDisplay',
                          color: titleColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_isOpeningChat)
                      const Center(child: CircularProgressIndicator())
                    else if (_chatError.isNotEmpty)
                      Text(
                        _chatError,
                        style: GoogleFonts.manrope(
                          color: const Color(0xFF8C2323),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      Obx(() {
                        final activeChatId =
                            _chatController.activeChat.value?.id ?? '';
                        final List<ChatMessageEntity> chatMessages =
                            _chatController.messages
                                .where((m) => m.chatId == activeChatId)
                                .toList();

                        if (chatMessages.isEmpty) {
                          return Text(
                            'No messages yet. Start the conversation.',
                            style: GoogleFonts.manrope(
                              color: isInterior
                                  ? const Color(0xFF5B5347)
                                  : const Color(0xFF9EA9AD),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: chatMessages.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final message = chatMessages[index];
                            return _ChatMessageBubble(
                              message: message,
                              isInterior: isInterior,
                            );
                          },
                        );
                      }),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                16,
                widget.waitingForApproval ? 8 : 12,
                16,
                widget.waitingForApproval ? 8 : 16,
              ),
              decoration: BoxDecoration(color: bgColor),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          focusNode: _messageFocusNode,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: InputDecoration(
                            hintText: 'Write a message',
                            hintStyle: GoogleFonts.manrope(
                              color: const Color(0xFF8E8E93),
                              fontSize: 13,
                            ),
                            filled: true,
                            fillColor: isInterior
                                ? const Color(0xFFF5F2EC)
                                : const Color(0xFF1A232A),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: GoogleFonts.manrope(
                            color: titleColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: widget.waitingForApproval ? 40 : 44,
                        height: widget.waitingForApproval ? 40 : 44,
                        child: ElevatedButton(
                          onPressed: _isSendingMessage ? null : _sendMessage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF8A6B37),
                            disabledBackgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: _isSendingMessage
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF8A6B37),
                                  ),
                                )
                              : const Icon(Icons.send_rounded, size: 22),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (roleKey == 'client' && !widget.waitingForApproval)
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              onPressed: _isApproving || _isRejecting
                                  ? null
                                  : _approveAndComplete,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB5946E),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: const Color(
                                  0xFF1E2127,
                                ),
                                disabledForegroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: _isApproving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Accept',
                                      style: GoogleFonts.manrope(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        height: 1.4,
                                        letterSpacing: 0,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: OutlinedButton(
                              onPressed: _isApproving || _isRejecting
                                  ? null
                                  : _rejectTask,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isInterior
                                      ? Colors.white
                                      : const Color(0xFFB84B4B),
                                ),
                                foregroundColor: isInterior
                                    ? Colors.white
                                    : const Color(0xFFFFCACA),
                                disabledForegroundColor: isInterior
                                    ? Colors.white70
                                    : const Color(0xFF6F7479),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: _isRejecting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFFFFCACA),
                                      ),
                                    )
                                  : Text(
                                      'Reject',
                                      style: GoogleFonts.manrope(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        height: 1.4,
                                        letterSpacing: 0,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: widget.waitingForApproval ? 40 : 44,
                      child: ElevatedButton(
                        onPressed: widget.waitingForApproval || _isApproving
                            ? null
                            : _approveAndComplete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.waitingForApproval
                              ? const Color(0xFF1E2127)
                              : const Color(0xFFB5946E),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF1E2127),
                          disabledForegroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isApproving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                widget.waitingForApproval
                                    ? 'Waiting for Approval...'
                                    : 'Approve & Complete',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                  letterSpacing: 0,
                                ),
                              ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _resolveTaskPhotoUrls() {
    final ordered = <String>[];
    final seen = <String>{};

    void add(String raw) {
      final resolved = _resolveMediaUrl(raw);
      if (resolved.isEmpty) return;
      if (seen.add(resolved)) {
        ordered.add(resolved);
      }
    }

    for (final image in widget.item.imageUrls) {
      add(image);
    }

    final selectedProject = _taskController.selectedProject;
    if (selectedProject != null) {
      add(selectedProject.thumbnailUrl ?? '');
      for (final section in selectedProject.sections) {
        for (final item in section.items) {
          for (final image in item.imageUrls) {
            add(image);
          }
        }
      }
    }

    return ordered;
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

class _AuthorizedImage extends StatefulWidget {
  const _AuthorizedImage({
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.fallbackAsset,
  });

  final String imageUrl;
  final double width;
  final double height;
  final String fallbackAsset;

  @override
  State<_AuthorizedImage> createState() => _AuthorizedImageState();
}

class _AuthorizedImageState extends State<_AuthorizedImage> {
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
          width: widget.width,
          height: widget.height,
          fit: BoxFit.cover,
          headers: headers,
          errorBuilder: (_, __, ___) => Image.asset(
            widget.fallbackAsset,
            width: widget.width,
            height: widget.height,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}

class _ChatMessageBubble extends StatelessWidget {
  const _ChatMessageBubble({required this.message, required this.isInterior});

  final ChatMessageEntity message;
  final bool isInterior;

  @override
  Widget build(BuildContext context) {
    final bool isMine = message.isMine;
    final Color bubbleColor = isMine
        ? (isInterior ? const Color(0xFF8D7A56) : const Color(0xFF1B262D))
        : (isInterior ? const Color(0xFFDAD4C8) : const Color(0xFF10171D));
    final Color textColor = isMine
        ? Colors.white
        : (isInterior ? const Color(0xFF262626) : Colors.white);
    final bool hasSenderLabel = !isMine && message.senderName.trim().isNotEmpty;
    final double avatarTopOffset = hasSenderLabel ? 8 : 0;

    final bubble = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMine && message.senderName.trim().isNotEmpty) ...[
              Text(
                message.senderName,
                style: GoogleFonts.manrope(
                  color: textColor.withValues(alpha: 0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              message.text,
              style: GoogleFonts.manrope(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMine) ...[
            Padding(
              padding: EdgeInsets.only(top: avatarTopOffset),
              child: _MessageAvatar(
                imageUrl: message.senderAvatar,
                isMine: false,
              ),
            ),
            const SizedBox(width: 8),
          ],
          bubble,
          if (isMine) ...[
            const SizedBox(width: 8),
            _MessageAvatar(
              imageUrl: message.senderAvatar,
              isMine: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _MessageAvatar extends StatefulWidget {
  const _MessageAvatar({
    required this.imageUrl,
    required this.isMine,
  });

  final String imageUrl;
  final bool isMine;

  @override
  State<_MessageAvatar> createState() => _MessageAvatarState();
}

class _MessageAvatarState extends State<_MessageAvatar> {
  late final Future<String?> _tokenFuture;

  @override
  void initState() {
    super.initState();
    _tokenFuture = TokenManager.getToken();
  }

  @override
  Widget build(BuildContext context) {
    final fallbackOwnAvatar = widget.isMine
        ? Get.find<LoginController>().displayAvatar
        : '';
    final raw = widget.imageUrl.trim().isEmpty ? fallbackOwnAvatar : widget.imageUrl;
    final resolved = _resolveMediaUrl(raw);
    if (resolved.isEmpty) return _fallback();

    return FutureBuilder<String?>(
      future: _tokenFuture,
      builder: (context, snapshot) {
        final headers = _buildHeadersFor(resolved, snapshot.data);
        return ClipOval(
          child: Image.network(
            resolved,
            width: 28,
            height: 28,
            fit: BoxFit.cover,
            headers: headers,
            errorBuilder: (_, __, ___) => Image.asset(
              AssetsImages.placeholder,
              width: 28,
              height: 28,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  Widget _fallback() {
    return ClipOval(
      child: Image.asset(
        AssetsImages.placeholder,
        width: 28,
        height: 28,
        fit: BoxFit.cover,
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

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.priority});

  final String priority;

  @override
  Widget build(BuildContext context) {
    final bool highPriority = priority.trim().toLowerCase() == 'high';
    final chipPadding = highPriority
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 6);

    return Container(
      padding: chipPadding,
      decoration: BoxDecoration(
        color: highPriority ? const Color(0x80FF383C) : const Color(0xFF8A6400),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        priority.toUpperCase(),
        style: GoogleFonts.manrope(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
