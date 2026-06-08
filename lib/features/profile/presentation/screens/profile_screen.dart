import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/theme.dart';
import '../../../../core/auth/token_storage.dart';
import '../../../../core/network/dio_client.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  String _displayName = '';
  String _displayEmail = '';
  String? _localAvatarPath;

  static const _prefAvatarKey = 'profile_avatar_path';
  static const _prefNameKey = 'profile_display_name';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAvatar = prefs.getString(_prefAvatarKey);
    final savedName = prefs.getString(_prefNameKey);

    try {
      final response = await DioClient.instance.get('/api/me');
      final identity = (response.data as Map<String, dynamic>)['identity'] as Map<String, dynamic>? ?? {};
      if (mounted) {
        setState(() {
          _displayName = savedName ?? (identity['name'] as String?) ?? '';
          _displayEmail = (identity['email'] as String?) ?? '';
          _localAvatarPath = savedAvatar;
        });
      }
    } on DioException {
      final userId = await TokenStorage.getUserId();
      if (mounted) {
        setState(() {
          _displayName = savedName ?? '';
          _displayEmail = userId ?? '';
          _localAvatarPath = savedAvatar;
        });
      }
    }
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _displayName);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Modifier le nom'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Votre nom'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefNameKey, result);
      if (mounted) setState(() => _displayName = result);
    }
  }

  Future<void> _editAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choisir depuis la galerie'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            if (_localAvatarPath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Supprimer la photo', style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(context, null),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null && _localAvatarPath != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefAvatarKey);
      if (mounted) setState(() => _localAvatarPath = null);
      return;
    }

    if (source != null) {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 80);
      if (picked != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefAvatarKey, picked.path);
        if (mounted) setState(() => _localAvatarPath = picked.path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Profil'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAvatarSection(),
            const SizedBox(height: 24),
            _buildSettingsSection(),
            const SizedBox(height: 24),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _editAvatar,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _localAvatarPath != null
                  ? CircleAvatar(
                      radius: 36,
                      backgroundImage: FileImage(File(_localAvatarPath!)),
                    )
                  : Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: AppColors.primary, size: 40),
                    ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.card,
                  ),
                  child: const Icon(Icons.edit, size: 13, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _editName,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _displayName.isNotEmpty ? _displayName : (_displayEmail.isNotEmpty ? _displayEmail : 'Mon profil'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.edit, size: 14, color: AppColors.textTertiary),
            ],
          ),
        ),
        if (_displayEmail.isNotEmpty && _displayName.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            _displayEmail,
            style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
          ),
        ],
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'PARAMÈTRES',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.08,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppShadows.card,
          ),
          child: _buildSettingRow(
            'Notifications',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (v) => setState(() => _notificationsEnabled = v),
              activeThumbColor: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow(String label, {required Widget trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          trailing,
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFD04040),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      onPressed: () async {
        await TokenStorage.clear();
        if (context.mounted) context.go('/login');
      },
      child: const Text('Se déconnecter'),
    );
  }
}
