import 'package:expeness/pages/expense_page.dart';
import 'package:expeness/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ColorSchemeSeed = const Color.fromRGBO(0, 00, 255, 255);

  Future<void> _signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
    } catch (e) {
      print("Error signing in anonymously: $e");
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    _signInAnonymously();
    return MaterialApp(
      title: 'Expenses',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: ColorSchemeSeed,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: ColorSchemeSeed,
      ),
      themeMode: ThemeMode.system,
      routes: {
        '': (context) => const HomePage(),
        '/expense': (context) => const ExpensePage(),
      },
      home: const HomePage(),
    );
  }
}
