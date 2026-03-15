import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:stephen_farmer/feature/auth/presentation/controller/login_controller.dart';
import 'package:stephen_farmer/feature/update/data/model/update_model.dart';
import 'package:stephen_farmer/feature/update/presentation/controller/update_controller.dart';

class UpdateCommentsView extends StatefulWidget {
  const UpdateCommentsView({
    super.key,
    required this.controller,
    required this.updateId,
    required this.isInterior,
  });

  final UpdateController controller;
  final String updateId;
  final bool isInterior;

  @override
  State<UpdateCommentsView> createState() => _UpdateCommentsViewState();
}

class _UpdateCommentsViewState extends State<UpdateCommentsView> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  final List<UpdateCommentModel> _comments = <UpdateCommentModel>[];
  bool _isLoading = true;
  bool _isSending = false;
  String? _replyToName;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _textController.dispose();
    _inputFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final loaded = await widget.controller.fetchComments(widget.updateId);
    if (!mounted) return;
    setState(() {
      _comments
        ..clear()
        ..addAll(loaded);
      _isLoading = false;
    });
  }

  Future<void> _submitComment() async {
    if (_isSending) return;
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final authController = Get.find<LoginController>();
    final currentUserName = authController.displayName.isEmpty
        ? 'User'
        : authController.displayName;
    final currentUserAvatar = authController.displayAvatar.isEmpty
        ? null
        : authController.displayAvatar;

    final payloadText = _replyToName != null && !text.startsWith('@')
        ? '@$_replyToName $text'
        : text;
    final tempComment = UpdateCommentModel(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      updateId: widget.updateId,
      text: payloadText,
      userName: currentUserName,
      userAvatar: currentUserAvatar,
      createdAt: DateTime.now(),
    );

    setState(() {
      _isSending = true;
      _comments.add(tempComment);
      _textController.clear();
      _replyToName = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });

    final added = await widget.controller.addComment(
      updateId: widget.updateId,
      comment: payloadText,
    );

    if (!mounted) return;
    setState(() {
      final tempIndex = _comments.indexWhere((c) => c.id == tempComment.id);
      if (tempIndex >= 0) {
        if (added != null) {
          _comments[tempIndex] = added;
        } else {
          _comments.removeAt(tempIndex);
        }
      }
      _isSending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isInterior = widget.isInterior;
    final showBackButton = defaultTargetPlatform == TargetPlatform.android;
    final panelColor = isInterior
        ? const Color(0xFFD6D1C7)
        : const Color(0xFF111B21);
    final titleColor = isInterior ? Colors.black : Colors.white;
    final bodyColor = isInterior
        ? const Color(0xFF181818)
        : const Color(0xFFF2F2F2);
    final mutedColor = isInterior
        ? const Color(0xFF4B4B4B)
        : const Color(0xFF8E8E93);

    return Scaffold(
      backgroundColor: panelColor,
      appBar: AppBar(
        backgroundColor: panelColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: showBackButton
            ? IconButton(
                onPressed: () => Get.back<void>(),
                icon: const Icon(Icons.chevron_left_rounded),
                color: titleColor,
              )
            : null,
        title: Text(
          'Comments',
          style: GoogleFonts.manrope(
            color: titleColor,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                ? Center(
                    child: Text(
                      'No comments yet',
                      style: GoogleFonts.manrope(
                        color: mutedColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                : Builder(
                    builder: (_) {
                      final commentThreads = _buildCommentThreads(_comments);
                      return ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: commentThreads.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (_, index) {
                          final thread = commentThreads[index];
                          final comment = thread.parent;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCommentTile(
                                comment: comment,
                                isInterior: isInterior,
                                titleColor: titleColor,
                                bodyColor: bodyColor,
                                mutedColor: mutedColor,
                                messageText: comment.text,
                                onReply: () {
                                  final name = comment.userName.trim();
                                  if (name.isEmpty) return;
                                  setState(() {
                                    _replyToName = name;
                                    _textController.text = '@$name ';
                                    _textController.selection =
                                        TextSelection.collapsed(
                                          offset: _textController.text.length,
                                        );
                                  });
                                  _inputFocusNode.requestFocus();
                                },
                              ),
                              if (thread.replies.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.only(left: 24),
                                  child: Column(
                                    children: List.generate(
                                      thread.replies.length,
                                      (replyIndex) {
                                        final reply =
                                            thread.replies[replyIndex];
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            bottom:
                                                replyIndex ==
                                                    thread.replies.length - 1
                                                ? 0
                                                : 10,
                                          ),
                                          child: _buildCommentTile(
                                            comment: reply.comment,
                                            isInterior: isInterior,
                                            titleColor: titleColor,
                                            bodyColor: bodyColor,
                                            mutedColor: mutedColor,
                                            messageText: reply.displayText,
                                            onReply: () {
                                              final name = reply
                                                  .comment
                                                  .userName
                                                  .trim();
                                              if (name.isEmpty) return;
                                              setState(() {
                                                _replyToName = name;
                                                _textController.text =
                                                    '@$name ';
                                                _textController.selection =
                                                    TextSelection.collapsed(
                                                      offset: _textController
                                                          .text
                                                          .length,
                                                    );
                                              });
                                              _inputFocusNode.requestFocus();
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      );
                    },
                  ),
          ),
          if (_replyToName != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isInterior
                          ? const Color(0xFFB0A38D)
                          : const Color(0xFF232A33),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Replying to $_replyToName',
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _replyToName = null;
                        _textController.clear();
                      });
                    },
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: mutedColor,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isInterior
                          ? const Color(0xFF7A787A)
                          : const Color(0xFF2B2E37),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: TextField(
                      controller: _textController,
                      focusNode: _inputFocusNode,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submitComment(),
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Write a Comment...',
                        hintStyle: GoogleFonts.manrope(
                          color: const Color(0xFFDBDBDB),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _isSending ? null : _submitComment,
                  icon: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.send_rounded,
                          size: 30,
                          color: isInterior
                              ? const Color(0xFF8E6500)
                              : const Color(0xFFD09A2F),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentTile({
    required UpdateCommentModel comment,
    required bool isInterior,
    required Color titleColor,
    required Color bodyColor,
    required Color mutedColor,
    required String messageText,
    required VoidCallback onReply,
  }) {
    final avatarUrl = comment.userAvatar;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: isInterior
              ? const Color(0xFFC3BEB4)
              : const Color(0xFF2D3238),
          backgroundImage: avatarUrl != null && avatarUrl.trim().isNotEmpty
              ? NetworkImage(avatarUrl.trim())
              : null,
          child: avatarUrl == null || avatarUrl.trim().isEmpty
              ? Icon(
                  Icons.person_rounded,
                  size: 18,
                  color: isInterior
                      ? const Color(0xFF6A6358)
                      : const Color(0xFFD0D0D0),
                )
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
                decoration: BoxDecoration(
                  color: isInterior
                      ? const Color(0xFFE3DED3)
                      : const Color(0xFF1E2A33),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userName,
                      style: GoogleFonts.manrope(
                        color: titleColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      messageText,
                      style: GoogleFonts.manrope(
                        color: bodyColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Text(
                    _timeLabel(comment.createdAt),
                    style: GoogleFonts.manrope(
                      color: mutedColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Like',
                    style: GoogleFonts.manrope(
                      color: mutedColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onReply,
                    child: Text(
                      'Reply',
                      style: GoogleFonts.manrope(
                        color: mutedColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<_CommentThread> _buildCommentThreads(List<UpdateCommentModel> comments) {
    final threads = <_CommentThread>[];
    for (final comment in comments) {
      final targetName = _extractReplyTargetName(
        comment.text,
        threads.map((thread) => thread.parent.userName).toList(),
      );
      if (targetName == null) {
        threads.add(_CommentThread(parent: comment, replies: []));
        continue;
      }
      final parentIndex = threads.lastIndexWhere(
        (thread) =>
            thread.parent.userName.trim().toLowerCase() ==
            targetName.trim().toLowerCase(),
      );
      if (parentIndex < 0) {
        threads.add(_CommentThread(parent: comment, replies: []));
        continue;
      }
      final replyText = _stripReplyPrefix(comment.text, targetName);
      threads[parentIndex].replies.add(
        _ThreadedReply(comment: comment, displayText: replyText),
      );
    }
    return threads;
  }

  String? _extractReplyTargetName(String message, List<String> candidateNames) {
    final trimmedMessage = message.trimLeft();
    if (!trimmedMessage.startsWith('@')) return null;
    String? bestMatch;
    var bestLength = -1;
    for (final name in candidateNames) {
      final trimmedName = name.trim();
      if (trimmedName.isEmpty) continue;
      final tag = '@$trimmedName ';
      if (trimmedMessage.toLowerCase().startsWith(tag.toLowerCase()) &&
          tag.length > bestLength) {
        bestMatch = trimmedName;
        bestLength = tag.length;
      }
    }
    return bestMatch;
  }

  String _stripReplyPrefix(String message, String targetName) {
    final trimmed = message.trimLeft();
    final prefix = '@${targetName.trim()} ';
    if (!trimmed.toLowerCase().startsWith(prefix.toLowerCase())) {
      return message;
    }
    final stripped = trimmed.substring(prefix.length).trimLeft();
    return stripped.isEmpty ? message : stripped;
  }

  String _timeLabel(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

class _CommentThread {
  final UpdateCommentModel parent;
  final List<_ThreadedReply> replies;

  const _CommentThread({required this.parent, required this.replies});
}

class _ThreadedReply {
  final UpdateCommentModel comment;
  final String displayText;

  const _ThreadedReply({required this.comment, required this.displayText});
}
