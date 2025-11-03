import 'package:flutter/material.dart';

import '../models/clinics.dart';
import '../services/api_service.dart';

import '../widgets/clinic_card.dart';
import '../widgets/custom_app_bar.dart';

class ClinicsScreen extends StatelessWidget {
  const ClinicsScreen({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Nearby Clinics', 
        actions: [],
      ),
      
      body: FutureBuilder<List<Clinics>> (
        future: ApiService.getAllClinics(),
        builder: (context, snapshot) {
          // loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } 

          // error
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          // empty list retured 
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No clinics found'),
            );
          }

          // data found
          final clinics = snapshot.data!;
          return ListView.builder(
            itemCount: clinics.length,
            itemBuilder: (context, index) {
              final clinic = clinics[index];

              return ClinicCard(
                name: clinic.name, 
                address: clinic.address, 
                phoneNumber: clinic.phoneNumber, 
                email: clinic.email, 
                services: clinic.services, // .split(',').map((service) => service.trim()).toList()
                operatingHours: clinic.operatingHours.map(
                  (key, value) => MapEntry(key, value.toString()),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
