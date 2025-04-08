import 'package:flutter/material.dart';
import 'package:ordivo/pages/register.dart';
import 'package:ordivo/pages/classes/loginService.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();

  bool isPasswordHidden = true;
  bool showEyeIcon = false;
  
  @override
  void initState() {
    super.initState();
    passwordcontroller.addListener(() {
      setState(() {
        showEyeIcon = passwordcontroller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    emailcontroller.dispose();
    passwordcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png'),
                SizedBox(height: 20,),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    children: [
                      TextField(
                        controller: emailcontroller,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          labelText: "שם משתמש או אימייל",
                          floatingLabelAlignment: FloatingLabelAlignment.start,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10,),
                      TextField(
                        controller: passwordcontroller,
                        textAlign: TextAlign.right,
                        obscureText: isPasswordHidden,
                        decoration: InputDecoration(
                          labelText: "סיסמא",
                          floatingLabelAlignment: FloatingLabelAlignment.start,
                          border: OutlineInputBorder(),
                          suffixIcon: showEyeIcon
                        ? IconButton(
                          icon: Icon(
                            isPasswordHidden ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordHidden = !isPasswordHidden;
                            });
                          },
                        )
                        : null,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                ElevatedButton(
                  onPressed: () {
                    Loginservice.loginUser(context, emailcontroller.text, passwordcontroller.text);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.blue,
                  ),
                   child: Text("התחבר" , style: TextStyle(fontSize: 20),),
                ),
                SizedBox(height: 10,),
                TextButton(
                  onPressed: () {},
                   child: Text("?שכחת את הסיסמא", style: TextStyle(color: Colors.blue),)
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                   Navigator.of(context).push(MaterialPageRoute(builder: (context) => Register(),));
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('אין לך חשבון? הירשם כאן', style: TextStyle(color: Colors.blue)),
                  ),
                )
              ],
            ),
          ),
          ),
    );
  }
}
