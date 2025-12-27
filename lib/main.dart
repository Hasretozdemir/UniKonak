import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'screens/home_screen.dart';

import 'screens/profile_screen.dart';

import 'utils/app_theme.dart';

final ThemeNotifier themeNotifier = ThemeNotifier(AppTheme.darkTheme);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeData>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, child) {
        return MaterialApp(
          title: 'ÜNİKONAK',
          debugShowCheckedModeBanner: false,
          theme: currentTheme,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasData) {
                return const UniKonakHome();
              }

              return const AuthScreen();
            },
          ),
        );
      },
    );
  }
}
