import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthlink_app/screens/tips_screen.dart';
import 'package:healthlink_app/screens/my_appointments_screen.dart';
import 'package:healthlink_app/screens/symptom_history_screen.dart';
import 'package:healthlink_app/screens/add_symptom_screen.dart';
import 'package:healthlink_app/screens/medications_screen.dart';
import 'package:healthlink_app/screens/alerts_screen.dart';
import 'package:healthlink_app/screens/clinics_screen.dart';
import 'package:healthlink_app/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;

  const HomeScreen({
    super.key, 
    required this.userId
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Widget> screens = [
      _HomeDashboard(userId: widget.userId),
      AddSymptomScreen(userId: widget.userId),
      const ClinicsScreen(),
      const AlertsScreen(),
      ProfileScreen(userId: widget.userId),
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: SafeArea(child: screens[_selectedIndex]),
      bottomNavigationBar: SizedBox(
        height: 65,
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) => setState(() => _selectedIndex = index),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          elevation: 3,
          backgroundColor: theme.colorScheme.surface,
          indicatorColor: theme.colorScheme.primaryContainer,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(
                Icons.home, 
                color: Colors.green
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(
                Icons.add_circle, 
                color: Colors.green
              ),
              label: 'Add',
              tooltip: 'Add a symptom',
            ),
            NavigationDestination(
              icon: Icon(Icons.local_hospital_outlined),
              selectedIcon: Icon(
                Icons.local_hospital, 
                color: Colors.green
              ),
              label: 'Clinics',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              selectedIcon: Icon(
                Icons.notifications, 
                color: Colors.green
              ),
              label: 'Alerts',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(
                Icons.person, 
                color: Colors.green
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeDashboard extends StatefulWidget {
  final int userId;

  const _HomeDashboard({
    required this.userId
  });

  @override
  State<_HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<_HomeDashboard> {
  String username = "";

  @override
  void initState() {
    super.initState();
    loadUsername();
  }

  Future<void> loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username") ?? "";
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.secondaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(2, 24, 20, 32),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [      
                  const SizedBox(width: 6),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HealthLink App \u{1F3E5}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Take control of your health journey',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _getGreeting(),
                        style: TextStyle(
                          fontSize: 15, 
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        username.isNotEmpty
                            ? username
                            : 'Welcome!', 
                        style: TextStyle(
                          fontSize: 14, 
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis, 
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.tertiaryContainer,
                    theme.colorScheme.tertiaryContainer.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 210, 207, 207),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.favorite,
                      size: 32,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Track your symptoms regularly and keep up with your medication.',
                      style: TextStyle(
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width < 360 ? 1 : 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                mainAxisExtent: 180, 
              ),
              itemCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final cards = [
                  _ActionCard(
                    icon: Icons.history,
                    label: 'Symptom History',
                    subtitle: 'View logged symptoms',
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SymptomHistoryScreen(userId: widget.userId),
                      ),
                    ),
                  ),

                  _ActionCard(
                    icon: Icons.medication,
                    label: 'My Medications',
                    subtitle: 'Manage your meds',
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MedicationsScreen(userId: widget.userId),
                      ),
                    ),
                  ),

                  _ActionCard(
                    icon: Icons.calendar_month,
                    label: 'My Appointments',
                    subtitle: 'View scheduled appointments',
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade400, Colors.purple.shade600],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MyAppointmentsScreen(userId: widget.userId),
                      ),
                    ),
                  ),

                  _ActionCard(
                    icon: Icons.lightbulb,
                    label: 'Health Tips',
                    subtitle: 'Learn more',
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade400, Colors.orange.shade600],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TipsScreen()),
                    ),
                  ),
                ];

                return cards[index];
              },
            ),

          ),

          const SizedBox(height: 28),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Features',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _FeatureListItem(
                  icon: Icons.notifications_active,
                  title: 'Smart Reminders',
                  subtitle: 'Never miss medications or appointments',
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 8),
                _FeatureListItem(
                  icon: Icons.analytics,
                  title: 'Health Insights',
                  subtitle: 'Track symptoms in your health',
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(height: 8),
                _FeatureListItem(
                  icon: Icons.security,
                  title: 'Secure & Private',
                  subtitle: 'Your health data is encrypted and safe',
                  color: theme.colorScheme.tertiary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 210, 207, 207),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(
              isSmallScreen ? 12 : 16,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, 
              children: [
                Container(
                  padding: EdgeInsets.all(
                    isSmallScreen ? 8 : 12,
                  ), 
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 210, 207, 207),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    size: isSmallScreen
                        ? 24
                        : 32, 
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 8 : 12), 
                
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 15, 
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              
                const SizedBox(height: 2),

                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 10 : 12, 
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _FeatureListItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 210, 207, 207),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
