import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/theme.dart';
import '../../../../core/auth/token_storage.dart';
import '../../../../core/constants/local_storage_keys.dart';
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

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAvatar = prefs.getString(LocalStorageKeys.profileAvatarPath);
    final savedName = prefs.getString(LocalStorageKeys.profileDisplayName);
    final savedNotifications =
        prefs.getBool(LocalStorageKeys.profileNotificationsEnabled);

    try {
      final response = await DioClient.instance.get('/api/me');
      final identity = (response.data as Map<String, dynamic>)['identity']
              as Map<String, dynamic>? ??
          {};
      if (mounted) {
        setState(() {
          _displayName =
              savedName ?? (identity['name'] as String?) ?? '';
          _displayEmail = (identity['email'] as String?) ?? '';
          _localAvatarPath = savedAvatar;
          _notificationsEnabled = savedNotifications ?? true;
        });
      }
    } on DioException {
      final userId = await TokenStorage.getUserId();
      if (mounted) {
        setState(() {
          _displayName = savedName ?? '';
          _displayEmail = userId ?? '';
          _localAvatarPath = savedAvatar;
          _notificationsEnabled = savedNotifications ?? true;
        });
      }
    }
  }

  Future<void> _setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(LocalStorageKeys.profileNotificationsEnabled, value);
    if (mounted) setState(() => _notificationsEnabled = value);
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
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, controller.text.trim()),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(LocalStorageKeys.profileDisplayName, result);
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
              onTap: () =>
                  Navigator.pop(context, ImageSource.gallery),
            ),
            if (_localAvatarPath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline,
                    color: Colors.red),
                title: const Text('Supprimer la photo',
                    style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(context, null),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null && _localAvatarPath != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(LocalStorageKeys.profileAvatarPath);
      if (mounted) setState(() => _localAvatarPath = null);
      return;
    }

    if (source != null) {
      final picker = ImagePicker();
      final picked =
          await picker.pickImage(source: source, imageQuality: 80);
      if (picked != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(LocalStorageKeys.profileAvatarPath, picked.path);
        if (mounted) setState(() => _localAvatarPath = picked.path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHero()),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSettingsSection(),
                const SizedBox(height: 24),
                _buildLogoutButton(),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    final initials = _displayName.isNotEmpty
        ? _displayName
            .trim()
            .split(' ')
            .map((w) => w[0])
            .take(2)
            .join()
            .toUpperCase()
        : (_displayEmail.isNotEmpty ? _displayEmail[0].toUpperCase() : '?');

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            children: [
              Row(
                children: [
                  const Text('Profil',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70)),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _editAvatar,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _localAvatarPath != null
                        ? CircleAvatar(
                            radius: 44,
                            backgroundImage:
                                FileImage(File(_localAvatarPath!)),
                          )
                        : Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.4),
                                  width: 2),
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          boxShadow: AppShadows.card,
                        ),
                        child: const Icon(Icons.edit,
                            size: 14,
                            color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: _editName,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _displayName.isNotEmpty
                          ? _displayName
                          : (_displayEmail.isNotEmpty
                              ? _displayEmail
                              : 'Mon profil'),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.edit,
                        size: 14, color: Colors.white60),
                  ],
                ),
              ),
              if (_displayEmail.isNotEmpty &&
                  _displayName.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  _displayEmail,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.white60),
                ),
              ],
            ],
          ),
        ),
      ),
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
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.textTertiary),
          ),
        ),
        Container(
          decoration: AppDecorations.card,
          child: _buildSettingRow(
            'Notifications',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: _setNotificationsEnabled,
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
          Text(label,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textPrimary)),
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
      ),
      onPressed: () async {
        await TokenStorage.clear();
        if (context.mounted) context.go('/login');
      },
      child: const Text('Se déconnecter'),
    );
  }
}
