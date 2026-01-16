import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:healthlink_app/widgets/loading_indicator.dart';
import 'package:healthlink_app/services/api_service.dart';
import 'package:healthlink_app/widgets/custom_app_bar.dart';

class AddSymptomScreen extends StatefulWidget {
  const AddSymptomScreen({super.key});

  @override
  State<AddSymptomScreen> createState() => _AddSymptomScreenState();
}

class _AddSymptomScreenState extends State<AddSymptomScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _symptomController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final _supabase = Supabase.instance.client;

  String _severity = 'low';
  String? _userUuid;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = _supabase.auth.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnack('Session expired. Please login again.', isError: true);
        Navigator.pushReplacementNamed(context, '/login');
      });
    } else {
      _userUuid = user.id;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _userUuid == null) return;

    setState(() => _loading = true);

    try {
      await ApiService.addSymptom(
        _userUuid!,
        _symptomController.text.trim(),
        _severity,
        _notesController.text.trim(),
      );

      if (!mounted) return;

      _showSnack('Symptom added successfully');

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/symptom-history',
        (route) => false,
      );
      return;

    } catch (error) {
      _showSnack('Failed to add symptom');
    } finally {
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
          ? const Color.fromARGB(255, 244, 29, 13)
          : const Color.fromARGB(255, 12, 185, 9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _symptomController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity) {
      case 'low':
        return Icons.sentiment_satisfied;
      case 'medium':
        return Icons.sentiment_neutral;
      case 'high':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.help_outline;
    }
  }

  String _getSeverityDescription(String severity) {
    switch (severity) {
      case 'low':
        return 'Mild discomfort';
      case 'medium':
        return 'Moderate concern';
      case 'high':
        return 'Severe or urgent';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Add Symptom',
        actions: [],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primaryContainer,
                                theme.colorScheme.secondaryContainer,
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.health_and_safety,
                            size: 65,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      TextFormField(
                        controller: _symptomController,
                        decoration: const InputDecoration(
                          labelText: 'Symptom',
                          hintText: 'e.g., Headache, Fever',
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),

                      const SizedBox(height: 20),

                      Column(
                        children: [
                          _severityOption('low', 'Low'),
                          const SizedBox(height: 8),
                          _severityOption('medium', 'Medium'),
                          const SizedBox(height: 8),
                          _severityOption('high', 'High'),
                        ],
                      ),

                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _notesController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Additional notes (optional)',
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _loading ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: _getSeverityColor(_severity),
                  ),
                  child: _loading
                    ? const LoadingIndicator()
                    : const Text('Save Symptom'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _severityOption(String value, String label) {
    final theme = Theme.of(context);
    final bool selected = _severity == value;
    final color = _getSeverityColor(value);

    return InkWell(
      onTap: () => setState(() => _severity = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.1) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : theme.colorScheme.outline.withOpacity(0.2),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected
                  ? color.withOpacity(0.2)
                  : theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getSeverityIcon(value),
                color: selected
                  ? color
                  : theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected ? color : null,
                    ),
                  ),
                  Text(
                    _getSeverityDescription(value), 
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
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
}
