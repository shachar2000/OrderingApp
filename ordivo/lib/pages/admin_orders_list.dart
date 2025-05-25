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

    String url = 'https://shachar.online:3000/admin/all_orders';
    Map<String, String> queryParams = {};

    if (_startDate != null) {
      queryParams['startDate'] = DateFormat('yyyy-MM-dd').format(_startDate!);
    }
    if (_endDate != null) {
      queryParams['endDate'] = DateFormat('yyyy-MM-dd').format(_endDate!);
    }

    if (queryParams.isNotEmpty) {
      url += '?' + Uri.encodeQueryComponent(queryParams.entries.map((e) => '${e.key}=${e.value}').join('&'));
    }

    try {
      final response = await http.get(
        Uri.parse(url),
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
      } else {
        // Handle unauthorized or other errors
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
      fetchAllOrders(); // Fetch orders again with new date filters
    }
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
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () => _selectDate(context, isStartDate: true),
                    child: Text(_startDate == null ? 'בחר תאריך התחלה' : 'החל מ: ${DateFormat('dd/MM/yyyy').format(_startDate!)}'),
                  ),
                  ElevatedButton(
                    onPressed: () => _selectDate(context, isStartDate: false),
                    child: Text(_endDate == null ? 'בחר תאריך סיום' : 'עד: ${DateFormat('dd/MM/yyyy').format(_endDate!)}'),
                  ),
                  IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                      fetchAllOrders(); // Clear filters and fetch all orders
                    },
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
                          margin: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'הזמנה מ: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(order['date']).toLocal())}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text.rich(
                                  TextSpan(
                                    text: 'מזמין: ',
                                    style: const TextStyle(fontWeight: FontWeight.bold), // הדגש את "מזמין:"
                                    children: [
                                      TextSpan(
                                        text: '${order['firstname']} ${order['lastname']} (${order['username']})',
                                        style: const TextStyle(fontWeight: FontWeight.normal), // שאר הטקסט רגיל
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ..._buildOrderItems(order), // Helper to build product list
                                const Divider(),
                                Text(
                                  'סה"כ: ₪${double.tryParse(order['price'].toString())?.toStringAsFixed(2) ?? order['price'].toString()}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                                ),
                              ],
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
          Text.rich( // 💡 שינוי כאן: שימוש ב-Text.rich כדי להדגיש את שם המוצר
            TextSpan(
              text: '$value: ', // שם המוצר עם נקודתיים
              style: const TextStyle(fontWeight: FontWeight.bold), // הדגש את שם המוצר
              children: [
                TextSpan(
                  text: '${productQuantity} יח\'', // הכמות רגילה
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        );
      }
    });
    return items;
  }
}