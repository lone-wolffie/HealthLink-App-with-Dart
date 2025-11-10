import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

  final List<String> orderedDays = const [
    "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
  ];

  @override
  Widget build(BuildContext context) {
    // Normalize Keys for Ordering
    final normalizedHours = operatingHours.map((key, value) {
      final formattedKey = key[0].toUpperCase() + key.substring(1).toLowerCase();
      return MapEntry(formattedKey, value);
    });

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Clinic Name
          Text(name,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),

          // Address
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(address,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Phone
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Text(phoneNumber,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
            ],
          ),
          const SizedBox(height: 6),

          // Email
          Row(
            children: [
              const Icon(Icons.email_outlined, size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(email,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Services
          const Text('Services',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: services.map((service) {
              return Chip(
                label: Text(service, style: const TextStyle(color: Colors.white)),
                backgroundColor: Colors.blueAccent,
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Operating Hours
          const Text('Operating Hours',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),

          Column(
            children: orderedDays.map((day) {
              if (!normalizedHours.containsKey(day)) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(day, style: TextStyle(color: Colors.grey.shade800)),
                    Text(normalizedHours[day]!,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 18),

          // ACTION BUTTONS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _button(
                icon: Icons.call,
                label: "Call",
                color: Colors.green,
                onTap: () => launchUrl(Uri(scheme: 'tel', path: phoneNumber)),
              ),
              _button(
                icon: Icons.email_outlined,
                label: "Email",
                color: Colors.blue,
                onTap: () => launchUrl(Uri(scheme: 'mailto', path: email)),
              ),
              _button(
                icon: Icons.map_outlined,
                label: "Map",
                color: Colors.deepOrange,
                onTap: () => launchUrl(
                  Uri.parse("https://www.google.com/maps/search/?api=1&query=$address"),
                ),
              ),

              // *** NEW VIEW / BOOK BUTTON ***
              _button(
                icon: Icons.arrow_forward_ios_rounded,
                label: "View",
                color: Colors.purple,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/clinicDetails',
                    arguments: {
                      'name': name,
                      'address': address,
                      'phone': phoneNumber,
                      'email': email,
                      'services': services,
                      'hours': operatingHours,
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _button({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
