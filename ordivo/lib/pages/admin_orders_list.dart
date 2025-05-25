import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class AdminOrdersListScreen extends StatefulWidget {
  const AdminOrdersListScreen({super.key});

  @override
  State<AdminOrdersListScreen> createState() => _AdminOrdersListScreenState();
}

class _AdminOrdersListScreenState extends State<AdminOrdersListScreen> {
  List<Map<String, dynamic>> allOrders = [];
  String? token;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadTokenAndFetchAllOrders();
  }

  Future<void> loadTokenAndFetchAllOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedToken = prefs.getString('token');

    if (savedToken != null) {
      setState(() {
        token = savedToken;
      });
      fetchAllOrders();
    } else {
      print("⚠️ Token not found, user might not be logged in.");
      // Optionally navigate to login or show an error
    }
  }

  Future<void> fetchAllOrders() async {
    if (token == null) return;

    setState(() {
      _isLoading = true;
    });

    Map<String, String> queryParameters = {}; // נשנה את השם כדי למנוע בלבול
    if (_startDate != null) {
      queryParameters['startDate'] = DateFormat('yyyy-MM-dd').format(_startDate!);
    }
    if (_endDate != null) {
      queryParameters['endDate'] = DateFormat('yyyy-MM-dd').format(_endDate!);
    }

    final Uri uri = Uri.https(
      'shachar.online:3000', // Host and port
      '/admin/all_orders',   // Path
      queryParameters.isNotEmpty ? queryParameters : null, // Pass the map here
    );

    try {
      final response = await http.get(
        uri, // השתמש באובייקט ה-Uri שבנינו
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          allOrders = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
        print('Orders fetched successfully: ${allOrders.length} orders'); // הדפסה לבדיקה
      } else {
        print("Failed to load all orders: ${response.statusCode} ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load orders: ${jsonDecode(response.body)['message'] ?? response.body}')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching all orders: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching orders: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      fetchAllOrders();
    }
  }

  Widget _buildDateButton(BuildContext context, {required bool isStartDate, DateTime? date, required String label}) {
    return ElevatedButton(
      onPressed: () => _selectDate(context, isStartDate: isStartDate),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black, backgroundColor: Colors.white, // צבע טקסט ורקע
        elevation: 2, // צל קטן
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // פינות מעוגלות
          side: const BorderSide(color: Colors.grey, width: 0.5), // מסגרת דקה
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // כדי שהטקסט והאייקון יהיו בקצוות
        textDirection: ui.TextDirection.rtl, // כיוון טקסט מימין לשמאל בתוך הכפתור
        children: [
          Icon(Icons.calendar_today, size: 20, color: Colors.blue[700]), // אייקון קלנדר
          const SizedBox(width: 8),
          Expanded( // כדי שהטקסט יתפרס
            child: Text(
              date == null ? label : '$label ${DateFormat('dd/MM/yyyy').format(date)}',
              textAlign: TextAlign.right, // יישור לימין
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ניהול הזמנות', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.blue,
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column( // 💡 שינוי: מעבר מ-Row ל-Column עבור פריסת התאריכים
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // 💡 שינוי: ריווח בין האלמנטים
                    children: [
                      Expanded( // 💡 שינוי: כפתור שימלא את השטח
                        child: _buildDateButton(
                          context,
                          isStartDate: true,
                          date: _startDate,
                          label: 'תאריך התחלה:',
                        ),
                      ),
                      const SizedBox(width: 10), // מרווח קטן בין הכפתורים
                      Expanded( // 💡 שינוי: כפתור שימלא את השטח
                        child: _buildDateButton(
                          context,
                          isStartDate: false,
                          date: _endDate,
                          label: 'תאריך סיום:',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10), // מרווח בין שורת התאריכים לכפתור האיפוס
                  Align(
                    alignment: Alignment.centerLeft, // מניח את כפתור האיפוס בצד שמאל (ימין ב-RTL)
                    child: TextButton.icon( // 💡 שינוי: שימוש ב-TextButton.icon לאיפוס
                      onPressed: () {
                        setState(() {
                          _startDate = null;
                          _endDate = null;
                        });
                        fetchAllOrders(); // Clear filters and fetch all orders
                      },
                      icon: const Icon(Icons.clear_all, color: Colors.red), // אייקון יותר ברור
                      label: const Text('נקה סינון תאריכים', style: TextStyle(color: Colors.red)), // טקסט ברור יותר
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero, // כדי למנוע ריפוד מיותר
                        alignment: Alignment.centerRight, // יישור לימין של הכפתור עצמו
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: allOrders.length,
                      itemBuilder: (context, index) {
                        final order = allOrders[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              print('Order ${order['id']} tapped!');
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end, // זה בסדר, מיישר את הילדים לעמודה לימין
                                children: [
                                  // 💡 שינוי כאן: ליישר את תאריך ההזמנה לימין
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'הזמנה מ: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(order['date']).toLocal())}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // 💡 שינוי כאן: ליישר את פרטי המזמין לימין
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text.rich(
                                      TextSpan(
                                        text: 'מזמין: ',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                        children: [
                                          TextSpan(
                                            text: '${order['firstname']} ${order['lastname']} (${order['username']})',
                                            style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black87),
                                          ),
                                        ],
                                      ),
                                      // אין צורך ב-textAlign כאן כי Align כבר עושה את העבודה
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // 💡 ודא שגם זה מיושר לימין - כבר סידרנו את זה ב-_buildOrderItems
                                  ..._buildOrderItems(order),
                                  const Divider(height: 24, thickness: 1, color: Colors.grey),
                                  // סכום כולל כבר מיושר לימין
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'סה"כ: ₪${double.tryParse(order['price'].toString())?.toStringAsFixed(2) ?? order['price'].toString()}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Colors.green),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOrderItems(Map<String, dynamic> order) {
    List<Widget> items = [];
    Map<String, String> productNames = {
      'computer': 'מחשב',
      'laptop': 'מחשב נייד',
      'galaxy': 'גלקסי',
      'iphone': 'אייפון',
      'xiaomi': 'שיאומי',
      'watch': 'שעון',
    };

    productNames.forEach((key, value) {
      final productQuantity = int.tryParse(order[key]?.toString() ?? '0') ?? 0;

      if (productQuantity > 0) {
        items.add(
          Align( // 💡 הוסף את ה-Align כאן!
            alignment: Alignment.centerRight, // יישר את השורה לימין
            child: Text.rich(
              TextSpan(
                text: '$value: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: '${productQuantity} יח\'',
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
              // אין צורך ב-textAlign: TextAlign.right כאן. ה-Align מטפל בזה.
            ),
          ),
        );
      }
    });
    return items;
  }
}