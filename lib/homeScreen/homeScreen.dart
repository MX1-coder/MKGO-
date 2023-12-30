// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, sort_child_properties_last, avoid_unnecessary_containers, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unused_local_variable, sized_box_for_whitespace, avoid_print, prefer_interpolation_to_compose_strings

import 'dart:async';
import 'dart:convert';
// import 'dart:js_interop';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fr.innoyadev.mkgodev/Utility/bottomSheet.dart';
import 'package:fr.innoyadev.mkgodev/login/loginModel.dart';
import 'package:fr.innoyadev.mkgodev/profile/profile.dart';
import 'package:fr.innoyadev.mkgodev/tripDetails/tripDetails.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:pie_menu/pie_menu.dart';

GetStorage box = GetStorage();
bool isPasser = false;
bool isAujoudHui = false;
bool isAvenir = false;
bool isRefreshed = false;
// bool handOpen = false;

List<Map<String, dynamic>> filteredList = [] ?? [];
List<Map<String, dynamic>> trips = [] ?? [];
List<Map<String, dynamic>> tripsPresent = [] ?? [];
List<Map<String, dynamic>> tripsFuture = [] ?? [];

List<bool>? handOpen = isPasser
    ? List.generate(trips.length, (index) => false, growable: true)
    : isAujoudHui
        ? List.generate(tripsPresent.length, (index) => false, growable: true)
        : isAvenir
            ? List.generate(tripsPresent.length, (index) => false,
                growable: true)
            : null;

