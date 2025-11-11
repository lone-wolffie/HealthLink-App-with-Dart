import 'package:flutter/material.dart';
import '../models/clinics.dart';
import '../services/api_service.dart';
import '../widgets/clinic_card.dart';
import '../widgets/custom_app_bar.dart';

class ClinicsScreen extends StatefulWidget {
  const ClinicsScreen({super.key});

  @override
  State<ClinicsScreen> createState() => _ClinicsScreenState();
}

class _ClinicsScreenState extends State<ClinicsScreen> {
  late Future<List<Clinics>> _clinicsFuture;
  List<Clinics> _allClinics = [];
  List<Clinics> _filteredClinics = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadClinics();
    _searchController.addListener(_runSearch);
  }

  void _loadClinics() {
    _clinicsFuture = ApiService.getAllClinics();
  }

  void _runSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredClinics = _allClinics.where((clinic) {
        return clinic.name.toLowerCase().contains(query) ||
               clinic.address.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _refreshClinics() async {
    setState(() {
      _loadClinics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Top Clinics', actions: []),

      body: FutureBuilder<List<Clinics>>(
        future: _clinicsFuture,
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load clinics.\nTap to retry.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No clinics available at the moment.',
                style: TextStyle(fontSize: 15),
              ),
            );
          }

          // Store data & apply initial filter if needed
          _allClinics = snapshot.data!;
          _filteredClinics = _filteredClinics.isEmpty && _searchController.text.isEmpty
              ? _allClinics
              : _filteredClinics;

          return RefreshIndicator(
            onRefresh: _refreshClinics,
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      hintText: 'Search clinics...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    itemCount: _filteredClinics.length,
                    itemBuilder: (context, index) {
                      final clinic = _filteredClinics[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ClinicCard(
                          name: clinic.name,
                          address: clinic.address,
                          phoneNumber: clinic.phoneNumber,
                          email: clinic.email,
                          services: clinic.services,
                          operatingHours: clinic.operatingHours.map(
                            (key, value) => MapEntry(key, value.toString()),
                          ), clinic: clinic,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
