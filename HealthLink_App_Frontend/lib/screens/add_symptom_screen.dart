import 'package:flutter/material.dart';
import 'package:healthlink_app/widgets/loading_indicator.dart';
import '../services/api_service.dart';
import '../widgets/custom_app_bar.dart';

class AddSymptomScreen extends StatefulWidget {
  final int userId;

  const AddSymptomScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AddSymptomScreen> createState() => _AddSymptomScreenState();
}

class _AddSymptomScreenState extends State<AddSymptomScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _symptomController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _severity = 'low';

  bool _loading = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final res = await ApiService.addSymptom(
        widget.userId,
        _symptomController.text.trim(),
        _severity,
        _notesController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Saved')
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $error')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _symptomController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Add Symptom',
        actions: [],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _symptomController,
                      decoration: InputDecoration(
                        labelText: 'Symptom',
                        filled: true,
                        fillColor: const Color.fromARGB(255, 212, 209, 209),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      validator: (value) => (value == null || value.trim().isEmpty)
                          ? 'Enter a symptom'
                          : null,
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Severity',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 10,
                      children: [
                        _severityChip('low', Colors.green),
                        _severityChip('medium', Colors.orange),
                        _severityChip('high', Colors.red),
                      ],
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'Notes (optional)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 10,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromARGB(255, 212, 209, 209),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _loading ? null : _save,
                  child: _loading
                      ? const LoadingIndicator()
                      : const Text(
                          'Save Symptom',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16, 
                            fontWeight: FontWeight.bold
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

  Widget _severityChip(String value, Color color) {
    final bool selected = _severity == value;

    return ChoiceChip(
      label: Text(
        value[0].toUpperCase() + value.substring(1),
        style: TextStyle(
          color: selected ? Colors.white : color,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: selected,
      selectedColor: color,
      onSelected: (_) => setState(() => _severity = value),
    );
  }
}
