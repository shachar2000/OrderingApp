import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Orderlist extends StatefulWidget {
  const Orderlist({super.key});

  @override
  State<Orderlist> createState() => _OrderlistState();
}

class _OrderlistState extends State<Orderlist> {
  List<Map<String, dynamic>> orderlist = [];
  String? token;

  @override
  void initState() {
    super.initState();
    loadTokenAndFetchOrders();
  }

  Future<void> loadTokenAndFetchOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedToken = prefs.getString('token'); 

    if (savedToken != null) {
      setState(() {
        token = savedToken;
      });
      fetchOrders();
    } else {
      print("⚠️ Token not found, user might not be logged in.");
    }
  }

  Future<void> fetchOrders() async {
    if (token == null) return; // אם אין טוקן, לא נשלח בקשה

    try {
      final response = await http.get(
        Uri.parse('https://shachar.online:3000/orderlist'),
        headers: {
          "Authorization": "Bearer $token",  
          "Content-Type": "application/json"
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          orderlist = List<Map<String, dynamic>>.from(data);
        });
      } else {
        print('❌ שגיאה בטעינת הזמנות: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ שגיאה בחיבור לשרת: $e');
    }
  }

  String formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);

      // הוספת 3 שעות לתאריך
      parsedDate = parsedDate.add(Duration(hours: 3));

      // מחזיר את התאריך בפורמט הרצוי
      return "${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year} ${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      print("❌ Error parsing date: $e");
      return date;  // במקרה של שגיאה, נחזיר את התאריך כמו שהוא
    }
  }

  Widget buildBoldText(String title, dynamic value) {
    String displayValue = (value?.isEmpty ?? true) ? 'לא הוזמן' : value.toString();

    return Align(
      alignment: Alignment.centerRight,
      child: RichText(
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl, 
        text: TextSpan(
          style: TextStyle(fontSize: 16, color: Colors.black), // עיצוב ברירת מחדל
          children: [
            TextSpan(
              text: '$title ',
              style: TextStyle(fontWeight: FontWeight.bold), // הכותרת מודגשת
            ),
            TextSpan(
              text: displayValue,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Image.asset('assets/bluelogo.png',
          height: 40,),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                'הזמנות קודמות',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20,),
            Expanded(
              child: orderlist.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(child: CircularProgressIndicator()),
                      SizedBox(height: 10,),
                      Text('לא בוצעו הזמנות',
                        style: TextStyle(fontWeight: FontWeight.bold,),),
                    ],
                  )
                : ListView.builder(
                    itemCount: orderlist.length,
                    itemBuilder: (context, index) {
                      final order = orderlist[index];
                      String date = order['date'] ?? '';
                      String formattedDate = formatDate(date);
                      
                      // מפצל את התאריך לשני חלקים
                      List<String> dateParts = formattedDate.split(' ');
                      String datePart = dateParts.isNotEmpty ? dateParts[0] : '';
                      String timePart = dateParts.length > 1 ? dateParts[1] : '';

                      return ExpansionTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              datePart,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 10,),
                            Text(
                              timePart,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            Text(
                              'הזמנה ${order['id']}',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildBoldText('מחשב:', order['computer']),
                                  buildBoldText('מחשב נייד:', order['laptop']),
                                  buildBoldText('גלקסי:', order['galaxy']),
                                  buildBoldText('אייפון:', order['iphone']),
                                  buildBoldText('שיאומי:', order['xiaomi']),
                                  buildBoldText('שעון:', order['watch']),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "₪${double.tryParse(order['price'].toString())?.toStringAsFixed(2) ?? order['price'].toString()}",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold, // לדוגמה, אם תרצה להדגיש את המחיר
                                        ),
                                      ),
                                      SizedBox(width: 10,),
                                      Text(
                                        ":מחיר כולל",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'Roboto', // אחיד עם הפונט של המחיר
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
