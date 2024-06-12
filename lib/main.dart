import 'package:expeness/pages/expense_page.dart';
import 'package:expeness/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

Future<void> _signInAnonymously() async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  try {
    await _auth.signInAnonymously();
  } catch (e) {
    print("Error signing in anonymously: $e");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _signInAnonymously();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ColorSchemeSeed = const Color.fromRGBO(0, 00, 255, 255);

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
      // routes: {
      //   '': (context) => const HomePage(),
      //   '/expense': (context) => const ExpensePage(),
      // },
      onGenerateRoute: (settings) {
        if (settings.name == '/expense') {
          return PageRouteBuilder(
              settings: settings, // Pass this to make popUntil(), pushNamedAndRemoveUntil(), works
              pageBuilder: (_, __, ___) => const ExpensePage(),
              transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c)
          );
        }
        // Unknown route
        return MaterialPageRoute(builder: (_) => const HomePage());
      },
      home: const HomePage(),
    );
  }
}
