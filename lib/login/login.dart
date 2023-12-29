// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:fr.innoyadev.mkgodev/login/loginModel.dart';
import 'package:fr.innoyadev.mkgodev/signup/signUp.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class loginScreen extends StatefulWidget {
  const loginScreen({super.key});

  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isVisible = false;
  final LoginController loginController = Get.find();

  String? validateEmail(value) {
    if (value!.isEmpty) {
      return 'Please Enter Valid Email';
    }
    RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please Enter Valid Email';
    }
    return null;
  }

  Future<void> submitForm() async {
    ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      showNoInternetError();
    } else if (_formKey.currentState!.validate()) {
      await loginController.login();
      // await _requestLocationAndNotificationPermission();
      // await init();
      setState(() {
        isLoading = false;
      });
    }
  }

  void showNoInternetError() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          backgroundColor: Color(0xFFE6F7FD),
          title: Text("No Internet Connection"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Please connect to the internet and try again."),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF3954A4),
                    minimumSize: Size(200, 40),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // init();
  }

  bool isLoading = false;

 

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 5,
                ),
                Image.asset(
                  "assets/images/MKGOLogo.png",
                  width: 108,
                  height: 58,
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  "Connectez-vous à votre compte",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.black),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: loginController.emailController,
                      decoration: InputDecoration(
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 1.2),
                        ),
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFA4A4A4),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Email cannot be empty';
                        }
                        if (validateEmail(value) != null) {
                          return 'Invalid email format';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x07000000),
                        blurRadius: 10,
                        offset: Offset(0, 0),
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: !isVisible,
                      controller: loginController.passwordController,
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isVisible =
                                    !isVisible; // Toggle password visibility
                              });
                            },
                            icon: Icon(
                              isVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 1.2),
                          ),
                          labelText: 'Mot de passe',
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFA4A4A4),
                          ) // Placeholder text
                          ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please Enter Password';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20, bottom: 20),
                  width: 334,
                  height: 59,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Color(0xff3954a4)),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3954A4)),
                    onPressed: () async {
                      if (isLoading) return;
                      setState(() {
                        isLoading = true;
                      });
                      await submitForm();
                      setState(() {
                        isLoading = false;
                      });
                    },
                    child: isLoading
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                    height: 45,
                                    width: 40,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    )),
                                SizedBox(
                                  width: 24,
                                ),
                                Text('Please Wait...')
                              ],
                            ),
                          )
                        : Text("Se connecter",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.white)),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Vous n'avez pas de compte ?",
                      style: TextStyle(
                        color: Color(0xFFA3A3A3),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    //S'inscrire
                    TextButton(
                      onPressed: () {
                        Get.to(() => SignupScreen())?.then((value) {
                          loginController.emailController.text = "";
                          loginController.passwordController.text = "";
                        });
                      },
                      child: Text(
                        " " + "S'inscire",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.orange),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 90,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
