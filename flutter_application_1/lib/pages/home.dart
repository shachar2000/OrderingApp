import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/orders.dart';
import 'package:flutter_application_1/pages/orderlist.dart';
import 'classes/loginService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String firstname = '';
  String lastname = '';

  @override
  void initState() {
    super.initState();
    loadUserName();
  }

  Future<void> loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      firstname = prefs.getString('firstname') ?? '';
      lastname = prefs.getString('lastname') ?? '';
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
          ]
        ),
      ),
    );
  }
}