import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;
  
  // Constructor loads saved theme
  ThemeProvider() {
    _loadThemeFromPrefs();
  }
  
  // Load theme preference from storage
  Future<void> _loadThemeFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? true; // Default to dark mode
    notifyListeners();
  }
  
  // Save theme preference to storage
  Future<void> _saveThemeToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
  }
  
  // Toggle between light and dark theme
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemeToPrefs();
    notifyListeners();
  }
  
  // Get appropriate theme data
  ThemeData getTheme() {
    return _isDarkMode 
        ? ThemeData.dark().copyWith(
            primaryColor: const Color(0xffedb41d),
            colorScheme: const ColorScheme.dark().copyWith(
              primary: const Color(0xffedb41d),
              secondary: const Color(0xffedb41d),
            ),
            scaffoldBackgroundColor: Colors.black,
          )
        : ThemeData.light().copyWith(
            primaryColor: const Color(0xffedb41d),
            colorScheme: const ColorScheme.light().copyWith(
              primary: const Color(0xffedb41d),
              secondary: const Color(0xffedb41d),
            ),
            scaffoldBackgroundColor: Colors.white,
          );
  }
}