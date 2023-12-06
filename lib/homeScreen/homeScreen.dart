// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, sort_child_properties_last, avoid_unnecessary_containers, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unused_local_variable, sized_box_for_whitespace, avoid_print, prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:mkgo_mobile/Utility/bottomSheet.dart';
import 'package:mkgo_mobile/login/loginModel.dart';
import 'package:mkgo_mobile/profile/profile.dart';
import 'package:mkgo_mobile/tripDetails/tripDetails.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

GetStorage box = GetStorage();
bool isPasser = false;
bool isAujoudHui = false;
bool isAvenir = false;

List<dynamic> filteredList = box.read('filteredListDriver');
List<dynamic> trips = box.read('tripList') ?? [" "];
List<dynamic> tripsPresent = box.read('present') ?? [" "];
List<dynamic> tripsFuture = box.read('future') ?? [" "];
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

    passerContainerColor = Colors.white;
    aujourdhuiContainerColor = Color(0xFFF8B43D);
    avenirContainerColor = Colors.white;

    setState(() {
      isAujoudHui = true;
      isPasser = false;
      isAvenir = false;
    });

    setState(() {
      isRefreshed = true;
    });
    Future.delayed(Duration(milliseconds: 300), () {
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

  bool isRefreshed = false;

  Color passerContainerColor = Colors.white;
  Color aujourdhuiContainerColor = Color(0xFFF8B43D);
  Color avenirContainerColor = Colors.white;

  void _changePasserContainerColor() {
    // loadInitialData();
    setState(() {
      passer = "passer";
      passerContainerColor = Color(0xFFF8B43D);
      aujourdhuiContainerColor = Colors.white;
      avenirContainerColor = Colors.white;
      print('passeAvenirToday : $passer');
    });
    setState(() {
      isPasser = true;
      isRefreshed = true;
      isAujoudHui = false;
    });
    Future.delayed(Duration(milliseconds: 300), () {
      tripListPast();
      setState(() {
        isRefreshed = false;
      });
    });
  }

  void _changeAujourdHuiContainerColor() {
    // loadInitialData();
    setState(() {
      today = 'today';
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
    // loadInitialData();
    setState(() {
      future = "future";
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

  bool isExpanded = false;
  bool showLeftButton = false;
  bool showRightButton = false;

  void toggleButtons() {
    setState(() {
      showLeftButton = !showLeftButton;
      showRightButton = !showRightButton;
    });
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
        final List<dynamic> typeData = apiData["collections"] ?? [" "];
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
                                        title: Text(item["libelle"]),
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
                        GestureDetector(
                          onTap: () {
                            print(
                                '==================================================');
                          },
                          child: Flexible(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
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
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            print(
                                '==================================================');
                            setState(() {
                              selectedItems.clear();
                              selectedType = '';
                              _typeController.text = 'Type';
                            });
                          },
                          child: Flexible(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
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
                            ),
                          ),
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

      print(apiData);

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

      print(tripList);
      box.write('tripList', tripList);
      List<dynamic> trips = box.read('tripList') ?? [" "];
      print('Past from APi in storage : $trips');

      return tripList;
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

      List<Map<String, dynamic>> tripPresent = [];
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

        tripPresent.add({
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

      print(tripPresent);
      box.write('present', tripPresent);
      List<dynamic> tripsPresent = box.read('present') ?? [" "];
      print('Present List from APi in storage : $tripsPresent');

      return tripPresent;
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

      List<Map<String, dynamic>> tripFuture = [];
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
        tripFuture.add({
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

      print(tripFuture);
      box.write('future', tripFuture);
      List<dynamic> tripFuture2 = box.read('future') ?? [" "];
      print('Future List from APi in storage : $tripFuture2');

      return tripFuture;
    } else {
      print(response.reasonPhrase);
    }
    return [];
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
    final driverId = storage.read('user_Id');

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
      if (isAujoudHui) "passeAvenirToday": today.toString(),
      if (isAvenir) "passeAvenirToday": future.toString(),
      if (isPasser) "passeAvenirToday": passer.toString(),
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final apiData = jsonDecode(responseBody);

      List<Map<String, dynamic>> Filteredlist = [];
      int total = apiData['totalCount'];
      print('Total Count : $total');
      for (var courses in apiData['courses']) {
        int id = courses['id'];
        // String start = courses['start'];
        int nombrePassager = courses['nombrePassager'];
        String commentaire = courses['commentaire'];
        String paiement = courses['paiement'];
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
        });
      }
      print('Filtered List in API: $Filteredlist');
      box.write('filteredListDriver', Filteredlist);
      List<dynamic> filteredAdmin = box.read('filteredListDriver') ?? [" "];
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

  List<dynamic> trips = box.read('tripList') ?? [" "];
  List<dynamic> tripsPresent = box.read('present') ?? [" "];
  List<dynamic> tripsFuture = box.read('future') ?? [" "];
  List<dynamic> filteredList = box.read('filteredListDriver') ?? [" "];

  void loadInitialData() {
    print('loadmoredata fucntion is calling');

    trips = box.read('tripList') ?? [" "];
    tripsPresent = box.read('present') ?? [" "];
    tripsFuture = box.read('future') ?? [" "];
    // filteredList = box.read('filteredListDriver');

    print('Past Trips in loadmore : $trips');

    setState(() {
      trips = trips.toList();
      tripsPresent = tripsPresent.toList();
      tripsFuture = tripsFuture.toList();
      // filteredList = filteredList.toList();
    });
  }

  void filteredData() {
    print('loadmoredata fucntion is calling');

    filteredList = box.read('filteredListDriver');

    print('Past Trips in loadmore : $trips');

    setState(() {
      // trips = trips.toList();
      // tripsPresent = tripsPresent.toList();
      // tripsFuture = tripsFuture.toList();
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
      await Future.delayed(Duration(milliseconds: 1500));

      // Load additional items
      currentPage++;
      setState(() {
        isAtEndOfList = false;
      });
    }
  }

  int calculateItemCount() {
    int itemCount = 0;

    if (isAujoudHui) {
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

  bool hasInternetConnection() {
    var connectivityResult = Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.none;
  }

  Widget buildListItem(int index) {
    if (filteredList.isNotEmpty && index < filteredList.length) {
      final item = filteredList[index];
      // _HomeScreen2State().rebuildWidgetTree();
      return YourListItemWidget(item: item);
    } else if (isAujoudHui && index < tripsPresent.length) {
      final item = tripsPresent[index];
      return YourListItemWidget(item: item);
    } else if (isPasser && index < trips.length) {
      final item = trips[index];
      return YourListItemWidget(item: item);
    } else if (isAvenir && index < tripsFuture.length) {
      final item = tripsFuture[index];
      return YourListItemWidget(item: item);
    } else {
      return SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: () async {
          // Handle back button press
          await showLogoutAccountBottomSheet2(context);
          return _logoutConfirmed;
        },
        child: Container(
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
              (tripsFuture.isEmpty && isAvenir && !isPasser && !isAujoudHui)
                  ? Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                              child: Image.asset('assets/images/noTrip.png')),
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
                      ),
                    )
                  : Container(),
              (trips.isEmpty && isPasser && !isAvenir && !isAujoudHui)
                  ? Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                              child: Image.asset('assets/images/noTrip.png')),
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
                      ),
                    )
                  : Container(),
              (tripsPresent.isEmpty && isAujoudHui && !isPasser && !isAvenir)
                  ? Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                              child: Image.asset('assets/images/noTrip.png')),
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
                      ),
                    )
                  : Container(),
              Expanded(
                child: LiquidPullToRefresh(
                  backgroundColor: Color(0xFF3954A4),
                  height: 80,
                  animSpeedFactor: 2,
                  showChildOpacityTransition: false,
                  color: Colors.white,
                  onRefresh: handleRefresh,
                  child: ((trips.isEmpty &&
                              isPasser &&
                              !isAvenir &&
                              !isAujoudHui) ||
                          (tripsPresent.isEmpty &&
                              isAujoudHui &&
                              !isPasser &&
                              !isAvenir) ||
                          (tripsFuture.isEmpty &&
                              isAvenir &&
                              !isPasser &&
                              !isAujoudHui))
                      ? Container()
                      : isRefreshed
                          ? Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFF3954A4)),
                            )
                          : ListView.builder(
                              controller: controller,
                              // physics: NeverScrollableScrollPhysics(),
                              itemCount: calculateItemCount(),
                              itemBuilder: (context, index) {
                                if (shouldShowLoader(index)) {
                                  return Center(
                                    child: CircularProgressIndicator(),
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

class YourListItemWidget extends StatelessWidget {
  final Map<String, dynamic> item;

  const YourListItemWidget({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String Status1 = item['status1'] ?? "Status1";
    String Status2 = item['status2'] ?? "Status2";
    String imgType = item['imgType'].toString();
    String date = item['dateCourse'];
    String borderColor = item['backgroundColor'];
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
          return Image.asset('assets/images/taxi.png');
        case "2":
          return Image.asset('assets/images/ambulance.png');
        case "3":
          return Image.asset('assets/images/school.png');
        default:
          return null;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        width: 393,
        height: 227,
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
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Column(
            children: [
              ListTile(
                minLeadingWidth: 0,
                leading: IconButton(
                  onPressed: () async {
                    final call = Uri.parse('tel:${item['tel1']}');
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
                  '${item['nom']} ${item['prenom']}',
                  style: TextStyle(
                    color: Color(0xFF524D4D),
                    fontSize: 16,
                    fontFamily: 'Kanit',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
                trailing: GestureDetector(
                    onTap: () {
                      Get.to(() => TripDetails(), arguments: [
                        // item['status1'],
                        // item['status2'],

                        item['id'].toString(),
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
              Row(
                children: [
                  SizedBox(
                    width: 30,
                  ),
                  Image.asset('assets/images/location.png'),
                  SizedBox(
                    width: 15,
                  ),
                  Text(
                    'Depart',
                    style: TextStyle(
                      color: Color(0xFF524D4D),
                      fontSize: 16,
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.w300,
                      height: 0,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
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
                  Text(
                    item['id'].toString(),
                    // item['status1'],
                    style: TextStyle(
                      color: Color(0xFF524D4D),
                      fontSize: 16,
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.w300,
                      height: 0,
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
                            item['id'].toString(),
                            // formattedDate
                          ]);
                        },
                        child: Image.asset('assets/images/search.png')),
                    SizedBox(width: 5),
                     isAujoudHui
                            ? GestureDetector(
                                onTap: () {},
                                child: Image.asset('assets/images/hand.png'),
                              )
                            : isAvenir
                                ? GestureDetector(
                                    onTap: () {},
                                    child:
                                        Image.asset('assets/images/hand.png'),
                                  )
                                : SizedBox(width: 5),
                  ],
                ),
                trailing: Container(
                  child: Text(
                    formattedDate,
                    style: TextStyle(
                      color: Color(0xFF524D4D),
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
    );
  }
}
