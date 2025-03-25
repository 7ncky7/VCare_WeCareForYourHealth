import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:roti_planta/pages/landing_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Enable Firestore offline persistence
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double _fontScale = 1.0; // Default to medium
  Locale _locale = Locale('en'); // Default to English
  bool _isLoading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load user settings from Firestore
  void _loadSettings() async {
    try {
      // Wait for authentication state to resolve
      User? user = await FirebaseAuth.instance.authStateChanges().first;
      if (user == null) {
        print("No user logged in. Using default locale: $_locale");
        setState(() {
          _isLoading = false; // Stop loading
        });
        return;
      }

      print("Logged-in user UID: ${user.uid}"); // Log the UID

      // Initial fetch with retry mechanism
      DocumentSnapshot? doc;
      int retries = 3;
      for (int i = 0; i < retries; i++) {
        try {
          doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          break; // Success, exit the retry loop
        } catch (e) {
          print("Firestore fetch attempt ${i + 1} failed: $e");
          if (i == retries - 1) {
            print("All retries failed. Using default locale: $_locale");
            setState(() {
              _isLoading = false; // Stop loading
            });
            return;
          }
          await Future.delayed(Duration(seconds: 2)); // Wait before retrying
        }
      }

      if (doc != null && doc.exists && doc.data() != null) {
        // Handle fontSize, which might be an int
        var fontSizeValue = doc['fontSize'] ?? 'medium';
        String fontSize = fontSizeValue is String
            ? fontSizeValue
            : fontSizeValue.toString(); // Convert int to String if necessary
        String language = doc['language'] ?? 'en';
        print("Initial fetch - UID: ${user.uid}, fontSize: $fontSize, language: $language");

        setState(() {
          _fontScale = fontSize == 'small' ? 0.8 : fontSize == 'large' ? 1.2 : 1.0;
          _locale = Locale(language);
          _isLoading = false; // Stop loading
          print("Locale updated to: $_locale");
        });
      } else {
        print("No document found for UID: ${user.uid}. Using default locale: $_locale");
        setState(() {
          _isLoading = false; // Stop loading
        });
      }

      // Real-time listener for updates
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((doc) {
        if (doc.exists && doc.data() != null) {
          // Handle fontSize, which might be an int
          var fontSizeValue = doc['fontSize'] ?? 'medium';
          String fontSize = fontSizeValue is String
              ? fontSizeValue
              : fontSizeValue.toString(); // Convert int to String if necessary
          String language = doc['language'] ?? 'en';
          print("Real-time update - UID: ${user.uid}, fontSize: $fontSize, language: $language");

          setState(() {
            _fontScale = fontSize == 'small' ? 0.8 : fontSize == 'large' ? 1.2 : 1.0;
            _locale = Locale(language);
            print("Locale updated in real-time to: $_locale");
          });
        } else {
          print("Real-time: No document found for UID: ${user.uid}");
        }
      }, onError: (error) {
        print("Error listening to Firestore updates: $error");
      });
    } catch (e) {
      print("Error fetching settings: $e");
      setState(() {
        _isLoading = false; // Stop loading even if there's an error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(), // Show loading spinner
          ),
        ),
      );
    }

    print("Building MyApp with locale: $_locale, fontScale: $_fontScale");
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
            fontSize: 40 * _fontScale,
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
    );
  }
}