import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:roti_planta/pages/application_page.dart';
import 'package:roti_planta/pages/profile_page.dart';
// import 'package:roti_planta/pages/settings_page.dart';
import 'package:roti_planta/pages/test_page.dart';
import 'package:url_launcher/url_launcher.dart'; // For initiating calls and emails

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _familyName = "Loading...";
  String _greeting = "Loading...";
  int _carePoints = 0;
  int _currentIndex = 0;
  String? _emergencyPhoneNumber;
  String? _emergencyEmail;

  @override
  void initState() {
    super.initState();
    _fetchFamilyName();
    _fetchCarePoints();
    _fetchEmergencyContact();
  }

  // Fetch user's family name from Firestore
  void _fetchFamilyName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          _familyName = doc['fullName'].split(' ').last;
        });
      }
    }
  }

  // Fetch care points from Firestore
  void _fetchCarePoints() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && doc['carePoints'] != null) {
        setState(() {
          _carePoints = doc['carePoints'];
        });
      }
    }
  }

  // Fetch emergency contact details (phone and email) from Firestore
  void _fetchEmergencyContact() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          _emergencyPhoneNumber = doc['emergencyPhoneNumber'] ?? '1234567890'; // Default for testing
          _emergencyEmail = doc['emergencyEmail'] ?? 'emergency@example.com'; // Default for testing
        });
      }
    }
  }

  // Set greeting based on the time of day
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
      _greeting = "Good Morning"; // Fallback
    }
    setState(() {});
  }

  // Handle bottom navigation bar taps
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 1) {
      // Navigate to AI Chat page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TestPage(location: 'AI Chat')),
      ).then((_) {
        setState(() {
          _currentIndex = 0;
        });
      });
    } else if (index == 2) {
      // Navigate to Application page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ApplicationPage()),
      ).then((_) {
        setState(() {
          _currentIndex = 0;
        });
      });
    } else if (index == 3) {
      // Navigate to Diet page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DietPage()),
      ).then((_) {
        _fetchCarePoints(); // Refresh care points when returning from Diet page
        setState(() {
          _currentIndex = 0;
        });
      });
    } else if (index == 4) {
      // Navigate to Profile page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      ).then((_) {
        setState(() {
          _currentIndex = 0;
        });
      });
    }
  }

  // Function to initiate a phone call
  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone call')),
      );
    }
  }

  // Function to send an email
  void _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Emergency Notification',
        'body': 'This is an emergency notification from Vcare Test.',
      },
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch email')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    String currentTime = DateFormat('HH:mm').format(DateTime.now());

    // Set greeting after the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setGreeting(context);
    });

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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Display Name, Greeting, and Care Points
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${localizations?.hi ?? 'Hi'} $_familyName',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            Text(
                              _greeting,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
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

                    // 2. Peach Card Box for Date, Time, and Health Metrics
                    Card(
                      elevation: 7.0,  // Shadow for the card
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: const Color(0xFFFFE5D9),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date and Time Row
                            Row(
                              children: [
                                Text(
                                  'Date: $currentDate',
                                  //style: Theme.of(context).textTheme.bodySmall,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const Spacer(),
                                Text(
                                  'Time: $currentTime',
                                  //style: Theme.of(context).textTheme.bodySmall,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),

                            // 3. Three White Boxes for Health Metrics
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,  //
                              children: [
                                _buildHealthBox(
                                  icon: 'assets/images/heartrate_icon.png',
                                  title: localizations?.heartRate ?? 'Heart Rate',
                                  value: 'N/A',
                                ),
                                SizedBox(height: 10),
                                _buildHealthBox(
                                  icon: 'assets/images/steps_icon.png',
                                  title: localizations?.steps ?? 'Walk Steps',
                                  value: 'N/A',
                                ),
                                SizedBox(height: 10),
                                _buildHealthBox(
                                  icon: 'assets/images/bloodpressure_icon.png',
                                  title: localizations?.bloodPressure ?? 'Blood Pressure',
                                  value: 'N/A',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 4. Peach Card Box for Emergency Button
                    Card(
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
                            Text(
                              localizations?.emergencyButton ?? 'Emergency Button',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 10),
                            // Row for Call and Email Boxes
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Call Box
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (_emergencyPhoneNumber != null) {
                                        _makePhoneCall(_emergencyPhoneNumber!);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('No emergency phone number available')),
                                        );
                                      }
                                    },
                                    child: Container(
                                      height: 100,
                                      margin: const EdgeInsets.only(right: 7.5), // Space between the two boxes
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            spreadRadius: 2,
                                            blurRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/phone_icon.png',
                                            height: 50,
                                            color: const Color(0xFF852745),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            localizations?.call ?? 'Call',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Email Box
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (_emergencyEmail != null) {
                                        _sendEmail(_emergencyEmail!);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('No emergency email available')),
                                        );
                                      }
                                    },
                                    child: Container(
                                      height: 100,
                                      margin: const EdgeInsets.only(left: 7.5), // Space between the two boxes
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            spreadRadius: 2,
                                            blurRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/message_icon.png',
                                            height: 50,
                                            color: const Color(0xFF852745),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            localizations?.email ?? 'Email',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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

      // 5. Bottom Navigation Bar
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

  // Widget for Health Metric Boxes
  Widget _buildHealthBox({required String icon, required String title, required String value}) {
    return Container(
      width: 350,
      height: 100,
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
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30.0, top: 10.0, right: 20.0, bottom: 10.0),
            child: Image.asset(
              icon,
              height: 80,
              color: const Color(0xFF852745),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,  //
              crossAxisAlignment: CrossAxisAlignment.center,  //
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF852745),
                  ),
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelSmall,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
