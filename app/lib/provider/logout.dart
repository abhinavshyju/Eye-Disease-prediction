import 'package:app/features/auth/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Logout {
  static Future<void> logout(BuildContext context) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();

    await pref.clear();

    // Navigate to the login screen
    Navigator.pushAndRemoveUntil(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false, // This removes all previous routes
    );
  }
}
