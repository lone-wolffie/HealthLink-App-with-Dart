import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;

  const ProfileScreen({
    super.key, 
    required this.userId
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = true;
  bool _saving = false;
  bool _isEditing = false;

  Map<String, dynamic>? _userData;

  // controllers
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
      await prefs.setString("username", _username.text.trim());

      _showSnack('Profile updated successfully');

      setState(() => _isEditing = false);
      await _fetchProfile();
    } catch (error) {
      _showSnack('Failed to update profile: $error', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmLogout() async {
    final doLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
        ],
      ),
    );

    if (doLogout == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color.fromARGB(255, 207, 38, 38) : const Color.fromARGB(255, 25, 139, 30),
      ),
    );
  }

  void _cancelEdits() {
    if (_userData != null) {
      _fullname.text = _userData!['fullname'] ?? '';
      _email.text = _userData!['email'] ?? '';
      _phone.text = _userData!['phonenumber'] ?? '';
      _username.text = _userData!['username'] ?? '';
    }
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final initials = (_fullname.text.isNotEmpty) ? _fullname.text.trim()[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F7),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Profile', 
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 25,
            
          ),
        ),
          
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.logout, color: Colors.black54),
            tooltip: _isEditing ? 'Cancel edits' : 'Logout',
            onPressed: _isEditing ? _cancelEdits : _confirmLogout,
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18, 
            vertical: 12
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(
                    color: Colors.black12, 
                    offset: Offset(0, 6)
                  )],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18, 
                  vertical: 22
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.green.shade600,
                          child: Text(initials, style: const TextStyle(
                            fontSize: 28, color: Colors.white)
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _fullname.text.isNotEmpty ? _fullname.text : 'Unnamed User',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _email.text.isNotEmpty ? _email.text : 'No email provided',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade700
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Edit / Save button
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _isEditing
                              ? Row(
                                  key: const ValueKey('save_buttons'),
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check_circle, color: Colors.green),
                                      tooltip: 'Save',
                                      onPressed: _saving ? null : _saveProfile,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.cancel, color: Colors.grey),
                                      tooltip: 'Cancel',
                                      onPressed: _saving ? null : _cancelEdits,
                                    ),
                                  ],
                                )
                              : IconButton(
                                  key: const ValueKey('edit_btn'),
                                  icon: const Icon(Icons.edit, color: Colors.black54),
                                  tooltip: 'Edit profile',
                                  onPressed: () => setState(() => _isEditing = true),
                                ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Edit form
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 15),
                        _buildTextField(
                          label: 'Full name',
                          controller: _fullname,
                          enabled: _isEditing,
                          validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter full name' : null,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          label: 'Email',
                          controller: _email,
                          enabled: _isEditing,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Enter email';
                            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                            if (!emailRegex.hasMatch(value.trim())) return 'Enter valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          label: 'Phone number',
                          controller: _phone,
                          enabled: _isEditing,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          label: 'Username',
                          controller: _username,
                          enabled: _isEditing,
                          validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter username' : null,
                        ),

                        const SizedBox(height: 18),

                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, 
          vertical: 14
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.blue,
            width: 2,
          ),
        ),
      ),
    );
  }
}
