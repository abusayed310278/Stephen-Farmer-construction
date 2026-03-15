import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stephen_farmer/core/common/role_bg_color.dart';
import 'package:stephen_farmer/core/utils/images.dart';
import 'package:stephen_farmer/feature/auth/presentation/controller/login_controller.dart';
import 'package:stephen_farmer/core/utils/camera_utils.dart';

class ProfileScreenView extends StatefulWidget {
  const ProfileScreenView({super.key});

  @override
  State<ProfileScreenView> createState() => _ProfileScreenViewState();
}

class _ProfileScreenViewState extends State<ProfileScreenView> {
  late final LoginController _authController;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  bool _isEditing = false;
  File? _localAvatarFile;

  @override
  void initState() {
    super.initState();
    _authController = Get.find<LoginController>();
    _syncControllersFromAuth();
    _authController.refreshProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _syncControllersFromAuth() {
    final displayName = _authController.displayName.isEmpty
        ? 'User'
        : _authController.displayName;
    final displayEmail = _authController.displayEmail.isEmpty
        ? _authController.email.value.trim()
        : _authController.displayEmail;

    _nameController.text = displayName;
    _emailController.text = displayEmail;
  }

  Future<void> _pickAvatar(ImageSource source) async {
    if (source == ImageSource.camera && !await CameraUtils.isCameraAvailable()) {
      Get.snackbar(
        'Camera unavailable',
        'Camera is not available on this device. Please choose from gallery.',
      );
      await _pickAvatar(ImageSource.gallery);
      return;
    }

    if (!_picker.supportsImageSource(source)) {
      Get.snackbar(
        'Unavailable',
        source == ImageSource.camera
            ? 'Camera is not available on this device.'
            : 'Gallery is not available on this device.',
      );
      return;
    }

    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (picked == null) return;

      setState(() {
        _localAvatarFile = File(picked.path);
      });
    } on PlatformException catch (e) {
      if (source == ImageSource.camera && _isCameraUnavailableError(e)) {
        Get.snackbar(
          'Camera unavailable',
          'Camera is not available here. Please choose from gallery.',
        );
        await _pickAvatar(ImageSource.gallery);
        return;
      }

      Get.snackbar(
        'Error',
        _friendlyPickerError(source, e),
      );
    }
  }

  bool _isCameraUnavailableError(PlatformException e) {
    final code = e.code.toLowerCase();
    final message = (e.message ?? '').toLowerCase();
    return code.contains('camera_not_available') ||
        message.contains('camera not available') ||
        message.contains('no camera');
  }


  String _friendlyPickerError(ImageSource source, PlatformException e) {
    final code = e.code.toLowerCase();
    final message = (e.message ?? '').toLowerCase();
    final denied =
        code.contains('denied') ||
        message.contains('denied') ||
        message.contains('permission');

    if (!denied) {
      return e.message ?? 'Unable to open image source right now.';
    }

    if (source == ImageSource.camera) {
      return 'Camera permission denied. Enable Camera access in iOS Settings.';
    }

    return 'Photos permission denied. Enable Photos access in iOS Settings.';
  }

  Future<void> _onTapEditOrSave() async {
    if (!_isEditing) {
      setState(() => _isEditing = true);
      return;
    }

    final success = await _authController.updateProfile(
      name: _nameController.text,
      email: _emailController.text,
      avatarFile: _localAvatarFile,
    );

    if (success) {
      setState(() {
        _isEditing = false;
        _localAvatarFile = null;
      });
      Get.snackbar('Success', 'Profile updated successfully.');
    }
  }

