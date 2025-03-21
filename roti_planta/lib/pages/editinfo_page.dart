import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:roti_planta/pages/home_page.dart';
import 'package:intl/intl.dart';
import 'package:roti_planta/pages/profile_page.dart';

class EditInfoPage extends StatefulWidget {
  const EditInfoPage({super.key});

  @override
  _EditInfoPageState createState() => _EditInfoPageState();
}

class _EditInfoPageState extends State<EditInfoPage> {
  // Controllers for Personal Information
  final _fullNameController = TextEditingController();
  String? _gender;
  DateTime? _dateOfBirth;
  final _dateOfBirthController = TextEditingController();
  int? _age;
  final _emailController = TextEditingController();

  // Controllers for Health Details
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _glucoseLevelController = TextEditingController();
  final _familyHistoryController = TextEditingController();
  String? _activityLevel;
  final Map<String, bool> _foodAllergies = {
    'Milk': false,
    'Eggs': false,
    'Shellfish': false,
    'Nuts': false,
  };
  final Map<String, bool> _dietaryPreferences = {
    'Halal': false,
    'Vegan': false,
    'Vegetarian': false,
  };
  final Map<String, bool> _favouriteCuisines = {
    'Malay': false,
    'Japanese': false,
    'Chinese': false,
    'Korean': false,
    'Western': false,
    'Vietnamese': false,
  };

  // Controllers for Emergency Contact
  final _emergencyNameController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from Firestore and initialize if necessary
  void _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      
      DocumentSnapshot doc = await userDocRef.get();

      // If the document doesn't exist, initialize it with default values
      if (!doc.exists) {
        await userDocRef.set({
          // Personal Information
          'fullName': null,
          'gender': 'Male', // Default value
          'dateOfBirth': null,
          'age': null,
          'email': user.email, // Use the email from Firebase Auth if available

          // Health Details
          'weight': 0.0,
          'height': 0.0,
          'glucoseLevel': 0.0,
          'familyHistory': null,
          'activityLevel': 'Inactive', // Default value
          'foodAllergies': [],
          'dietaryPreferences': [],
          'favouriteCuisines': [],

          // Emergency Contact
          'emergencyName': null,
          'emergencyPhoneNumber': null,
          'emergencyEmail': null,
        });

        // Fetch the document again after initializing
        doc = await userDocRef.get();
      }

