import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:healthlink_app/services/api_service.dart';
import 'package:healthlink_app/widgets/loading_indicator.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;

  const ProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = true;
  bool _saving = false;
  bool _isEditing = false;
  String? _profileImagePath;
  Uint8List? _imageBytes;

  Map<String, dynamic>? _userData;

  final TextEditingController _fullname = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _username = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _fullname.dispose();
    _email.dispose();
    _phone.dispose();
    _username.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() => _loading = true);
    try {
      final profile = await ApiService.getUserProfile(widget.userId);
      _userData = profile;
      _fullname.text = profile['fullname'] ?? '';
      _email.text = profile['email'] ?? '';
      _phone.text = profile['phonenumber'] ?? '';
      _username.text = profile['username'] ?? '';
    } catch (error) {
      _showSnack('Failed to load profile: $error', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await ApiService.updateUserProfile(
        widget.userId,
        _fullname.text.trim(),
        _email.text.trim(),
        _phone.text.trim(),
        _username.text.trim(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', _username.text.trim());

      _showSnack('Profile updated successfully');

      setState(() => _isEditing = false);
      await _fetchProfile();
    } catch (error) {
      _showSnack('Failed: $error', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmLogout() async {
    final theme = Theme.of(context);
    final doLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
        ),
        icon: const Icon(
          Icons.logout, 
          size: 48
        ),
        title: const Text(
          'Logout', 
          style: TextStyle(
            fontWeight: FontWeight.bold
          )
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel', 
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant
              )
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 244, 29, 13)
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (doLogout == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context, 
        '/login', 
        (_) => false
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() => _imageBytes = bytes);
      } else {
        setState(() => _profileImagePath = picked.path);
        
        bool success = await ApiService.uploadProfileImage(widget.userId, picked.path);
        success 
          ? _showSnack('Photo updated successfully') 
          : _showSnack('Upload failed', isError: true);
      }
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Color.fromARGB(255, 244, 29, 13) : Color.fromARGB(255, 12, 185, 9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        content: Row(
          children: [
            Icon(isError ? Icons.error : Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  void _cancelEdits() {
    _fullname.text = _userData!['fullname'] ?? '';
    _email.text = _userData!['email'] ?? '';
    _phone.text = _userData!['phonenumber'] ?? '';
    _username.text = _userData!['username'] ?? '';
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _fullname.text.isNotEmpty ? _fullname.text[0].toUpperCase() : '?';

    if (_loading) {
      return const Scaffold(
        body: Center(
          child: LoadingIndicator()
      ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 190,
              pinned: true,
              stretch: true,
              backgroundColor: theme.colorScheme.primary,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back, 
                  color: Colors.white
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.logout, 
                    color: Colors.white
                  ),
                  onPressed: _confirmLogout,
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.fadeTitle],
                background: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white, 
                              width: 4,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage: kIsWeb
                              ? (_imageBytes != null ? MemoryImage(_imageBytes!) : null)
                              : (_profileImagePath != null ? FileImage(File(_profileImagePath!)) : null),
                            child: (kIsWeb ? _imageBytes == null : _profileImagePath == null)
                              ? Text(
                                initials,
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              )
                              : null,
                          ),
                        ),

                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white, 
                                  width: 3
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt, 
                                color: Colors.white, 
                                size: 19
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _fullname.text.isNotEmpty ? _fullname.text : 'Unnamed User',
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 18, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      '@${_username.text.isNotEmpty ? _username.text : 'username'}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8), 
                        fontSize: 14
                      ),
                    )
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildSectionHeader(theme),
                      const SizedBox(height: 15),
                      _buildInfoCard(
                        theme, 
                        Icons.person, 
                        'Full Name', 
                        _fullname,
                        enabled: _isEditing,
                        validator: (value) => value!.isEmpty ? 'Required' : null
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        theme, 
                        Icons.email, 
                       'Email', 
                        _email,
                        enabled: _isEditing, 
                        validator: (value) => value!.contains("@") ? null : 'Invalid email'
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        theme, 
                        Icons.phone, 
                        'Phone', 
                        _phone, 
                        enabled: _isEditing
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        theme, 
                        Icons.account_circle, 
                        'Username', 
                        _username,
                        enabled: _isEditing, 
                        validator: (value) => value!.isEmpty ? 'Required' : null),
                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Text(
            'Personal Information',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        _isEditing
            ? Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: _cancelEdits,
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                  ),

                  FilledButton.icon(
                    onPressed: _saving ? null : _saveProfile,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: LoadingIndicator(),
                          )
                        : const Icon(Icons.check),
                    label: Text(_saving ? 'Saving...' : 'Save'),
                  ),
                ],
              )
            : FilledButton.tonalIcon(
                onPressed: () => setState(() => _isEditing = true),
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
      ],
    );
  }


  Widget _buildInfoCard(
    ThemeData theme,
    IconData icon,
    String label,
    TextEditingController controller, {
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Row(
              children: [
                Icon(
                  icon, 
                  color: theme.colorScheme.primary
                ),
                const SizedBox(width: 8),
                Text(
                  label, 
                  style: TextStyle(
                    color: Colors.grey[700], 
                    fontWeight: FontWeight.w600
                  )
                )
              ],
            ),
            TextFormField(
              controller: controller,
              enabled: enabled,
              validator: validator,
              decoration: const InputDecoration(
                border: InputBorder.none, 
                hintText: 'Enter value'
              ),
            )
          ],
        ),
      ),
    );
  }
}
