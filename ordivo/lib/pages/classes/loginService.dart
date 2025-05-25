import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ordivo/pages/home.dart';
import 'package:ordivo/pages/login.dart';

class Loginservice {
  static Future<void> loginUser(BuildContext context, String email, String password) async {
    final response = await http.post(
      Uri.parse('https://shachar.online:3000/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email,
        "password": password
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      String token = data['token'];
      String firstname = data['firstname'];
      String lastname = data['lastname'];
      bool isAdmin = data['is_admin'] ?? false;
      await saveToken(token, firstname, lastname, isAdmin);
      showSnackbar(context, data['message'], Colors.green);
      // מעבר לעמוד הבית לאחר התחברות מוצלחת
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      showSnackbar(context, data['message'], Colors.red);
    }
  }

  static Future<void> saveToken(String token, String firstname, String lastname, bool isAdmin) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('firstname', firstname);
    await prefs.setString('lastname', lastname);
    await prefs.setBool('is_admin', isAdmin);
  }
  
  static void showSnackbar(BuildContext context, String message, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      duration: Duration(seconds: 2),
    ),
  );
}

  static Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // מוחק את הטוקן
    
    // מעבר למסך ההתחברות ומניעת חזרה לאחור
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Login()),);
  }

}