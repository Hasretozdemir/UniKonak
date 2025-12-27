import 'package:flutter/material.dart';
import 'constants.dart';

enum AppThemeType { light, dark, custom }

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.white,
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
          color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppConstants.primaryBackgroundColor,
      secondary: AppConstants.accentColor,
      surface: Colors.white,
      onSurface: Colors.black87,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppConstants.accentColor,
      unselectedItemColor: Colors.grey,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    scaffoldBackgroundColor: Colors.black,
    cardColor: const Color(0xFF1C1C1E),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      secondary: AppConstants.accentColor,
      surface: const Color(0xFF1C1C1E),
      onSurface: Colors.white,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
      selectedItemColor: AppConstants.accentColor,
      unselectedItemColor: Colors.grey,
    ),
  );

  static final ThemeData customTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppConstants.primaryBackgroundColor,
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: AppConstants.primaryBackgroundColor),
      titleTextStyle: TextStyle(
          color: AppConstants.primaryBackgroundColor,
          fontSize: 22,
          fontWeight: FontWeight.bold),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppConstants.primaryBackgroundColor,
      secondary: AppConstants.accentColor,
      surface: Colors.white,
      onSurface: Colors.black87,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.grey.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppConstants.primaryBackgroundColor,
      unselectedItemColor: Colors.grey,
      elevation: 10,
    ),
  );
}

class ThemeNotifier extends ValueNotifier<ThemeData> {
  ThemeNotifier(super.value);

  void setTheme(AppThemeType type) {
    switch (type) {
      case AppThemeType.light:
        value = AppTheme.lightTheme;
        break;
      case AppThemeType.dark:
        value = AppTheme.darkTheme;
        break;
      case AppThemeType.custom:
        value = AppTheme.customTheme;
        break;
    }
  }
}
