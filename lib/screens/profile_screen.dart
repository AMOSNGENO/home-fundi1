import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/php_api_service.dart';
import '../utils/helpers.dart';
import '../widgets/app_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _skills = TextEditingController();
  final _picker = ImagePicker();

  String? _loadedUserId;
  Uint8List? _profileImageBytes;
  String? _profileImageName;

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    _skills.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user!;
    if (_loadedUserId != user.id) {
      _loadedUserId = user.id;
      _email.text = user.email;
      _phone.text = user.phone;
      _address.text = user.address ?? '';
      _skills.text = user.skills ?? '';
      _profileImageBytes = null;
      _profileImageName = null;
    }

    final canEdit = user.role == 'technician';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: const [
          NotificationBellButton(color: Colors.white),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundImage: _profileImageBytes != null
                        ? MemoryImage(_profileImageBytes!)
                        : (user.profileImage == null || user.profileImage!.isEmpty
                              ? null
                              : NetworkImage(
                                  PhpApiService.mediaUrl(user.profileImage),
                                )),
                    child:
                        _profileImageBytes == null &&
                            (user.profileImage == null ||
                                user.profileImage!.isEmpty)
                        ? Text(
                            user.name.isEmpty ? 'U' : user.name[0].toUpperCase(),
                          )
                        : null,
                  ),
                  if (canEdit)
                    IconButton.filledTonal(
                      tooltip: 'Add photo',
                      onPressed: _pickProfilePhoto,
                      icon: const Icon(Icons.photo_camera_outlined),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: Text(user.name),
              subtitle: Text(user.role.toUpperCase()),
            ),
            if (canEdit) ...[
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value == null || !value.contains('@') ? 'Enter a valid email.' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Enter your phone number.' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _address,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _skills,
                decoration: const InputDecoration(
                  labelText: 'Skills',
                  prefixIcon: Icon(Icons.handyman_outlined),
                ),
                minLines: 1,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: auth.isLoading ? null : _save,
                icon: auth.isLoading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text('Save profile'),
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: Text(user.email),
              ),
              ListTile(
                leading: const Icon(Icons.phone_outlined),
                title: Text(user.phone),
              ),
              if (user.address != null)
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(user.address!),
                ),
            ],
            if (user.role == 'technician')
              ListTile(
                leading: const Icon(Icons.verified_outlined),
                title: Text(
                  user.isApproved
                      ? 'Approved technician'
                      : 'Pending admin approval',
                ),
              ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.read<AuthProvider>().logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await context.read<AuthProvider>().updateTechnicianProfile(
            email: _email.text,
            phone: _phone.text,
            address: _address.text,
            skills: _skills.text,
            profileImageData: _profileImageBytes == null
                ? null
                : base64Encode(_profileImageBytes!),
            profileImageName: _profileImageName,
          );
      if (mounted) showToast(context, 'Profile updated.');
    } on PhpApiException catch (error) {
      if (mounted) showToast(context, error.message, error: true);
    }
  }

  Future<void> _pickProfilePhoto() async {
    final source = await _chooseImageSource();
    if (source == null) return;
    final image = await _picker.pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 80,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    setState(() {
      _profileImageBytes = bytes;
      _profileImageName = image.name;
    });
  }

  Future<ImageSource?> _chooseImageSource() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}