// filteredList = box.read('filteredListDriver');

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController searchController = TextEditingController();
  TextEditingController returnController = TextEditingController();

  Future<List<Map<String, dynamic>>> tripListPast() async {
    final box = GetStorage();
    final _token = box.read('token') ?? '';
    final storage = GetStorage();
    final UserID = storage.read('user_id');

    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final gestionBaseUrl = configJson['planning_baseUrl'];
    final gestionApiKey = configJson['planning_apiKey'];

    final gestionMainUrl =
        gestionBaseUrl + "mob/course-chauffeur-passe/" + UserID.toString();

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
      print('Chauffeur id for the specific trip: ${apiData['chauffeur']}');

      List<Map<String, dynamic>> tripList = [];
      for (var courses in apiData['courses']) {
        int id = courses['id'];
        // String start = courses['start'];
        int nombrePassager = courses['nombrePassager'];
        String commentaire = courses['commentaire'];
        String paiement = courses['paiement'];
        String chauffeur = courses['chauffeur'];
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
        tripList.add({
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
          "chauffeur": chauffeur
        });
      }

      // print(tripList);
      box.write('tripList', tripList);
      print('Checking list for chauffeurid: $tripList');
      setState(() {
        trips = tripList;
      });

      return [];
    } else {
      print(response.reasonPhrase);
    }
    return [];
  }

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

      // print('Chauffeur id for the specific trip: ${apiData['courses']['chauffeur'].toString()}');
      print(apiData);

      List<Map<String, dynamic>> tripPresentAPI = [];
      for (var courses in apiData['courses']) {
        int id = courses['id'];
        // String start = courses['start'];
        int nombrePassager = courses['nombrePassager'];
        String commentaire = courses['commentaire'];
        String paiement = courses['paiement'];
        String chauffeur = courses['chauffeur'];
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
          "chauffeur": chauffeur
        });
      }

      // print(tripPresent);
      box.write('present', tripPresentAPI);
      print('Checking list for chauffeurid: $tripPresentAPI');
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
        String chauffeur = courses['chauffeur'];
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
          'chauffeur': chauffeur
        });
      }

      // print(tripFuture);
      box.write('future', tripFutureAPI);
      print('Checking list for chauffeurid: $tripFutureAPI');
      setState(() {
        tripsFuture = tripFutureAPI;
      });

      return [];
    } else {
      print(response.reasonPhrase);
    }
    return [];
  }

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
     
    
    } else {
      print(response.reasonPhrase);
    }
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 5,
          title: Text('Return Ride??'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey, width: 0.5)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Motive For Return",
                    ),
                  ),
                ),
              ),
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
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Color(0xFF3954A4)),
                    child: Text('Return\nRide'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  int currentPage = 1;
  int itemsPerPage = 10;
  int itemsPerPage2 = 5;
  bool isAtEndOfList = false;

  final GlobalKey<_HomeScreen2State> _key = GlobalKey<_HomeScreen2State>();

  @override
  void initState() {
    super.initState();
    // _requestLocationAndNotificationPermission();
    // init();
    decoding();
    _requestLocationAndNotificationPermission();
    init();
    _changeAujourdHuiContainerColor();

    passerContainerColor = Colors.white;
    aujourdhuiContainerColor = Color(0xFFF8B43D);
    avenirContainerColor = Colors.white;

    setState(() {
      isAujoudHui = true;
      isPasser = false;
      isAvenir = false;
      isRefreshed = true;
    });

    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        isRefreshed = false;
      });
    });
    submitForm();
    getHotline();
    typeList();
    tripListPast();
    tripListPresent();
    tripListFuture();
    loadInitialData();

    controller = ScrollController()..addListener(_scrollListener);
    print('Controller : $controller');
    print('Testinf in inistState');
    filteredList.clear();
  }

  Future<void> submitForm() async {
    ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      showNoInternetError();
    } else {}
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
                    Get.offAll(() => false);
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

  Color passerContainerColor = Colors.white;
  Color aujourdhuiContainerColor = Color(0xFFF8B43D);
  Color avenirContainerColor = Colors.white;

  void _changePasserContainerColor() {
    tripListPast();
    loadInitialData();
    setState(() {
      passer = "passer";
      today = "";
      future = "";
      passerContainerColor = Color(0xFFF8B43D);
      aujourdhuiContainerColor = Colors.white;
      avenirContainerColor = Colors.white;
      print('passeAvenirToday : $passer');
    });
    setState(() {
      isPasser = true;
      isRefreshed = true;
      isAujoudHui = false;
      isAvenir = false;
    });
    Future.delayed(Duration(milliseconds: 300), () {
      tripListPast();
      setState(() {
        isRefreshed = false;
      });
    });
  }

  void _changeAujourdHuiContainerColor() {
    tripListPresent();
    loadInitialData();
    setState(() {
      today = 'today';
      passer = "";
      future = "";
      passerContainerColor = Colors.white;
      aujourdhuiContainerColor = Color(0xFFF8B43D);
      avenirContainerColor = Colors.white;
      print('passeAvenirToday : $today');
      isAujoudHui = true;
      isRefreshed = true;
      isPasser = false;
      isAvenir = false;
    });
    Future.delayed(Duration(milliseconds: 300), () {
      tripListPresent();
      setState(() {
        isRefreshed = false;
      });
    });
  }

  void _changeAvenirContainerColor() {
    tripListFuture();
    loadInitialData();
    setState(() {
      future = "Avenir";
      today = "";
      passer = "";
      passerContainerColor = Colors.white;
      aujourdhuiContainerColor = Colors.white;
      avenirContainerColor = Color(0xFFF8B43D);
      print('passeAvenirToday : $future');
    });
    setState(() {
      isAvenir = true;
      isRefreshed = true;
      isPasser = false;
      isAujoudHui = false;
    });
    Future.delayed(Duration(milliseconds: 300), () {
      tripListFuture();
      setState(() {
        isRefreshed = false;
      });
    });
  }

  void decoding() {
    String originalValue = "Hello, World!";

    // Hash the original value using SHA-256
    String hashedValue = sha256.convert(utf8.encode(originalValue)).toString();

    print("Original Value: $originalValue");
    print("Hashed Value: $hashedValue");

    // Now, let's check if a given input matches the hashed value
    String inputToCheck =
        "Hello, World!"; // Change this to test different values

    String hashedInput = sha256.convert(utf8.encode(inputToCheck)).toString();

    if (hashedInput == hashedValue) {
      print("Input matches the hashed value!");
    } else {
      print("Input does not match the hashed value.");
    }
  }

  Future<void> handleRefresh() async {
    setState(() {
      isRefreshed = true;
    });
    await Future.delayed(Duration(milliseconds: 500), () {
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

  bool showOptions = false;
  bool isDimmed = false;
  List<String> selectedItems = [];
  String selectedType = '';
  final TextEditingController _typeController = TextEditingController();

  Future<List<Map<String, dynamic>>> typeList() async {
    final box = GetStorage();
    final _token = box.read('token') ?? '';

    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final gestionBaseUrl = configJson['gestion_baseUrl'];
    final gestionApiKey = configJson['gestion_apiKey'];

    final gestionMainUrl = gestionBaseUrl + "api/liste/type/client";

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

      if (apiData.containsKey("collections")) {
        final List<dynamic> typeData = apiData["collections"] ?? [];
        List<Map<String, dynamic>> type = typeData.map((item) {
          return {
            "id": item["id"].toString(),
            "libelle": item["libelle"].toString(),
          };
        }).toList();
        box.write('type2', type);

        return type;
      } else {}
    } else {
      print(response.reasonPhrase);
    }
    return [];
  }

  Future<dynamic> bottomSheet1(BuildContext context) {
    ScrollController _controller2 = ScrollController();

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController searchController1 = TextEditingController();

    void clearTextField() {
      searchController1.text = '';
    }

    final box = GetStorage();
    List<dynamic> type = (box.read('type2') ?? []);
    print("Type List in the Bottomsheet: $type");
    List<dynamic> filteredType = List.from(type);

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
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 1.6,
                child: Center(
                  child: Form(
                    key: _formKey,
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
                                'Select the type of race',
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 54,
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: TextFormField(
                                onChanged: (text) {
                                  setState(() {
                                    filteredType = type
                                        .where((item) => item["libelle"]
                                            .toLowerCase()
                                            .contains(text.toLowerCase()))
                                        .toList();
                                  });
                                },
                                controller: searchController1,
                                decoration: InputDecoration(
                                  hintText: 'Search',
                                  border: InputBorder.none,
                                  suffixIcon: Icon(
                                    Icons.search,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: searchController1.text.isEmpty
                              ? ListView.builder(
                                  itemCount: type.length,
                                  itemBuilder: ((context, index) {
                                    final item = type[index];

                                    if (shouldShowLoader(index)) {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else {
                                      return ListTile(
                                        title: Text(
                                          item["libelle"],
                                          style: TextStyle(fontFamily: 'Kanit'),
                                        ),
                                        trailing: selectedItems
                                                .contains(item["libelle"])
                                            ? Icon(Icons.check,
                                                color: Colors.blue)
                                            : null,
                                        onTap: () {
                                          selectedItems.clear();

                                          final box = GetStorage();
                                          final typeDriverFilter = box.write(
                                              'typeFilter', item['id']);
                                          final typeID = box.read('typeFilter');
                                          print(
                                              'Type id for filter in get storage : $typeID');
                                          setState(() {
                                            if (selectedItems
                                                .contains(item["libelle"])) {
                                              selectedItems
                                                  .remove(item["libelle"]);
                                            } else {
                                              selectedItems
                                                  .add(item["libelle"]);
                                            }
                                          });
                                        },
                                      );
                                    }
                                  }),
                                )
                              : ListView.builder(
                                  itemCount: filteredType.length,
                                  itemBuilder: ((context, index) {
                                    final item = filteredType[index];

                                    return ListTile(
                                      title: Text(item["libelle"]),
                                      trailing: selectedItems
                                              .contains(item["libelle"])
                                          ? Icon(Icons.check,
                                              color: Colors.blue)
                                          : null,
                                      onTap: () {
                                        selectedItems.clear();
                                        final box = GetStorage();
                                        final typeDriverFilter =
                                            box.write('typeFilter', item['id']);
                                        final typeID = box.read('typeFilter');
                                        print(
                                            'Type id for filter in get storage : $typeID');
                                        setState(() {
                                          if (selectedItems
                                              .contains(item["libelle"])) {
                                            selectedItems
                                                .remove(item["libelle"]);
                                          } else {
                                            selectedItems.add(item["libelle"]);
                                          }
                                          // selectedItems.clear();
                                        });
                                      },
                                    );
                                  }),
                                ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 250,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xFF3954A4),
                                ),
                                child: Text('Valider'),
                                onPressed: () {
                                  filteredListDriver();
                                  Navigator.of(context).pop(
                                    selectedItems.join(''),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 250,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.grey,
                                ),
                                child: Text('Reset'),
                                onPressed: () {
                                  setState(() {
                                    filteredList.clear();
                                    selectedItems.clear();
                                    selectedType = '';
                                    _typeController.text = 'Type';
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() => setState(() {
          isRefreshed = true;
          _typeController.text;
          clearTextField();
          Future.delayed(Duration(milliseconds: 550), () {
            setState(() {
              isRefreshed = false;
            });
          });
        }));
  }

  Future<dynamic> bottomSheet3(BuildContext context) {
    void clearTextField() {
      returnController.text = '';
    }

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
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 3,
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
                          'Return Ride??',
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 54,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: TextField(
                          controller: returnController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Motive For Return",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 250,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Color(0xFF3954A4)),
                              child: Text('Return'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(clearTextField);
  }

  String today = "";
  String future = "";
  String passer = "";

  Future<List<Map<String, dynamic>>> filteredListDriver() async {
    final box = GetStorage();
    final _token = box.read('token') ?? '';

    final storage = GetStorage();

    final regionId = storage.read('user_region_Id');
    final typeId = box.read('typeFilter');
    final driverId = storage.read('user_id');

    print(
        'Ids for filter list admin: $regionId, $typeId, $driverId, $today, $passer, $future');

    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final gestionBaseUrl = configJson['planning_baseUrl'];
    final gestionApiKey = configJson['planning_apiKey'];

    final gestionMainUrl = gestionBaseUrl + "mob/filtre-course";

    var headers = {
      'x-api-key': '$gestionApiKey',
      'Authorization': 'Bearer ' + _token
    };

    var request = http.Request('POST', Uri.parse(gestionMainUrl));
    request.body = json.encode({
      "region": regionId,
      "typeCourse": typeId,
      // "client": clientId,
      "chauffeur": driverId,
      "passeAvenirToday": isAujoudHui
          ? today.toString()
          : isPasser
              ? passer.toString()
              : isAvenir
                  ? future.toString()
                  : ""
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final apiData = jsonDecode(responseBody);

      List<Map<String, dynamic>> Filteredlist = [];

      print('Chauffeur id for the specific trip: ${apiData['chauffeur']}');

      int total = apiData['totalCount'];
      print('Total Count : $total');
      for (var courses in apiData['courses']) {
        int id = courses['id'];
        // String start = courses['start'];
        int nombrePassager = courses['nombrePassager'];
        String commentaire = courses['commentaire'];
        String paiement = courses['paiement'];
        String chuaffeur = courses['chauffeur'];
        int client = courses['client'];
        var affectationCourses = courses['affectationCourses'];
        String reference = courses['reference'];
        String backgroundColor = courses['backgroundColor'];
        String dateCourse = courses['dateCourse'];
        // String distanceTrajet = courses['distanceTrajet'];
        // String dureeTrajet = courses['dureeTrajet'];
        String nom = courses['clientDetails']['nom'];
        String prenom = courses['clientDetails']['prenom'];
        String telephone = courses['clientDetails']['tel1'];
        int region = courses['region'];
        String depart = courses['depart'];
        String arrive = courses['arrive'];

        int imgType = courses['clientDetails']['typeClient']['id'] ?? "";
        Filteredlist.add({
          'id': id,
          // 'start': start,
          'nombrePassager': nombrePassager,
          'commentaire': commentaire,
          'paiement': paiement,
          'reference': reference,
          'dateCourse': dateCourse,
          // 'distanceTrajet': distanceTrajet,
          // 'dureeTrajet': dureeTrajet,
          'client': client,
          'region': region,
          // 'status1': status1,
          // 'status2': status2,
          'backgroundColor': backgroundColor,
          'nom': nom,
          'prenom': prenom,
          'telephone': telephone,
          'imgType': imgType,
          'depart': depart,
          'arrive': arrive,
          'chauffeur': chuaffeur
        });
      }
      print('Filtered List in API: $Filteredlist');
      box.write('filteredListDriver', Filteredlist);
      List<dynamic> filteredAdmin = box.read('filteredListDriver') ?? [];
      print('Filtered list in Storage: $filteredAdmin');
      filteredData();
      // Navigator.of(context).pop();

      return Filteredlist;
    } else {
      print(response.reasonPhrase);
    }

    return [];
  }

  String hotlineNumber = "";

  Future<void> getHotline() async {
    final box = GetStorage();
    final _token = box.read('token') ?? '';
    print("token called: $_token");

    final storage = GetStorage();
    final UserID = storage.read('user_id');

    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final gestionBaseUrl = configJson['gestion_baseUrl'];
    final gestionApiKey = configJson['gestion_apiKey'];

    final gestionMainUrl = gestionBaseUrl + "api/get/entreprise/31";

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

      String hotlineTelephone = apiData['telephone'];

      print("Hotline from api : $hotlineTelephone");

      setState(() {
        hotlineNumber = hotlineTelephone;
      });

      print('Hotline number in string: $hotlineNumber');
    } else {
      print(response.reasonPhrase);
    }
  }

  bool _logoutConfirmed = false;

  Future<void> showLogoutAccountBottomSheet2(BuildContext context) async {
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
          height: MediaQuery.of(context).size.height / 2.5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 10,
                child: Center(
                  child: Text(
                    'Se déconnecter ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Get.find<AuthController>().logout();
                  setState(() {
                    _logoutConfirmed = true;
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 55,
                  decoration: BoxDecoration(
                      border: Border(
                    top: BorderSide(width: 0.5, color: Colors.black),
                  )),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        'Confirmer',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w500,
                          height: 0.09,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Get.back(result: false); // Logout canceled
                  setState(() {
                    _logoutConfirmed = false;
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 55,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(width: 0.5, color: Colors.black),
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        'Annuler',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w500,
                          height: 0.09,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  ScrollController controller = ScrollController();
  bool isLoadingMore = false;

  // List<dynamic> trips = box.read('tripList') ?? [];
  // List<dynamic> tripsPresent = box.read('present') ?? [];
  // List<dynamic> tripsFuture = box.read('future') ?? [];
  // List<dynamic> filteredList = box.read('filteredListDriver') ?? [];

  void loadInitialData() {
    print('loadmoredata fucntion is calling');

    tripListPast();
    tripListPresent();
    tripListFuture();

    setState(() {
      trips = trips.toList();
      tripsPresent = tripsPresent.toList();
      tripsFuture = tripsFuture.toList();
    });
  }

  void filteredData() {
    print('loadmoredata fucntion is calling');

    filteredList = box.read('filteredListDriver');

    print('Past Trips in loadmore : $trips');

    setState(() {
      filteredList = filteredList.toList();
    });
  }

  int currentIndex = 0; // Keeps track of the current index

  Future<void> _scrollListener() async {
    if (controller.position.pixels == controller.position.maxScrollExtent) {
      setState(() {
        isAtEndOfList = true;
      });

      // Simulate a delay before loading more items (adjust the duration as needed)
      await Future.delayed(Duration(milliseconds: 800));

      // Load additional items
      currentPage++;
      setState(() {
        isAtEndOfList = false;
      });
    }
  }

  int calculateItemCount() {
    int itemCount = 0;

    if ((isPasser || isAujoudHui || isAvenir) && filteredList.isNotEmpty) {
      itemCount += isAtEndOfList
          ? currentPage * itemsPerPage + 1
          : currentPage * itemsPerPage;
    } else if (isAujoudHui) {
      itemCount += isAtEndOfList
          ? currentPage * itemsPerPage + 1
          : currentPage * itemsPerPage;
    } else if (isPasser) {
      itemCount += isAtEndOfList
          ? currentPage * itemsPerPage + 1
          : currentPage * itemsPerPage;
    } else if (isAvenir) {
      itemCount += isAtEndOfList
          ? currentPage * itemsPerPage + 1
          : currentPage * itemsPerPage;
    }

    itemCount += isAtEndOfList ? 0 : 0;

    return itemCount;
  }

  bool shouldShowLoader(int index) {
    return isAtEndOfList && index == calculateItemCount() - 1;
  }

  Widget buildListItem(int index) {
    if ((isPasser || isAujoudHui || isAvenir) &&
        filteredList.isNotEmpty &&
        index < filteredList.length) {
      final item = filteredList[index];
      return YourListItemWidget(
        item: item,
        index: index,
      );
    } else if (isAujoudHui && index < tripsPresent.length) {
      final item = tripsPresent[index];
      return YourListItemWidget(
        item: item,
        index: index,
      );
    } else if (isPasser && index < trips.length) {
      final item = trips[index];
      return YourListItemWidget(
        item: item,
        index: index,
      );
    } else if (isAvenir && index < tripsFuture.length) {
      final item = tripsFuture[index];
      return YourListItemWidget(
        item: item,
        index: index,
      );
    } else {
      return SizedBox();
    }
  }

  Future<void> _requestLocationAndNotificationPermission() async {
    var locationStatus = await Permission.location.request();
    var notificationStatus = await Permission.notification.request();

    if (locationStatus.isGranted && notificationStatus.isGranted) {
      _startLocationUpdates();
    } else if (locationStatus.isDenied || notificationStatus.isDenied) {
    } else if (locationStatus.isPermanentlyDenied ||
        notificationStatus.isPermanentlyDenied) {}
  }

  late Timer timer;

  void _startLocationUpdates() async {
    CurrentLocation().whenComplete(() {
      setLocation();
    });
    timer = Timer.periodic(Duration(minutes: 3), (timer) {
      CurrentLocation();
      Future.delayed(Duration(seconds: 2), () {
        setLocation();
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timer;
  }

  String? location1;
  String? location2;

  Future<void> CurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double latitude1 = position.latitude;
      double longitude1 = position.longitude;
      setState(() {
        location2 = longitude1.toString();
        location1 = latitude1.toString();
      });
      print(
          'Current location: latitude after setState: ${location1}, Longitude after setState ${location2}');
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  String role = "";

  Future<void> setLocation() async {
    final box = GetStorage();
    final token = box.read('token');

    final storage = GetStorage();
    final UserID = storage.read('user_id');

    List<dynamic> userRoles = storage.read('user_roles') ?? [];

    if (userRoles.contains('ROLE_CHAUFFEUR')) {
      setState(() {
        role = "ROLE_CHAUFFEUR";
      });
    }
    print('User Role is : $role');
    print('User id for locations : $UserID');
    print('User latitude is : $location1');
    print('User longitude is : $location2');

    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final LocationBaseUrl = configJson['planning_baseUrl'];
    final LocationApiKey = configJson['planning_apiKey'];

    final LocationMainUrl = LocationBaseUrl + "set/location";

    var headers = {
      'x-api-key': '$LocationApiKey',
      'Authorization': 'Bearer ' + token
    };

    print('Data for API Body: $location1, $location2, $UserID, $role');

    var request = http.Request('POST', Uri.parse(LocationMainUrl));
    request.body = json.encode({
      "chauffeur-id": UserID.toString(),
      "role": role,
      "long": location2.toString(),
      "lat": location1.toString()
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      print('Location is set after API');
    } else {
      print(response.reasonPhrase);
      print('Location is not set after API');
    }
  }

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  String? mToken;
  FirebaseMessaging _firebaseMessage = FirebaseMessaging.instance;

  Future getDeviceToken() async {
    //request user permission for push notification
    FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    String? deviceToken = await _firebaseMessage.getToken();
    setState(() {
      mToken = deviceToken;
    });
    print('FCM Token in string for posting on backend api server: $mToken');
    return (deviceToken == null) ? "" : deviceToken;
  }

  init() async {
    String deviceToken = await getDeviceToken();
    // print("###### PRINT DEVICE TOKEN TO USE FOR PUSH NOTIFCIATION FOR DRIVERS ######");
    print('Print fcm token for drivers in init state: $deviceToken');
    print("############################################################");

    GetStorage fcm = GetStorage();
    fcm.write('FCMToken', deviceToken);
    final String TokenDevice = fcm.read('FCMToken');
    print('FCM Token for in local storage after loggin in: $TokenDevice');

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage remoteMessage) {
        String? title = remoteMessage.notification!.title;
        String? description = remoteMessage.notification!.body;

        Alert(
          context: context,
          type: AlertType.error,
          title: title, // title from push notification data
          desc: description, // description from push notifcation data
          buttons: [
            DialogButton(
              child: Text(
                "COOL",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () => Navigator.pop(context),
              width: 120,
            )
          ],
        ).show();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PieCanvas(
      theme: PieTheme(
          delayDuration: Duration.zero,
          tooltipTextStyle: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
          ),
          buttonSize: 65),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Container(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 185,
                      decoration: BoxDecoration(color: Color(0xFF3954A4)),
                      child: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 25,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Planning',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontFamily: 'Kanit',
                                    fontWeight: FontWeight.w600,
                                    height: 0,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => Profile()));
                                  },
                                  icon: Icon(
                                    Icons.person_outline,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 405,
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 15.0),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        bottomSheet1(context).then(
                                          (value) {
                                            if (value != null &&
                                                value.isNotEmpty) {
                                              setState(
                                                () {
                                                  selectedType = value;
                                                },
                                              );
                                            }
                                          },
                                        );
                                      },
                                      child: Container(
                                        width: 120,
                                        height: 35,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0x3F000000),
                                                blurRadius: 4,
                                                offset: Offset(0, 0),
                                                spreadRadius: 0,
                                              )
                                            ]),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SizedBox(width: 10),
                                              if (selectedType.isNotEmpty ||
                                                  filteredList.isNotEmpty)
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      isRefreshed = true;
                                                      selectedItems.clear();
                                                      selectedType = '';
                                                      GetStorage box =
                                                          GetStorage();
                                                      if (box.hasData(
                                                          'filteredList')) {
                                                        box.remove(
                                                            'filteredList');
                                                      }
                                                      filteredList.clear();
                                                    });
                                                    Future.delayed(
                                                        Duration(
                                                            milliseconds: 600),
                                                        () {
                                                      setState(() {
                                                        isRefreshed = false;
                                                      });
                                                    });
                                                  },
                                                  child: Image.asset(
                                                    'assets/images/cross2.png',
                                                    color: Colors.red,
                                                    scale: 1.6,
                                                  ),
                                                ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8),
                                                child: Text(
                                                  selectedItems.isNotEmpty
                                                      ? selectedItems.join(', ')
                                                      : _typeController
                                                              .text.isEmpty
                                                          ? 'Type'
                                                          : _typeController
                                                              .text,
                                                  style: TextStyle(
                                                    color: Color(0xFF524D4D),
                                                    fontSize: 14,
                                                    fontFamily: 'Kanit',
                                                    fontWeight: FontWeight.w400,
                                                    height: 0.11,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 15),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        final call =
                                            Uri.parse('tel: $hotlineNumber');
                                        if (await canLaunchUrl(call)) {
                                          launchUrl(call);
                                        } else {
                                          throw 'Could not launch $call';
                                        }
                                      },
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.white,
                                        child: Center(
                                          child: Image.asset(
                                              'assets/images/phone.png'),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: -12.5,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _changePasserContainerColor();
                                },
                                child: Container(
                                  width: 110,
                                  height: 43,
                                  decoration: BoxDecoration(
                                      color: passerContainerColor,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x3F000000),
                                          blurRadius: 4,
                                          offset: Offset(0, 0),
                                          spreadRadius: 0,
                                        )
                                      ]),
                                  child: Center(
                                    child: Text(
                                      'Passer',
                                      style: TextStyle(
                                        color: Color(0xFF524D4D),
                                        fontSize: 12,
                                        fontFamily: 'Kanit',
                                        fontWeight: FontWeight.w400,
                                        height: 0.11,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.025,
                              ),
                              GestureDetector(
                                onTap: () {
                                  _changeAujourdHuiContainerColor();
                                },
                                child: Container(
                                  width: 110,
                                  height: 43,
                                  decoration: BoxDecoration(
                                      color: aujourdhuiContainerColor,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x3F000000),
                                          blurRadius: 4,
                                          offset: Offset(0, 0),
                                          spreadRadius: 0,
                                        )
                                      ]),
                                  child: Center(
                                    child: Text(
                                      "Aujourd'hui",
                                      style: TextStyle(
                                        color: Color(0xFF524D4D),
                                        fontSize: 12,
                                        fontFamily: 'Kanit',
                                        fontWeight: FontWeight.w400,
                                        height: 0.11,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.025,
                              ),
                              GestureDetector(
                                onTap: () {
                                  _changeAvenirContainerColor();
                                },
                                child: Container(
                                  width: 110,
                                  height: 43,
                                  decoration: BoxDecoration(
                                      color: avenirContainerColor,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x3F000000),
                                          blurRadius: 4,
                                          offset: Offset(0, 0),
                                          spreadRadius: 0,
                                        )
                                      ]),
                                  child: Center(
                                    child: Text(
                                      "Avenir",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontFamily: 'Kanit',
                                        fontWeight: FontWeight.w400,
                                        height: 0.11,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 50,
              ),
              Expanded(
                child: LiquidPullToRefresh(
                  backgroundColor: Color(0xFF3954A4),
                  height: 80,
                  animSpeedFactor: 2,
                  showChildOpacityTransition: false,
                  color: Colors.white,
                  onRefresh: handleRefresh,
                  child: isRefreshed
                      ? Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF3954A4)),
                        )
                      : (tripsFuture.isEmpty &&
                              isAvenir &&
                              !isPasser &&
                              !isAujoudHui)
                          ? isRefreshed
                              ? CircularProgressIndicator(
                                  color: Color(0xFF3954A4),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                        child: Image.asset(
                                            'assets/images/noTrip.png')),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "No Trips Avaialble..!!",
                                      style: TextStyle(
                                        color: Color(0xFF3954A4),
                                        fontSize: 20,
                                        fontFamily: 'Display',
                                        fontWeight: FontWeight.w400,
                                        height: 0,
                                      ),
                                    )
                                  ],
                                )
                          : isRefreshed
                              ? CircularProgressIndicator(
                                  color: Color(0xFF3954A4),
                                )
                              : (trips.isEmpty &&
                                      isPasser &&
                                      !isAvenir &&
                                      !isAujoudHui)
                                  ? isRefreshed
                                      ? CircularProgressIndicator(
                                          color: Color(0xFF3954A4),
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Center(
                                                child: Image.asset(
                                                    'assets/images/noTrip.png')),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              "No Trips Avaialble..!!",
                                              style: TextStyle(
                                                color: Color(0xFF3954A4),
                                                fontSize: 20,
                                                fontFamily: 'Display',
                                                fontWeight: FontWeight.w400,
                                                height: 0,
                                              ),
                                            )
                                          ],
                                        )
                                  : isRefreshed
                                      ? CircularProgressIndicator(
                                          color: Color(0xFF3954A4),
                                        )
                                      : (tripsPresent.isEmpty &&
                                              isAujoudHui &&
                                              !isPasser &&
                                              !isAvenir)
                                          ? isRefreshed
                                              ? CircularProgressIndicator(
                                                  color: Color(0xFF3954A4),
                                                )
                                              : Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Center(
                                                        child: Image.asset(
                                                            'assets/images/noTrip.png')),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      "No Trips Avaialble..!!",
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF3954A4),
                                                        fontSize: 20,
                                                        fontFamily: 'Display',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 0,
                                                      ),
                                                    )
                                                  ],
                                                )
                                          : ListView.builder(
                                              controller: controller,
                                              // physics: NeverScrollableScrollPhysics(),
                                              itemCount: calculateItemCount(),
                                              itemBuilder: (context, index) {
                                                if (shouldShowLoader(index)) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Color(0xFF3954A4),
                                                    ),
                                                  );
                                                } else {
                                                  return buildListItem(index);
                                                }
                                              },
                                            ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class YourListItemWidget extends StatefulWidget {
  final Map<String, dynamic> item;
  final int index;

  const YourListItemWidget(
      {super.key, required this.item, required this.index});

  @override
  State<YourListItemWidget> createState() => _YourListItemWidgetState();
}

class _YourListItemWidgetState extends State<YourListItemWidget> {
  @override
  Future<List<Map<String, dynamic>>> tripListPast() async {
    final box = GetStorage();
    final _token = box.read('token') ?? '';
    final storage = GetStorage();
    final UserID = storage.read('user_id');

    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final gestionBaseUrl = configJson['planning_baseUrl'];
    final gestionApiKey = configJson['planning_apiKey'];

    final gestionMainUrl =
        gestionBaseUrl + "mob/course-chauffeur-passe/" + UserID.toString();

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

      List<Map<String, dynamic>> tripList = [];
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
        tripList.add({
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

      // print(tripList);
      box.write('tripList', tripList);

      setState(() {
        trips = tripList;
      });

      return [];
    } else {
      print(response.reasonPhrase);
    }
    return [];
  }

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

  Widget build(BuildContext context) {
    Widget _buildTextButton(String text, bool hovered) {
      return Container(
        height: 100,
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          // color: Colors.white,
        ),
        child: Center(
            child: Text(
          overflow: TextOverflow.ellipsis,
          text,
          style: TextStyle(color: Colors.white, fontSize: 14.5),
        )),
      );
    }

    Widget _buildIconButton(IconData icon, bool hovered) {
      return Container(
        height: 100,
        width: 200,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.blue[400],
            boxShadow: [
              BoxShadow(
                color: Colors.white,
                blurRadius: 4,
                offset: Offset(0, 0),
                spreadRadius: 0,
              )
            ]),
        child: Center(child: Icon(icon)),
      );
    }

    void showSnackBar(String message) {
      ScaffoldMessenger.of(this as BuildContext).removeCurrentSnackBar();
      ScaffoldMessenger.of(this as BuildContext).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    //  print('List of bool for hand action: $handOpen');

    String Status1 = widget.item['status1'] ?? "";
    String Status2 = widget.item['status2'] ?? "";
    String imgType = widget.item['imgType'].toString() ?? "";
    String date = widget.item['dateCourse'] ?? "";
    String borderColor = widget.item['backgroundColor'] ?? "";
    print('Background color from the list: $borderColor');
    DateTime dateTime = DateTime.parse(date);
    tz.TZDateTime parisDateTime =
        tz.TZDateTime.from(dateTime, tz.getLocation('Europe/Paris'));

    String formattedDate = DateFormat('dd-MMM.hh:MM').format(parisDateTime);

    String statusText;

    switch ("$Status1-$Status2") {
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
    Color _getStatusColor(String status1, String status2) {
      switch ("$status1-$status2") {
        case '1-1':
          return HexColor('#bbacac');
        case '0-0':
          return HexColor('#f17407');
        case '1-2':
          return Colors.yellow.shade600;
        case '1-5':
          return HexColor('#0F056B');
        case '1-3':
          return HexColor('#fd6c9e');
        case '1-4':
          return HexColor('#811453');
        case '1-0':
          return HexColor('#0AAF20');
        default:
          return Color(0xFF135DB9);
      }
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

    print('List of bool when first loaded: $handOpen');

    String accpeted = "";

    Future<void> updateTripStatus() async {
      print('Accpedt status for API: $accpeted');

      final box = GetStorage();
      final _token = box.read('token') ?? '';

      final configData =
          await rootBundle.loadString('assets/config/config.json');
      final configJson = json.decode(configData);

      final gestionBaseUrl = configJson['planning_baseUrl'];
      final gestionApiKey = configJson['planning_apiKey'];

      final gestionMainUrl = gestionBaseUrl +
          "mob/course-accepte-refuse/" +
          widget.item['id'].toString();

      var headers = {
        'x-api-key': '$gestionApiKey',
        'Authorization': 'Bearer ' + _token
      };

      var request = http.Request('POST', Uri.parse(gestionMainUrl));
      request.body = json.encode({
        "etat": accpeted,
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
        // tripDetails();
        print("==================After API for trip management");
        tripListPresent();
        print("==================After API for trip management");
        // Get.to(() => TripDetails());

        setState(() {
          isRefreshed = false;
        });
      } else {
        print(response.reasonPhrase);
      }
    }

    String trip2Status = "";

    Future<void> updateTripStatus2() async {
      print('Trip Status for phase 2 trip status management: $trip2Status');

      final box = GetStorage();
      final _token = box.read('token') ?? '';

      final configData =
          await rootBundle.loadString('assets/config/config.json');
      final configJson = json.decode(configData);

      final gestionBaseUrl = configJson['planning_baseUrl'];
      final gestionApiKey = configJson['planning_apiKey'];

      final gestionMainUrl =
          gestionBaseUrl + "mob/course-etat/" + widget.item['id'].toString();

      var headers = {
        'x-api-key': '$gestionApiKey',
        'Authorization': 'Bearer ' + _token
      };

      var request = http.Request('POST', Uri.parse(gestionMainUrl));
      request.body = json.encode({
        "etat2": trip2Status,
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
        tripListPresent();

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
        // tripDetails();
        // Get.to(() => TripDetails());

        setState(() {
          isRefreshed = false;
        });

        // Navigator.of(context).pop();
      } else {
        print(response.reasonPhrase);
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

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        width: 393,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(20),
          // borderRadius: BorderRadius.circular(5),
          border: Border(
            left: BorderSide(color: HexColor(borderColor)),
            top: BorderSide(color: HexColor(borderColor), width: 7),
            right: BorderSide(color: HexColor(borderColor)),
            bottom: BorderSide(color: HexColor(borderColor)),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 0),
              spreadRadius: 0,
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 10),
          child: Column(
            children: [
              ListTile(
                minLeadingWidth: 0,
                leading: IconButton(
                  onPressed: () async {
                    final call = Uri.parse('tel:${widget.item['tel1']}');
                    if (await canLaunchUrl(call)) {
                      launchUrl(call);
                    } else {
                      throw 'Could not launch $call';
                    }
                  },
                  icon: Icon(
                    Icons.phone,
                    color: Color(0xFF3954A4),
                    size: 30,
                  ),
                ),
                title: Text(
                  '${widget.item['nom']} ${widget.item['prenom']}',
                  style: TextStyle(
                    color: Color(0xFF524D4D),
                    fontSize: 14.5,
                    fontFamily: 'Kanit',
                    fontWeight: FontWeight.w500,
                    height: 0,
                  ),
                ),
                trailing: GestureDetector(
                    onTap: () {
                      Get.to(() => TripDetails(), arguments: [
                        // item['status1'],
                        // item['status2'],

                        widget.item['id'].toString(),
                      ]);
                    },
                    child: Container(
                        width: 40,
                        height: 40,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: CircleBorder(),
                          shadows: [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 0),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: getImageBasedOnType(imgType))),
              ),
              // SizedBox(
              //   height: 5,
              // ),
              Row(
                children: [
                  SizedBox(
                    width: 30,
                  ),
                  Image.asset('assets/images/location.png'),
                  SizedBox(
                    width: 15,
                  ),
                  Container(
                    width: 275,
                    child: GestureDetector(
                      onTap: () {
                        currentLocaionlaunchMap(widget.item['depart']);
                      },
                      child: Text(
                        widget.item['depart'],
                        style: TextStyle(
                          color: Color(0xFF524D4D),
                          fontSize: 14.5,
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w300,
                          height: 0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 30,
                  ),
                  GestureDetector(
                    child: Image.asset('assets/images/location2.png'),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Container(
                    width: 275,
                    child: GestureDetector(
                      onTap: () {
                        currentLocaionlaunchMap(widget.item['arrive']);
                      },
                      child: Text(
                        widget.item['arrive'],
                        // item['status1'],
                        style: TextStyle(
                          color: Color(0xFF524D4D),
                          fontSize: 14.5,
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w300,
                          height: 0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 0.5,
                color: Color(0xFFE6E6E6),
              ),
              ListTile(
                visualDensity: VisualDensity(vertical: -4),
                leading: Container(
                  width: 65,
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: _getStatusColor(Status1, Status2),
                      fontSize: 14,
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.clip,
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                        onTap: () {
                          Get.to(() => TripDetails(), arguments: [
                            widget.item['id'].toString(),
                            // formattedDate
                          ]);
                        },
                        child: Image.asset('assets/images/search.png')),
                    SizedBox(width: 5),
                    isAujoudHui
                        ? handOpen![widget.index] == true
                            ? PieMenu(
                                theme: PieTheme.of(context).copyWith(
                                  brightness: Brightness.dark,
                                ),
                                actions: [
                                  PieAction.builder(
                                    buttonTheme: PieButtonTheme(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white,
                                              blurRadius: 4,
                                              offset: Offset(0, 0),
                                              spreadRadius: 0,
                                            )
                                          ],
                                          color:
                                              Color.fromARGB(255, 253, 206, 64),
                                        ),
                                        backgroundColor: Colors.yellow[400],
                                        iconColor: null),
                                    tooltip:
                                        Center(child: const Text(' Surplace')),
                                    onSelect: () {
                                      setState(() {
                                        trip2Status = 'Sur-place';
                                        isRefreshed = true;
                                      });
                                      updateTripStatus2();
                                    },
                                    builder: (hovered) {
                                      return Center(
                                        child: _buildTextButton(
                                            'Surplace', hovered),
                                      );
                                    },
                                  ),
                                  PieAction.builder(
                                    buttonTheme: PieButtonTheme(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white,
                                              blurRadius: 4,
                                              offset: Offset(0, 0),
                                              spreadRadius: 0,
                                            )
                                          ],
                                          color: HexColor('#0F056B'),
                                        ),
                                        backgroundColor: HexColor('#0F056B'),
                                        iconColor: null),
                                    tooltip: Center(child: const Text('Abord')),
                                    onSelect: () {
                                      setState(() {
                                        trip2Status = 'Client abord';
                                        isRefreshed = true;
                                      });
                                      updateTripStatus2();
                                    },
                                    builder: (hovered) {
                                      return Center(
                                        child: Center(
                                          child: _buildTextButton(
                                              'Abord', hovered),
                                        ),
                                      );
                                    },
                                  ),
                                  PieAction.builder(
                                    buttonTheme: PieButtonTheme(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white,
                                              blurRadius: 4,
                                              offset: Offset(0, 0),
                                              spreadRadius: 0,
                                            )
                                          ],
                                          color: HexColor('#fd6c9e'),
                                        ),
                                        backgroundColor: HexColor('#fd6c9e'),
                                        iconColor: null),
                                    tooltip: Center(
                                        child: const Text(
                                            ' Absent + Displacement')),
                                    onSelect: () {
                                      setState(() {
                                        trip2Status = 'Client absent';
                                        isRefreshed = true;
                                      });
                                      updateTripStatus2();
                                    },
                                    builder: (hovered) {
                                      return Center(
                                        child: _buildTextButton(
                                            '  Absent\n  Displacement',
                                            hovered),
                                      );
                                    },
                                  ),
                                  PieAction.builder(
                                    buttonTheme: PieButtonTheme(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white,
                                              blurRadius: 4,
                                              offset: Offset(0, 0),
                                              spreadRadius: 0,
                                            )
                                          ],
                                          color: HexColor('#bbacac'),
                                        ),
                                        backgroundColor: HexColor('#bbacac'),
                                        iconColor: null),
                                    tooltip:
                                        Center(child: const Text(' En Route')),
                                    onSelect: () {
                                      setState(() {
                                        trip2Status = 'En route';
                                        isRefreshed = true;
                                      });
                                      updateTripStatus2();
                                    },
                                    builder: (hovered) {
                                      return Center(
                                        child: _buildTextButton(
                                            ' En\nRoute', hovered),
                                      );
                                    },
                                  ),
                                  PieAction.builder(
                                    buttonTheme: PieButtonTheme(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white,
                                              blurRadius: 4,
                                              offset: Offset(0, 0),
                                              spreadRadius: 0,
                                            )
                                          ],
                                          color: HexColor('#811453'),
                                        ),
                                        backgroundColor: HexColor('#811453'),
                                        iconColor: null),
                                    tooltip:
                                        Center(child: const Text(' Terminer')),
                                    onSelect: () {
                                      setState(() {
                                        trip2Status = 'Terminee';
                                        isRefreshed = true;
                                      });
                                      updateTripStatus2();
                                    },
                                    builder: (hovered) {
                                      return Center(
                                        child: _buildTextButton(
                                            ' Terminer', hovered),
                                      );
                                    },
                                  ),
                                ],
                                child: CircleAvatar(
                                    backgroundColor: HexColor(borderColor),
                                    child:
                                        Image.asset('assets/images/hand.png')))
                            : ((Status1 == "1" && Status2 == "0"))
                                ? PieMenu(
                                    theme: PieTheme.of(context).copyWith(
                                      brightness: Brightness.dark,
                                    ),
                                    actions: [
                                      PieAction.builder(
                                        buttonTheme: PieButtonTheme(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.white,
                                                  blurRadius: 4,
                                                  offset: Offset(0, 0),
                                                  spreadRadius: 0,
                                                )
                                              ],
                                              color: Color.fromARGB(
                                                  255, 253, 206, 64),
                                            ),
                                            backgroundColor: Colors.yellow[400],
                                            iconColor: null),
                                        tooltip: Center(
                                            child: const Text(' Surplace')),
                                        onSelect: () {
                                          setState(() {
                                            trip2Status = 'Sur-place';
                                            isRefreshed = true;
                                          });
                                          updateTripStatus2();
                                        },
                                        builder: (hovered) {
                                          return Center(
                                            child: _buildTextButton(
                                                'Surplace', hovered),
                                          );
                                        },
                                      ),
                                      PieAction.builder(
                                        buttonTheme: PieButtonTheme(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.white,
                                                  blurRadius: 4,
                                                  offset: Offset(0, 0),
                                                  spreadRadius: 0,
                                                )
                                              ],
                                              color: HexColor('#0F056B'),
                                            ),
                                            backgroundColor:
                                                HexColor('#0F056B'),
                                            iconColor: null),
                                        tooltip:
                                            Center(child: const Text('Abord')),
                                        onSelect: () {
                                          setState(() {
                                            trip2Status = 'Client abord';
                                            isRefreshed = true;
                                          });
                                          updateTripStatus2();
                                        },
                                        builder: (hovered) {
                                          return Center(
                                            child: Center(
                                              child: _buildTextButton(
                                                  'Abord', hovered),
                                            ),
                                          );
                                        },
                                      ),
                                      PieAction.builder(
                                        buttonTheme: PieButtonTheme(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.white,
                                                  blurRadius: 4,
                                                  offset: Offset(0, 0),
                                                  spreadRadius: 0,
                                                )
                                              ],
                                              color: HexColor('#fd6c9e'),
                                            ),
                                            backgroundColor:
                                                HexColor('#fd6c9e'),
                                            iconColor: null),
                                        tooltip: Center(
                                            child: const Text(
                                                ' Absent + Displacement')),
                                        onSelect: () {
                                          setState(() {
                                            trip2Status = 'Client absent';
                                            isRefreshed = true;
                                          });
                                          updateTripStatus2();
                                        },
                                        builder: (hovered) {
                                          return Center(
                                            child: _buildTextButton(
                                                '  Absent\n  Displacement',
                                                hovered),
                                          );
                                        },
                                      ),
                                      PieAction.builder(
                                        buttonTheme: PieButtonTheme(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.white,
                                                  blurRadius: 4,
                                                  offset: Offset(0, 0),
                                                  spreadRadius: 0,
                                                )
                                              ],
                                              color: HexColor('#bbacac'),
                                            ),
                                            backgroundColor:
                                                HexColor('#bbacac'),
                                            iconColor: null),
                                        tooltip: Center(
                                            child: const Text(' En Route')),
                                        onSelect: () {
                                          setState(() {
                                            trip2Status = 'En route';
                                            isRefreshed = true;
                                          });
                                          updateTripStatus2();
                                        },
                                        builder: (hovered) {
                                          return Center(
                                            child: _buildTextButton(
                                                ' En\nRoute', hovered),
                                          );
                                        },
                                      ),
                                      PieAction.builder(
                                        buttonTheme: PieButtonTheme(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.white,
                                                  blurRadius: 4,
                                                  offset: Offset(0, 0),
                                                  spreadRadius: 0,
                                                )
                                              ],
                                              color: HexColor('#811453'),
                                            ),
                                            backgroundColor:
                                                HexColor('#811453'),
                                            iconColor: null),
                                        tooltip: Center(
                                            child: const Text(' Terminer')),
                                        onSelect: () {
                                          setState(() {
                                            trip2Status = 'Terminee';
                                            isRefreshed = true;
                                          });
                                          updateTripStatus2();
                                        },
                                        builder: (hovered) {
                                          return Center(
                                            child: _buildTextButton(
                                                ' Terminer', hovered),
                                          );
                                        },
                                      ),
                                    ],
                                    child: CircleAvatar(
                                        backgroundColor: HexColor(borderColor),
                                        child: Image.asset(
                                            'assets/images/hand.png')))
                                : ((Status1 == "1" && Status2 == "1"))
                                    ? PieMenu(
                                        theme: PieTheme.of(context).copyWith(
                                          brightness: Brightness.dark,
                                        ),
                                        actions: [
                                          PieAction.builder(
                                            buttonTheme: PieButtonTheme(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.white,
                                                      blurRadius: 4,
                                                      offset: Offset(0, 0),
                                                      spreadRadius: 0,
                                                    )
                                                  ],
                                                  color: Color.fromARGB(
                                                      255, 253, 206, 64),
                                                ),
                                                backgroundColor:
                                                    Colors.yellow[400],
                                                iconColor: null),
                                            tooltip: Center(
                                                child: const Text(' Surplace')),
                                            onSelect: () {
                                              setState(() {
                                                trip2Status = 'Sur-place';
                                                isRefreshed = true;
                                              });
                                              updateTripStatus2();
                                            },
                                            builder: (hovered) {
                                              return Center(
                                                child: _buildTextButton(
                                                    'Surplace', hovered),
                                              );
                                            },
                                          ),
                                          PieAction.builder(
                                            buttonTheme: PieButtonTheme(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.white,
                                                      blurRadius: 4,
                                                      offset: Offset(0, 0),
                                                      spreadRadius: 0,
                                                    )
                                                  ],
                                                  color: HexColor('#0F056B'),
                                                ),
                                                backgroundColor:
                                                    HexColor('#0F056B'),
                                                iconColor: null),
                                            tooltip: Center(
                                                child: const Text('Abord')),
                                            onSelect: () {
                                              setState(() {
                                                trip2Status = 'Client abord';
                                                isRefreshed = true;
                                              });
                                              updateTripStatus2();
                                            },
                                            builder: (hovered) {
                                              return Center(
                                                child: Center(
                                                  child: _buildTextButton(
                                                      'Abord', hovered),
                                                ),
                                              );
                                            },
                                          ),
                                          PieAction.builder(
                                            buttonTheme: PieButtonTheme(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.white,
                                                      blurRadius: 4,
                                                      offset: Offset(0, 0),
                                                      spreadRadius: 0,
                                                    )
                                                  ],
                                                  color: HexColor('#fd6c9e'),
                                                ),
                                                backgroundColor:
                                                    HexColor('#fd6c9e'),
                                                iconColor: null),
                                            tooltip: Center(
                                                child: const Text(
                                                    ' Absent + Displacement')),
                                            onSelect: () {
                                              setState(() {
                                                trip2Status = 'Client absent';
                                                isRefreshed = true;
                                              });
                                              updateTripStatus2();
                                            },
                                            builder: (hovered) {
                                              return Center(
                                                child: _buildTextButton(
                                                    '  Absent\n  Displacement',
                                                    hovered),
                                              );
                                            },
                                          ),
                                          PieAction.builder(
                                            buttonTheme: PieButtonTheme(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.white,
                                                      blurRadius: 4,
                                                      offset: Offset(0, 0),
                                                      spreadRadius: 0,
                                                    )
                                                  ],
                                                  color: HexColor('#bbacac'),
                                                ),
                                                backgroundColor:
                                                    HexColor('#bbacac'),
                                                iconColor: null),
                                            tooltip: Center(
                                                child: const Text(' En Route')),
                                            onSelect: () {
                                              setState(() {
                                                trip2Status = 'En route';
                                                isRefreshed = true;
                                              });
                                              updateTripStatus2();
                                            },
                                            builder: (hovered) {
                                              return Center(
                                                child: _buildTextButton(
                                                    ' En\nRoute', hovered),
                                              );
                                            },
                                          ),
                                          PieAction.builder(
                                            buttonTheme: PieButtonTheme(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.white,
                                                      blurRadius: 4,
                                                      offset: Offset(0, 0),
                                                      spreadRadius: 0,
                                                    )
                                                  ],
                                                  color: HexColor('#811453'),
                                                ),
                                                backgroundColor:
                                                    HexColor('#811453'),
                                                iconColor: null),
                                            tooltip: Center(
                                                child: const Text(' Terminer')),
                                            onSelect: () {
                                              setState(() {
                                                trip2Status = 'Terminee';
                                                isRefreshed = true;
                                              });
                                              updateTripStatus2();
                                            },
                                            builder: (hovered) {
                                              return Center(
                                                child: _buildTextButton(
                                                    ' Terminer', hovered),
                                              );
                                            },
                                          ),
                                        ],
                                        child: CircleAvatar(
                                          backgroundColor:
                                              HexColor(borderColor),
                                          child: Image.asset(
                                              'assets/images/hand.png'),
                                        ))
                                    : ((Status1 == "1" && Status2 == "2"))
                                        ? PieMenu(
                                            theme:
                                                PieTheme.of(context).copyWith(
                                              brightness: Brightness.dark,
                                            ),
                                            actions: [
                                              PieAction.builder(
                                                buttonTheme: PieButtonTheme(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.white,
                                                          blurRadius: 4,
                                                          offset: Offset(0, 0),
                                                          spreadRadius: 0,
                                                        )
                                                      ],
                                                      color: Color.fromARGB(
                                                          255, 253, 206, 64),
                                                    ),
                                                    backgroundColor:
                                                        Colors.yellow[400],
                                                    iconColor: null),
                                                tooltip: Center(
                                                    child: const Text(
                                                        ' Surplace')),
                                                onSelect: () {
                                                  setState(() {
                                                    trip2Status = 'Sur-place';
                                                    isRefreshed = true;
                                                  });
                                                  updateTripStatus2();
                                                },
                                                builder: (hovered) {
                                                  return Center(
                                                    child: _buildTextButton(
                                                        'Surplace', hovered),
                                                  );
                                                },
                                              ),
                                              PieAction.builder(
                                                buttonTheme: PieButtonTheme(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.white,
                                                          blurRadius: 4,
                                                          offset: Offset(0, 0),
                                                          spreadRadius: 0,
                                                        )
                                                      ],
                                                      color:
                                                          HexColor('#0F056B'),
                                                    ),
                                                    backgroundColor:
                                                        HexColor('#0F056B'),
                                                    iconColor: null),
                                                tooltip: Center(
                                                    child: const Text('Abord')),
                                                onSelect: () {
                                                  setState(() {
                                                    trip2Status =
                                                        'Client abord';
                                                    isRefreshed = true;
                                                  });
                                                  updateTripStatus2();
                                                },
                                                builder: (hovered) {
                                                  return Center(
                                                    child: Center(
                                                      child: _buildTextButton(
                                                          'Abord', hovered),
                                                    ),
                                                  );
                                                },
                                              ),
                                              PieAction.builder(
                                                buttonTheme: PieButtonTheme(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.white,
                                                          blurRadius: 4,
                                                          offset: Offset(0, 0),
                                                          spreadRadius: 0,
                                                        )
                                                      ],
                                                      color:
                                                          HexColor('#fd6c9e'),
                                                    ),
                                                    backgroundColor:
                                                        HexColor('#fd6c9e'),
                                                    iconColor: null),
                                                tooltip: Center(
                                                    child: const Text(
                                                        ' Absent + Displacement')),
                                                onSelect: () {
                                                  setState(() {
                                                    trip2Status =
                                                        'Client absent';
                                                    isRefreshed = true;
                                                  });
                                                  updateTripStatus2();
                                                },
                                                builder: (hovered) {
                                                  return Center(
                                                    child: _buildTextButton(
                                                        '  Absent\n  Displacement',
                                                        hovered),
                                                  );
                                                },
                                              ),
                                              PieAction.builder(
                                                buttonTheme: PieButtonTheme(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.white,
                                                          blurRadius: 4,
                                                          offset: Offset(0, 0),
                                                          spreadRadius: 0,
                                                        )
                                                      ],
                                                      color:
                                                          HexColor('#bbacac'),
                                                    ),
                                                    backgroundColor:
                                                        HexColor('#bbacac'),
                                                    iconColor: null),
                                                tooltip: Center(
                                                    child: const Text(
                                                        ' En Route')),
                                                onSelect: () {
                                                  setState(() {
                                                    trip2Status = 'En route';
                                                    isRefreshed = true;
                                                  });
                                                  updateTripStatus2();
                                                },
                                                builder: (hovered) {
                                                  return Center(
                                                    child: _buildTextButton(
                                                        ' En\nRoute', hovered),
                                                  );
                                                },
                                              ),
                                              PieAction.builder(
                                                buttonTheme: PieButtonTheme(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.white,
                                                          blurRadius: 4,
                                                          offset: Offset(0, 0),
                                                          spreadRadius: 0,
                                                        )
                                                      ],
                                                      color:
                                                          HexColor('#811453'),
                                                    ),
                                                    backgroundColor:
                                                        HexColor('#811453'),
                                                    iconColor: null),
                                                tooltip: Center(
                                                    child: const Text(
                                                        ' Terminer')),
                                                onSelect: () {
                                                  setState(() {
                                                    trip2Status = 'Terminee';
                                                    isRefreshed = true;
                                                  });
                                                  updateTripStatus2();
                                                },
                                                builder: (hovered) {
                                                  return Center(
                                                    child: _buildTextButton(
                                                        ' Terminer', hovered),
                                                  );
                                                },
                                              ),
                                            ],
                                            child: CircleAvatar(
                                              backgroundColor:
                                                  HexColor(borderColor),
                                              child: Image.asset(
                                                  'assets/images/hand.png'),
                                            ))
                                        : ((Status1 == "1" && Status2 == "5"))
                                            ? PieMenu(
                                                theme: PieTheme.of(context)
                                                    .copyWith(
                                                  brightness: Brightness.dark,
                                                ),
                                                actions: [
                                                  PieAction.builder(
                                                    buttonTheme: PieButtonTheme(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color:
                                                                  Colors.white,
                                                              blurRadius: 4,
                                                              offset:
                                                                  Offset(0, 0),
                                                              spreadRadius: 0,
                                                            )
                                                          ],
                                                          color: Color.fromARGB(
                                                              255,
                                                              253,
                                                              206,
                                                              64),
                                                        ),
                                                        backgroundColor:
                                                            Colors.yellow[400],
                                                        iconColor: null),
                                                    tooltip: Center(
                                                        child: const Text(
                                                            ' Surplace')),
                                                    onSelect: () {
                                                      setState(() {
                                                        trip2Status =
                                                            'Sur-place';
                                                        isRefreshed = true;
                                                      });
                                                      updateTripStatus2();
                                                    },
                                                    builder: (hovered) {
                                                      return Center(
                                                        child: _buildTextButton(
                                                            'Surplace',
                                                            hovered),
                                                      );
                                                    },
                                                  ),
                                                  PieAction.builder(
                                                    buttonTheme: PieButtonTheme(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color:
                                                                  Colors.white,
                                                              blurRadius: 4,
                                                              offset:
                                                                  Offset(0, 0),
                                                              spreadRadius: 0,
                                                            )
                                                          ],
                                                          color: HexColor(
                                                              '#0F056B'),
                                                        ),
                                                        backgroundColor:
                                                            HexColor('#0F056B'),
                                                        iconColor: null),
                                                    tooltip: Center(
                                                        child: const Text(
                                                            'Abord')),
                                                    onSelect: () {
                                                      setState(() {
                                                        trip2Status =
                                                            'Client abord';
                                                        isRefreshed = true;
                                                      });
                                                      updateTripStatus2();
                                                    },
                                                    builder: (hovered) {
                                                      return Center(
                                                        child: Center(
                                                          child:
                                                              _buildTextButton(
                                                                  'Abord',
                                                                  hovered),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  PieAction.builder(
                                                    buttonTheme: PieButtonTheme(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color:
                                                                  Colors.white,
                                                              blurRadius: 4,
                                                              offset:
                                                                  Offset(0, 0),
                                                              spreadRadius: 0,
                                                            )
                                                          ],
                                                          color: HexColor(
                                                              '#fd6c9e'),
                                                        ),
                                                        backgroundColor:
                                                            HexColor('#fd6c9e'),
                                                        iconColor: null),
                                                    tooltip: Center(
                                                        child: const Text(
                                                            ' Absent + Displacement')),
                                                    onSelect: () {
                                                      setState(() {
                                                        trip2Status =
                                                            'Client absent';
                                                        isRefreshed = true;
                                                      });
                                                      updateTripStatus2();
                                                    },
                                                    builder: (hovered) {
                                                      return Center(
                                                        child: _buildTextButton(
                                                            '  Absent\n  Displacement',
                                                            hovered),
                                                      );
                                                    },
                                                  ),
                                                  PieAction.builder(
                                                    buttonTheme: PieButtonTheme(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color:
                                                                  Colors.white,
                                                              blurRadius: 4,
                                                              offset:
                                                                  Offset(0, 0),
                                                              spreadRadius: 0,
                                                            )
                                                          ],
                                                          color: HexColor(
                                                              '#bbacac'),
                                                        ),
                                                        backgroundColor:
                                                            HexColor('#bbacac'),
                                                        iconColor: null),
                                                    tooltip: Center(
                                                        child: const Text(
                                                            ' En Route')),
                                                    onSelect: () {
                                                      setState(() {
                                                        trip2Status =
                                                            'En route';
                                                        isRefreshed = true;
                                                      });
                                                      updateTripStatus2();
                                                    },
                                                    builder: (hovered) {
                                                      return Center(
                                                        child: _buildTextButton(
                                                            ' En\nRoute',
                                                            hovered),
                                                      );
                                                    },
                                                  ),
                                                  PieAction.builder(
                                                    buttonTheme: PieButtonTheme(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color:
                                                                  Colors.white,
                                                              blurRadius: 4,
                                                              offset:
                                                                  Offset(0, 0),
                                                              spreadRadius: 0,
                                                            )
                                                          ],
                                                          color: HexColor(
                                                              '#811453'),
                                                        ),
                                                        backgroundColor:
                                                            HexColor('#811453'),
                                                        iconColor: null),
                                                    tooltip: Center(
                                                        child: const Text(
                                                            ' Terminer')),
                                                    onSelect: () {
                                                      setState(() {
                                                        trip2Status =
                                                            'Terminee';
                                                        isRefreshed = true;
                                                      });
                                                      updateTripStatus2();
                                                    },
                                                    builder: (hovered) {
                                                      return Center(
                                                        child: _buildTextButton(
                                                            ' Terminer',
                                                            hovered),
                                                      );
                                                    },
                                                  ),
                                                ],
                                                child: CircleAvatar(
                                                  backgroundColor:
                                                      HexColor(borderColor),
                                                  child: Image.asset(
                                                      'assets/images/hand.png'),
                                                ))
                                            : ((Status1 == "1" &&
                                                    Status2 == "4"))
                                                ? CircleAvatar(
                                                    backgroundColor:
                                                        HexColor(borderColor),
                                                    child: Image.asset(
                                                        'assets/images/hand.png'),
                                                  )
                                                : ((Status1 == "1" &&
                                                        Status2 == "3"))
                                                    ? CircleAvatar(
                                                        backgroundColor:
                                                            HexColor(
                                                                borderColor),
                                                        child: Image.asset(
                                                            'assets/images/hand.png'),
                                                      )
                                                    : PieMenu(
                                                        theme:
                                                            PieTheme.of(context)
                                                                .copyWith(
                                                          buttonTheme:
                                                              PieButtonTheme(
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                            backgroundColor:
                                                                Colors
                                                                    .deepOrange,
                                                            iconColor:
                                                                Colors.white,
                                                          ),
                                                          buttonThemeHovered:
                                                              const PieButtonTheme(
                                                            backgroundColor:
                                                                Colors
                                                                    .orangeAccent,
                                                            iconColor:
                                                                Colors.black,
                                                          ),
                                                          brightness:
                                                              Brightness.dark,
                                                        ),
                                                        actions: [
                                                          PieAction.builder(
                                                            tooltip: const Text(
                                                                'Refuser'),
                                                            onSelect: () {
                                                              bottomSheet4(
                                                                  context);
                                                            },
                                                            builder: (hovered) {
                                                              return _buildIconButton(
                                                                  (Icons
                                                                      .visibility_off),
                                                                  hovered);
                                                            },
                                                          ),
                                                          PieAction.builder(
                                                            tooltip: const Text(
                                                                'Accepte'),
                                                            onSelect: () {
                                                              setState(() {
                                                                print(
                                                                    'set ho gya value');
                                                                handOpen![widget
                                                                        .index] =
                                                                    true;
                                                                isRefreshed =
                                                                    true;
                                                              });
                                                              print(
                                                                  'List of bool after tapping first time: $handOpen');
                                                              Future.delayed(
                                                                  Duration(
                                                                      milliseconds:
                                                                          150),
                                                                  () {
                                                                setState(() {
                                                                  accpeted =
                                                                      'Accepte';
                                                                });
                                                                updateTripStatus()
                                                                    .whenComplete(
                                                                        () =>
                                                                            () {
                                                                              setState(() {
                                                                                isRefreshed = true;
                                                                              });
                                                                              tripListPresent();
                                                                              setState(() {
                                                                                isRefreshed = false;
                                                                              });
                                                                            });
                                                                // Get.to(()=> LandingScreen2())
                                                              });
                                                              setState(() {
                                                                handOpen![widget
                                                                        .index] =
                                                                    false;
                                                              });
                                                            },
                                                            builder: (hovered) {
                                                              return _buildIconButton(
                                                                  Icons
                                                                      .check_outlined,
                                                                  hovered);
                                                            },
                                                          ),
                                                        ],
                                                        child: Image.asset(
                                                            'assets/images/hand.png'),
                                                      )
                        : isAvenir
                            ? (Status1 == "1" && Status2 == "0")
                                ? CircleAvatar(
                                    backgroundColor: HexColor(borderColor),
                                    child:
                                        Image.asset('assets/images/hand.png'))
                                : PieMenu(
                                    theme: PieTheme.of(context).copyWith(
                                      buttonTheme: PieButtonTheme(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        backgroundColor: Colors.deepOrange,
                                        iconColor: Colors.white,
                                      ),
                                      buttonThemeHovered: const PieButtonTheme(
                                        backgroundColor: Colors.orangeAccent,
                                        iconColor: Colors.black,
                                      ),
                                      brightness: Brightness.dark,
                                    ),
                                    actions: [
                                      PieAction.builder(
                                        tooltip: Container(),
                                        onSelect: () {},
                                        builder: (hovered) {
                                          return _buildIconButton(
                                              (Icons.visibility_off), hovered);
                                        },
                                      ),
                                      PieAction.builder(
                                        tooltip: const Text('Accepte'),
                                        onSelect: () {
                                          setState(() {
                                            print('set ho gya value');
                                            handOpen![widget.index] = true;
                                            isRefreshed = true;
                                          });
                                          print(
                                              'List of bool after tapping first time: $handOpen');
                                          Future.delayed(
                                              Duration(milliseconds: 150), () {
                                            setState(() {
                                              accpeted = 'Accepte';
                                            });
                                            updateTripStatus()
                                                .whenComplete(() => () {
                                                      setState(() {
                                                        isRefreshed = true;
                                                      });
                                                      tripListPresent();
                                                      setState(() {
                                                        isRefreshed = false;
                                                      });
                                                    });
                                            // Get.to(()=> LandingScreen2())
                                          });
                                          setState(() {
                                            handOpen![widget.index] = false;
                                          });
                                        },
                                        builder: (hovered) {
                                          return _buildIconButton(
                                              Icons.check_outlined, hovered);
                                        },
                                      ),
                                    ],
                                    child:
                                        Image.asset('assets/images/hand.png'),
                                  )
                            : SizedBox(),
                  ],
                ),
                trailing: Container(
                  child: Text(
                    formattedDate,
                    style: TextStyle(
                      color: Color(0xFF524D4D),
                      fontSize: 16,
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
    );
  }
}
