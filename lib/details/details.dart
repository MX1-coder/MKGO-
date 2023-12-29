// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, curly_braces_in_flow_control_structures

import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
// import 'package:fr.innoyadev.mkgodev/Utility/bottomSheet.dart';
// import 'package:fr.innoyadev.mkgodev/homeScreen/DriverPlanning.dart';
import 'package:fr.innoyadev.mkgodev/profile/profile.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/timezone.dart' as tz;

class RegisterDetails extends StatefulWidget {
  const RegisterDetails({super.key});

  @override
  State<RegisterDetails> createState() => _RegisterDetailsState();
}

class _RegisterDetailsState extends State<RegisterDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController name = TextEditingController();
  TextEditingController surmame = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController telephone = TextEditingController();
  TextEditingController dateController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: selectedDate,
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
  );

  if (picked != null && picked != selectedDate) {
    setState(() {
      selectedDate = picked;
      // Format the date to dd-MM-yy using intl package
      String formattedDate = DateFormat('dd-MMMM-yyyy').format(picked);
      dateController.text = formattedDate;
    });
  }
}

  bool isRefreshed = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      isRefreshed = true;
    });
    Future.delayed(Duration(milliseconds: 600), () async {
      setState(() {
        isRefreshed = false;
      });
    });
    // getDetails();
    submitForm();
  }

  Future<void> submitForm() async {
    ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      showNoInternetError();
    } else {
      getDetails();
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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    dateController = TextEditingController();
  }

  String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un numéro de téléphone';
    }
    if (value.length < 8) {
      return 'Veuillez saisir un numéro de \ntéléphone comportant au between 8-15 chiffres';
    }
    if (value.length > 15) {
      return 'Veuillez saisir un numéro de \ntéléphone comportant au maximum 15 chiffres';
    }
    return null;
  }

  bool isLoading = false;

  Future<void> editDetails() async {
    editEmployee();
  }

  Future<void> editEmployee() async {
    final box = GetStorage();
    final storage = GetStorage();
    final _token = box.read('token') ?? '';
    final id = storage.read('user_id');

    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final gestionBaseUrl = configJson['gestion_baseUrl'];
    final gestionApiKey = configJson['gestion_apiKey'];

    final gestionRegisterUrl =
        gestionBaseUrl + "mob/edit-employe/" + id.toString();

    var headers = {
      'x-api-key': '$gestionApiKey',
      'Authorization': 'Bearer ' + _token
    };

    var request = http.Request('PUT', Uri.parse(gestionRegisterUrl));
    request.body = json.encode({
      "telephone": telephone.text,
      "adresse": address.text,
      "dateNaissance": dateController.text
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseString = await response.stream.bytesToString();
      final updatedData = json.decode(responseString);

      print("Updated Data: $updatedData");
      Get.snackbar(
        colorText: Colors.white,
        'Success',
        'Details are Updated',
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
          'Details are Updated',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
      );

      Get.offAll(() => Profile());
    } else {
      print(response.reasonPhrase);
    }
  }

  String Nom1 = "";
  String Prenom1 = "";
  String emailAdresse1 = "";
  String telephoneNumer1 = "";
  String address3 = "";
  String dateNaissance1 = "";

  Future<void> getDetails() async {
    final box = GetStorage();
    final _token = box.read('token') ?? '';
    print("token called: $_token");

    final storage = GetStorage();
    final UserID = storage.read('user_id');

    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final gestionBaseUrl = configJson['gestion_baseUrl'];
    final gestionApiKey = configJson['gestion_apiKey'];

    final gestionMainUrl =
        gestionBaseUrl + "mob/one-employe/" + UserID.toString();

    var headers = {
      'x-api-key': '$gestionApiKey',
      'Authorization': 'Bearer ' + _token
    };
    var request = http.Request('GET', Uri.parse(gestionMainUrl));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final apiData = jsonDecode(responseBody);

      String name2 = apiData['nom'];
      String surname2 = apiData['prenom'];
      String telephone2 = apiData['telephone'];
      String email2 = apiData['email'];
      String adresse2 = apiData['adresse'];
      String DOB2 = apiData['dateNaissance'];
      List<dynamic> roles2 = apiData['roles'];

      print(
          "Data Fro APi of user : ${name2}, ${surname2}, ${DOB2}, ${adresse2}, ${email2}, ${telephone2}, ${roles2}");

      DateTime dateTime = DateTime.parse(DOB2);
      tz.TZDateTime parisDateTime =
          tz.TZDateTime.from(dateTime, tz.getLocation('Europe/Paris'));

      String formattedDate = DateFormat('dd-MMMM-yyyy').format(parisDateTime);

      print('Formatted Date: $formattedDate');

      setState(() {
        Nom1 = name2;
        Prenom1 = surname2;
        telephone.text = telephone2;
        emailAdresse1 = email2;
        address.text = adresse2;
        dateController.text = formattedDate;
      });

      print(
          "Data is set : ${Nom1},${Prenom1},${emailAdresse1},${address3},${dateNaissance1},");

      setState(() {
        isLoading = false;
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Center(
                      child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            color: Color(0xFF3954A4),
                            size: 30,
                          )),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Text(
                        'Votre Profile',
                        style: TextStyle(
                          color: Color(0xFF3954A4),
                          fontSize: 20,
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w500,
                          height: 0,
                        ),
                        overflow: TextOverflow.clip,
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
                height: 10,
              ),
              isRefreshed
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF3954A4),
                      ),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2.7,
                                    height: 59,
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Color(0xFFA4A4A4)))),
                                    child: Column(children: [
                                      Row(
                                        children: [
                                          Text('Nom',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFFA4A4A4),
                                              )),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 9,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '$Nom1',
                                            style: TextStyle(
                                              color: Color(0xFF524D4D),
                                              fontSize: 16,
                                              fontFamily: 'Kanit',
                                              fontWeight: FontWeight.w400,
                                              height: 0,
                                            ),
                                          ),
                                        ],
                                      )
                                    ])
                                    // child: TextFormField(
                                    //   autovalidateMode: AutovalidateMode.onUserInteraction,
                                    //   controller: nom,
                                    //   decoration: InputDecoration(
                                    //       errorBorder: OutlineInputBorder(
                                    //         borderRadius: BorderRadius.circular(10),
                                    //         borderSide: const BorderSide(
                                    //             color: Colors.red, width: 1.2),
                                    //       ),
                                    //       hintText: '${GetStorage().read('user_nom')}',
                                    //       labelText: 'Nom',
                                    //       labelStyle: TextStyle(
                                    //         fontWeight: FontWeight.w900,
                                    //         color: Color(0xFFA4A4A4),
                                    //       )),
                                    // ),
                                    ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width / 2.7,
                                  height: 59,
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Color(0xFFA4A4A4)))),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text('Prenom',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFFA4A4A4),
                                              )),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 9,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '$Prenom1',
                                            style: TextStyle(
                                              color: Color(0xFF524D4D),
                                              fontSize: 16,
                                              fontFamily: 'Kanit',
                                              fontWeight: FontWeight.w400,
                                              height: 0,
                                            ),
                                          ),
                                        ],
                                      )
                                      // TextFormField(
                                      //   autovalidateMode: AutovalidateMode.onUserInteraction,
                                      //   controller: prenom,
                                      //   decoration: InputDecoration(
                                      //       errorBorder: OutlineInputBorder(
                                      //         borderRadius: BorderRadius.circular(10),
                                      //         borderSide: const BorderSide(
                                      //             color: Colors.red, width: 1.2),
                                      //       ),
                                      //       hintText: '${GetStorage().read('user_prenom')}',
                                      //       labelStyle: TextStyle(
                                      //         fontWeight: FontWeight.w900,
                                      //         color: Color(0xFFA4A4A4),
                                      //       )),
                                      // ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 18,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: Container(
                              height: 59,
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Color(0xFFA4A4A4)))),
                              child: Column(children: [
                                Row(
                                  children: [
                                    Text('Email',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFFA4A4A4),
                                        )),
                                  ],
                                ),
                                SizedBox(
                                  height: 9,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '$emailAdresse1',
                                      style: TextStyle(
                                        color: Color(0xFF524D4D),
                                        fontSize: 16,
                                        fontFamily: 'Kanit',
                                        fontWeight: FontWeight.w400,
                                        height: 0,
                                      ),
                                    ),
                                  ],
                                )
                              ])
                              // TextFormField(
                              //   controller: email,
                              //   decoration: InputDecoration(
                              //       prefixIcon: Icon(
                              //         Icons.mail_outline,
                              //         color: Color(0xFFA4A4A4),
                              //       ),
                              //       errorBorder: OutlineInputBorder(
                              //         borderRadius: BorderRadius.circular(10),
                              //         borderSide:
                              //             const BorderSide(color: Colors.red, width: 1.2),
                              //       ), // Remove the TextField's default border
                              //       contentPadding: EdgeInsets.symmetric(
                              //           horizontal: 16,
                              //           vertical: 16), // Adjust padding as needed
                              //       // labelText: '${GetStorage().read('user_email')}',
                              //       hintText: '${GetStorage().read('user_email')}',
                              //       labelText: 'Email',
                              //       labelStyle: TextStyle(
                              //         fontWeight: FontWeight.w900,
                              //         color: Color(0xFFA4A4A4),
                              //       ) // Placeholder text
                              //       ),
                              // ),
                              ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: Container(
                              // height: 80,
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Color(0xFFA4A4A4)))),
                              child: Column(children: [
                                TextFormField(
                                  controller: address,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    labelText: 'Adresse',
                                    labelStyle: TextStyle(
                                      color: Color(0xFF524D4D),
                                      fontSize: 16,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.w400,
                                      height: 0,
                                    ),
                                  ),
                                )
                              ])
                              //     TextFormField(
                              //   controller: address,
                              //   decoration: InputDecoration(
                              //       prefixIcon: Icon(
                              //         Icons.mail_outline,
                              //         color: Color(0xFFA4A4A4),
                              //       ),
                              //       errorBorder: OutlineInputBorder(
                              //         borderRadius: BorderRadius.circular(10),
                              //         borderSide: const BorderSide(
                              //             color: Colors.red, width: 1.2),
                              //       ), // Remove the TextField's default border
                              //       contentPadding: EdgeInsets.symmetric(
                              //           horizontal: 16,
                              //           vertical: 16), // Adjust padding as needed
                              //       labelText:
                              //           'Adresse:- ${GetStorage().read('user_adresse')}',
                              //       labelStyle: TextStyle(
                              //         fontWeight: FontWeight.w900,
                              //         color: Color(0xFFA4A4A4),
                              //       ) // Placeholder text
                              //       ),
                              // ),
                              ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: Container(
                              // height: 76,
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Color(0xFFA4A4A4)))),
                              child: Column(children: [
                                GestureDetector(
                                  onTap: () {
                                    _selectDate(context);
                                  },
                                  child: AbsorbPointer(
                                    child: TextFormField(
                                      controller: dateController,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        labelText: 'Date de naissance',
                                        labelStyle: TextStyle(
                                          color: Color(0xFF524D4D),
                                          fontSize: 16,
                                          fontFamily: 'Kanit',
                                          fontWeight: FontWeight.w400,
                                          height: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ])),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: Container(
                              // height: 76,
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Color(0xFFA4A4A4)))),
                              child: Column(children: [
                                TextFormField(
                                  maxLength: 15,
                                  keyboardType: TextInputType.number,
                                  controller: telephone,
                                  decoration: InputDecoration(
                                    counterText: "",
                                    border: InputBorder.none,
                                    labelText: 'Téléphone',
                                    labelStyle: TextStyle(
                                      color: Color(0xFF524D4D),
                                      fontSize: 16,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.w400,
                                      height: 0,
                                    ),
                                  ),
                                )
                              ])
                              //     TextFormField(
                              //   controller: address,
                              //   decoration: InputDecoration(
                              //       prefixIcon: Icon(
                              //         Icons.mail_outline,
                              //         color: Color(0xFFA4A4A4),
                              //       ),
                              //       errorBorder: OutlineInputBorder(
                              //         borderRadius: BorderRadius.circular(10),
                              //         borderSide: const BorderSide(
                              //             color: Colors.red, width: 1.2),
                              //       ), // Remove the TextField's default border
                              //       contentPadding: EdgeInsets.symmetric(
                              //           horizontal: 16,
                              //           vertical: 16), // Adjust padding as needed
                              //       labelText:
                              //           'Adresse:- ${GetStorage().read('user_adresse')}',
                              //       labelStyle: TextStyle(
                              //         fontWeight: FontWeight.w900,
                              //         color: Color(0xFFA4A4A4),
                              //       ) // Placeholder text
                              //       ),
                              // ),
                              ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 35),
                        //   child: TextFormField(
                        //     keyboardType: TextInputType.number,
                        //     maxLength: 15,
                        //     autovalidateMode:
                        //         AutovalidateMode.onUserInteraction,
                        //     controller: telephone,
                        //     decoration: InputDecoration(
                        //         counterText: "",
                        //         errorBorder: OutlineInputBorder(
                        //           borderRadius: BorderRadius.circular(10),
                        //           borderSide: const BorderSide(
                        //               color: Colors.red, width: 1.2),
                        //         ),
                        //         prefixIcon: Icon(
                        //           Icons.phone_outlined,
                        //           color: Color(0xFFA4A4A4),
                        //         ),
                        //         contentPadding: EdgeInsets.symmetric(
                        //             horizontal: 16, vertical: 16),
                        //         labelText: 'Téléphone',
                        //         labelStyle: TextStyle(
                        //           fontWeight: FontWeight.w900,
                        //           color: Color(0xFFA4A4A4),
                        //         )),
                        //   ),
                        // ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 8,
                        ),
                        Container(
                            width: 334,
                            height: 59,
                            decoration: ShapeDecoration(
                              color: Color(0xFF3954A4),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                            ),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF3954A4)),
                                onPressed: () async {
                                  if (isLoading) return;
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await editDetails();
                                  setState(() {
                                    isLoading = false;
                                  });
                                },
                                child: isLoading
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                                height: 45,
                                                width: 40,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                )),
                                            SizedBox(
                                              width: 24,
                                            ),
                                            Text('Please Wait...')
                                          ],
                                        ),
                                      )
                                    : Text(
                                        "Enregistrer les détails",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontFamily: 'Kanit',
                                          fontWeight: FontWeight.w400,
                                          height: 0,
                                        ),
                                      ))),
                        SizedBox(
                          height: 90,
                        ),
                      ],
                    )
            ],
          ),
        ),
      ),
    );
  }
}
