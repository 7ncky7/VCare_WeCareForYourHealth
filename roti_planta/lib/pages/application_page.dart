import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:roti_planta/pages/aichat_page.dart';
import 'package:roti_planta/pages/aiemotional_page.dart';
import 'package:roti_planta/pages/aimedicine_page.dart';
import 'package:roti_planta/pages/aisymptoms_page.dart';
import 'package:roti_planta/pages/checkin_page.dart';
import 'package:roti_planta/pages/dietrec_page.dart';
import 'package:roti_planta/pages/home_page.dart';
import 'package:roti_planta/pages/imagediag_page.dart';
import 'package:roti_planta/pages/minichat_page.dart';
import 'package:roti_planta/pages/profile_page.dart';
import 'package:roti_planta/pages/redemption_page.dart';
import 'package:roti_planta/pages/reportdiag_page.dart';

// class CommunityPage extends StatelessWidget {
//   const CommunityPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Community')),
//       body: const Center(child: Text('Community Page - To Be Implemented')),
//     );
//   }
// }

// class GamePage extends StatelessWidget {
//   const GamePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Game')),
//       body: const Center(child: Text('Game Page - To Be Implemented')),
//     );
//   }
// }

class ApplicationPage extends StatefulWidget {
  const ApplicationPage({super.key});

  @override
  State<ApplicationPage> createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<ApplicationPage> {
  int _currentIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AiChatPage()),
      );
    } else if (index == 2) {
      // Already on ApplicationPage
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DietRecPage()),
      );
    } else if (index == 4) {
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
            padding: const EdgeInsets.only(top: 40, left: 30, right: 30, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations?.application ?? 'Application',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.2,
                    children: [
                      _buildAppBox(
                        context,
                        icon: 'assets/images/aichat_icon.png',
                        title: localizations?.aiChat ?? 'AI',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AiChatPage()),
                        ),
                      ),
                      _buildAppBox(
                        context,
                        icon: 'assets/images/food_icon.png',
                        title: localizations?.dietRec ?? 'Diet',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DietRecPage()),
                        ),
                      ),
                      _buildAppBox(
                        context,
                        icon: 'assets/images/healthboard_icon.png',
                        title: localizations?.reportDiagnosis ?? 'Report Diagnosis',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ReportDiagPage()),
                        ),
                      ),
                      _buildAppBox(
                        context,
                        icon: 'assets/images/imagediag_icon.png',
                        title: localizations?.imageDiagnosis ?? 'Image Diagnosis',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ImageDiagPage()),
                        ),
                      ),
                      _buildAppBox(
                        context,
                        icon: 'assets/images/checkin_icon.png',
                        title: localizations?.checkIn ?? 'Check In',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CheckInPage()),
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
                      // _buildAppBox(
                      //   context,
                      //   icon: 'assets/images/game_icon.png',
                      //   title: localizations?.game ?? 'Game',
                      //   onTap: () => Navigator.push(
                      //     context,
                      //     MaterialPageRoute(builder: (context) => const GamePage()),
                      //   ),
                      // ),
                      // _buildAppBox(
                      //   context,
                      //   icon: 'assets/images/community_icon.png',
                      //   title: localizations?.community ?? 'Community',
                      //   onTap: () => Navigator.push(
                      //     context,
                      //     MaterialPageRoute(builder: (context) => const CommunityPage()),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => Container(
              height: MediaQuery.of(context).size.height * 0.8,
              child: MiniChatWidget(
                currentPage: "ApplicationPage",
                onNavigateToProfile: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfilePage()),
                  );
                },
                onNavigateToApps: () {
                  Navigator.pop(context);
                },
                onNavigateToDiet: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DietRecPage()),
                  );
                },
                onNavigateToAiChat: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AiChatPage()),
                  );
                },
                onNavigateToEmotionalSupport: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AiEmotionalPage()),
                  );
                },
                onNavigateToCheckSymptoms: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AiSymptomsPage()),
                  );
                },
                onNavigateToMedicineRecommendation: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AiMedicinePage()),
                  );
                },
              ),
            ),
          );
        },
        child: Icon(Icons.chat, color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.primary,
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
            label: localizations?.aiChatNavBar ?? 'AI CHAT',
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
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
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
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(icon, height: 70, color: const Color(0xFF852745)),
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