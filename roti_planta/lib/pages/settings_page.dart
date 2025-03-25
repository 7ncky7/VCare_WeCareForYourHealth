import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:roti_planta/pages/profile_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _fontSize = 2; // Slider value (1: small, 2: medium, 3: large)
  bool _isDarkTheme = false; // Default to Light theme
  String _language = 'en'; // Default language (English)

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load user settings from Firestore
  void _loadSettings() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          _fontSize = (doc['fontSize'] ?? 2).toDouble(); // Default to medium (2)
          _isDarkTheme = doc['theme'] == 'dark';
          _language = doc['language'] ?? 'en';
        });
      }
    }
  }

  // Save settings to Firestore
  void _saveSettings() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'fontSize': _fontSize.round(),
        'theme': _isDarkTheme ? 'dark' : 'light',
        'language': _language,
      }, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.settingsSaved ?? 'Settings saved!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF852745)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          },
        ),
        backgroundColor: Color(0xFFD59FA6),
        elevation: 0,
      ),
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
            // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            padding: const EdgeInsets.only(top: 0, bottom: 0, left: 25, right: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title: "Settings" with gear icon
                Row(
                  children: [
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.settings,
                      color: Color(0xFF852745),
                      size: 45,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      localizations?.settings ?? 'Settings',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: const Color(0xFF852745),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Font Size Section
                        _buildSection(
                          title: localizations?.fontSize ?? 'Font Size',
                          child: Row(
                            children: [
                              Text(localizations?.fontSizeSmall ?? 'Small'),
                              Expanded(
                                child: Slider(
                                  value: _fontSize,
                                  min: 1,
                                  max: 3,
                                  divisions: 2,
                                  label: _fontSize == 1
                                      ? localizations?.fontSizeSmall ?? 'Small'
                                      : _fontSize == 2
                                          ? localizations?.fontSizeMedium ?? 'Medium'
                                          : localizations?.fontSizeLarge ?? 'Large',
                                  onChanged: (value) {
                                    setState(() {
                                      _fontSize = value;
                                    });
                                  },
                                ),
                              ),
                             Text(localizations?.fontSizeLarge ?? 'Large'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Theme Section
                        _buildSection(
                          title: localizations?.theme ?? 'Theme',
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.wb_sunny, size: 30),
                                color: !_isDarkTheme ? const Color(0xFF852745) : Colors.grey,
                                onPressed: () {
                                  setState(() {
                                    _isDarkTheme = false;
                                  });
                                },
                              ),
                              const SizedBox(width: 20),
                              IconButton(
                                icon: const Icon(Icons.nightlight_round, size: 30),
                                color: _isDarkTheme ? const Color(0xFF852745) : Colors.grey,
                                onPressed: () {
                                  setState(() {
                                    _isDarkTheme = true;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Language Section
                        _buildSection(
                          title: localizations?.language ?? 'Language',
                          child: Column(
                            children: [
                              CheckboxListTile(
                                title: Text(localizations?.languageEnglish ?? 'English'),
                                value: _language == 'en',
                                onChanged: (value) {
                                  if (value == true) {
                                    setState(() {
                                      _language = 'en';
                                    });
                                  }
                                },
                                activeColor: const Color(0xFF852745),
                              ),
                              CheckboxListTile(
                                title: Text(localizations?.languageMalay ?? 'Malay'),
                                value: _language == 'ms',
                                onChanged: (value) {
                                  if (value == true) {
                                    setState(() {
                                      _language = 'ms';
                                    });
                                  }
                                },
                                activeColor: const Color(0xFF852745),
                              ),
                              CheckboxListTile(
                                title: Text(localizations?.languageChinese ?? 'Chinese'),
                                value: _language == 'zh',
                                onChanged: (value) {
                                  if (value == true) {
                                    setState(() {
                                      _language = 'zh';
                                    });
                                  }
                                },
                                activeColor: const Color(0xFF852745),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Submit Button
                        Center(
                          child: ElevatedButton(
                            onPressed: _saveSettings,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF852745),
                              foregroundColor: Colors.white,
                              // padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                              padding: const EdgeInsets.only(top: 15, bottom: 15, left: 90, right: 90),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              localizations?.submit ?? 'Submit',
                              style: const TextStyle(fontSize: 20),
                            ),
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
    );
  }

  // Helper method to build a section with a shadow
  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFE5D9),
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
      //padding: const EdgeInsets.all(15),
      padding: const EdgeInsets.only(top: 15, bottom: 15, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF852745),
              decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}