import 'package:flutter/material.dart';
import 'package:ordivo/pages/classes/order_row.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ordivo/pages/classes/loginService.dart';


class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  // יצירת TextEditingController לכל שדה
  final TextEditingController _computerController = TextEditingController();
  final TextEditingController _laptopController = TextEditingController();
  final TextEditingController _galaxyController = TextEditingController();
  final TextEditingController _iphoneController = TextEditingController();
  final TextEditingController _xiaomiController = TextEditingController();
  final TextEditingController _watchController = TextEditingController();

  double totalPrice = 0.0;

  void calculateTotalPrice(){
    double total = 0.0;
    Map<String, double> prices = {
    "מחשב": 2065.0,
    "מחשב נייד": 1899.0,
    "גלקסי": 3179.0,
    "אייפון": 5688.0,
    "שיאומי": 3079.0,
    "שעון": 1399.0,
  };
  total += (double.tryParse(_computerController.text)?? 0)*prices['מחשב']!;
  total += (double.tryParse(_laptopController.text) ?? 0) * prices["מחשב נייד"]!;
  total += (double.tryParse(_galaxyController.text) ?? 0) * prices["גלקסי"]!;
  total += (double.tryParse(_iphoneController.text) ?? 0) * prices["אייפון"]!;
  total += (double.tryParse(_xiaomiController.text) ?? 0) * prices["שיאומי"]!;
  total += (double.tryParse(_watchController.text) ?? 0) * prices["שעון"]!;

  setState(() {
    totalPrice = total;
  });
  }

  @override
void initState() {
  super.initState();

  // מאזינים לכל קלט כדי לעדכן את המחיר הכולל
  _computerController.addListener(calculateTotalPrice);
  _laptopController.addListener(calculateTotalPrice);
  _galaxyController.addListener(calculateTotalPrice);
  _iphoneController.addListener(calculateTotalPrice);
  _xiaomiController.addListener(calculateTotalPrice);
  _watchController.addListener(calculateTotalPrice);
}


  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> sendOrder() async {
    String? token = await getToken();

    Map<String, dynamic> orderData = {
      "מחשב": _computerController.text,
      "מחשב נייד": _laptopController.text,
      "גלקסי": _galaxyController.text,
      "אייפון": _iphoneController.text,
      "שיאומי": _xiaomiController.text,
      "שעון": _watchController.text,
      "מחיר": totalPrice,
    };

    String jsonData = jsonEncode(orderData);

    try {
      var response = await http.post(
        Uri.parse("https://shachar.online:3000/order"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonData,
      );

      if (response.statusCode == 200) {
        Loginservice.showSnackbar(context, 'ההזמנה נשלחה בהצלחה', Colors.green);
      } else {
        Loginservice.showSnackbar(
            context, "משהו לא עבד טוב ${response.statusCode}", Colors.red);
      }
    } catch (e) {
      Loginservice.showSnackbar(context, "שגיאה: $e", Colors.red);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Image.asset('assets/bluelogo.png',
          height: 40,),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
                    alignment: Alignment.center,
                    child: Text(
                      'ביצוע הזמנה',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            SizedBox(height: 20,),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 80),
                children: [
                  OrderRow(imageUrl: 'assets/computer.png', label: 'מחשב', controller: _computerController, price: '2065',),
                  const SizedBox(height: 10),
                  OrderRow(imageUrl: 'assets/laptop.png', label: 'מחשב נייד', controller: _laptopController, price: '1899',),
                  const SizedBox(height: 10),
                  OrderRow(imageUrl: 'assets/galaxy.png', label: 'גלקסי',controller: _galaxyController, price: '3179',),
                  const SizedBox(height: 10),
                  OrderRow(imageUrl: 'assets/iphone.png', label:  'אייפון', controller: _iphoneController, price: '5688',),
                  const SizedBox(height: 10),
                  OrderRow(imageUrl: 'assets/xiaomi.png', label:  'שיאומי', controller: _xiaomiController, price: '3079',),
                  const SizedBox(height: 10),
                  OrderRow(imageUrl: 'assets/clock.png', label:  'שעון', controller: _watchController, price: '1399',),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'סה"כ לתשלום: ₪$totalPrice',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: sendOrder,
        backgroundColor: Colors.blue,
        label: const Text('שלח הזמנה', style: TextStyle(fontSize: 18)),
        icon: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(3.1416), // הופך את האייקון אופקית
          child: const Icon(Icons.send),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}