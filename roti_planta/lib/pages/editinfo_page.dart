import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    'Meal': false,
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
          'gender': 'Male', // Default value (standardized key)
          'dateOfBirth': null,
          'age': null,
          'email': user.email, // Use the email from Firebase Auth if available

          // Health Details
          'weight': 0.0,
          'height': 0.0,
          'glucoseLevel': 0.0,
          'familyHistory': null,
          'activityLevel': 'Inactive', // Default value (standardized key)
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
            String locale = AppLocalizations.of(context)?.localeName ?? 'en';
            _dateOfBirthController.text = DateFormat.yMd(locale).format(_dateOfBirth!);
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
        String locale = AppLocalizations.of(context)?.localeName ?? 'en';
        _dateOfBirthController.text = DateFormat.yMd(locale).format(picked);
        _age = DateTime.now().year - picked.year;
      });
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

  // Helper method to get standardized key from localized string
  String _getStandardizedKey(String localizedValue, Map<String, String> map) {
    final localizations = AppLocalizations.of(context);
    for (var entry in map.entries) {
      String localizedString = _getLocalizedString(entry.key, map, entry.key);
      if (localizedString == localizedValue) {
        return entry.key;
      }
    }
    return localizedValue; // Fallback to the localized value if no match is found
  }

  // Save updated data to Firestore
  void _saveData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
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
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations?.infoUpdatedSuccess ?? 'Information updated successfully!')),
        );

        // Navigate back to ProfilePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
      } catch (e) {
        print("Error saving data: $e");
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations?.errorSavingData ?? 'Error saving data. Please try again.')),
        );
      }
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
            padding: const EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Icon and "Edit" Title
                Row(
                  children: [
                    const SizedBox(width: 30),
                    const Icon(
                      Icons.edit,
                      color: Color(0xFF852745),
                      size: 45,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      localizations?.edit ?? 'Edit',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: const Color(0xFF852745),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),

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
                        padding: const EdgeInsets.only(top: 18, bottom: 20, left: 20, right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 3. First White Box: Personal Information
                            _buildSection(
                              title: localizations?.personalInformation ?? 'Personal Information',
                              children: [
                                _buildInfoField(localizations?.fullName ?? 'Full Name:', _fullNameController),
                                _buildRadioField(
                                  title: localizations?.gender ?? 'Gender:',
                                  value: _gender,
                                  options: [
                                    _getLocalizedString('Male', _genderMap, 'Male'),
                                    _getLocalizedString('Female', _genderMap, 'Female'),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _gender = _getStandardizedKey(value!, _genderMap);
                                    });
                                  },
                                ),
                                _buildInfoField(localizations?.age ?? 'Age:', null, value: _age?.toString() ?? 'None', enabled: false),
                                _buildInfoField(localizations?.dateOfBirth ?? 'Date of Birth:', _dateOfBirthController, onTap: () => _selectDate(context)),
                                _buildInfoField(localizations?.emailAddress ?? 'Email Address:', _emailController),
                              ],
                            ),
                            const SizedBox(height: 30),

                            // 4. Second White Box: Health Details
                            _buildSection(
                              title: localizations?.healthDetails ?? 'Health Details',
                              children: [
                                _buildInfoField(localizations?.weight ?? 'Weight (kg):', _weightController),
                                _buildInfoField(localizations?.height ?? 'Height (cm):', _heightController),
                                _buildInfoField(localizations?.familyHistory ?? 'Family History:', _familyHistoryController),
                                _buildRadioField(
                                  title: localizations?.activityLevel ?? 'Activity Level:',
                                  value: _activityLevel,
                                  options: [
                                    _getLocalizedString('Inactive', _activityLevelMap, 'Inactive'),
                                    _getLocalizedString('Sedentary', _activityLevelMap, 'Sedentary'),
                                    _getLocalizedString('Moderately active', _activityLevelMap, 'Moderately active'),
                                    _getLocalizedString('Vigorously active', _activityLevelMap, 'Vigorously active'),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _activityLevel = _getStandardizedKey(value!, _activityLevelMap);
                                    });
                                  },
                                  isColumn: true,
                                ),
                                _buildCheckboxField(
                                  title: localizations?.foodAllergies ?? 'Food Allergies:',
                                  options: _foodAllergies,
                                  onChanged: (key, value) {
                                    setState(() {
                                      _foodAllergies[key] = value;
                                    });
                                  },
                                  displayMap: _foodAllergiesMap,
                                ),
                                _buildCheckboxField(
                                  title: localizations?.dietaryPreference ?? 'Dietary Preference:',
                                  options: _dietaryPreferences,
                                  onChanged: (key, value) {
                                    setState(() {
                                      _dietaryPreferences[key] = value;
                                    });
                                  },
                                  displayMap: _dietaryPreferencesMap,
                                ),
                                _buildCheckboxField(
                                  title: localizations?.favouriteCuisine ?? 'Favourite Cuisine:',
                                  options: _favouriteCuisines,
                                  onChanged: (key, value) {
                                    setState(() {
                                      _favouriteCuisines[key] = value;
                                    });
                                  },
                                  displayMap: _favouriteCuisinesMap,
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),

                            // 5. Third White Box: Emergency Contact
                            _buildSection(
                              title: localizations?.emergencyContact ?? 'Emergency Contact',
                              children: [
                                _buildInfoField(localizations?.emergencyName ?? 'Name:', _emergencyNameController),
                                _buildInfoField(localizations?.emergencyContactNumber ?? 'Contact Number:', _emergencyContactController),
                                _buildInfoField(localizations?.emergencyEmailAddress ?? 'Email Address:', _emergencyEmailController),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Center(
                              child: ElevatedButton(
                                onPressed: _saveData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF852745),
                                  foregroundColor: Colors.white,
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
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 13, right: 13),
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
          const SizedBox(height: 5),
          ...children,
        ],
      ),
    );
  }

  // Helper method to build an info field with a label and editable text
  Widget _buildInfoField(String label, TextEditingController? controller, {VoidCallback? onTap, bool enabled = true, String? value}) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 5, left: 3, right: 3),
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
      padding: const EdgeInsets.only(top: 0, bottom: 5, left: 3, right: 3),
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
          isColumn
              ? Column(
                  children: options.map((option) {
                    return Row(
                      children: [
                        Radio<String>(
                          value: option,
                          groupValue: value != null ? _getLocalizedString(value, isColumn ? _activityLevelMap : _genderMap, value) : null,
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
                          groupValue: value != null ? _getLocalizedString(value, isColumn ? _activityLevelMap : _genderMap, value) : null,
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
    required Map<String, String> displayMap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5, left: 3, right: 3),
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
          Column(
            children: _buildCheckboxRows(options, onChanged, displayMap),
          ),
        ],
      ),
    );
  }

  // Helper method to build checkbox rows (2 items per row)
  List<Widget> _buildCheckboxRows(Map<String, bool> options, Function(String, bool) onChanged, Map<String, String> displayMap) {
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
                  Text(_getLocalizedString(keys[i], displayMap, keys[i])),
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
                    Text(_getLocalizedString(keys[i + 1], displayMap, keys[i + 1])),
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