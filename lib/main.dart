import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ujikom/firebase_options.dart';
import 'package:ujikom/layout/login.dart';
import 'package:ujikom/rules/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: cPrimary,
      ),
      home: Login(),
    );
  }
}
