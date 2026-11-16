import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'helpers/shared_pref_helper.dart';
import 'screens/login_screen.dart';
import 'screens/main_nav_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final bool isLoggedIn = await SharedPrefHelper.isLoggedIn();

  runApp(ResponsiApp(isLoggedIn: isLoggedIn));
}

class ResponsiApp extends StatelessWidget {
  final bool isLoggedIn;
  const ResponsiApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi SpaceNews Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 90, 75, 255),
          brightness: Brightness.light,
        ),
      ),

      home: isLoggedIn ? const MainNavScreen() : const LoginScreen(),
    );
  }
}
