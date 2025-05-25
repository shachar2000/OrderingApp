import 'package:flutter/material.dart';
import 'package:ordivo/pages/orders.dart';
import 'package:ordivo/pages/orderlist.dart';
import 'classes/loginService.dart';
import 'package:ordivo/pages/admin_orders_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String firstname = '';
  String lastname = '';
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    loadUserNameAndAdminStatus();
  }

  Future<void> loadUserNameAndAdminStatus() async { 
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      firstname = prefs.getString('firstname') ?? '';
      lastname = prefs.getString('lastname') ?? '';
      _isAdmin = prefs.getBool('is_admin') ?? false;
    });
  }

    @override
  Widget build(BuildContext context) {
    
    return Directionality(
      textDirection: TextDirection.rtl, // מימין לשמאל
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: Image.asset('assets/bluelogo.png',
          height: 40,),
          backgroundColor: Colors.blue,
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.logout, color: Colors.black), // אייקון יציאה
              onPressed: () {
                Loginservice.logout(context);
              },
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('שלום $firstname $lastname',
                  style: TextStyle(
                    fontSize: 30
                  ),
                ),
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => Orders(),));
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: Colors.blue
                ),
                child: const Text('בצע הזמנה'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => Orderlist(),));
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: Colors.blue
                ),
                child: const Text('הזמנות קודמות'),
              ),
            ],
          ),
          if (_isAdmin) // הצג את הכפתור הזה רק אם המשתמש הוא מנהל
            Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                    onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => AdminOrdersListScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                        backgroundColor: Colors.redAccent, // צבע שונה לכפתור מנהל
                    ),
                    child: const Text('ניהול הזמנות (מנהל)'),
                ),
            ),
          ]
        ),
      ),
    );
  }
}