  void _onCancelEdit() {
    setState(() {
      _isEditing = false;
      _localAvatarFile = null;
    });
    _syncControllersFromAuth();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool showBackButton =
          defaultTargetPlatform == TargetPlatform.android;
      final role = _authController.role.value;
      final isInterior = RoleBgColor.isInterior(role);
      final titleColor = isInterior ? const Color(0xFF1F1B16) : Colors.white;
      final subtitleColor = isInterior
          ? const Color(0xFF5F584B)
          : const Color(0xFF9A9A9A);
      final fieldBorderColor = isInterior
          ? const Color(0xFF9B927F)
          : const Color(0xFF5B6670);
      final fieldFillColor = isInterior
          ? const Color(0xFFF2EEE6)
          : const Color(0xFF161E23);
      final logoutColor = const Color(0xFFFF2222);
      final displayName = _authController.displayName.isEmpty
          ? 'User'
          : _authController.displayName;
      final displayEmail = _authController.displayEmail.isEmpty
          ? _authController.email.value.trim().isEmpty
                ? 'No email available'
                : _authController.email.value.trim()
          : _authController.displayEmail;
      final displayRole = _formatRole(_authController.normalizedRoleKey);
      final avatar = _authController.displayAvatar;

      if (!_isEditing) {
        _nameController.value = TextEditingValue(text: displayName);
        _emailController.value = TextEditingValue(text: displayEmail);
      }

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: RoleBgColor.overlayStyle(role),
        child: Scaffold(
          backgroundColor: RoleBgColor.scaffoldColor(role),
          body: Container(
            decoration: RoleBgColor.decoration(role),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showBackButton)
                          IconButton(
                            onPressed: Get.back,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: titleColor,
                              size: 18,
                            ),
                          ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Text(
                              'Personal Info',
                              style: TextStyle(
                                fontFamily: 'ClashDisplay',
                                color: titleColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: _authController.isUpdatingProfile.value
                                  ? null
                                  : _onTapEditOrSave,
                              icon: Icon(
                                _isEditing
                                    ? Icons.check_rounded
                                    : Icons.edit_rounded,
                                color: const Color(0xFFA77935),
                                size: 18,
                              ),
                              label: Text(
                                _isEditing ? 'Save' : 'Edit',
                                style: GoogleFonts.manrope(
                                  color: const Color(0xFFA77935),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Manage Your Profile',
                          style: GoogleFonts.manrope(
                            color: subtitleColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 26),
                        Center(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: !_isEditing
                                    ? null
                                    : () => showModalBottomSheet<void>(
                                        context: context,
                                        builder: (_) => SafeArea(
                                          child: Wrap(
                                            children: [
                                              ListTile(
                                                leading: const Icon(
                                                  Icons.photo_library_outlined,
                                                ),
                                                title: const Text(
                                                  'Choose from gallery',
                                                ),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  _pickAvatar(
                                                    ImageSource.gallery,
                                                  );
                                                },
                                              ),
                                              FutureBuilder<bool>(
                                                future: CameraUtils.isCameraAvailable(),
                                                builder: (context, snapshot) {
                                                  if (snapshot.data == true) {
                                                    return ListTile(
                                                      leading: const Icon(
                                                        Icons.photo_camera_outlined,
                                                      ),
                                                      title: const Text(
                                                        'Take a photo',
                                                      ),
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                        _pickAvatar(
                                                          ImageSource.camera,
                                                        );
                                                      },
                                                    );
                                                  }
                                                  return const SizedBox.shrink();
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                child: _ProfileAvatar(
                                  avatarUrl: avatar,
                                  localFile: _localAvatarFile,
                                  radius: 28,
                                  isInterior: isInterior,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                displayName,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.manrope(
                                  color: titleColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '($displayRole)',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.manrope(
                                  color: titleColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                displayEmail,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.manrope(
                                  color: titleColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 26),
                        Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: fieldFillColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: fieldBorderColor),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: isInterior
                                      ? const Color(0xFFCFBE9A)
                                      : const Color(0xFFC7B08A),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.person_outline_rounded,
                                  size: 16,
                                  color: isInterior
                                      ? const Color(0xFF594C34)
                                      : Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _isEditing
                                    ? TextField(
                                        controller: _nameController,
                                        style: GoogleFonts.manrope(
                                          color: titleColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                        ),
                                      )
                                    : Text(
                                        displayName,
                                        style: GoogleFonts.manrope(
                                          color: titleColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: fieldFillColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: fieldBorderColor),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: isInterior
                                      ? const Color(0xFFCFBE9A)
                                      : const Color(0xFFC7B08A),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.email_outlined,
                                  size: 16,
                                  color: isInterior
                                      ? const Color(0xFF594C34)
                                      : Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _isEditing
                                    ? TextField(
                                        controller: _emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        style: GoogleFonts.manrope(
                                          color: titleColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                        ),
                                      )
                                    : Text(
                                        displayEmail,
                                        style: GoogleFonts.manrope(
                                          color: titleColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        if (_isEditing)
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: OutlinedButton(
                                    onPressed: _onCancelEdit,
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: fieldBorderColor),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.manrope(
                                        color: titleColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed:
                                        _authController.isUpdatingProfile.value
                                        ? null
                                        : _onTapEditOrSave,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFA77935),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child:
                                        _authController.isUpdatingProfile.value
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            'Update',
                                            style: GoogleFonts.manrope(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
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
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () async {
                                final shouldLogout = await _showLogoutDialog(
                                  context: context,
                                  isInterior: isInterior,
                                );
                                if (shouldLogout == true) {
                                  await _authController.logoutUser();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: logoutColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Logout',
                                style: GoogleFonts.manrope(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
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
      );
    });
  }

  Future<bool?> _showLogoutDialog({
    required BuildContext context,
    required bool isInterior,
  }) {
    final dialogBorderColor = isInterior
        ? const Color.fromRGBO(109, 111, 115, 1)
        : const Color(0xFF5D6570);
    final dialogBackground = isInterior
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(226, 221, 215, 1),
              Color.fromRGBO(144, 137, 120, 1),
            ],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F1A20), Color(0xFF0A141A)],
          );
    final accentColor = isInterior
        ? const Color(0xFF8E6500)
        : const Color(0xFFAF8C6A);
    final promptColor = isInterior ? const Color(0xFF040404) : Colors.white;

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: dialogBorderColor, width: 2),
              gradient: dialogBackground,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(AssetsImages.logout, height: 48, width: 48),
                const SizedBox(height: 14),
                Text(
                  'Are you sure ?',
                  style: GoogleFonts.manrope(
                    color: promptColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: accentColor,
                            side: BorderSide(color: accentColor, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.manrope(
                              color: accentColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Yes',
                            style: GoogleFonts.manrope(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatRole(String role) {
    switch (role) {
      case 'manager':
        return 'Site Manager';
      case 'user':
        return 'Client';
      default:
        final normalized = role.trim();
        if (normalized.isEmpty) return 'User';
        return normalized[0].toUpperCase() + normalized.substring(1);
    }
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.avatarUrl,
    this.localFile,
    required this.radius,
    required this.isInterior,
  });

  final String avatarUrl;
  final File? localFile;
  final double radius;
  final bool isInterior;

  @override
  Widget build(BuildContext context) {
    if (localFile != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: isInterior
            ? const Color(0xFFE8DFD2)
            : const Color(0xFF182127),
        backgroundImage: FileImage(localFile!),
      );
    }

    final hasAvatar = avatarUrl.trim().isNotEmpty;
    return CircleAvatar(
      radius: radius,
      backgroundColor: isInterior
          ? const Color(0xFFE8DFD2)
          : const Color(0xFF182127),
      backgroundImage: hasAvatar
          ? NetworkImage(avatarUrl.trim())
          : const AssetImage(AssetsImages.placeholder) as ImageProvider,
    );
  }
}
