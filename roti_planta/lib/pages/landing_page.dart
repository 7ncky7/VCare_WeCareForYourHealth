import 'package:flutter/material.dart';
import 'package:roti_planta/pages/signin_page.dart';
import 'package:roti_planta/pages/signup_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

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
        child: Center(
          child: Card(
            elevation: 7.0, // Shadow for the card
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            color: Color(0xFFFFECE9), // Peach color for the card
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 45, vertical: 35),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Ensures the card size fits content
                children: [
                  Image.asset(
                    'assets/images/Logo with Name and Slogan.png', // Replace with your actual logo path
                    height: 250,
                  ),
                  SizedBox(height: 35),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignInPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF852745),
                      padding: EdgeInsets.symmetric(horizontal: 90, vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4.0,  // Shadow for the button
                    ),
                    child: Text(
                      'Sign In',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 255, 255, 255),),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF852745),
                      padding: EdgeInsets.symmetric(horizontal: 90, vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4.0, // Shadow for the button
                    ),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 255, 255, 255),),
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
}
