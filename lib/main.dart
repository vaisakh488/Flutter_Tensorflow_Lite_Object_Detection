import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'splash.dart';

void main() async {
  // Ensure all Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Open a default box (optional, but common)
  await Hive.openBox('appBox');

  // Run the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trace Mind',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}