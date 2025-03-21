import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roti_planta/pages/home_page.dart';
import 'package:roti_planta/pages/signup_page.dart'; // Import SignUpPage for navigation
//import 'package:roti_planta/pages/test_page.dart'; // Import ShowPage for navigation

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _signIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Sign in with email and password using Firebase Authentication
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful!')),
        );

        // Navigate to ShowPage with location 'home'
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false,
        );

      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Resize to avoid keyboard overlap
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
              padding: EdgeInsets.only(top: 80, left: 18, right: 18, bottom: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: 10),
                      Image.asset('assets/images/Logo.png', height: 150),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome\nBack',
                            style: TextStyle(
                              fontSize: 47,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF852745),
                              height: 1.0,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Hey! Good to see you again',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF852745),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Card(
                    elevation: 7.0, // Shadow for the card
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    color: Color(0xFFFFE5D9),
                    child: Padding(
                      padding: EdgeInsets.only(top: 35, left: 25, right: 25, bottom: 15),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
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
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      // Placeholder for "Forget password?" functionality
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Forget password functionality coming soon!')),
                                      );
                                    },
                                    child: Text(
                                      'Forget password?',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: _signIn, // Triggers _signIn when clicked
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF852745),
                              padding: EdgeInsets.symmetric(horizontal: 90, vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 4.0,
                            ),
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SignUpPage()),
                              );
                            },
                            child: Text(
                              'Don\'t have an account? Sign up',
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}