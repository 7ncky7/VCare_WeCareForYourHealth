import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:vcare_test/pages/test_page.dart';
import 'package:intl/intl.dart';
import 'package:roti_planta/pages/signin_page.dart'; // For formatting the date

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  String? _gender;  // Updated to use a string variable for the dropdown
  DateTime? _selectedDate;  // To store the selected date
  final _dateOfBirthController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {  // Function to show the date picker
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900), // Allow dates from 1900
      lastDate: DateTime.now(), // Up to the current date
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateOfBirthController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text == _confirmPasswordController.text) {
        try {
          // Create user with email and password in Firebase Authentication
          UserCredential userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

          await Future.delayed(Duration(milliseconds: 250));  // Add delay to allow Firestore to initialize
          // Store additional user data in Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'fullName': _fullNameController.text.trim(),
            'gender': _gender,
            //'dateOfBirth': _selectedDate != null ? _selectedDate!.toIso8601String() : null,
            'dateOfBirth': _selectedDate?.toIso8601String(), // Store date as ISO string
            'email': _emailController.text.trim(),
            'carePoints': 0,
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration successful!')),
          );

          // Navigate back to the landing page
          //Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SignInPage()),
          );

        } catch (e) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Passwords do not match!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD59FA6), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SizedBox( // Ensure the Container fills the screen height
          height: MediaQuery.of(context).size.height, // Full screen height
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Row(
                    children: [
                      SizedBox(width: 10),
                      Image.asset('assets/images/Logo.png', height: 150),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF852745),
                            ),
                          ),
                          Text(
                            'Hello! Let\'s join with us',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF852745),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Column(
                    children: [
                      SingleChildScrollView(
                        child: Card(
                          elevation: 7.0, // Shadow for the card
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          color: Color(0xFFFFE5D9),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                            child: Column(
                              mainAxisSize: MainAxisSize.min, // Ensures the card size fits content
                              children: [
                                // Scrollable section for text fields
                                Flexible(
                                  child: SingleChildScrollView(
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        children: [
                                          TextFormField(
                                            controller: _fullNameController,
                                            decoration: InputDecoration(
                                              labelText: 'Full Name',
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              filled: true,  // Fill the text field with a background color
                                              fillColor: Colors.white,
                                            ),
                                            validator: (value) =>
                                                value!.isEmpty ? '* Please enter your full name' : null,
                                          ),
                                          SizedBox(height: 15),
                                          DropdownButtonFormField<String>(
                                            value: _gender,
                                            decoration: InputDecoration(
                                              labelText: 'Gender',
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                            ),
                                            items: <String>['Male', 'Female']
                                                .map<DropdownMenuItem<String>>((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,  // Store the value in the dropdown
                                                child: Text(value),  // Display the value in the dropdown
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                _gender = newValue;
                                              });
                                            },
                                            validator: (value) =>
                                                value == null ? '* Please select your gender' : null,
                                          ),
                                          SizedBox(height: 15),
                                          TextFormField(
                                            controller: _dateOfBirthController,
                                            readOnly: true, // Prevent manual text input
                                            onTap: () => _selectDate(context),
                                            decoration: InputDecoration(
                                              labelText: 'Date of Birth',
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                              suffixIcon: Icon(Icons.calendar_today),
                                            ),
                                            validator: (value) =>
                                                value!.isEmpty ? '* Please select your date of birth' : null,
                                          ),
                                          SizedBox(height: 15),
                                          TextFormField(
                                            controller: _emailController,
                                            decoration: InputDecoration(
                                              labelText: 'Email Address',
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                            ),
                                            validator: (value) =>
                                                value!.isEmpty ? '* Please enter your email' : null,
                                          ),
                                          SizedBox(height: 15),
                                          TextFormField(
                                            controller: _passwordController,
                                            decoration: InputDecoration(
                                              labelText: 'Password',
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                            ),
                                            obscureText: true,
                                            validator: (value) =>
                                                value!.isEmpty ? '* Please enter your password' : null,
                                          ),
                                          SizedBox(height: 15),
                                          TextFormField(
                                            controller: _confirmPasswordController,
                                            decoration: InputDecoration(
                                              labelText: 'Confirm Password',
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                            ),
                                            obscureText: true,
                                            validator: (value) =>
                                                value!.isEmpty ? '* Please enter your confirm password' : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 50),
                                // Submit button (fixed at the bottom)
                                ElevatedButton(
                                  onPressed: _signUp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF852745),
                                    padding: EdgeInsets.symmetric(horizontal: 90, vertical: 13),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 4.0, // Shadow for the button
                                  ),
                                  child: Text(
                                    'Submit',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                // Sign In link (fixed)
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => SignInPage()),
                                    );
                                  },
                                  child: Text(
                                    'Already have an account? Sign In',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dateOfBirthController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}