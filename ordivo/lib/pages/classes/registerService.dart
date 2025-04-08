import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterService {

  // ולידציה עבור אימייל
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'יש להזין אימייל';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'פורמט אימייל לא תקין';
    }
    return null;
  }

  // ולידציה עבור שם משתמש
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'יש להזין שם משתמש';
    }
    if (value.length < 3) {
      return 'שם משתמש חייב להיות לפחות 3 תווים';
    }
    return null;
  }

  // ולידציה עבור סיסמה
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'יש להזין סיסמה';
    }
    if (value.length < 6) {
      return 'הסיסמה חייבת להיות לפחות 6 תווים';
    }
    return null;
  }

  // ולידציה עבור שם פרטי ושם משפחה
  static String? validatefirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'יש להזין שם';
    }
    if (value.length < 2) {
      return 'השם חייב להיות לפחות 2 תווים';
    }
    return null;
  }

  static String? validatelastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'יש להזין שם משפחה';
    }
    if (value.length < 2) {
      return 'השם משפחה חייב להיות לפחות 2 תווים';
    }
    return null;
  }
  

 static Future<String> registerUser(String email, String username, String password, String firstname, String lastname) async {
  try {
    final response = await http.post(
      Uri.parse('https://shachar.online:3000/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email,
        "username": username,
        "password": password,
        "firstname": firstname,
        "lastname": lastname
      })
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['message'];
    } else {
      return " שגיאה: ${data['message']}";
    }
  } catch (e) {
    return " שגיאה בחיבור לשרת";
  }
}
}

