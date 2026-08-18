import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wash_club/core/i18n/extensions/i18n_extension.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/services/client_session.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _session = ClientSession.instance;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String? _profileImage; // base64
  bool _saving = false;

  ApparenceKitColors get _c =>
      Theme.of(context).extension<ApparenceKitColors>()!;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = _session.name ?? '';
    _phoneCtrl.text = _session.phone ?? '';
    _profileImage = _session.profileImage;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _nameCtrl.text.trim().isNotEmpty &&
      _phoneCtrl.text.trim().length >= 9;

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (picked != null) {
        final bytes = await File(picked.path).readAsBytes();
        final base64 = base64Encode(bytes);
        setState(() => _profileImage = base64);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.t.profile.imagePickError}: $e'),
            backgroundColor: _c.error,
          ),
        );
      }
    }
  }

  Future<void> _removeImage() async {
    await _session.removeProfileImage();
    setState(() => _profileImage = null);
  }

  Future<void> _save() async {
    if (!_isValid || _saving) return;
    setState(() => _saving = true);

    try {
      await _session.saveProfile(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
      );

      if (_profileImage != null) {
        await _session.saveProfileImage(_profileImage!);
      }

      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _c;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onBackground),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.t.profile.editProfile,
          style: TextStyle(
            color: colors.onBackground,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          children: [
            _buildAvatar(colors),
            const SizedBox(height: 32),
            _buildTextField(
              label: context.t.profile.name,
              controller: _nameCtrl,
              colors: colors,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: context.t.settings.phoneLabel,
              controller: _phoneCtrl,
              colors: colors,
              keyboardType: TextInputType.phone,
              editable: false,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isValid && !_saving ? _save : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.info,
                  foregroundColor: colors.onPrimary,
                  disabledBackgroundColor: colors.surface,
                  disabledForegroundColor: colors.grey3,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation(colors.onPrimary),
                        ),
                      )
                    : Text(context.t.settings.save,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ApparenceKitColors colors) {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary,
              image: _profileImage != null
                  ? DecorationImage(
                      image: MemoryImage(base64Decode(_profileImage!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _profileImage == null
                ? Center(
                    child: Text(
                      (_nameCtrl.text.isNotEmpty
                              ? _nameCtrl.text[0]
                              : 'M')
                          .toUpperCase(),
                      style: TextStyle(
                        color: colors.onPrimary,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colors.info,
                shape: BoxShape.circle,
                border: Border.all(color: colors.background, width: 3),
              ),
              child: Icon(Icons.camera_alt,
                  color: colors.onPrimary, size: 16),
            ),
          ),
          if (_profileImage != null)
            Positioned(
              top: 0,
              right: -4,
              child: GestureDetector(
                onTap: _removeImage,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: colors.error,
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: colors.background, width: 2),
                  ),
                  child: Icon(Icons.close,
                      color: colors.onPrimary, size: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required ApparenceKitColors colors,
    TextInputType? keyboardType,
    bool editable = true,
  }) {
    final field = TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: !editable,
      enableInteractiveSelection: editable,
      onChanged: editable ? (_) => setState(() {}) : null,
      style: TextStyle(color: colors.onSurface, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colors.grey2),
        filled: true,
        fillColor: colors.onPrimaryContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.info, width: 1.5),
        ),
      ),
    );
    if (!editable) return IgnorePointer(child: field);
    return field;
  }
}