      // Load the data into the form
      if (doc.exists) {
        setState(() {
          // Personal Information
          _fullNameController.text = doc['fullName']?.toString().trim().isEmpty ?? true ? 'None' : doc['fullName'].toString();
          _gender = doc['gender'] ?? 'Male';
          if (doc['dateOfBirth'] != null) {
            _dateOfBirth = DateTime.parse(doc['dateOfBirth']);
            _dateOfBirthController.text = DateFormat('dd-MM-yyyy').format(_dateOfBirth!);
            _age = DateTime.now().year - _dateOfBirth!.year;
          } else {
            _dateOfBirthController.text = 'None';
            _age = null;
          }
          _emailController.text = doc['email']?.toString().trim().isEmpty ?? true ? 'None' : doc['email'].toString();

          // Health Details
          _weightController.text = doc['weight']?.toString() ?? '0.0';
          _heightController.text = doc['height']?.toString() ?? '0.0';
          _glucoseLevelController.text = doc['glucoseLevel']?.toString() ?? '0.0';
          _familyHistoryController.text = doc['familyHistory']?.toString().trim().isEmpty ?? true ? 'None' : doc['familyHistory'].toString();
          _activityLevel = doc['activityLevel'] ?? 'Inactive';
          if (doc['foodAllergies'] != null) {
            List<dynamic> allergies = doc['foodAllergies'];
            for (var allergy in allergies) {
              if (_foodAllergies.containsKey(allergy)) {
                _foodAllergies[allergy] = true;
              }
            }
          }
          if (doc['dietaryPreferences'] != null) {
            List<dynamic> preferences = doc['dietaryPreferences'];
            for (var preference in preferences) {
              if (_dietaryPreferences.containsKey(preference)) {
                _dietaryPreferences[preference] = true;
              }
            }
          }
          if (doc['favouriteCuisines'] != null) {
            List<dynamic> cuisines = doc['favouriteCuisines'];
            for (var cuisine in cuisines) {
              if (_favouriteCuisines.containsKey(cuisine)) {
                _favouriteCuisines[cuisine] = true;
              }
            }
          }

          // Emergency Contact
          _emergencyNameController.text = doc['emergencyName']?.toString().trim().isEmpty ?? true ? 'None' : doc['emergencyName'].toString();
          _emergencyContactController.text = doc['emergencyPhoneNumber']?.toString().trim().isEmpty ?? true ? 'None' : doc['emergencyPhoneNumber'].toString();
          _emergencyEmailController.text = doc['emergencyEmail']?.toString().trim().isEmpty ?? true ? 'None' : doc['emergencyEmail'].toString();
        });
      }
    }
  }

  // Select Date of Birth
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
        _dateOfBirthController.text = DateFormat('dd-MM-yyyy').format(picked);
        _age = DateTime.now().year - picked.year;
      });
    }
  }

  // Save updated data to Firestore
  void _saveData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        // Personal Information
        'fullName': _fullNameController.text == 'None' ? null : _fullNameController.text,
        'gender': _gender,
        'dateOfBirth': _dateOfBirth?.toIso8601String(),
        'age': _age,
        'email': _emailController.text == 'None' ? null : _emailController.text,

        // Health Details
        'weight': double.tryParse(_weightController.text) ?? 0.0,
        'height': double.tryParse(_heightController.text) ?? 0.0,
        'glucoseLevel': double.tryParse(_glucoseLevelController.text) ?? 0.0,
        'familyHistory': _familyHistoryController.text == 'None' ? null : _familyHistoryController.text,
        'activityLevel': _activityLevel,
        'foodAllergies': _foodAllergies.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList(),
        'dietaryPreferences': _dietaryPreferences.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList(),
        'favouriteCuisines': _favouriteCuisines.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList(),

        // Emergency Contact
        'emergencyName': _emergencyNameController.text == 'None' ? null : _emergencyNameController.text,
        'emergencyPhoneNumber': _emergencyContactController.text == 'None' ? null : _emergencyContactController.text,
        'emergencyEmail': _emergencyEmailController.text == 'None' ? null : _emergencyEmailController.text,
      }, SetOptions(merge: true));

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Information updated successfully!')),
      );

      // Navigate back to HomePage
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF852745)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          },
        ),
        backgroundColor: Colors.white,
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Icon and "Edit" Title
                Row(
                  children: [
                    const Icon(
                      Icons.edit,
                      color: Color(0xFF852745),
                      size: 30,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Edit',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: const Color(0xFF852745),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. Peach Box Containing Three White Boxes
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
                            // 3. First White Box: Personal Information
                            _buildSection(
                              title: 'Personal Information',
                              children: [
                                _buildInfoField('Full Name:', _fullNameController),
                                _buildRadioField(
                                  title: 'Gender:',
                                  value: _gender,
                                  options: const ['Male', 'Female'],
                                  onChanged: (value) {
                                    setState(() {
                                      _gender = value;
                                    });
                                  },
                                ),
                                _buildInfoField('Age:', null, value: _age?.toString() ?? 'None', enabled: false),
                                _buildInfoField('Date of Birth:', _dateOfBirthController, onTap: () => _selectDate(context)),
                                _buildInfoField('Email Address:', _emailController),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // 4. Second White Box: Health Details
                            _buildSection(
                              title: 'Health Details',
                              children: [
                                _buildInfoField('Weight (cm):', _weightController),
                                _buildInfoField('Height (cm):', _heightController),
                                // _buildInfoField('Glucose Level (mg/dL):', _glucoseLevelController),
                                _buildInfoField('Family History:', _familyHistoryController),
                                _buildRadioField(
                                  title: 'Activity Level:',
                                  value: _activityLevel,
                                  options: const ['Inactive', 'Sedentary', 'Moderately active', 'Vigorously active'],
                                  onChanged: (value) {
                                    setState(() {
                                      _activityLevel = value;
                                    });
                                  },
                                  isColumn: true,
                                ),
                                _buildCheckboxField(
                                  title: 'Food Allergies:',
                                  options: _foodAllergies,
                                  onChanged: (key, value) {
                                    setState(() {
                                      _foodAllergies[key] = value;
                                    });
                                  },
                                ),
                                _buildCheckboxField(
                                  title: 'Dietary Preference:',
                                  options: _dietaryPreferences,
                                  onChanged: (key, value) {
                                    setState(() {
                                      _dietaryPreferences[key] = value;
                                    });
                                  },
                                ),
                                _buildCheckboxField(
                                  title: 'Favourite Cuisine:',
                                  options: _favouriteCuisines,
                                  onChanged: (key, value) {
                                    setState(() {
                                      _favouriteCuisines[key] = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // 5. Third White Box: Emergency Contact
                            _buildSection(
                              title: 'Emergency Contact',
                              children: [
                                _buildInfoField('Name:', _emergencyNameController),
                                _buildInfoField('Contact Number:', _emergencyContactController),
                                _buildInfoField('Email Address:', _emergencyEmailController),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 6. Submit Button
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF852745),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(fontSize: 16),
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
  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
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
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF852745),
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  // Helper method to build an info field with a label and editable text
  Widget _buildInfoField(String label, TextEditingController? controller, {VoidCallback? onTap, bool enabled = true, String? value}) {
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
            child: controller != null
                ? TextField(
                    controller: controller,
                    enabled: enabled,
                    onTap: onTap,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  )
                : Text(
                    value ?? 'None',
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

  // Helper method to build a radio button field (with option for row or column layout)
  Widget _buildRadioField({
    required String title,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    bool isColumn = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF852745),
            ),
          ),
          const SizedBox(height: 5),
          isColumn
              ? Column(
                  children: options.map((option) {
                    return Row(
                      children: [
                        Radio<String>(
                          value: option,
                          groupValue: value,
                          onChanged: onChanged,
                          activeColor: const Color(0xFF852745),
                        ),
                        Text(option),
                      ],
                    );
                  }).toList(),
                )
              : Row(
                  children: options.map((option) {
                    return Row(
                      children: [
                        Radio<String>(
                          value: option,
                          groupValue: value,
                          onChanged: onChanged,
                          activeColor: const Color(0xFF852745),
                        ),
                        Text(option),
                        const SizedBox(width: 10),
                      ],
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  // Helper method to build a checkbox field (aligned in columns)
  Widget _buildCheckboxField({
    required String title,
    required Map<String, bool> options,
    required Function(String, bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF852745),
            ),
          ),
          const SizedBox(height: 5),
          Column(
            children: _buildCheckboxRows(options, onChanged),
          ),
        ],
      ),
    );
  }

  // Helper method to build checkbox rows (2 items per row)
  List<Widget> _buildCheckboxRows(Map<String, bool> options, Function(String, bool) onChanged) {
    List<Widget> rows = [];
    List<String> keys = options.keys.toList();
    for (int i = 0; i < keys.length; i += 2) {
      rows.add(
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Checkbox(
                    value: options[keys[i]],
                    onChanged: (value) {
                      onChanged(keys[i], value!);
                    },
                    activeColor: const Color(0xFF852745),
                  ),
                  Text(keys[i]),
                ],
              ),
            ),
            if (i + 1 < keys.length) // Check if there's a second item
              Expanded(
                child: Row(
                  children: [
                    Checkbox(
                      value: options[keys[i + 1]],
                      onChanged: (value) {
                        onChanged(keys[i + 1], value!);
                      },
                      activeColor: const Color(0xFF852745),
                    ),
                    Text(keys[i + 1]),
                  ],
                ),
              ),
          ],
        ),
      );
    }
    return rows;
  }

  @override
  void dispose() {
    // Dispose of all controllers
    _fullNameController.dispose();
    _dateOfBirthController.dispose();
    _emailController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _glucoseLevelController.dispose();
    _familyHistoryController.dispose();
    _emergencyNameController.dispose();
    _emergencyContactController.dispose();
    _emergencyEmailController.dispose();
    super.dispose();
  }
}