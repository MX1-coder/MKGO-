// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, non_constant_identifier_names, unused_element, deprecated_member_use, sized_box_for_whitespace, unnecessary_null_comparison, unnecessary_cast

import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fr.innoyadev.mkgodev/Utility/bottomSheet.dart';
import 'package:fr.innoyadev.mkgodev/changePassword/changePassword.dart';
import 'package:fr.innoyadev.mkgodev/conditions/conditions.dart';
import 'package:fr.innoyadev.mkgodev/details/details.dart';
import 'package:fr.innoyadev.mkgodev/download/download.dart';
// import 'package:fr.innoyadev.mkgodev/download/takephotoModel.dart';
// import 'package:fr.innoyadev.mkgodev/homeScreen/homeScreen.dart';
import 'package:fr.innoyadev.mkgodev/location/location.dart';
// import 'package:fr.innoyadev.mkgodev/notes/notes.dart';
import 'package:fr.innoyadev.mkgodev/notifications/notification.dart';
import 'package:fr.innoyadev.mkgodev/profile/takephotoControlller.dart';
import 'package:fr.innoyadev.mkgodev/version/version.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TakePhotoController2 takePhotoController2 =
      Get.find<TakePhotoController2>();
  // final RxString imagePath = Get.arguments[0];

  bool isloading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    urlData();
    // print("RGPD url: $RgpdUrl");
    // print("Terms url: $Terms");

    setState(() {
      isLoading = true;
    });
    // Future.delayed(Duration(milliseconds: 1200), () {
    //   setState(() {
    //     isloading = false;
    //   });
    // });
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

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 5,
          title: Text('Delete Account ??'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                    ),
                    child: Text('No'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF3954A4),
                    ),
                    child: Text('Yes'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // PickedFile? _imageFile;
  // final ImagePicker _picker = ImagePicker();

  void showAlertDialog2(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 5,
          title: Text('Are you sure you want to Logout ??'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                    ),
                    child: Text('No'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF3954A4),
                    ),
                    child: Text('Yes'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String imageFileProfile = "";
  String CameraFile = "";
  String GalleryFile = "";
  String selectedImagePath = "";
  void _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Color(0xFFE6F7FD),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(38),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height / 1.8,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 25,
                ),
                GestureDetector(
                  onTap: () async {
                    takePhotoController2.takephoto2(
                        ImageSource.camera, context);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.3,
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Center(
                      child: Text(
                        'Choose From Camera',
                        style: TextStyle(
                          color: Color(0xFF3954A4),
                          fontSize: 16,
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () async {
                    takePhotoController2.takephoto2(
                        ImageSource.gallery, context);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.3,
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Center(
                      child: Text(
                        'Choose From Gallery',
                        style: TextStyle(
                          color: Color(0xFF3954A4),
                          fontSize: 16,
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 55,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          clipBehavior: Clip.none,
                          width: MediaQuery.of(context).size.width / 1.3,
                          height: 50,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25)),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Color(0xFF3954A4),
                                fontSize: 16,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w400,
                                height: 0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          if (GalleryFile == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Select an image first.'),
                              ),
                            );
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          clipBehavior: Clip.none,
                          width: MediaQuery.of(context).size.width / 1.3,
                          height: 50,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25)),
                          child: Center(
                            child: Text(
                              'Okay',
                              style: TextStyle(
                                color: Color(0xFF3954A4),
                                fontSize: 16,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w400,
                                height: 0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool isLoading = false;
  String imagePath2 = "";

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
      //   setState(() {
      //   isloading = true;
      // });
      final responseBody = await response.stream.bytesToString();
      final apiData = jsonDecode(responseBody);

      String name2 = apiData['nom'];
      String surname2 = apiData['prenom'];
      String telephone2 = apiData['telephone'];
      String email2 = apiData['email'];
      String adresse2 = apiData['adresse'];
      String DOB2 = apiData['dateNaissance'];
      // List<String> roles2 = apiData['roles'];

      print(
          "Data Fro APi of user : ${name2}, ${surname2}, ${DOB2}, ${adresse2}, ${email2}, ${telephone2}, ");

      setState(() {
        Nom1 = name2;
        Prenom1 = surname2;
        telephoneNumer1 = telephone2;
        emailAdresse1 = email2;
        address3 = adresse2;
        dateNaissance1 = DOB2;
      });
      setState(() {
        isLoading = false;
      });
      print(
          "Data is set : ${Nom1},${Prenom1},${emailAdresse1},${address3},${dateNaissance1},");
    } else {
      print(response.reasonPhrase);
    }
  }

  String role = "";

  Future<void> revokeFCMToken() async {
    final box = GetStorage();
    final token = box.read('token');

    final storage = GetStorage();
    final UserID = storage.read('user_id');

    List<dynamic> userRoles = storage.read('user_roles') ?? [];

    if (userRoles.contains('ROLE_ADMIN')) {
      setState(() {
        role = "ROLE_ADMIN";
      });
    }

    final Messagetoken = box.read('FCMToken');

    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final NotificationBaseUrl = configJson['planning_baseUrl'];
    final NotificationApiKey = configJson['planning_apiKey'];

    final LocationMainUrl = NotificationBaseUrl + "notification/revoke";

    var headers = {
      'x-api-key': '$NotificationApiKey',
      'Authorization': 'Bearer ' + token
    };

    print('Data for API Body: $Messagetoken, $UserID, $role');

    var request = http.Request('POST', Uri.parse(LocationMainUrl));
    request.body = json.encode({
      "userID": UserID.toString(),
      // "role": role,
      "token": Messagetoken
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      print('Token is revoked after API');
    } else {
      print(response.reasonPhrase);
      print('Token is not revoked after API');
    }
  }

  String RgpdUrl = "";
  String Terms = "";

  void urlData() async {
    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final RGPD = configJson['rgpd_url'];
    final ConditionTerms = configJson['terms_url'];

    print('RGPD url: $RGPD');
    print('Terms url: $ConditionTerms');

    setState(() {
      RgpdUrl = RGPD;
      Terms = ConditionTerms;
    });
  }

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    final imagePath = storage.read('imagePath2');
    List<dynamic> userRoles = storage.read('user_roles') ?? [];
    bool isChauffeur = userRoles.contains('ROLE_CHAUFFEUR');
    // bool isAdmin = userRoles.contains('ROLE_ADMIN');

    return Material(
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
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
                IconButton(
                    onPressed: () {
                      Get.to(() => RegisterDetails());
                    },
                    icon: Icon(
                      Icons.edit_rounded,
                      color: Color(0xFF3954A4),
                    )),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 3.75,
                      width: MediaQuery.of(context).size.width,
                      child: isloading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF3954A4),
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _openBottomSheet(context);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 25,
                                          right: 25,
                                        ),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 48,
                                          child: isLoading
                                              ? CircularProgressIndicator(
                                                  color: Color(0xFF3954A4),
                                                )
                                              : imagePath == null
                                                  ? Image.asset(
                                                      'assets/images/pfp2.png')
                                                  : isloading
                                                      ? CircularProgressIndicator(
                                                          color:
                                                              Color(0xFF3954A4),
                                                        )
                                                      : ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(60),
                                                          child: CircleAvatar(
                                                            backgroundColor:
                                                                Colors.white,
                                                            radius: 48,
                                                            child: Image.file(
                                                              File(imagePath),
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: isloading
                                              ? CircularProgressIndicator(
                                                  color: Color(0xFF3954A4),
                                                )
                                              : Text(
                                                  '$Nom1 $Prenom1',
                                                  style: TextStyle(
                                                    color: Color(0xFF524D4D),
                                                    fontSize: 26,
                                                    fontFamily: 'Kanit',
                                                    fontWeight: FontWeight.w500,
                                                    height: 0,
                                                  ),
                                                ),
                                        ),
                                        Container(
                                          child: isloading
                                              ? CircularProgressIndicator(
                                                  color: Color(0xFF3954A4),
                                                )
                                              : Text(
                                                  isChauffeur
                                                      ? 'Driver'
                                                      : 'Admin',
                                                  style: TextStyle(
                                                    color: Color(0xFFA3A3A3),
                                                    fontSize: 14,
                                                    fontFamily: 'Kanit',
                                                    fontWeight: FontWeight.w500,
                                                    height: 0,
                                                  ),
                                                ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 25),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.phone_outlined,
                                        color: Color(0xFFA3A3A3),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.05,
                                      ),
                                      Container(
                                        child: isloading
                                            ? CircularProgressIndicator(
                                                color: Color(0xFF3954A4),
                                              )
                                            : Text(
                                                '$telephoneNumer1',
                                                style: TextStyle(
                                                  color: Color(0xFFA3A3A3),
                                                  fontSize: 14,
                                                  fontFamily: 'Kanit',
                                                  fontWeight: FontWeight.w500,
                                                  height: 0,
                                                ),
                                              ),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 25),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.email_outlined,
                                        color: Color(0xFFA3A3A3),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.05,
                                      ),
                                      Container(
                                        child: isloading
                                            ? CircularProgressIndicator(
                                                color: Color(0xFF3954A4),
                                              )
                                            : Text(
                                                '$emailAdresse1',
                                                style: TextStyle(
                                                  color: Color(0xFFA3A3A3),
                                                  fontSize: 14,
                                                  fontFamily: 'Kanit',
                                                  fontWeight: FontWeight.w500,
                                                  height: 0,
                                                ),
                                              ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                )
                              ],
                            ),
                    ),
                    Divider(
                      thickness: 0.5,
                      color: Colors.grey,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0, top: 10),
                      child: Column(
                        children: [
                          ListTile(
                            minVerticalPadding: 20,
                            minLeadingWidth: 50,
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => NotificationScreen()));
                            },
                            leading: Image.asset(
                              'assets/images/notification.png',
                              scale: 1,
                            ),
                            title: Text(
                              'Notifications',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w400,
                                height: 0,
                              ),
                            ),
                          ),
                          isChauffeur
                              ? ListTile(
                                  minVerticalPadding: 20,
                                  minLeadingWidth: 50,
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => Download()));
                                  },
                                  leading: Image.asset(
                                    'assets/images/expense.png',
                                    scale: 1,
                                  ),
                                  title: Text(
                                    'Rapport de dépenses',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.w400,
                                      height: 0,
                                    ),
                                  ),
                                )
                              : ListTile(
                                  minVerticalPadding: 20,
                                  minLeadingWidth: 50,
                                  onTap: () {
                                    Get.to(() => Location());
                                  },
                                  leading: Image.asset(
                                    'assets/images/location6.png',
                                    scale: 1,
                                    color: Color(0xFF3954A4),
                                  ),
                                  title: Text(
                                    'location',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.w400,
                                      height: 0,
                                    ),
                                  ),
                                ),
                          ListTile(
                            minVerticalPadding: 20,
                            minLeadingWidth: 50,
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ChangePassword()));
                            },
                            leading: Image.asset(
                              'assets/images/changepass.png',
                              scale: 1,
                            ),
                            title: Text(
                              'Changer le mot de passe',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w400,
                                height: 0,
                              ),
                            ),
                          ),
                          ListTile(
                            minVerticalPadding: 20,
                            minLeadingWidth: 50,
                            onTap: () {
                              Get.to(() => RegisterDetails());
                            },
                            leading: Image.asset(
                              'assets/images/contactInfo.png',
                              scale: 1,
                            ),
                            title: Text(
                              'Détails de votre contact',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w400,
                                height: 0,
                              ),
                            ),
                          ),
                          ListTile(
                            minVerticalPadding: 20,
                            minLeadingWidth: 50,
                            onTap: () {
                              showDeleteAccountBottomSheet(context);
                            },
                            leading: Image.asset(
                              'assets/images/deleteAcc.png',
                              scale: 1,
                            ),
                            title: Text(
                              'Supprimer mon compte',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w400,
                                height: 0,
                              ),
                            ),
                          ),
                          ListTile(
                            minVerticalPadding: 20,
                            minLeadingWidth: 50,
                            onTap: () async {
                              final url = Uri.parse('$Terms');
                              if (await canLaunchUrl(url)) {
                                launchUrl(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                            leading: Image.asset(
                              'assets/images/terms.png',
                              scale: 1,
                            ),
                            title: Text(
                              'Conditions générales',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w400,
                                height: 0,
                              ),
                            ),
                          ),
                          ListTile(
                            minVerticalPadding: 20,
                            minLeadingWidth: 50,
                            onTap: () async {
                              // Get.to(() => RGPD());
                              final url = Uri.parse('$RgpdUrl');
                              if (await canLaunchUrl(url)) {
                                launchUrl(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                            leading: Image.asset(
                              'assets/images/RPGD.png',
                              scale: 1,
                            ),
                            title: Text(
                              'RGPD',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w400,
                                height: 0,
                              ),
                            ),
                          ),
                          ListTile(
                            minVerticalPadding: 20,
                            minLeadingWidth: 50,
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => versionPage()));
                            },
                            leading: Image.asset(
                              'assets/images/appVersion.png',
                              scale: 1,
                            ),
                            title: Text(
                              "Version de l'application",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w400,
                                height: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 0.5,
                      color: Colors.grey,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0, top: 10),
                      child: ListTile(
                        onTap: () async {
                          revokeFCMToken();
                          Future.delayed(Duration(milliseconds: 300), () {
                            showLogoutAccountBottomSheet(context);
                          });
                        },
                        minVerticalPadding: 20,
                        minLeadingWidth: 50,
                        leading: Image.asset(
                          'assets/images/logout.png',
                          scale: 1,
                        ),
                        title: Text(
                          "Se déconnecter",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: 'Kanit',
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
