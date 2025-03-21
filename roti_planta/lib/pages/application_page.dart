import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:roti_planta/pages/home_page.dart';
import 'package:roti_planta/pages/profile_page.dart';
import 'package:roti_planta/pages/test_page.dart';
import 'package:roti_planta/pages/settings_page.dart';

// Placeholder pages for navigation (to be replaced with actual pages later)
class AIChatPage extends StatelessWidget {
  const AIChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Chat')),
      body: const Center(child: Text('AI Chat Page - To Be Implemented')),
    );
  }
}

class GlucosePage extends StatelessWidget {
  const GlucosePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Glucose')),
      body: const Center(child: Text('Glucose Page - To Be Implemented')),
    );
  }
}

class DietPage extends StatelessWidget {
  const DietPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diet')),
      body: const Center(child: Text('Diet Page - To Be Implemented')),
    );
  }
}

class MedicinePage extends StatelessWidget {
  const MedicinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medicine')),
      body: const Center(child: Text('Medicine Page - To Be Implemented')),
    );
  }
}

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report')),
      body: const Center(child: Text('Report Page - To Be Implemented')),
    );
  }
}

class RedemptionPage extends StatelessWidget {
  const RedemptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Redemption')),
      body: const Center(child: Text('Redemption Page - To Be Implemented')),
    );
  }
}

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      body: const Center(child: Text('Community Page - To Be Implemented')),
    );
  }
}

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game')),
      body: const Center(child: Text('Game Page - To Be Implemented')),
    );
  }
}

class ApplicationPage extends StatefulWidget {
  const ApplicationPage({super.key});

  @override
  State<ApplicationPage> createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<ApplicationPage> {
  int _currentIndex = 2; // Default to "APPS" tab since we're on ApplicationPage

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      // Navigate to Home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (index == 1) {
      // Navigate to AI Chat page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TestPage(location: 'AI Chat')),
      );
    } else if (index == 2) {
      // Already on ApplicationPage, do nothing
    } else if (index == 3) {
      // Navigate to Diet page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DietPage()),
      );
    } else if (index == 4) {
      // Navigate to Profile page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD59FA6), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title: "Application"
                Text(
                  localizations?.application ?? 'Application',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 20),
                // Grid of 8 boxes
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2, // 2 columns
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.2, // Adjust to make boxes more square
                    children: [
                      _buildAppBox(
                        context,
                        icon: 'assets/images/aichat_icon.png',
                        title: localizations?.aiChat ?? 'AI',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AIChatPage()),
                        ),
                      ),
                      _buildAppBox(
                        context,
                        icon: 'assets/images/sugar_icon.png',
                        title: localizations?.glucose ?? 'Glucose',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const GlucosePage()),
                        ),
                      ),
                      _buildAppBox(
                        context,
                        icon: 'assets/images/food_icon.png',
                        title: localizations?.diet ?? 'Diet',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DietPage()),
                        ),
                      ),
                      _buildAppBox(
                        context,
                        icon: 'assets/images/medicine_icon.png',
                        title: localizations?.medicine ?? 'Medicine',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MedicinePage()),
                        ),
                      ),
                      _buildAppBox(
                        context,
                        icon: 'assets/images/healthboard_icon.png',
                        title: localizations?.report ?? 'Report',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ReportPage()),
                        ),
                      ),
                      _buildAppBox(
                        context,
                        icon: 'assets/images/redemption_icon.png',
                        title: localizations?.redemption ?? 'Redemption',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RedemptionPage()),
                        ),
                      ),
                      _buildAppBox(
                        context,
                        icon: 'assets/images/community_icon.png',
                        title: localizations?.community ?? 'Community',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CommunityPage()),
                        ),
                      ),
                      _buildAppBox(
                        context,
                        icon: 'assets/images/game_icon.png',
                        title: localizations?.game ?? 'Game',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const GamePage()),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFFFE5D9),
        selectedItemColor: const Color(0xFF852745),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Stack(
              alignment: Alignment.topCenter,
              children: [
                Image.asset('assets/images/home_icon.png', height: 30),
                if (_currentIndex == 0)
                  Positioned(
                    top: -5,
                    child: Container(
                      width: 20,
                      height: 5,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
            label: localizations?.home ?? 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              alignment: Alignment.topCenter,
              children: [
                Image.asset('assets/images/aichat_icon.png', height: 30),
                if (_currentIndex == 1)
                  Positioned(
                    top: -5,
                    child: Container(
                      width: 20,
                      height: 5,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
            label: localizations?.aiChat ?? 'AI CHAT',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              alignment: Alignment.topCenter,
              children: [
                Image.asset('assets/images/Logo.png', height: 30),
                if (_currentIndex == 2)
                  Positioned(
                    top: -5,
                    child: Container(
                      width: 20,
                      height: 5,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
            label: localizations?.apps ?? 'APPS',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              alignment: Alignment.topCenter,
              children: [
                Image.asset('assets/images/food_icon.png', height: 30),
                if (_currentIndex == 3)
                  Positioned(
                    top: -5,
                    child: Container(
                      width: 20,
                      height: 5,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
            label: localizations?.diet ?? 'DIET',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              alignment: Alignment.topCenter,
              children: [
                Image.asset('assets/images/profile_icon.png', height: 30),
                if (_currentIndex == 4)
                  Positioned(
                    top: -5,
                    child: Container(
                      width: 20,
                      height: 5,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
            label: localizations?.profile ?? 'PROFILE',
          ),
        ],
      ),
    );
  }

  Widget _buildAppBox(BuildContext context, {required String icon, required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFE5D9),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3), // Darker shadow color for more visibility
              spreadRadius: 3, // Increase spread for a larger shadow
              blurRadius: 8, // Increase blur for a softer shadow
              offset: const Offset(0, 4), // Move shadow slightly downward
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(icon, height: 50, color: const Color(0xFF852745)),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}