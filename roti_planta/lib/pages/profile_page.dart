 import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:roti_planta/pages/application_page.dart';
import 'package:roti_planta/pages/editinfo_page.dart';
import 'package:roti_planta/pages/home_page.dart';
import 'package:roti_planta/pages/settings_page.dart';
import 'package:roti_planta/pages/test_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _lastName = "Loading...";
  int _carePoints = 0;
  int _currentIndex = 4; // Profile page is selected by default

  // Personal Information
  String _fullName = "None";
  String _gender = "None";
  int? _age;
  String _dateOfBirth = "None";
  String _email = "None";

  // Health Details
  double _weight = 0.0;
  double _height = 0.0;
  String _familyHistory = "None";
  String _activityLevel = "None";
  List<String> _foodAllergies = [];
  List<String> _dietaryPreferences = [];
  List<String> _favouriteCuisines = [];

  // Emergency Contact
  String _emergencyName = "None";
  String _emergencyPhoneNumber = "None";
  String _emergencyEmail = "None";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from Firestore
  void _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          // Last Name and Care Points
          _lastName = doc['fullName']?.toString().trim().isEmpty ?? true
              ? "User"
              : doc['fullName'].toString().split(' ').last;
          _carePoints = doc['carePoints'] ?? 0;

          // Personal Information
          _fullName = doc['fullName']?.toString().trim().isEmpty ?? true
              ? "None"
              : doc['fullName'].toString();
          _gender = doc['gender']?.toString().trim().isEmpty ?? true
              ? "None"
              : doc['gender'].toString();
          _age = doc['age'];
          _dateOfBirth = doc['dateOfBirth'] != null
              ? DateFormat('dd-MM-yyyy')
                  .format(DateTime.parse(doc['dateOfBirth']))
              : "None";
          _email = doc['email']?.toString().trim().isEmpty ?? true
              ? "None"
              : doc['email'].toString();

          // Health Details
          _weight = doc['weight'] ?? 0.0;
          _height = doc['height'] ?? 0.0;
          _familyHistory = doc['familyHistory']?.toString().trim().isEmpty ?? true
              ? "None"
              : doc['familyHistory'].toString();
          _activityLevel = doc['activityLevel']?.toString().trim().isEmpty ?? true
              ? "None"
              : doc['activityLevel'].toString();
          _foodAllergies = List<String>.from(doc['foodAllergies'] ?? []);
          _dietaryPreferences = List<String>.from(doc['dietaryPreferences'] ?? []);
          _favouriteCuisines = List<String>.from(doc['favouriteCuisines'] ?? []);

          // Emergency Contact
          _emergencyName = doc['emergencyName']?.toString().trim().isEmpty ?? true
              ? "None"
              : doc['emergencyName'].toString();
          _emergencyPhoneNumber =
              doc['emergencyPhoneNumber']?.toString().trim().isEmpty ?? true
                  ? "None"
                  : doc['emergencyPhoneNumber'].toString();
          _emergencyEmail = doc['emergencyEmail']?.toString().trim().isEmpty ?? true
              ? "None"
              : doc['emergencyEmail'].toString();
        });
      }
    }
  }

  // Handle bottom navigation bar taps
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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TestPage(location: 'AI Chat')),
      ).then((_) {
        setState(() {
          _currentIndex = 4;
        });
      });
    } else if (index == 2) {
      // Navigate to Application page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ApplicationPage()),
      ).then((_) {
        setState(() {
          _currentIndex = 4;
        });
      });
    } else if (index == 3) {
      // Navigate to Diet page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DietPage()),
      ).then((_) {
        _fetchUserData(); // Refresh data when returning from Diet page
        setState(() {
          _currentIndex = 4;
        });
      });
    } else if (index == 4) {
      // Already on Profile page
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Display "Hi <Last Name>" and Care Points
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hi $_lastName',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: const Color(0xFF852745),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset('assets/images/carepoints_icon.png', height: 70),
                        Text(
                          '$_carePoints',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF852745),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. Peach Box with Personal Info, Health Details, and Emergency Contact
                Expanded(
                  child: SingleChildScrollView(
                    child: Card(
                      elevation: 7.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: const Color(0xFFFFE5D9),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icons for Edit and Settings
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
                                      MaterialPageRoute(
                                          builder: (context) => const EditInfoPage()),
                                    ).then((_) => _fetchUserData());
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.settings,
                                    color: Color(0xFF852745),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const SettingsPage()),
                                    );
                                  },
                                ),
                              ],
                            ),

                            // 3. Personal Information
                            _buildSection(
                              title: '',
                              children: [
                                _buildInfoField('Full Name:', _fullName),
                                _buildInfoField('Gender:', _gender),
                                _buildInfoField('Age:', _age?.toString() ?? 'None'),
                                _buildInfoField('Date of Birth:', _dateOfBirth),
                                _buildInfoField('Email Address:', _email),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // 4. Health Details (First White Box)
                            _buildSection(
                              title: 'Health Details',
                              children: [
                                _buildInfoField('Weight (cm):', _weight.toString()),
                                _buildInfoField('Height (cm):', _height.toString()),
                                _buildInfoField('Family History:', _familyHistory),
                                _buildInfoField('Activity Level:', _activityLevel),
                                _buildInfoField('Food Allergies:',
                                    _foodAllergies.isEmpty ? 'None' : _foodAllergies.join(', ')),
                                _buildInfoField('Dietary Preference:',
                                    _dietaryPreferences.isEmpty ? 'None' : _dietaryPreferences.join(', ')),
                                _buildInfoField('Favourite Cuisine:',
                                    _favouriteCuisines.isEmpty ? 'None' : _favouriteCuisines.join(', ')),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // 5. Emergency Contact (Second White Box)
                            _buildSection(
                              title: 'Emergency Contact',
                              children: [
                                _buildInfoField('Name:', _emergencyName),
                                _buildInfoField('Contact Number:', _emergencyPhoneNumber),
                                _buildInfoField('Email Address:', _emergencyEmail),
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

      // 6. Bottom Navigation Bar
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

  // Helper method to build a section with a shadow
  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF852745),
            ),
          ),
        if (title.isNotEmpty) const SizedBox(height: 10),
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
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        if (title.isEmpty) ...children,
      ],
    );
  }

  // Helper method to build an info field with a label and value
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

// Placeholder for HomePage (already defined in your previous code)
// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home'),
//       ),
//       body: const Center(child: Text('Home Page')),
//     );
//   }
// }

// Placeholder for TestPage (already defined in your previous code)
// class TestPage extends StatelessWidget {
//   final String location;
//   const TestPage({super.key, required this.location});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(location),
//       ),
//       body: const Center(child: Text('AI Chat Page')),
//     );
//   }
// }

// // Placeholder for ApplicationPage (already defined in your previous code)
// class ApplicationPage extends StatelessWidget {
//   const ApplicationPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Applications'),
//       ),
//       body: const Center(child: Text('Application Page')),
//     );
//   }
// }

// Placeholder for DietPage (already defined in your previous code)
class DietPage extends StatelessWidget {
  const DietPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            User? user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .update({
                'carePoints': FieldValue.increment(1),
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Diet recorded! Care Points updated.')),
              );
            }
          },
          child: const Text('Record Diet'),
        ),
      ),
    );
  }
}