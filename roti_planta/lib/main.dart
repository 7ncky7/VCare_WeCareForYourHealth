// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:roti_planta/firebase_options.dart';
// import 'package:roti_planta/pages/landing_page.dart';


// Future<void> main() async{
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: LandingPage()
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:roti_planta/pages/editinfo_page.dart';
// import 'package:roti_planta/pages/home_page.dart';
import 'package:roti_planta/pages/landing_page.dart';
// import 'package:roti_planta/pages/profile_page.dart';
// import 'package:roti_planta/pages/signin_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double _fontScale = 1.0; // Default to medium
  Locale _locale = Locale('en'); // Default to English

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
        String fontSize = doc['fontSize'] ?? 'medium';
        String language = doc['language'] ?? 'en';
        setState(() {
          _fontScale = fontSize == 'small' ? 0.8 : fontSize == 'large' ? 1.2 : 1.0;
          _locale = Locale(language);
        });
      }
    }
    // Listen for auth state changes to update settings
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen((doc) {
          if (doc.exists) {
            String fontSize = doc['fontSize'] ?? 'medium';
            String language = doc['language'] ?? 'en';
            setState(() {
              _fontScale = fontSize == 'small' ? 0.8 : fontSize == 'large' ? 1.2 : 1.0;
              _locale = Locale(language);
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roti Planta',
      locale: _locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'), // English
        Locale('ms'), // Malay
        Locale('zh'), // Chinese
      ],
      theme: ThemeData(
        primaryColor: Color(0xFF852745),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.pink,
        ).copyWith(
          primary: Color(0xFF852745),
          secondary: Color(0xFFD59FA6),
          background: Colors.white,
          surface: Color(0xFFFFE5D9),
          onPrimary: Colors.white,
          onSecondary: Color(0xFF852745),
          onSurface: Color(0xFF852745),
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 40 * _fontScale, // Adjusted for font scaling
            fontWeight: FontWeight.w900,
            color: Color(0xFF852745),
          ),
          bodyMedium: TextStyle(
            fontSize: 16 * _fontScale,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
          titleMedium: TextStyle(
            fontSize: 18 * _fontScale,
            fontWeight: FontWeight.bold,
            color: Color(0xFF852745),
          ),
          labelSmall: TextStyle(
            fontSize: 14 * _fontScale,
            color: Colors.grey[700],
          ),
          bodySmall: TextStyle(
            fontSize: 14 * _fontScale,
            color: Color(0xFF852745),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF852745),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 90, vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4.0,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[700],
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: Color(0xFF852745)),
        ),
      ),
      home: LandingPage(),
      //home: HomePage(),
      //home: ProfilePage(),
    );
  }
}