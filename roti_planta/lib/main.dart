import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:roti_planta/firebase_options.dart';
import 'package:roti_planta/pages/landing_page.dart';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LandingPage()
    );
  }
}
