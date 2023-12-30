// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fr.innoyadev.mkgodev/tripDetails/webview.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
// import 'package:latlng/latlng.dart';
import 'package:fr.innoyadev.mkgodev/cart/cart.dart';
import 'package:fr.innoyadev.mkgodev/homeScreen/AdminPlanning.dart';
import 'package:fr.innoyadev.mkgodev/homeScreen/DriverPlanning.dart';
import 'package:fr.innoyadev.mkgodev/homeScreen/homeScreen.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
// import 'package:fr.innoyadev.mkgodev/tripDetails/route.dart';
// import 'package:fr.innoyadev.mkgodev/tripDetails/tripLocation.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class TripDetails extends StatefulWidget {
  const TripDetails({super.key});

  @override
  State<TripDetails> createState() => _TripDetailsState();
}

class _TripDetailsState extends State<TripDetails> {
  String id = Get.arguments[0].toString();

  bool isRefreshed = false;

  Future<List<Map<String, dynamic>>> tripListPresent() async {
    final box = GetStorage();
    final _token = box.read('token') ?? '';
    final storage = GetStorage();
    final UserID = storage.read('user_id');

    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final gestionBaseUrl = configJson['planning_baseUrl'];
    final gestionApiKey = configJson['planning_apiKey'];

    final gestionMainUrl =
        gestionBaseUrl + "mob/course-chauffeur-aujourdhui/" + UserID.toString();

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

      print(apiData);

      List<Map<String, dynamic>> tripPresentAPI = [];
      for (var courses in apiData['courses']) {
        int id = courses['id'];
        // String start = courses['start'];
        int nombrePassager = courses['nombrePassager'];
        String commentaire = courses['commentaire'];
        String paiement = courses['paiement'];
        int client = courses['client'];
        String status1 = courses['affectationCourses'][0]['status1'];
        String status2 = courses['affectationCourses'][0]['status2'];
        String backgroundColor = courses['backgroundColor'];
        String dateCourse = courses['dateCourse'];
        String distanceTrajet = courses['distanceTrajet'];
        String dureeTrajet = courses['dureeTrajet'];
        String nom = courses['clientDetails']['nom'];
        String prenom = courses['clientDetails']['prenom'];
        String telephone = courses['clientDetails']['tel1'];
        String depart = courses['depart'] ?? '';
        String arrive = courses['arrive'] ?? '';
        int imgType = courses['clientDetails']['typeClient']['id'] ?? "";

        tripPresentAPI.add({
          'id': id,
          // 'start': start,
          'nombrePassager': nombrePassager,
          'commentaire': commentaire,
          'paiement': paiement,
          'client': client,
          'status1': status1,
          'status2': status2,
          'backgroundColor': backgroundColor,
          'dateCourse': dateCourse,
          'distanceTrajet': distanceTrajet,
          'dureeTrajet': dureeTrajet,
          'nom': nom,
          'prenom': prenom,
          'tel1': telephone,
          'depart': depart,
          'arrive': arrive,
          "imgType": imgType,
        });
      }

      // print(tripPresent);
      box.write('present', tripPresentAPI);
      setState(() {
        tripsPresent = tripPresentAPI;
      });

      return [];
    } else {
      print(response.reasonPhrase);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> tripListFuture() async {
    final box = GetStorage();
    final _token = box.read('token') ?? '';
    final storage = GetStorage();
    final UserID = storage.read('user_id');

    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final gestionBaseUrl = configJson['planning_baseUrl'];
    final gestionApiKey = configJson['planning_apiKey'];

    final gestionMainUrl =
        gestionBaseUrl + "mob/course-chauffeur-avenir/" + UserID.toString();

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

      List<Map<String, dynamic>> tripFutureAPI = [];
      for (var courses in apiData['courses']) {
        int id = courses['id'];
        // String start = courses['start'];
        int nombrePassager = courses['nombrePassager'];
        String commentaire = courses['commentaire'];
        String paiement = courses['paiement'];
        int client = courses['client'];
        String status1 = courses['affectationCourses'][0]['status1'];
        String status2 = courses['affectationCourses'][0]['status2'];
        String backgroundColor = courses['backgroundColor'];
        String dateCourse = courses['dateCourse'];
        String distanceTrajet = courses['distanceTrajet'];
        String dureeTrajet = courses['dureeTrajet'];
        String nom = courses['clientDetails']['nom'];
        String prenom = courses['clientDetails']['prenom'];
        String telephone = courses['clientDetails']['tel1'];
        String depart = courses['depart'] ?? '';
        String arrive = courses['arrive'] ?? '';
        int imgType = courses['clientDetails']['typeClient']['id'] ?? "";
        tripFutureAPI.add({
          'id': id,
          // 'start': start,
          'nombrePassager': nombrePassager,
          'commentaire': commentaire,
          'paiement': paiement,
          'client': client,
          'status1': status1,
          'status2': status2,
          'backgroundColor': backgroundColor,
          'dateCourse': dateCourse,
          'distanceTrajet': distanceTrajet,
          'dureeTrajet': dureeTrajet,
          'nom': nom,
          'prenom': prenom,
          'tel1': telephone,
          'depart': depart,
          'arrive': arrive,
          "imgType": imgType,
        });
      }

      // print(tripFuture);
      box.write('future', tripFutureAPI);
      List<dynamic> tripFuture2 = box.read('future') ?? [];
      setState(() {
        tripsFuture = tripFutureAPI;
      });

      return [];
    } else {
      print(response.reasonPhrase);
    }
    return [];
  }

