import 'package:flutter/material.dart';
import '../widgets/clinic_card.dart';
import '../widgets/custom_app_bar.dart';

class ClinicsScreen extends StatelessWidget {
  const ClinicsScreen({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Nearby Clinics'),
      body: ListView(
        children: const [
          ClinicCard(
            name: 'Kenyatta National Hospital',
            address: 'Hospital Rd, Upper Hill, Nairobi',
            phoneNumber: '+254 20 2726300',
            email: 'knhadmin@knh.or.ke',
            services: ['Emergency', 'Surgery', 'Pediatrics'],
            operatingHours: {
              "Monday": "08:00 - 17:00",
              "Tuesday": "08:00 - 17:00",
              "Wednesday": "08:00 - 17:00",
              "Thursday": "08:00 - 17:00",
              "Friday": "08:00 - 17:00",
              "Saturday": "09:00 - 13:00",
              "Sunday": "Closed"
            },
          ),

          ClinicCard(
            name: 'Aga Khan University Hospital',
            address: '3rd Parklands Ave, Nairobi',
            phoneNumber: '+254 20 3662000',
            email: 'akuh.nairobi@aku.edu',
            services: ['Emergency', 'Cardiology', 'Oncology'],
            operatingHours: {
              "Monday": "08:00 - 17:00",
              "Tuesday": "08:00 - 17:00",
              "Wednesday": "08:00 - 17:00",
              "Thursday": "08:00 - 17:00",
              "Friday": "08:00 - 15:00",
              "Saturday": "09:00 - 13:00",
              "Sunday": "Closed"
            },
          ),

          ClinicCard(
            name: 'Nairobi Hospital',
            address: 'Argwings Kodhek Rd, Nairobi',
            phoneNumber: '+254 20 2845000',
            email: 'hosp@nbihosp.org',
            services: ['Emergency', 'Maternity', 'Surgery'],
            operatingHours: {
              "Monday": "08:00 - 18:00",
              "Tuesday": "08:00 - 18:00",
              "Wednesday": "08:00 - 18:00",
              "Thursday": "08:00 - 18:00",
              "Friday": "08:00 - 18:00",
              "Saturday": "09:00 - 14:00",
              "Sunday": "Closed"
            },
          ),

          ClinicCard(
            name: 'Gertrudes Children Hospital',
            address: 'Muthaiga Rd, Nairobi',
            phoneNumber: '+254 20 7206000',
            email: 'info@gerties.org',
            services: ['Pediatrics', 'Emergency', 'Vaccination'],
            operatingHours: {
              "Monday": "08:00 - 17:00",
              "Tuesday": "08:00 - 17:00",
              "Wednesday": "08:00 - 17:00",
              "Thursday": "08:00 - 17:00",
              "Friday": "08:00 - 17:00",
              "Saturday": "09:00 - 12:00",
              "Sunday": "Closed"
            },
          ),
        ],
      ),
    );
  }
}
