import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/custom_app_bar.dart';

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
  Map<String, dynamic>? userData;

  final _fullname = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _username = TextEditingController();

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await ApiService.getUserProfile(widget.userId);
    setState(() {
      userData = profile;
      _fullname.text = profile['fullname'];
      _email.text = profile['email'];
      _phone.text = profile['phonenumber'] ?? '';
      _username.text = profile['username'];
    });
  }

  Future<void> _saveProfile() async {
    try {
      await ApiService.updateUserProfile(
        widget.userId,
        _fullname.text.trim(),
        _email.text.trim(),
        _phone.text.trim(),
        _username.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated')
        ),
      );

      setState(() => isEditing = false);
      _loadProfile();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Update failed: $error')
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Profile',
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditing) {
                _saveProfile();
              } else {
                setState(() => isEditing = true);
              }
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 45,
              child: Text(
                userData!['fullname'][0].toUpperCase(),
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _fullname,
            enabled: isEditing,
            decoration: const InputDecoration(labelText: 'Full Name'),
          ),

          TextField(
            controller: _email,
            enabled: isEditing,
            decoration: const InputDecoration(labelText: 'Email'),
          ),

          TextField(
            controller: _phone,
            enabled: isEditing,
            decoration: const InputDecoration(labelText: 'Phone Number'),
          ),

          TextField(
            controller: _username,
            enabled: isEditing,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
        ],
      ),
    );
  }
}
