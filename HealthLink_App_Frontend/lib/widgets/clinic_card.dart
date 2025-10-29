import 'package:flutter/material.dart';

class ClinicCard extends StatelessWidget {
  final String name;
  final String address;
  final String phoneNumber;
  final String services;
  final String operatingHours;

  const ClinicCard({
    super.key,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.services,
    required this.operatingHours,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: 8, 
        horizontal: 12
      ),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold
            )),

            const SizedBox(height: 6),
            Text(address, style: const TextStyle(color: Colors.black87)),

            const SizedBox(height: 6),
            Text('Phone: $phoneNumber', style: const TextStyle(color: Colors.black54)),

            const SizedBox(height: 6),
            Text('Services: $services', style: const TextStyle(color: Colors.black54)),

            const SizedBox(height: 6),
            Text('Hours: $operatingHours', style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}