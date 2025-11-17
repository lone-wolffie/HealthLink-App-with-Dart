import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthlink_app/services/api_service.dart';
import 'package:healthlink_app/models/health_tips.dart';
import 'package:healthlink_app/widgets/custom_app_bar.dart';
import 'package:healthlink_app/widgets/loading_indicator.dart';
import 'package:healthlink_app/widgets/error_message.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({
    super.key
  });

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  late Future<List<HealthTips>> _tipsFuture;
  List<HealthTips> _allTips = [];
  List<HealthTips> _filteredTips = [];
  final TextEditingController _searchController = TextEditingController();

  Set<int> _favoriteTips = {};

  final List<String> _categories = [
    'All',
    'Nutrition',
    'Physical Activity',
    'Lifestyle',
    'Hygiene',
    'Mental Health',
    'Medical Care',
    'General Wellness',
  ];

  String _selectedCategory = 'All';

  final Map<String, Color> _categoryColors = {
    'All': Colors.grey,
    'Nutrition': Colors.green,
    'Physical Activity': Colors.blue,
    'Lifestyle': Colors.orange,
    'Hygiene': Colors.teal,
    'Mental Health': Colors.purple,
    'Medical Care': Colors.red,
    'General Wellness': Colors.brown,
  };

  @override
  void initState() {
    super.initState();
    _loadTips();
    _loadFavorites();
  }

  void _loadTips() {
    _tipsFuture = ApiService.getAllHealthTips();
    _tipsFuture.then((data) {
      setState(() {
        _allTips = data;
        _filteredTips = data;
      });
    });
  }

  // load favorites 
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favList = prefs.getStringList('favoriteTips') ?? [];
    setState(() {
      _favoriteTips = favList.map(int.parse).toSet();
    });
  }

  /// Save favorites 
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favoriteTips',
      _favoriteTips.map((id) => id.toString()).toList(),
    );
  }

  void _applyFilters() {
    setState(() {
      _filteredTips = _allTips.where((tip) {
        final matchesSearch = tip.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          tip.content.toLowerCase().contains(_searchController.text.toLowerCase());

        final matchesCategory = _selectedCategory == 'All' || tip.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Health Tips', 
        actions: []
      ),

      body: FutureBuilder<List<HealthTips>>(
        future: _tipsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }

          if (snapshot.hasError) {
            return ErrorMessage(message: snapshot.error.toString());
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => _applyFilters(),
                  decoration: InputDecoration(
                    hintText: 'Search tips...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: _categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          category,
                          style: TextStyle(
                            color: _selectedCategory == category ? Colors.white : const Color.fromARGB(255, 38, 35, 35),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: _selectedCategory == category,
                        selectedColor: _categoryColors[category],
                        backgroundColor: _categoryColors[category]!,
                        onSelected: (selected) {
                          setState(() => _selectedCategory = category);
                          _applyFilters();
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              Expanded(
                child: _filteredTips.isEmpty
                    ? const Center(
                      child: Text('No health tips found.')
                    )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _filteredTips.length,
                        itemBuilder: (context, i) {
                          final tip = _filteredTips[i];
                          final formattedDate = DateFormat('dd/MM/yyyy').format(tip.dateRecorded);
                          final isFav = _favoriteTips.contains(tip.id);

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: _categoryColors[tip.category]!,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10, 
                                          vertical: 4
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: _categoryColors[tip.category]!,
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          tip.category,
                                          style: TextStyle(
                                            color: _categoryColors[tip.category]!,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),

                                      IconButton(
                                        icon: Icon(
                                          isFav ? Icons.favorite : Icons.favorite_border,
                                          color: isFav ? Colors.red : Colors.grey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            isFav ? _favoriteTips.remove(tip.id) : _favoriteTips.add(tip.id);
                                          });
                                          _saveFavorites();
                                        },
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  Text(
                                    tip.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  Text(
                                    tip.content,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 14),

                                  Text(
                                    'Recorded: $formattedDate',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
