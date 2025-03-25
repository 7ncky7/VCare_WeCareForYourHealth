import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:roti_planta/pages/aichat_page.dart';
import 'package:roti_planta/pages/aiemotional_page.dart';
import 'package:roti_planta/pages/aimedicine_page.dart';
import 'package:roti_planta/pages/aisymptoms_page.dart';
import 'package:roti_planta/pages/application_page.dart';
import 'package:roti_planta/pages/dietrec_page.dart';
import 'package:roti_planta/pages/editinfo_page.dart';
import 'package:roti_planta/pages/home_page.dart';
import 'package:roti_planta/pages/minichat_page.dart';
import 'package:roti_planta/pages/settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _lastName = "Loading...";
  String _greeting = "Loading...";
  int _carePoints = 0;
  int _currentIndex = 4;

  String _fullName = "None";
  String _gender = "None";
  int? _age;
  String _dateOfBirth = "None";
  String _email = "None";

  double _weight = 0.0;
  double _height = 0.0;
  String _familyHistory = "None";
  String _activityLevel = "None";
  List<String> _foodAllergies = [];
  List<String> _dietaryPreferences = [];
  List<String> _favouriteCuisines = [];

  String _emergencyName = "None";
  String _emergencyPhoneNumber = "None";
  String _emergencyEmail = "None";

  // Mapping of standardized keys to localized strings
  final Map<String, String> _genderMap = {
    'Male': 'genderMale',
    'Female': 'genderFemale',
  };

  final Map<String, String> _activityLevelMap = {
    'Inactive': 'activityLevelInactive',
    'Sedentary': 'activityLevelSedentary',
    'Moderately active': 'activityLevelModeratelyActive',
    'Vigorously active': 'activityLevelVigorouslyActive',
  };

  final Map<String, String> _foodAllergiesMap = {
    'Milk': 'foodAllergyMilk',
    'Eggs': 'foodAllergyEggs',
    'Shellfish': 'foodAllergyShellfish',
    'Nuts': 'foodAllergyNuts',
  };

  final Map<String, String> _dietaryPreferencesMap = {
    'Halal': 'dietaryPreferenceHalal',
    'Vegan': 'dietaryPreferenceVegan',
    'Vegetarian': 'dietaryPreferenceVegetarian',
    'Meal': 'dietaryPreferenceMeal',
  };

  final Map<String, String> _favouriteCuisinesMap = {
    'Malay': 'cuisineMalay',
    'Japanese': 'cuisineJapanese',
    'Chinese': 'cuisineChinese',
    'Korean': 'cuisineKorean',
    'Western': 'cuisineWestern',
    'Vietnamese': 'cuisineVietnamese',
  };

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>?;

          if (data != null) {
            setState(() {
              // Personal Information
              _fullName = data['fullName']?.toString().trim().isNotEmpty == true
                  ? data['fullName'].toString()
                  : "None";
              _lastName = _fullName == "None"
                  ? "User"
                  : _fullName.split(' ').last;
              _gender = data['gender']?.toString().trim().isNotEmpty == true
                  ? data['gender'].toString()
                  : "None";
              _age = data['age'] != null ? int.tryParse(data['age'].toString()) : null;
              if (data['dateOfBirth'] != null) {
                try {
                  _dateOfBirth = DateTime.parse(data['dateOfBirth']) as String;
                  String locale = AppLocalizations.of(context)?.localeName ?? 'en';
                  _dateOfBirth = DateFormat.yMd(locale).format(DateTime.parse(data['dateOfBirth']));
                } catch (e) {
                  _dateOfBirth = "None";
                }
              } else {
                _dateOfBirth = "None";
              }
              _email = data['email']?.toString().trim().isNotEmpty == true
                  ? data['email'].toString()
                  : "None";

              // Health Details
              _weight = double.tryParse(data['weight']?.toString() ?? '0.0') ?? 0.0;
              _height = double.tryParse(data['height']?.toString() ?? '0.0') ?? 0.0;
              _familyHistory = data['familyHistory']?.toString().trim().isNotEmpty == true
                  ? data['familyHistory'].toString()
                  : "None";
              _activityLevel = data['activityLevel']?.toString().trim().isNotEmpty == true
                  ? data['activityLevel'].toString()
                  : "None";
              _foodAllergies = data['foodAllergies'] != null
                  ? List<String>.from(data['foodAllergies'])
                  : [];
              _dietaryPreferences = data['dietaryPreferences'] != null
                  ? List<String>.from(data['dietaryPreferences'])
                  : [];
              _favouriteCuisines = data['favouriteCuisines'] != null
                  ? List<String>.from(data['favouriteCuisines'])
                  : [];

              // Emergency Contact
              _emergencyName = data['emergencyName']?.toString().trim().isNotEmpty == true
                  ? data['emergencyName'].toString()
                  : "None";
              _emergencyPhoneNumber = data['emergencyPhoneNumber']?.toString().trim().isNotEmpty == true
                  ? data['emergencyPhoneNumber'].toString()
                  : "None";
              _emergencyEmail = data['emergencyEmail']?.toString().trim().isNotEmpty == true
                  ? data['emergencyEmail'].toString()
                  : "None";

              // Care Points
              _carePoints = data['carePoints'] != null
                  ? int.tryParse(data['carePoints'].toString()) ?? 0
                  : 0;
            });
          }
        }
      } catch (e) {
        print("Error fetching user data: $e");
        setState(() {
          _lastName = "User";
          _fullName = "None";
          _gender = "None";
          _age = null;
          _dateOfBirth = "None";
          _email = "None";
          _weight = 0.0;
          _height = 0.0;
          _familyHistory = "None";
          _activityLevel = "None";
          _foodAllergies = [];
          _dietaryPreferences = [];
          _favouriteCuisines = [];
          _emergencyName = "None";
          _emergencyPhoneNumber = "None";
          _emergencyEmail = "None";
          _carePoints = 0;
        });
      }
    }
  }

  void _setGreeting(BuildContext context) {
    int hour = DateTime.now().hour;
    final localizations = AppLocalizations.of(context);
    if (localizations != null) {
      if (hour >= 5 && hour < 12) {
        _greeting = localizations.goodMorning;
      } else if (hour >= 12 && hour < 17) {
        _greeting = localizations.goodAfternoon;
      } else {
        _greeting = localizations.goodEvening;
      }
    } else {
      _greeting = "Good Morning";
    }
    setState(() {});
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
          _currentIndex = 4;
        });
      });
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ApplicationPage()),
      ).then((_) {
        setState(() {
          _currentIndex = 4;
        });
      });
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DietRecPage()),
      ).then((_) {
        _fetchUserData();
        setState(() {
          _currentIndex = 4;
        });
      });
    } else if (index == 4) {
      // Already on Profile page
    }
  }

  // Helper method to get localized string from standardized key
  String _getLocalizedString(String key, Map<String, String> map, String defaultValue) {
    final localizations = AppLocalizations.of(context);
    final localizationKey = map[key];
    if (localizationKey == null) return defaultValue;
    switch (localizationKey) {
      case 'genderMale':
        return localizations?.genderMale ?? defaultValue;
      case 'genderFemale':
        return localizations?.genderFemale ?? defaultValue;
      case 'activityLevelInactive':
        return localizations?.activityLevelInactive ?? defaultValue;
      case 'activityLevelSedentary':
        return localizations?.activityLevelSedentary ?? defaultValue;
      case 'activityLevelModeratelyActive':
        return localizations?.activityLevelModeratelyActive ?? defaultValue;
      case 'activityLevelVigorouslyActive':
        return localizations?.activityLevelVigorouslyActive ?? defaultValue;
      case 'foodAllergyMilk':
        return localizations?.foodAllergyMilk ?? defaultValue;
      case 'foodAllergyEggs':
        return localizations?.foodAllergyEggs ?? defaultValue;
      case 'foodAllergyShellfish':
        return localizations?.foodAllergyShellfish ?? defaultValue;
      case 'foodAllergyNuts':
        return localizations?.foodAllergyNuts ?? defaultValue;
      case 'dietaryPreferenceHalal':
        return localizations?.dietaryPreferenceHalal ?? defaultValue;
      case 'dietaryPreferenceVegan':
        return localizations?.dietaryPreferenceVegan ?? defaultValue;
      case 'dietaryPreferenceVegetarian':
        return localizations?.dietaryPreferenceVegetarian ?? defaultValue;
      case 'dietaryPreferenceMeal':
        return localizations?.dietaryPreferenceMeal ?? defaultValue;
      case 'cuisineMalay':
        return localizations?.cuisineMalay ?? defaultValue;
      case 'cuisineJapanese':
        return localizations?.cuisineJapanese ?? defaultValue;
      case 'cuisineChinese':
        return localizations?.cuisineChinese ?? defaultValue;
      case 'cuisineKorean':
        return localizations?.cuisineKorean ?? defaultValue;
      case 'cuisineWestern':
        return localizations?.cuisineWestern ?? defaultValue;
      case 'cuisineVietnamese':
        return localizations?.cuisineVietnamese ?? defaultValue;
      default:
        return defaultValue;
    }
  }

  // Helper method to map a list of standardized keys to localized strings
  String _mapListToLocalized(List<String> items, Map<String, String> map) {
    if (items.isEmpty) return "None";
    return items.map((item) => _getLocalizedString(item, map, item)).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setGreeting(context);
    });

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
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${localizations?.hi ?? 'Hi'} $_lastName,',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        Text(
                          _greeting,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(height: 5),
                      ],
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset('assets/images/carepoints_icon.png', height: 75),
                        Text(
                          '$_carePoints',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF852745),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: SingleChildScrollView(
                    child: Card(
                      elevation: 7.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: const Color(0xFFFFE5D9),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2, left: 23, right: 23, bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Color(0xFF852745),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const EditInfoPage()),
                                    ).then((_) => _fetchUserData());
                                  },
                                  iconSize: 30.0,
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.settings,
                                    color: Color(0xFF852745),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const SettingsPage()),
                                    );
                                  },
                                  iconSize: 30.0,
                                ),
                              ],
                            ),
                            _buildSection(
                              title: localizations?.personalInformation ?? 'Personal Details',
                              children: [
                                _buildInfoField(localizations?.fullName ?? 'Full Name:', _fullName),
                                _buildInfoField(localizations?.gender ?? 'Gender:', _gender == "None" ? "None" : _getLocalizedString(_gender, _genderMap, _gender)),
                                _buildInfoField(localizations?.age ?? 'Age:', _age?.toString() ?? 'None'),
                                _buildInfoField(localizations?.dateOfBirth ?? 'Date of Birth:', _dateOfBirth),
                                _buildInfoField(localizations?.emailAddress ?? 'Email Address:', _email),
                              ],
                            ),
                            const SizedBox(height: 30),
                            _buildSection(
                              title: localizations?.healthDetails ?? 'Health Details',
                              children: [
                                _buildInfoField(localizations?.weight ?? 'Weight (kg):', _weight.toString()),
                                _buildInfoField(localizations?.height ?? 'Height (cm):', _height.toString()),
                                _buildInfoField(localizations?.familyHistory ?? 'Family History:', _familyHistory),
                                _buildInfoField(localizations?.activityLevel ?? 'Activity Level:', _activityLevel == "None" ? "None" : _getLocalizedString(_activityLevel, _activityLevelMap, _activityLevel)),
                                _buildInfoField(localizations?.foodAllergies ?? 'Food Allergies:', _mapListToLocalized(_foodAllergies, _foodAllergiesMap)),
                                _buildInfoField(localizations?.dietaryPreference ?? 'Dietary Preference:', _mapListToLocalized(_dietaryPreferences, _dietaryPreferencesMap)),
                                _buildInfoField(localizations?.favouriteCuisine ?? 'Favourite Cuisine:', _mapListToLocalized(_favouriteCuisines, _favouriteCuisinesMap)),
                              ],
                            ),
                            const SizedBox(height: 30),
                            _buildSection(
                              title: localizations?.emergencyContact ?? 'Emergency Contact',
                              children: [
                                _buildInfoField(localizations?.emergencyName ?? 'Name:', _emergencyName),
                                _buildInfoField(localizations?.emergencyContactNumber ?? 'Contact Number:', _emergencyPhoneNumber),
                                _buildInfoField(localizations?.emergencyEmailAddress ?? 'Email Address:', _emergencyEmail),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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
                currentPage: "ProfilePage",
                onNavigateToProfile: () {
                  Navigator.pop(context); // Close the chatbot
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

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Text(
            title,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Color(0xFF852745),
            ),
          ),
        if (title.isNotEmpty) const SizedBox(height: 5),
        if (title.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 3,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.only(top: 8, left: 12, right: 10, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        if (title.isEmpty) ...children,
      ],
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF852745),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}