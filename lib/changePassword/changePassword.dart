// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ExpenseReportState();
}

class _ExpenseReportState extends State<ChangePassword> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController ancientPassword = TextEditingController();
  TextEditingController NewPassword = TextEditingController();
  TextEditingController ConfirmPAssword = TextEditingController();

  String? confirmPasswords1(String password) {
    final box = GetStorage();
    final StoragePassword = box.read('password');

    if (password.isEmpty) {
      return 'Please Enter Previous Password';
    }
    if (password != StoragePassword) {
      return 'Passwords do not match with Previous Password';
    }
    return null;
  }

  String? confirmPasswords(String password, String confirmPassword) {
    if (password.isEmpty) {
      return 'Please Enter a Password';
    }
    if (confirmPassword.isEmpty) {
      return 'Please Confirm Your Password';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> submitForm() async {
    ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      showNoInternetError();
    } else if (_formKey.currentState!.validate()) {
      await editPassword();
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
                    backgroundColor: Color(0xFF3954A4),
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

  Future<void> editPassword() async {
    final box = GetStorage();
    final _token = box.read('token') ?? '';
    final id = box.read('user_id') ?? '';

    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final gestionBaseUrl = configJson['gestion_baseUrl'];
    final gestionApiKey = configJson['gestion_apiKey'];

    final gestionRegisterUrl = gestionBaseUrl + "mob/pwd/employe/" + id.toString();

    var headers = {
      'x-api-key': '$gestionApiKey',
      'Authorization': 'Bearer ' + _token
    };

    var request = http.Request('PUT', Uri.parse(gestionRegisterUrl));
    request.body = json.encode(
        {"oldPassword": ancientPassword.text, "newPassword": NewPassword.text});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      Get.snackbar(
        colorText: Colors.white,
        'Success',
        'Password is Updated',
        backgroundColor: Color.fromARGB(255, 8, 213, 59),
        snackStyle: SnackStyle.FLOATING,
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
        isDismissible: true,
        dismissDirection: DismissDirection.up,
        forwardAnimationCurve: Curves.easeOutBack,
        reverseAnimationCurve: Curves.easeInCirc,
        duration: const Duration(seconds: 3),
        barBlur: 0,
        messageText: const Text(
          'Password is Updated',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
      );
    } else {
      print(response.reasonPhrase);
    }
  }

  bool isLoading = false;

  void clearTextField(){
    ancientPassword.text = '';
    NewPassword.text = '';
    ConfirmPAssword.text = '';
  }

  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.white,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Center(
                      child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop(clearTextField);
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            color: Color(0xFF3954A4),
                            size: 30,
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Text(
                      'Changer mot de passe',
                      style: TextStyle(
                        color: Color(0xFF3954A4),
                        fontSize: 20,
                        fontFamily: 'Kanit',
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 9,
              ),
              // Container(
              //   decoration: BoxDecoration(
              //       boxShadow: [
              //         BoxShadow(
              //           color: Color(0x07000000),
              //           blurRadius: 10,
              //           offset: Offset(0, 0),
              //           spreadRadius: 8,
              //         ),
              //       ],
              //     ),
              //   child: TextFormField(
              //     autovalidateMode: AutovalidateMode.onUserInteraction,
              //     decoration: InputDecoration(
              //       errorBorder: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(10),
              //         borderSide:
              //             const BorderSide(color: Colors.red, width: 1.2),
              //       ),
              //       labelText: 'Ancien mot de passe',
              //       labelStyle: TextStyle(
              //         color: Color(0xFF524D4D),
              //         fontSize: 15,
              //         fontFamily: 'Kanit',
              //         fontWeight: FontWeight.w300,
              //         height: 0.05,
              //       ),
              //       border: InputBorder.none,
              //     ),
              //   ),
              // ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 45),
                  child: TextFormField(
                      controller: ancientPassword,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 1.2),
                          ),
                          labelText: 'Ancien mot de passe',
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.black54) // Placeholder text
                          ),
                      validator: (confirmPassword) {
                        return confirmPasswords1(ancientPassword.text);
                      }),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 30,
              ),
              // Container(
              //   child: TextFormField(
              //     autovalidateMode: AutovalidateMode.onUserInteraction,
              //     decoration: InputDecoration(
              //       contentPadding: EdgeInsets.symmetric(horizontal: 25),
              //       labelText: 'Nouveou mot de passe',
              //       labelStyle: TextStyle(
              //         color: Color(0xFF524D4D),
              //         fontSize: 15,
              //         fontFamily: 'Kanit',
              //         fontWeight: FontWeight.w300,
              //         height: 0.05,
              //       ),
              //       border: InputBorder.none, // Remove TextField's border
              //     ),
              //   ),
              // ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 45),
                  child: TextFormField(
                     obscureText: !isVisible,
                      controller: NewPassword,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isVisible =
                                    !isVisible; 
                              });
                            },
                            icon: Icon(
                              isVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 1.2),
                          ),
                          labelText: ' Nouveou Mot de passe',
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.black54) // Placeholder text
                          ),
                      validator: (password) {
                        return confirmPasswords(password!, NewPassword.text);
                      }),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 30,
              ),
              // Container(
              //   width: 333,
              //   height: 59,
              //   decoration: ShapeDecoration(
              //     color: Colors.white,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(5),
              //     ),
              //     shadows: [
              //       BoxShadow(
              //         color: Color(0x07000000),
              //         blurRadius: 10,
              //         offset: Offset(0, 0),
              //         spreadRadius: 8,
              //       ),
              //     ],
              //   ),
              //   child: TextFormField(
              //     autovalidateMode: AutovalidateMode.onUserInteraction,
              //     decoration: InputDecoration(
              //       contentPadding: EdgeInsets.symmetric(horizontal: 25),
              //       labelText: 'Confirmer le mot de passe',
              //       labelStyle: TextStyle(
              //         color: Color(0xFF524D4D),
              //         fontSize: 15,
              //         fontFamily: 'Kanit',
              //         fontWeight: FontWeight.w300,
              //         height: 0.05,
              //       ),
              //       border: InputBorder.none, // Remove TextField's border
              //     ),
              //   ),
              // ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 45),
                  child: TextFormField(
                    obscureText: !isVisible,
                      controller: ConfirmPAssword,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isVisible =
                                    !isVisible; 
                              });
                            },
                            icon: Icon(
                              isVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 1.2),
                          ),
                          labelText: ' Confirmer le mot de passe',
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.black54) // Placeholder text
                          ),
                      validator: (confirmPassword) {
                        return confirmPasswords(
                            NewPassword.text, confirmPassword!);
                      }),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 8,
              ),
              Container(
                width: 333,
                height: 59,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  shadows: [
                    BoxShadow(
                      color: Color(0x07000000),
                      blurRadius: 10,
                      offset: Offset(0, 0),
                      spreadRadius: 8,
                    )
                  ],
                ),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3556A7)),
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
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
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
                        : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                              'Valider',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w500,
                                height: 0.04,
                              ),
                            ),
                        )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
