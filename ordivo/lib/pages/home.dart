import 'package:flutter/material.dart';
import 'package:ordivo/pages/orders.dart';
import 'package:ordivo/pages/orderlist.dart';
import 'package:ordivo/pages/classes/loginService.dart';
import 'package:ordivo/pages/admin_orders_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

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
      textDirection: ui.TextDirection.rtl, // מימין לשמאל
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: Image.asset(
            'assets/bluelogo.png',
            height: 40,
          ),
          backgroundColor: Colors.blue,
          centerTitle: true,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.settings, color: Colors.black),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.black),
              onPressed: () {
                Loginservice.logout(context);
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Directionality(
                  textDirection: ui.TextDirection.rtl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person, color: Colors.white, size: 50),
                      const SizedBox(height: 10),
                      Text(
                        'שלום, $firstname $lastname',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ),

              if (_isAdmin)
                ListTile(
                  title: const Text(
                    'ניהול הזמנות',
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                    textAlign: TextAlign.right,
                  ),
                  trailing: const Icon(Icons.manage_accounts, color: Colors.blue),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AdminOrdersListScreen()));
                  },
                ),
              ListTile(
                title: const Text(
                  'אודות',
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                  textAlign: TextAlign.right,
                ),
                trailing: const Icon(Icons.info, color: Colors.grey),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('מסך אודות (טרם מומש)')),
                  );
                },
              ),
              const Divider(),
              ListTile(
                title: const Text(
                  'התנתק',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                  textAlign: TextAlign.right,
                ),
                trailing: const Icon(Icons.logout, color: Colors.red),
                onTap: () {
                  Navigator.pop(context);
                  Loginservice.logout(context);
                },
              ),
            ],
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'שלום $firstname $lastname',
              style: const TextStyle(fontSize: 30),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Orders()));
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('בצע הזמנה'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Orderlist()));
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('הזמנות קודמות'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}