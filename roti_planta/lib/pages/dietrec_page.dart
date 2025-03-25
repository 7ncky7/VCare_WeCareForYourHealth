import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:roti_planta/pages/aichat_page.dart';
import 'package:roti_planta/pages/aiemotional_page.dart';
import 'package:roti_planta/pages/aimedicine_page.dart';
import 'package:roti_planta/pages/aisymptoms_page.dart';
import 'package:roti_planta/pages/application_page.dart';
import 'package:roti_planta/pages/home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:roti_planta/appconfig.dart';
import 'package:roti_planta/pages/minichat_page.dart';
import 'package:roti_planta/pages/profile_page.dart';

class DietRecPage extends StatefulWidget {
  const DietRecPage({super.key});

  @override
  State<DietRecPage> createState() => _DietRecPageState();
}

class _DietRecPageState extends State<DietRecPage> {
  String? _selectedMeal;
  String _recommendationTitle = "";
  String _recommendationText = "Please select a meal to view recommendations";
  String _errorMessage = "";
  Map<String, dynamic>? _dietRecommendations;
  int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
    _fetchDietRecommendations();
  }

  Future<void> _fetchDietRecommendations() async {
    setState(() {
      _recommendationText = "Please select a meal to view recommendations";
      _errorMessage = "";
    });

    try {
      final url = Uri.parse('${AppConfig.baseUrl}/api/get-diet-recommendations');
      final String userEmail = "yunqi0729@gmail.com";

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': userEmail}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _dietRecommendations = data['recommendations'];
          if (_selectedMeal != null) {
            _updateRecommendationText(_selectedMeal!.trim());
          } else {
            _recommendationText = "Please select a meal to view recommendations";
          }
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load recommendations: ${response.body}";
          _recommendationText = "Error occurred";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
        _recommendationText = "Failed to connect to server";
      });
    }
  }

  void _updateRecommendationText(String meal) {
    setState(() {
      _recommendationTitle = "$meal Recommendation";
      if (_dietRecommendations == null) {
        _recommendationText = "Loading...";
        return;
      }
      switch (meal) {
        case 'Breakfast':
          _recommendationText = _dietRecommendations?['Breakfast'] ?? "Not available";
          break;
        case 'Lunch':
          _recommendationText = _dietRecommendations?['Lunch'] ?? "Not available";
          break;
        case 'Dinner':
          _recommendationText = _dietRecommendations?['Dinner'] ?? "Not available";
          break;
        default:
          _recommendationText = "Invalid meal selection";
      }
    });
  }

  Widget _buildRecommendationContent(String recommendationText) {
    if (recommendationText == "Not available" ||
        recommendationText == "Loading..." ||
        recommendationText == "Error occurred" ||
        recommendationText == "Failed to connect to server" ||
        recommendationText == "Please select a meal to view recommendations") {
      return Text(
        recommendationText,
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      );
    }

    final lines = recommendationText.split('\n');
    List<Widget> widgets = [];
    List<String> currentSection = [];
    bool isTotalSection = false;

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.startsWith("Carbs:") || line.startsWith("Protein:") || line.startsWith("Fat:") || line.startsWith("Total Calories:")) {
        isTotalSection = true;
        if (currentSection.isNotEmpty) {
          widgets.add(_buildMealSection(currentSection));
          currentSection = [];
        }
      }

      if (isTotalSection) {
        currentSection.add(line);
      } else {
        currentSection.add(line);
      }
    }

    if (currentSection.isNotEmpty) {
      if (isTotalSection) {
        widgets.add(_buildTotalSection(currentSection));
      } else {
        widgets.add(_buildMealSection(currentSection));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildMealSection(List<String> lines) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.map((line) {
          if (line.startsWith(RegExp(r'\d+\.'))) {
            return Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Text(
                line,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF852745),
                ),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 2),
              child: Text(
                line,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            );
          }
        }).toList(),
      ),
    );
  }

  Widget _buildTotalSection(List<String> lines) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF852745),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.map((line) {
          return Padding(
            padding: const EdgeInsets.only(top: 5, left: 5, bottom: 5, right: 5),
            child: Text(
              line,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AiChatPage()),
      ).then((_) {
        setState(() {
          _currentIndex = 3;
        });
      });
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ApplicationPage()),
      ).then((_) {
        setState(() {
          _currentIndex = 3;
        });
      });
    } else if (index == 3) {
      // Already on DietRec page
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      ).then((_) {
        setState(() {
          _currentIndex = 3;
        });
      });
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
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 15, left: 12, right: 12, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/food_icon.png',
                                  height: 70,
                                  color: const Color(0xFF852745),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  localizations?.dietRec ?? 'Diet',
                                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                        color: const Color(0xFF852745),
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const SizedBox(width: 11),
                                Text(
                                  localizations?.recommendation ?? 'Recommendation',
                                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                        color: const Color(0xFF852745),
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Card(
                      elevation: 7.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: const Color(0xFFFFE5D9),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 13, left: 15, right: 15, bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const SizedBox(width: 15),
                                Text(
                                  localizations?.dietRec ?? 'Diet',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: const Color(0xFF852745),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        decoration: TextDecoration.underline,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 7),
                            Row(
                              children: [
                                const SizedBox(width: 18),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Radio<String>(
                                          value: ' Breakfast',
                                          groupValue: _selectedMeal,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedMeal = value;
                                            });
                                            _updateRecommendationText(value!.trim());
                                          },
                                          activeColor: const Color(0xFF852745),
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: const VisualDensity(
                                            horizontal: VisualDensity.minimumDensity,
                                            vertical: VisualDensity.minimumDensity,
                                          ),
                                        ),
                                        Text(
                                          localizations?.breakfast ?? 'Breakfast',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: const Color(0xFF852745),
                                                fontSize: 15,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Radio<String>(
                                          value: ' Lunch',
                                          groupValue: _selectedMeal,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedMeal = value;
                                            });
                                            _updateRecommendationText(value!.trim());
                                          },
                                          activeColor: const Color(0xFF852745),
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: const VisualDensity(
                                            horizontal: VisualDensity.minimumDensity,
                                            vertical: VisualDensity.minimumDensity,
                                          ),
                                        ),
                                        Text(
                                          localizations?.lunch ?? 'Lunch',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: const Color(0xFF852745),
                                                fontSize: 15,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Radio<String>(
                                          value: ' Dinner',
                                          groupValue: _selectedMeal,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedMeal = value;
                                            });
                                            _updateRecommendationText(value!.trim());
                                          },
                                          activeColor: const Color(0xFF852745),
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: const VisualDensity(
                                            horizontal: VisualDensity.minimumDensity,
                                            vertical: VisualDensity.minimumDensity,
                                          ),
                                        ),
                                        Text(
                                          localizations?.dinner ?? 'Dinner',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: const Color(0xFF852745),
                                                fontSize: 15,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                  ),
                                ],
                                border: Border.all(
                                  color: const Color.fromARGB(255, 119, 26, 26),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    _recommendationTitle.isNotEmpty
                                        ? _recommendationTitle
                                        : localizations?.selectMeal ?? '<diet> Recommendation',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: const Color(0xFF852745),
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                          fontSize: 22,
                                        ),
                                  ),
                                  //const SizedBox(height: 5),
                                  _buildRecommendationContent(_recommendationText),
                                  if (_errorMessage.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Text(
                                      _errorMessage,
                                      style: const TextStyle(color: Colors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                currentPage: "DietRecPage",
                onNavigateToProfile: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfilePage()),
                  );
                },
                onNavigateToApps: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ApplicationPage()),
                  );
                },
                onNavigateToDiet: () {
                  Navigator.pop(context);
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
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