  // late GoogleMapController _controller;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    setState(() {
      isRefreshed = true;
    });

    tripDetails();
    getDetails();
    // _generateRouteCoordinates();
  }

  String nom = "";
  String prenom = "";

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
      setState(() {
        nom = name2;
        prenom = surname2;
      });
      setState(() {
        isRefreshed = false;
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  List<dynamic> mainTripDetails = [];
  String comment = "";
  String payment = "";
  String referenceNumber = "";
  String address1 = "";
  String address2 = "";
  String file1 = "";
  String file2 = "";
  String telephoneNumber = "";
  String distance = '';
  String time = '';
  String WebFile1 = "";
  String WebFile2 = "";

  void decoding() {
    String hashedFile1 = sha256.convert(utf8.encode(file1)).toString();

    String hashedFile2 = sha256.convert(utf8.encode(file2)).toString();

    setState(() {
      WebFile1 = hashedFile1;
      WebFile2 = hashedFile2;
      BaseUrl1 = "https://d-fe.mk-go.fr/#/files/get/$WebFile1";
      BaseUrl2 = "https://d-fe.mk-go.fr/#/files/get/$WebFile2";
    });
  }

  String BaseUrl1 = "";
  String BaseUrl2 = "";

  Future<List<Map<String, String>>> tripDetails() async {
    final box = GetStorage();
    final _token = box.read('token') ?? '';

    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final gestionBaseUrl = configJson['planning_baseUrl'];
    final gestionApiKey = configJson['planning_apiKey'];

    final gestionMainUrl =
        gestionBaseUrl + "mob/detailscourse/" + id.toString();

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

      // print(apiData);

      print('File Name 1 from API :${apiData["filename1"]}');
      print('File Name 2 from API :${apiData["filename2"]}');

      setState(() {
        referenceNumber = apiData['reference'];
        comment = apiData['commentaire'];
        payment = apiData['paiement'];
        address1 = apiData['depart'];
        address2 = apiData['arrive'];
        file1 = apiData['filename1'];
        file2 = apiData['filename2'];
        telephoneNumber = apiData['clientDetails']['tel1'];
        distance = apiData['distanceTrajet'];
        time = apiData['dureeTrajet'];
      });

      print("File Name !:$file1");

      decoding();

      List<Map<String, String>> tripDetailsList = [];

      int id = apiData['id'];
      int nombrePassager = apiData['nombrePassager'];
      String commentaire = apiData['commentaire'];
      String paiement = apiData['paiement'];
      int client = apiData['client'];
      String reference = apiData['reference'];
      // String referencefinal = apiData['reference'];
      // String reference = apiData['reference'];
      String status1 = apiData['affectationCourses'][0]['status1'];
      String status2 = apiData['affectationCourses'][0]['status2'];
      String backgroundColor = apiData['backgroundColor'];
      String dateCourse = apiData['dateCourse'];
      String distanceTrajet = apiData['distanceTrajet'];
      String dureeTrajet = apiData['dureeTrajet'];
      String nom = apiData['clientDetails']['nom'];
      String prenom = apiData['clientDetails']['prenom'];
      String telephone = apiData['clientDetails']['tel1'];
      String depart = apiData['depart'] ?? '';
      String arrive = apiData['arrive'] ?? '';
      int imgType = apiData['clientDetails']['typeClient']['id'] ?? "";

      // Create a map with the extracted values
      Map<String, String> tripDetails = {
        'id': id.toString(),
        'nombrePassager': nombrePassager.toString(),
        'commentaire': commentaire,
        'paiement': paiement,
        'client': client.toString(),
        'refernce': reference,
        'status1': status1,
        'status2': status2,
        'backgroundColor': backgroundColor,
        'dateCourse': dateCourse,
        'distanceTrajet': distanceTrajet,
        'dureeTrajet': dureeTrajet,
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
        'depart': depart,
        'arrive': arrive,
        'imgType': imgType.toString(),
      };

      tripDetailsList.add(tripDetails);

      tripListPresent();
      tripListFuture();

      setState(() {
        mainTripDetails = tripDetailsList;
        isRefreshed = false;
      });
      return tripDetailsList;
    } else {
      print(response.reasonPhrase);
    }
    return [];
  }

  String status = "";
  String acceptedStatus = "";

  Future<dynamic> acceptTrip(BuildContext context) {
    // print("Statues :${Status1}, ${Status2}, ${bkgColor}");
    return showModalBottomSheet(
      backgroundColor: Color(0xFFE6F7FD),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(38),
        ),
      ),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Status',
                              style: TextStyle(
                                color: Color(0xFF524D4D),
                                fontSize: 18,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w400,
                                height: 0.05,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 75,
                      ),
                      Divider(
                        thickness: 0.5,
                        color: Colors.grey,
                      ),
                      Container(
                        color: Color(0xFFE6F7FD),
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 30,
                            ),
                            Flexible(
                              child: RadioListTile(
                                title: GestureDetector(
                                    onTap: () {},
                                    child: Text(
                                      'Accepte',
                                      style: TextStyle(fontSize: 18),
                                    )),
                                value: "Accepte",
                                groupValue: status,
                                onChanged: (value) {
                                  setState(() {
                                    status = value.toString();
                                  });
                                },
                              ),
                            ),
                            Flexible(
                              child: RadioListTile(
                                title: Text(
                                  'Refuser',
                                  style: TextStyle(fontSize: 18),
                                ),
                                value: "Refuser",
                                groupValue: status,
                                onChanged: (value) {
                                  setState(() {
                                    status = value.toString();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 15,
                      ),
                      GestureDetector(
                        onTap: () {
                          print(
                              '==================================================');
                          setState(() {
                            isRefreshed = true;
                          });
                          updateTripStatus();
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 333,
                          height: 49,
                          decoration: ShapeDecoration(
                            color: Color(0xFF3556A7),
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
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Text(
                                'Valider',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'Kanit',
                                  fontWeight: FontWeight.w500,
                                  height: 0.04,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    )..whenComplete(() => setState(() {
          isRefreshed = true;
          Future.delayed(Duration(milliseconds: 500), () {
            setState(() {
              isRefreshed = false;
            });
          });
        }));
  }

  Future<dynamic> openAccepterBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      backgroundColor: Color(0xFFE6F7FD),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(38),
        ),
      ),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (
            context,
            setState,
          ) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 1.5,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Status',
                              style: TextStyle(
                                color: Color(0xFF524D4D),
                                fontSize: 18,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w400,
                                height: 0.05,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 75,
                      ),
                      Divider(
                        thickness: 0.5,
                        color: Colors.grey,
                      ),
                      // Add your additional RadioListTile widgets here
                      RadioListTile(
                        title: Text('En Route'),
                        value: "En route",
                        groupValue: acceptedStatus,
                        onChanged: (value) {
                          setState(() {
                            acceptedStatus = value.toString();
                          });
                        },
                      ),
                      RadioListTile(
                        title: Text('Sur Place'),
                        value: "Sur place",
                        groupValue: acceptedStatus,
                        onChanged: (value) {
                          setState(() {
                            acceptedStatus = value.toString();
                            print(
                                'Second Status after accepted: $acceptedStatus');
                          });
                        },
                      ),
                      RadioListTile(
                        title: Text('Client Abord'),
                        value: "Client abord",
                        groupValue: acceptedStatus,
                        onChanged: (value) {
                          setState(() {
                            acceptedStatus = value.toString();
                          });
                        },
                      ),
                      RadioListTile(
                        title: Text('Absent + Displacement'),
                        value: "Client absent",
                        groupValue: acceptedStatus,
                        onChanged: (value) {
                          setState(() {
                            acceptedStatus = value.toString();
                          });
                        },
                      ),
                      RadioListTile(
                        title: Text('Terminer'),
                        value: "Terminee",
                        groupValue: acceptedStatus,
                        onChanged: (value) {
                          setState(() {
                            acceptedStatus = value.toString();
                          });
                        },
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 15,
                      ),
                      GestureDetector(
                        onTap: () async {
                          // print('----------------$acceptedStatus-----------');
                          setState(() {
                            isRefreshed = true;
                          });
                          updateTripStatus2();
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 333,
                          height: 49,
                          decoration: ShapeDecoration(
                            color: Color(0xFF3556A7),
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
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Text(
                                'Valider',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'Kanit',
                                  fontWeight: FontWeight.w500,
                                  height: 0.04,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 15,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() => setState(() {
          isRefreshed = true;
          Future.delayed(Duration(milliseconds: 500), () {
            setState(() {
              isRefreshed = false;
            });
          });
        }));
  }

  Color _getStatusColor(String status1, String status2) {
    switch ("$status1-$status2") {
      case '1-1':
        return Colors.grey;
      case '0-0':
        return Colors.orange;
      case '1-2':
        return Colors.yellow.shade600;
      case '1-5':
        return Colors.purple.shade900;
      case '1-3':
        return Colors.pink.shade400;
      case '1-4':
        return Colors.pink.shade900;
      case '1-0':
        return Colors.green;
      default:
        return Color(0xFF135DB9);
    }
  }

  String getStatusText(String status1, String status2) {
    String statusText;

    switch ("$status1-$status2") {
      case "0-0":
        statusText = "En Attente";
        break;
      case "1-0":
        statusText = "Accepter";
        break;
      case "1-1":
        statusText = "En Route";
        break;
      case "1-2":
        statusText = "Sur Place";
        break;
      case "1-3":
        statusText = "Absent + Deplacement";
        break;
      case "1-4":
        statusText = "Terminé";
        break;
      case "1-5":
        statusText = "Abord";
        break;
      default:
        statusText = "No Status Available";
        break;
    }

    return statusText;
  }

  Image? getImageBasedOnType(String imgType) {
    switch (imgType) {
      case "1":
        return Image.asset(
          'assets/images/taxi.png',
          scale: 2,
          filterQuality: FilterQuality.high,
        );
      case "2":
        return Image.asset(
          'assets/images/ambulance.png',
          scale: 2,
          filterQuality: FilterQuality.high,
        );
      case "3":
        return Image.asset(
          'assets/images/school.png',
          scale: 2,
          filterQuality: FilterQuality.high,
        );
      default:
        return null;
    }
  }

  Future<void> updateTripStatus() async {
    final box = GetStorage();
    final _token = box.read('token') ?? '';

    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final gestionBaseUrl = configJson['planning_baseUrl'];
    final gestionApiKey = configJson['planning_apiKey'];

    final gestionMainUrl =
        gestionBaseUrl + "mob/course-accepte-refuse/" + id.toString();

    var headers = {
      'x-api-key': '$gestionApiKey',
      'Authorization': 'Bearer ' + _token
    };

    var request = http.Request('POST', Uri.parse(gestionMainUrl));
    request.body = json.encode({
      "etat": status,
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());

      Get.snackbar(
        colorText: Colors.white,
        'Success',
        'Trip is Accepted',
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
          'Trip is Accepted',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
      );
      tripDetails();
      tripListPresent();
      tripListFuture();

      Get.to(() => TripDetails());

      setState(() {
        isRefreshed = false;
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> updateTripStatus2() async {
    final box = GetStorage();
    final _token = box.read('token') ?? '';

    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final gestionBaseUrl = configJson['planning_baseUrl'];
    final gestionApiKey = configJson['planning_apiKey'];

    final gestionMainUrl = gestionBaseUrl + "mob/course-etat/" + id.toString();

    var headers = {
      'x-api-key': '$gestionApiKey',
      'Authorization': 'Bearer ' + _token
    };

    var request = http.Request('POST', Uri.parse(gestionMainUrl));
    request.body = json.encode({
      "etat2": acceptedStatus,
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());

      Get.snackbar(
        colorText: Colors.white,
        'Success',
        'Trip is Updated',
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
          'Trip is Updated',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
      );
      tripDetails();
      tripListPresent();
      tripListFuture();

      Get.to(() => TripDetails());

      setState(() {
        isRefreshed = false;
      });

      // Navigator.of(context).pop();
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> launchGoogleMap(String source, String destination) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&origin=$source&destination=$destination';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
 
  Future<void> launchWazeMap(String source, String destination) async {
    final url =
        "https://www.waze.com/ul?ll=$source,$destination&navigate=yes";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> currentLocaionlaunchMap(String destination) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=$destination';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void loadInitialData() {
    print('loadmoredata fucntion is calling');

    tripDetails();
    tripListPresent();
    tripListFuture();

    setState(() {
      tripsPresent = tripsPresent.toList();
      tripsFuture = tripsFuture.toList();
    });
  }

  Future<void> handleRefresh() async {
    setState(() {
      isRefreshed = true;
    });
    await Future.delayed(Duration(milliseconds: 600), () {
      // tripListPast();
      // tripListPresent();
      // tripListFuture();
      loadInitialData();
      // filteredListDriver();
      setState(() {
        isRefreshed = false;
      });
    });
  }

  void _showMapChooserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width /
                1.15, // Set your desired width
            // height: MediaQuery.of(context).size.height /
            //     2.5, // Set your desired height
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Color(0xFFE6F7FD), // Set your desired background color
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Choisissez l'application pour lancer la carte",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      // fontWeight: FontWeight.bold,
                      fontFamily: 'Kanit'),
                      textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    onTap: (){
                      launchGoogleMap(address1, address2);
                    },
                    leading: Image.asset('assets/images/gmaps.png'),
                    title: Text(
                      'Google Maps',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          // fontWeight: FontWeight.bold,
                          fontFamily: 'Kanit'),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    onTap: (){
                      launchWazeMap(address1, address2);
                    },
                    leading: Image.asset('assets/images/waze.png'),
                    title: Text(
                      'Waze',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          // fontWeight: FontWeight.bold,
                          fontFamily: 'Kanit'),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                  width: 250,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF3954A4),
                    ),
                    child: Text('Annuler'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    List<dynamic> userRoles = storage.read('user_roles') ?? [];
    bool isChauffeur = userRoles.contains('ROLE_CHAUFFEUR');
    bool isAdmin = userRoles.contains('ROLE_ADMIN');

    // String statusText = getStatusText(Status1, Status2);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 0, top: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    (isChauffeur)
                        ? Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => LandingScreen2()))
                        : (isAdmin)
                            ? Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => LandingScreen1()))
                            : null;
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    size: 30,
                    color: Color(0xFF3954A4),
                  ),
                )
              ],
            ),
          ),
          // SizedBox(
          //   height: MediaQuery.of(context).size.height / 35,
          // ),
          isRefreshed
              ? Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                    color: Color(0xFF3954A4),
                  ))
              : Expanded(
                  child: LiquidPullToRefresh(
                    backgroundColor: Color(0xFF3954A4),
                    height: 80,
                    animSpeedFactor: 2,
                    showChildOpacityTransition: false,
                    color: Colors.white,
                    onRefresh: handleRefresh,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: ListView(
                        children: [
                          Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              width: MediaQuery.of(context).size.width / 1.12,
                              height: 170,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                                shadows: [
                                  BoxShadow(
                                    color: Color(0x3F000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 0),
                                    spreadRadius: 0,
                                  )
                                ],
                              ),
                              child: isRefreshed
                                  ? Center(
                                      child: CircularProgressIndicator(
                                      color: Color(0xFF3954A4),
                                    ))
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: mainTripDetails.length,
                                      itemBuilder: (context, index) {
                                        final item = mainTripDetails[index];
                                        String Status1 = item['status1'];
                                        String Status2 = item['status2'];
                                        String imgType =
                                            item['imgType'].toString();
                                        String date = item['dateCourse'];
                                        String borderColor =
                                            item['backgroundColor'];
                                        print(
                                            'Background color from the list: $borderColor');
                                        DateTime dateTime =
                                            DateTime.parse(date);
                                        tz.TZDateTime parisDateTime =
                                            tz.TZDateTime.from(dateTime,
                                                tz.getLocation('Europe/Paris'));

                                        String formattedDate =
                                            DateFormat('dd.MMM.yyyy \nhh:MM')
                                                .format(parisDateTime);

                                        return Column(
                                          // mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5, vertical: 8),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "${item['nom']}\n${item['prenom']}",
                                                    // '$nom $prenom',
                                                    style: TextStyle(
                                                      color: Color(0xFF524D4D),
                                                      fontSize: 15,
                                                      fontFamily: 'Kanit',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      height: 0,
                                                    ),
                                                  ),
                                                  Text(
                                                    formattedDate,
                                                    style: TextStyle(
                                                      color: Color(0xFF524D4D),
                                                      fontSize: 15,
                                                      fontFamily: 'Kanit',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      height: 0,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.zero,
                                                    width: 40,
                                                    height: 40,
                                                    decoration: ShapeDecoration(
                                                      color: Colors.white,
                                                      shape: OvalBorder(),
                                                      shadows: [
                                                        BoxShadow(
                                                          color:
                                                              Color(0x3F000000),
                                                          blurRadius: 4,
                                                          offset: Offset(0, 0),
                                                          spreadRadius: 0,
                                                        )
                                                      ],
                                                    ),
                                                    child: getImageBasedOnType(
                                                        imgType),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () async {
                                                      if (isChauffeur) {
                                                        if (Status1 == "0" &&
                                                            Status2 == "0") {
                                                          acceptTrip(context);
                                                        } else if ((Status1 ==
                                                                    "1" &&
                                                                Status2 ==
                                                                    "3") ||
                                                            Status1 == "1" &&
                                                                Status2 ==
                                                                    "4") {
                                                          null;
                                                        } else {
                                                          openAccepterBottomSheet(
                                                              context);
                                                        }
                                                      } else {
                                                        null;
                                                      }
                                                    },
                                                    child: Container(
                                                      // width: 220,
                                                      height: 24,
                                                      decoration:
                                                          ShapeDecoration(
                                                        color: _getStatusColor(
                                                            Status1, Status2),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8)),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 5),
                                                        child: Center(
                                                          child: Text(
                                                            getStatusText(
                                                                Status1,
                                                                Status2),
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 13,
                                                              fontFamily:
                                                                  'Kanit',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              height: 0,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(
                                                      left: 10,
                                                      right: 10,
                                                      top: 15),
                                              child: Row(
                                                children: [
                                                  Flexible(
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        print(
                                                            'telephone Number: $telephoneNumber');
                                                        final call = Uri.parse(
                                                            'tel: $telephoneNumber');
                                                        if (await canLaunchUrl(
                                                            call)) {
                                                          launchUrl(call);
                                                        } else {
                                                          throw 'Could not launch $call';
                                                        }
                                                      },
                                                      child: Container(
                                                        width: 50,
                                                        height: 34,
                                                        decoration:
                                                            ShapeDecoration(
                                                          color:
                                                              Color(0xFFECF4FF),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                        ),
                                                        child: Icon(
                                                          Icons.phone,
                                                          size: 20,
                                                          color:
                                                              Color(0xFF135DB9),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Flexible(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        _showMapChooserDialog(
                                                            context);
                                                      },
                                                      child: Container(
                                                          width: 50,
                                                          height: 34,
                                                          decoration:
                                                              ShapeDecoration(
                                                            color: Color(
                                                                0xFFECF4FF),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5)),
                                                          ),
                                                          child: Image.asset(
                                                              'assets/images/maps.png')),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Container(
                                                    // width: 120,
                                                    height: 34,
                                                    decoration: ShapeDecoration(
                                                      color: Color(0xFFECF4FF),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        children: [
                                                          Image.asset(
                                                              'assets/images/watch.png'),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(
                                                            '$time minutes',
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xFF6E6868),
                                                              fontSize: 12,
                                                              fontFamily:
                                                                  'Kanit',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              height: 0,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                          ],
                                        );
                                      })),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 1.12,
                            height: MediaQuery.of(context).size.height / 4.5,
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                              shadows: [
                                BoxShadow(
                                  color: Color(0x3F000000),
                                  blurRadius: 5,
                                  // offset: Offset(0, 0),
                                  spreadRadius: 0,
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/images/location2.png'),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Image.asset('assets/images/car.png'),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Flexible(
                                  child: GestureDetector(
                                    onTap: () {
                                      currentLocaionlaunchMap(address1);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Text(
                                        address1,
                                        style: TextStyle(
                                          color: Color(0xFF524D4D),
                                          fontSize: 14,
                                          fontFamily: 'Kanit',
                                          fontWeight: FontWeight.w400,
                                          height: 0,
                                        ),
                                        textAlign: TextAlign.center,
                                        // overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/images/car4.png'),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Image.asset('assets/images/location5.png'),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Flexible(
                                  child: GestureDetector(
                                    onTap: () {
                                      currentLocaionlaunchMap(address2);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Text(
                                        address2,
                                        style: TextStyle(
                                          color: Color(0xFF524D4D),
                                          fontSize: 14,
                                          fontFamily: 'Kanit',
                                          fontWeight: FontWeight.w400,
                                          height: 0,
                                        ),
                                        textAlign: TextAlign.center,
                                        // overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 1.12,
                            height: 450,
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                              shadows: [
                                BoxShadow(
                                  color: Color(0x3F000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 0),
                                  spreadRadius: 0,
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ListTile(
                                  leading: Text(
                                    'Trajet',
                                    style: TextStyle(
                                      color: Color(0xFF524D4D),
                                      fontSize: 14,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.w400,
                                      height: 0,
                                    ),
                                  ),
                                  trailing: Text(
                                    distance,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: Color(0xFF3954A4),
                                      fontSize: 14,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.w500,
                                      height: 0,
                                    ),
                                  ),
                                ),
                                ListTile(
                                  leading: Text(
                                    'Type de paiement',
                                    style: TextStyle(
                                      color: Color(0xFF524D4D),
                                      fontSize: 14,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.w400,
                                      height: 0,
                                    ),
                                  ),
                                  trailing: Text(
                                    payment,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: Color(0xFF3954A4),
                                      fontSize: 14,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.w500,
                                      height: 0,
                                    ),
                                  ),
                                ),
                                ListTile(
                                  leading: Text(
                                    'Commentaire',
                                    style: TextStyle(
                                      color: Color(0xFF524D4D),
                                      fontSize: 14,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.w400,
                                      height: 0,
                                    ),
                                  ),
                                  trailing: Text(
                                    comment,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: Color(0xFF3954A4),
                                      fontSize: 14,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.w500,
                                      height: 0,
                                    ),
                                  ),
                                ),
                                ListTile(
                                    leading: Text(
                                      'Fichier 1:',
                                      style: TextStyle(
                                        color: Color(0xFF524D4D),
                                        fontSize: 14,
                                        fontFamily: 'Kanit',
                                        fontWeight: FontWeight.w400,
                                        height: 0,
                                      ),
                                    ),
                                    trailing: (file1 != "")
                                        ? IconButton(
                                            onPressed: () {
                                              // setState(() {
                                              //   BaseUrl = BaseUrl + "$file1";
                                              // });

                                              print(
                                                  'Final Base Url is: $BaseUrl1');

                                              Get.to(() => WebViewScreen(),
                                                  arguments: [BaseUrl1]);
                                            },
                                            icon: Icon(
                                              Icons.visibility,
                                              color: Color(0xFF3954A4),
                                            ))
                                        : Text(
                                            "N/A",
                                            style: TextStyle(
                                              color: Color(0xFF3954A4),
                                              fontSize: 14,
                                              fontFamily: 'Kanit',
                                              fontWeight: FontWeight.w500,
                                              height: 0,
                                            ),
                                          )),
                                ListTile(
                                    leading: Text(
                                      'Fichier 2:',
                                      style: TextStyle(
                                        color: Color(0xFF524D4D),
                                        fontSize: 14,
                                        fontFamily: 'Kanit',
                                        fontWeight: FontWeight.w400,
                                        height: 0,
                                      ),
                                    ),
                                    trailing: (file2 != "")
                                        ? IconButton(
                                            onPressed: () {
                                              print(
                                                  'Final Base Url is: $BaseUrl2');

                                              Get.to(() => WebViewScreen(),
                                                  arguments: [BaseUrl2]);
                                            },
                                            icon: Icon(
                                              Icons.visibility,
                                              color: Color(0xFF3954A4),
                                            ),
                                          )
                                        : Text(
                                            "N/A",
                                            style: TextStyle(
                                              color: Color(0xFF3954A4),
                                              fontSize: 14,
                                              fontFamily: 'Kanit',
                                              fontWeight: FontWeight.w500,
                                              height: 0,
                                            ),
                                          )),
                                ListTile(
                                  leading: isChauffeur
                                      ? Text(
                                          'Chauffeur',
                                          style: TextStyle(
                                            color: Color(0xFF524D4D),
                                            fontSize: 14,
                                            fontFamily: 'Kanit',
                                            fontWeight: FontWeight.w400,
                                            height: 0,
                                          ),
                                        )
                                      : isAdmin
                                          ? Text(
                                              'Chauffeur',
                                              style: TextStyle(
                                                color: Color(0xFF524D4D),
                                                fontSize: 14,
                                                fontFamily: 'Kanit',
                                                fontWeight: FontWeight.w400,
                                                height: 0,
                                              ),
                                            )
                                          : null,
                                  trailing: Text(
                                    '${nom} ${prenom}',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: Color(0xFF3954A4),
                                      fontSize: 14,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.w500,
                                      height: 0,
                                    ),
                                  ),
                                ),
                                ListTile(
                                  leading: Text(
                                    'Référence',
                                    style: TextStyle(
                                      color: Color(0xFF524D4D),
                                      fontSize: 14,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.w400,
                                      height: 0,
                                    ),
                                  ),
                                  trailing: Text(
                                    referenceNumber,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: Color(0xFF3954A4),
                                      fontSize: 14,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.w500,
                                      height: 0,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 35,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
        ],
      ),
    );
  }
}
