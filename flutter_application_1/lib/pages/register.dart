import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/classes/registerService.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {  

  final _formKey = GlobalKey<FormState>();
  final _field1Key = GlobalKey<FormFieldState>();
  final _field2Key = GlobalKey<FormFieldState>();
  final _field3Key = GlobalKey<FormFieldState>();
  final _field4Key = GlobalKey<FormFieldState>();
  final _field5Key = GlobalKey<FormFieldState>();

  String? activeField;

  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController usernamecontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  final TextEditingController firstnamecontroller = TextEditingController();
  final TextEditingController lastnamecontroller = TextEditingController();

  bool _submitted = false;

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
    usernamecontroller.dispose();
    passwordcontroller.dispose();
    firstnamecontroller.dispose();
    lastnamecontroller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
      FocusScope.of(context).unfocus();
      setState(() {
        activeField = null;
      });
    },
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Form(
              key: _formKey,
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
                        TextFormField(
                          controller: emailcontroller,
                          key: _field1Key,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            labelText: "אימייל",
                            floatingLabelAlignment: FloatingLabelAlignment.start,
                            border: OutlineInputBorder(),
                          ),
                          onTap: () {
                            setState(() {
                              activeField = 'field1';
                            });
                          },
                          autovalidateMode: AutovalidateMode.always,
                          validator: (value) {
                              if (!_submitted && activeField != 'field1') return null;
                              return RegisterService.validateEmail(value);
                            },
                            onChanged: (_) {
                              _field1Key.currentState?.validate();
                            },
                        ),
                        SizedBox(height: 10,),
                        TextFormField(
                          controller: usernamecontroller,
                          key: _field2Key,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            labelText: "שם משתמש",
                            floatingLabelAlignment: FloatingLabelAlignment.start,
                            border: OutlineInputBorder(),
                          ),
                          onTap: () {
                            setState(() {
                              activeField = 'field2';
                            });
                          },
                          autovalidateMode: AutovalidateMode.always,
                          validator: (value) {
                              if (!_submitted && activeField != 'field2') return null;
                              return RegisterService.validateUsername(value);
                            },
                            onChanged: (_) {
                              _field2Key.currentState?.validate();
                            },
                        ),
                        SizedBox(height: 10,),
                        TextFormField(
                          controller: passwordcontroller,
                          key: _field3Key,
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
                          onTap: () {
                            setState(() {
                              activeField = 'field3';
                            });
                          },
                          autovalidateMode: AutovalidateMode.always,
                          validator: (value) {
                              if (!_submitted && activeField != 'field3') return null;
                              return RegisterService.validatePassword(value);
                            },
                            onChanged: (_) {
                              _field3Key.currentState?.validate();
                            },
                        ),
                        SizedBox(height: 10,),
                        TextFormField(
                          controller: firstnamecontroller,
                          key: _field4Key,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            labelText: "שם פרטי",
                            floatingLabelAlignment: FloatingLabelAlignment.start,
                            border: OutlineInputBorder(),
                          ),
                           onTap: () {
                            setState(() {
                              activeField = 'field4';
                            });
                          },
                          autovalidateMode: AutovalidateMode.always,
                          validator: (value) {
                              if (!_submitted && activeField != 'field4') return null;
                              return RegisterService.validatefirstName(value);
                            },
                            onChanged: (_) {
                              _field4Key.currentState?.validate();
                            },
                        ),
                        SizedBox(height: 10,),
                        TextFormField(
                          controller: lastnamecontroller,
                          key: _field5Key,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            labelText: "שם משפחה",
                            floatingLabelAlignment: FloatingLabelAlignment.start,
                            border: OutlineInputBorder(),
                          ),
                          onTap: () {
                            setState(() {
                              activeField = 'field5';
                            });
                          },
                          autovalidateMode: AutovalidateMode.always,
                          validator: (value) {
                              if (!_submitted && activeField != 'field5') return null;
                              return RegisterService.validatelastName(value);
                            },
                            onChanged: (_) {
                              _field5Key.currentState?.validate();
                            },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  ElevatedButton(
                    onPressed: () async{
                      setState(() {
                        _submitted = true;
                      });
                      if (_formKey.currentState!.validate()){
                        String message =await RegisterService.registerUser(
                        emailcontroller.text,
                        usernamecontroller.text,
                        passwordcontroller.text,
                        firstnamecontroller.text,
                        lastnamecontroller.text
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(
                              message,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          backgroundColor: message.contains("שגיאה") ? Colors.red : Colors.green,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      if (!message.contains("שגיאה")) {
                        Navigator.pop(context);
                      }
                      }else {
                        ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(
                              "יש שגיאות בטופס, אנא בדוק את הפרטים.",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.blue,
                    ),
                    child: Text("הירשם", style: TextStyle(fontSize: 20),),
                  ),
                  SizedBox(height: 20,),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('כבר יש לך חשבון? התחבר כאן', style: TextStyle(color: Colors.blue)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
