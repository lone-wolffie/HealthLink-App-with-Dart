import 'package:flutter/material.dart';

class ClinicCard extends StatelessWidget {
  final String name;
  final String address;
  final String phoneNumber;
  final String email;
  final List<String> services;
  final Map<String, String> operatingHours;

  const ClinicCard({
    super.key,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.services,
    required this.operatingHours,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),
            Text(address),

            const SizedBox(height: 6),
            Text('Phone: $phoneNumber'),
            Text('Email: $email'),
            
            const SizedBox(height: 10),
            const Text(
              'Services:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Text(services.join(", ")),

            const SizedBox(height: 10),
            const Text(
              'Operating Hours:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            ...operatingHours.entries.map((entry) => Text('${entry.key}: ${entry.value}')),
          ],
        ),
      ),
    );
  }
}
