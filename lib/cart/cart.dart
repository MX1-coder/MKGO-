// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, avoid_print

import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
// import 'package:lottie/lottie.dart';
import 'package:mkgo_mobile/Utility/bottomSheet.dart';
import 'package:mkgo_mobile/login/loginModel.dart';
import 'package:mkgo_mobile/profile/profile.dart';
import 'package:mkgo_mobile/tripDetails/tripDetails.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/timezone.dart' as tz;

bool isToday = false;
bool isFuture = false;
String today = "";
String future = "";
bool isOptionsAndCommentVisible = false;
bool isOptionsAndCommentVisible2 = false;

Color todayContainerColor = Colors.white;
Color futureContainerColor = Colors.white;

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _PlanningState();
}

class _PlanningState extends State<Cart> {
  TextEditingController comment = TextEditingController();
  TextEditingController reassign = TextEditingController();

  bool isOn = false;

  void toggleSwitch() {
    setState(() {
      isOn = !isOn;
    });
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 5,
          title: Text('Reassign to Someone Else'),
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
                    controller: reassign,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Reason to Reassign",
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
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
                  Container(
                    width: 90,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFF3954A4),
                      ),
                      child: Text('Return Ride'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Client Absent??'),
                ],
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

  void _changeTodayContainerColor() {
    setState(() {
      today = "today";
      isToday = true;
      isFuture = false;
      todayContainerColor = Color(0xFFFFB040);
      futureContainerColor = Colors.white;
      print('Passe/avenir/today: $today');
    });
    setState(() {
      isRefreshed = true;
    });
    Future.delayed(Duration(milliseconds: 800), () {
      setState(() {
        isRefreshed = false;
      });
    });
  }

  void _changeFutureContainerColor() {
    setState(() {
      future = "avenir";
      isToday = false;
      isFuture = true;
      futureContainerColor = Color(0xFFFFB040);
      todayContainerColor = Colors.white;
      print('Passe/avenir/today: $future');
    });
    setState(() {
      isRefreshed = true;
    });
    Future.delayed(Duration(milliseconds: 800), () {
      setState(() {
        isRefreshed = false;
      });
    });
  }

  Future<void> handleRefresh() async {
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  void initState() {
    // TODO: implement initState
    todayContainerColor = Color(0xFFFFB040);
    futureContainerColor = Colors.white;
    super.initState();
    setState(() {
      isToday = true;
      isRefreshed = true;
    });
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        isRefreshed = false;
      });
    });
    controller = ScrollController()..addListener(_scrollListener);
    regionList();
    typeList();
    TripListToday();
    TripListFutureAdmin();
    _changeTodayContainerColor();
    // filteredListAdmin();
  }

  bool hasInternetConnection() {
    var connectivityResult = Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.none;
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

  List<dynamic> Region = [];

  Future<List<Map<String, dynamic>>> regionList() async {
    List<Map<String, dynamic>>? suggestions = [];
    final box = GetStorage();
    final _token = box.read('token') ?? '';
    print("token called: $_token");

    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final gestionBaseUrl = configJson['gestion_baseUrl'];
    final gestionApiKey = configJson['gestion_apiKey'];

    final gestionMainUrl = gestionBaseUrl + "api/get/region";

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
        final List<dynamic> regionData = apiData["collections"];
        List<Map<String, dynamic>> regions = regionData.map((item) {
          return {
            "id": item["id"].toString(),
            "libelle": item["libelle"].toString(),
          };
        }).toList();

        box.write('regions', regions);
        return regions;
      } else {
        print("API response does not contain 'collections'");
      }
    } else {
      print(response.reasonPhrase);
    }
    return [];
  }

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
        final List<dynamic> typeData = apiData["collections"];
        List<Map<String, dynamic>> type = typeData.map((item) {
          return {
            "id": item["id"].toString(),
            "libelle": item["libelle"].toString(),
          };
        }).toList();
        box.write('type', type);
        return type;
      } else {}
    } else {
      print(response.reasonPhrase);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> DriverList() async {
    final box = GetStorage();
    final _token = box.read('token') ?? '';
    final regionId = box.read('regionId');

    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final gestionBaseUrl = configJson['gestion_baseUrl'];
    final gestionApiKey = configJson['gestion_apiKey'];

    final gestionMainUrl =
        gestionBaseUrl + "api/liste/chauffeur/active/" + regionId.toString();

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

      List<Map<String, dynamic>> driverList = [];
      for (var driver in apiData['collections']) {
        int id = driver['id'];
        String nom = driver['nom'];
        String prenom = driver['prenom'];
        driverList.add({'id': id, 'nom': nom, 'prenom': prenom});
      }

      print(' Driver List With Id $driverList');
      box.write('driver', driverList);

      return driverList;
    } else {
      print(response.reasonPhrase);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> DriverList2() async {
    final box = GetStorage();
    final _token = box.read('token') ?? '';
    String regionId2 = box.read('regionId3').toString();

    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final gestionBaseUrl = configJson['gestion_baseUrl'];
    final gestionApiKey = configJson['gestion_apiKey'];

    final gestionMainUrl =
        gestionBaseUrl + "api/liste/chauffeur/active/" + regionId2.toString();

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

      List<Map<String, dynamic>> driverList = [];
      for (var driver in apiData['collections']) {
        int id = driver['id'];
        String nom = driver['nom'];
        String prenom = driver['prenom'];
        driverList.add({'id': id, 'nom': nom, 'prenom': prenom});
      }
      box.write('driver2', driverList);
      List<dynamic> driver3 = box.read('driver2');
      print('List for the bottomSheet : $driver3');
      return driverList;
    } else {
      print(response.reasonPhrase);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> ClientList() async {
    final box = GetStorage();
    final _token = box.read('token') ?? '';
    final regionId = box.read('regionId');

    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final gestionBaseUrl = configJson['gestion_baseUrl'];
    final gestionApiKey = configJson['gestion_apiKey'];

    final gestionMainUrl =
        gestionBaseUrl + "api/liste-clients-active/" + regionId.toString();

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

      List<Map<String, dynamic>> clientList = [];
      for (var client in apiData['collections']) {
        int id = client['id'];
        String nom = client['nom'];
        String prenom = client['prenom'];
        clientList.add({'id': id, 'nom': nom, 'prenom': prenom});
      }

      print('Clietn List with id: $clientList');
      box.write('client', clientList);

      return clientList;
    } else {
      print(response.reasonPhrase);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> returnRide() async {
    final box = GetStorage();
    final _token = box.read('token') ?? '';
    final courseId = box.read('courseId');

    final storage = GetStorage();
    final userId = storage.read('user_id');

    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final gestionBaseUrl = configJson['planning_baseUrl'];
    final gestionApiKey = configJson['planning_apiKey'];

    final gestionMainUrl =
        gestionBaseUrl + "api/affectation/course/" + courseId.toString();

    var headers = {
      'x-api-key': '$gestionApiKey',
      'Authorization': 'Bearer ' + _token
    };

    var request = http.Request('POST', Uri.parse(gestionMainUrl));
    request.body = json.encode(
        {"chauffeur": userId.toString(), "motifAnnulation": reassign.text});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());

      Get.snackbar(
        colorText: Colors.white,
        'Success',
        'Ride is Returned',
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
          'Ride is Returned',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
      );

      Navigator.of(context).pop();
    } else {
      print(response.reasonPhrase);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> returnRide2() async {
    final box = GetStorage();
    final _token = box.read('token') ?? '';
    final courseId = box.read('courseId2');

    print("courseId conditionally called in function : $courseId");

    final storage = GetStorage();
    final userId = storage.read('user_id');

    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final gestionBaseUrl = configJson['planning_baseUrl'];
    final gestionApiKey = configJson['planning_apiKey'];

    final gestionMainUrl =
        gestionBaseUrl + "api/affectation/course/" + courseId.toString();

    var headers = {
      'x-api-key': '$gestionApiKey',
      'Authorization': 'Bearer ' + _token
    };

    var request = http.Request('POST', Uri.parse(gestionMainUrl));
    request.body = json.encode(
        {"chauffeur": userId.toString(), "motifAnnulation": reassign.text});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());

      Get.snackbar(
        colorText: Colors.white,
        'Success',
        'Ride is Returned',
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
          'Ride is Returned',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
      );

      Navigator.of(context).pop();
    } else {
      print(response.reasonPhrase);
    }
    return [];
  }

  Future<dynamic> adminFilter(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    // void clearTextField() {
    //   searchController1.text = '';
    //   searchController2.text = '';
    //   searchController3.text = '';
    //   searchController4.text = '';
    // }

    // String selectedRegion = '';
    final ValueNotifier<String> selectedRegionNotifier =
        ValueNotifier<String>("REGION");
    final ValueNotifier<String> selectedTypeNotifier =
        ValueNotifier<String>("TYPE");
    final ValueNotifier<String> selectedDriverNotifier =
        ValueNotifier<String>("DRIVER");
    final ValueNotifier<String> selectedClientNotifier =
        ValueNotifier<String>("CLIENT");

    void resetValues() {
      selectedRegionNotifier.value = "REGION";
      selectedTypeNotifier.value = "TYPE";
      selectedDriverNotifier.value = "DRIVER";
      selectedClientNotifier.value = "CLIENT";
    }

    bool _isRegionSelected = false;
    bool _isTypeSelected = false;
    bool _isDriverSelected = false;
    bool _isClientSelected = false;

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
          return StatefulBuilder(builder: (BuildContext context, index) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 1.25,
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 45,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ' Filter the race here ',
                              style: TextStyle(
                                color: Color(0xFF524D4D),
                                fontSize: 20,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w400,
                                height: 0,
                              ),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 85,
                        ),
                        Divider(
                          thickness: 0.5,
                          color: Colors.grey,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, top: 25),
                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                  backgroundColor: Color(0xFFE6F7FD),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(38),
                                    ),
                                  ),
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (context) {
                                    return StatefulBuilder(builder:
                                        (BuildContext context,
                                            StateSetter setState) {
                                      final box = GetStorage();
                                      List<dynamic> region =
                                          (box.read('regions') ?? []);
                                      print(
                                          "Region LIst in the Bottomsheet: $region");

                                      List<dynamic> filteredRegion =
                                          List.from(region);
                                      return Padding(
                                        padding:
                                            MediaQuery.of(context).viewInsets,
                                        child: SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                1.5,
                                            child: Center(
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              25,
                                                    ),
                                                    Divider(
                                                      thickness: 0.5,
                                                      color: Colors.grey,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 20),
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        height: 54,
                                                        decoration:
                                                            ShapeDecoration(
                                                          color: Colors.white,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 5),
                                                          child: TextFormField(
                                                            onChanged: (text) {
                                                              setState(() {
                                                                print(
                                                                    'Search text: $text');
                                                                filteredRegion = region
                                                                    .where((item) => item[
                                                                            "libelle"]
                                                                        .toLowerCase()
                                                                        .contains(
                                                                            text.toLowerCase()))
                                                                    .toList();
                                                                print(
                                                                    'Filtered List in the form field setstate: $filteredRegion');
                                                              });
                                                            },
                                                            controller:
                                                                searchController1,
                                                            decoration:
                                                                InputDecoration(
                                                                    hintText:
                                                                        'Search',
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                    suffixIcon:
                                                                        Icon(
                                                                      Icons
                                                                          .search,
                                                                      color: Colors
                                                                          .black,
                                                                    )),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: ListView.builder(
                                                        itemCount:
                                                            region.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          final item =
                                                              region[index];
                                                          final String
                                                              regionName =
                                                              item["libelle"];
                                                          final bool
                                                              isSelected =
                                                              selectedRegionNotifier
                                                                      .value ==
                                                                  regionName;

                                                          final bool
                                                              shouldDisplay =
                                                              regionName
                                                                  .toLowerCase()
                                                                  .contains(
                                                                    searchController1
                                                                        .text
                                                                        .toLowerCase(),
                                                                  );

                                                          return shouldDisplay
                                                              ? Center(
                                                                  child:
                                                                      ListTile(
                                                                    onTap: () {
                                                                      selectedRegionNotifier
                                                                              .value =
                                                                          regionName;
                                                                      _isRegionSelected =
                                                                          true;
                                                                      int Id = int
                                                                          .parse(
                                                                              item["id"]);
                                                                      box.write(
                                                                          'regionId',
                                                                          Id);
                                                                      final idregion =
                                                                          box.read(
                                                                              'regionId');
                                                                      print(
                                                                          'id in storage for api: $idregion');
                                                                      DriverList();
                                                                      ClientList();
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    title: Text(
                                                                        regionName),
                                                                    trailing: isSelected
                                                                        ? Icon(
                                                                            Icons.check,
                                                                            color:
                                                                                Colors.blue,
                                                                          )
                                                                        : null,
                                                                  ),
                                                                )
                                                              : SizedBox
                                                                  .shrink();
                                                        },
                                                      ),
                                                    ),
                                                  ]),
                                            )),
                                      );
                                    });
                                  });
                            },
                            child: Container(
                              width: 280,
                              height: 45,
                              decoration: ShapeDecoration(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ValueListenableBuilder<String>(
                                    valueListenable: selectedRegionNotifier,
                                    builder: (context, selectedRegion, _) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(width: 20),
                                          if (selectedRegionNotifier.value !=
                                              "REGION")
                                            GestureDetector(
                                                onTap: () {
                                                  selectedRegionNotifier.value =
                                                      "REGION";
                                                },
                                                child: Image.asset(
                                                  'assets/images/cross2.png',
                                                  color: Colors.red,
                                                  scale: 1.5,
                                                )),
                                          SizedBox(width: 30),
                                          Text(
                                            selectedRegion,
                                            style: TextStyle(
                                              color: selectedRegionNotifier
                                                          .value !=
                                                      "REGION"
                                                  ? Colors.blue
                                                  : Color(0xFF524D4D),
                                              fontSize: 14,
                                              fontFamily: 'Kanit',
                                              fontWeight: FontWeight.w400,
                                              height: 0,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(width: 30),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, top: 15),
                          child: GestureDetector(
                            onTap: () {
                              if (selectedRegionNotifier.value != "REGION") {
                                showModalBottomSheet(
                                    backgroundColor: Color(0xFFE6F7FD),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(38),
                                      ),
                                    ),
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (context) {
                                      return StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter setState) {
                                        final box = GetStorage();
                                        List<dynamic> type =
                                            (box.read('type') ?? []);
                                        print(
                                            "Type LIst in the Bottomsheet: $type");
                                        List<dynamic> filteredType =
                                            List.from(type);

                                        void clearTextField() {
                                          searchController2.text = "";
                                        }

                                        return Padding(
                                          padding:
                                              MediaQuery.of(context).viewInsets,
                                          child: SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  1.5,
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              25,
                                                    ),
                                                    Divider(
                                                      thickness: 0.5,
                                                      color: Colors.grey,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 20),
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        height: 54,
                                                        decoration:
                                                            ShapeDecoration(
                                                          color: Colors.white,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 5),
                                                          child: TextFormField(
                                                            onChanged: (text) {
                                                              setState(() {
                                                                print(
                                                                    'Search text: $text');
                                                                filteredType = type
                                                                    .where((item) => item[
                                                                            "libelle"]
                                                                        .toLowerCase()
                                                                        .contains(
                                                                            text.toLowerCase()))
                                                                    .toList();
                                                                print(
                                                                    'Filtered List in the form field setstate: $filteredType');
                                                              });
                                                            },
                                                            controller:
                                                                searchController2,
                                                            decoration:
                                                                InputDecoration(
                                                                    hintText:
                                                                        'Search',
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                    suffixIcon:
                                                                        Icon(
                                                                      Icons
                                                                          .search,
                                                                      color: Colors
                                                                          .black,
                                                                    )),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: ListView.builder(
                                                        itemCount: type.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          final item =
                                                              type[index];
                                                          final String
                                                              typeName =
                                                              item["libelle"];
                                                          final bool
                                                              isSelected =
                                                              selectedTypeNotifier
                                                                      .value ==
                                                                  typeName;
                                                          final bool
                                                              shouldDisplay =
                                                              typeName
                                                                  .toLowerCase()
                                                                  .contains(
                                                                    searchController2
                                                                        .text
                                                                        .toLowerCase(),
                                                                  );
                                                          return shouldDisplay
                                                              ? Center(
                                                                  child:
                                                                      ListTile(
                                                                          onTap:
                                                                              () {
                                                                            selectedTypeNotifier.value =
                                                                                typeName;
                                                                            int Id =
                                                                                int.parse(item["id"]);
                                                                            box.write('typeId',
                                                                                Id);
                                                                            final idType =
                                                                                box.read('typeId');
                                                                            print(' Type id in storage for api: $idType');
                                                                            DriverList();
                                                                            ClientList();
                                                                            Navigator.pop(context);
                                                                          },
                                                                          title: Text(
                                                                              typeName),
                                                                          trailing: isSelected
                                                                              ? Icon(Icons.check)
                                                                              : null),
                                                                )
                                                              : SizedBox
                                                                  .shrink();
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )),
                                        );
                                      });
                                    });
                              }
                            },
                            child: Container(
                              width: 280,
                              height: 45,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                              child: Center(
                                child: ValueListenableBuilder<String>(
                                  valueListenable: selectedTypeNotifier,
                                  builder: (context, selectedRegion, _) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(width: 20),
                                        if (selectedTypeNotifier.value !=
                                            "TYPE")
                                          GestureDetector(
                                              onTap: () {
                                                selectedTypeNotifier.value =
                                                    "TYPE";
                                              },
                                              child: Image.asset(
                                                'assets/images/cross2.png',
                                                color: Colors.red,
                                                scale: 1.5,
                                              )),
                                        SizedBox(width: 30),
                                        Text(
                                          selectedRegion,
                                          style: TextStyle(
                                            color: selectedTypeNotifier.value !=
                                                    "TYPE"
                                                ? Colors.blue
                                                : Color(0xFF524D4D),
                                            fontSize: 14,
                                            fontFamily: 'Kanit',
                                            fontWeight: FontWeight.w400,
                                            height: 0,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(width: 30),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, top: 15),
                          child: GestureDetector(
                            onTap: () {
                              if (selectedRegionNotifier.value != "REGION") {
                                showModalBottomSheet(
                                    backgroundColor: Color(0xFFE6F7FD),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(38),
                                      ),
                                    ),
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (context) {
                                      return StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter setState) {
                                        final box = GetStorage();
                                        List<dynamic> allDrivers =
                                            (box.read('driver') ?? []);

                                        List<dynamic> filteredDrivers =
                                            List.from(allDrivers);
                                        return Padding(
                                          padding:
                                              MediaQuery.of(context).viewInsets,
                                          child: SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  1.5,
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              25,
                                                    ),
                                                    Divider(
                                                      thickness: 0.5,
                                                      color: Colors.grey,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 20),
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        height: 54,
                                                        decoration:
                                                            ShapeDecoration(
                                                          color: Colors.white,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 5),
                                                          child: TextFormField(
                                                            onChanged: (text) {
                                                              setState(() {
                                                                if (text
                                                                    .isEmpty) {
                                                                  filteredDrivers =
                                                                      List.from(
                                                                          allDrivers);
                                                                } else {
                                                                  filteredDrivers = allDrivers
                                                                      .where((item) =>
                                                                          item["nom"].toLowerCase().contains(text
                                                                              .toLowerCase()) ||
                                                                          item["prenom"]
                                                                              .toLowerCase()
                                                                              .contains(text.toLowerCase()))
                                                                      .toList();
                                                                }
                                                              });
                                                            },
                                                            controller:
                                                                searchController3,
                                                            decoration:
                                                                InputDecoration(
                                                                    hintText:
                                                                        'Search',
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                    suffixIcon:
                                                                        Icon(
                                                                      Icons
                                                                          .search,
                                                                      color: Colors
                                                                          .black,
                                                                    )),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                        child:
                                                            allDrivers.isEmpty
                                                                ? Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Image.asset(
                                                                          'assets/images/taxi2.png'),
                                                                      SizedBox(
                                                                          height:
                                                                              20),
                                                                      Text(
                                                                        'No Drivers available for this region..!!',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.black,
                                                                          fontSize:
                                                                              16,
                                                                          fontFamily:
                                                                              'Kanit',
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                          height:
                                                                              0,
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              20)
                                                                    ],
                                                                  )
                                                                : ListView
                                                                    .builder(
                                                                    itemCount:
                                                                        filteredDrivers
                                                                            .length,
                                                                    itemBuilder:
                                                                        (context,
                                                                            index) {
                                                                      if (filteredDrivers
                                                                          .isEmpty) {
                                                                        return Center(
                                                                          child:
                                                                              Text(
                                                                            'No Drivers available',
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 16,
                                                                              fontFamily: 'Kanit',
                                                                              fontWeight: FontWeight.w400,
                                                                              height: 0,
                                                                            ),
                                                                          ),
                                                                        );
                                                                      }

                                                                      final item =
                                                                          filteredDrivers[
                                                                              index];
                                                                      final String
                                                                          driverName =
                                                                          "${item["nom"]} ${item["prenom"]}"
                                                                              .toLowerCase();
                                                                      final bool
                                                                          isSelected =
                                                                          selectedDriverNotifier.value ==
                                                                              "${item["nom"]} ${item["prenom"]}";
                                                                      final bool
                                                                          shouldDisplay =
                                                                          driverName
                                                                              .contains(
                                                                        searchController3
                                                                            .text
                                                                            .toLowerCase(),
                                                                      );
                                                                      return shouldDisplay
                                                                          ? Center(
                                                                              child: ListTile(
                                                                                  onTap: () {
                                                                                    final box = GetStorage();
                                                                                    String driverid = item['id'].toString();
                                                                                    print('Driver Id for filter:  $driverid');
                                                                                    box.write('driverId', driverid);
                                                                                    selectedDriverNotifier.value = "${item["nom"]} ${item["prenom"]}";
                                                                                    Navigator.pop(context);
                                                                                    filteredDrivers.clear();
                                                                                  },
                                                                                  title: Row(
                                                                                    children: [
                                                                                      Text(item["nom"]),
                                                                                      SizedBox(width: 5),
                                                                                      Text(item["prenom"]),
                                                                                    ],
                                                                                  ),
                                                                                  trailing: isSelected ? Icon(Icons.check, color: Colors.blue) : null),
                                                                            )
                                                                          : SizedBox
                                                                              .shrink();
                                                                    },
                                                                  )),
                                                  ],
                                                ),
                                              )),
                                        );
                                      });
                                    });
                              }
                            },
                            child: Container(
                              width: 280,
                              height: 45,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                              child: Center(
                                child: ValueListenableBuilder<String>(
                                  valueListenable: selectedDriverNotifier,
                                  builder: (context, selectedRegion, _) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(width: 20),
                                        if (selectedDriverNotifier.value !=
                                            "DRIVER")
                                          GestureDetector(
                                              onTap: () {
                                                selectedDriverNotifier.value =
                                                    "DRIVER";
                                              },
                                              child: Image.asset(
                                                'assets/images/cross2.png',
                                                color: Colors.red,
                                                scale: 1.5,
                                              )),
                                        SizedBox(width: 30),
                                        Text(
                                          selectedRegion,
                                          style: TextStyle(
                                            color:
                                                selectedDriverNotifier.value !=
                                                        "DRIVER"
                                                    ? Colors.blue
                                                    : Color(0xFF524D4D),
                                            fontSize: 14,
                                            fontFamily: 'Kanit',
                                            fontWeight: FontWeight.w400,
                                            height: 0,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                          width: 30,
                                        )
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, top: 15, bottom: 35),
                          child: GestureDetector(
                            onTap: () {
                              if (selectedRegionNotifier.value != "REGION") {
                                showModalBottomSheet(
                                    backgroundColor: Color(0xFFE6F7FD),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(38),
                                      ),
                                    ),
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (context) {
                                      return StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter setState) {
                                        final box = GetStorage();
                                        List<dynamic> client =
                                            (box.read('client') ?? []);
                                        print(
                                            "Client LIst in the Bottomsheet: $client");
                                        List<dynamic> filteredClient =
                                            List.from(client);
                                        return Padding(
                                          padding:
                                              MediaQuery.of(context).viewInsets,
                                          child: SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  1.5,
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              25,
                                                    ),
                                                    Divider(
                                                      thickness: 0.5,
                                                      color: Colors.grey,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 20),
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        height: 54,
                                                        decoration:
                                                            ShapeDecoration(
                                                          color: Colors.white,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 5),
                                                          child: TextFormField(
                                                            onChanged: (text) {
                                                              setState(() {
                                                                if (text
                                                                    .isEmpty) {
                                                                  // Show the original list when the TextField is empty
                                                                  filteredClient =
                                                                      List.from(
                                                                          client);
                                                                } else {
                                                                  // Filter drivers based on the search text
                                                                  filteredClient = client
                                                                      .where((item) =>
                                                                          item["nom"].toLowerCase().contains(text
                                                                              .toLowerCase()) ||
                                                                          item["prenom"]
                                                                              .toLowerCase()
                                                                              .contains(text.toLowerCase()))
                                                                      .toList();
                                                                }
                                                              });
                                                            },
                                                            controller:
                                                                searchController4,
                                                            decoration:
                                                                InputDecoration(
                                                                    hintText:
                                                                        'Search',
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                    suffixIcon:
                                                                        Icon(
                                                                      Icons
                                                                          .search,
                                                                      color: Colors
                                                                          .black,
                                                                    )),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: client.isEmpty
                                                          ? Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Image.asset(
                                                                    'assets/images/client2.png'),
                                                                SizedBox(
                                                                    height: 20),
                                                                Text(
                                                                  'No Clients available for this region..!!',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        16,
                                                                    fontFamily:
                                                                        'Kanit',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    height: 0,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                                SizedBox(
                                                                    height: 20)
                                                              ],
                                                            )
                                                          : ListView.builder(
                                                              itemCount:
                                                                  filteredClient
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                if (filteredClient
                                                                    .isEmpty) {
                                                                  return Center(
                                                                    child: Text(
                                                                      'No Clients available',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            16,
                                                                        fontFamily:
                                                                            'Kanit',
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                        height:
                                                                            0,
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                                final item =
                                                                    filteredClient[
                                                                        index];
                                                                final String
                                                                    clientName =
                                                                    "${item["nom"]} ${item["prenom"]}"
                                                                        .toLowerCase();
                                                                final bool
                                                                    isSelected =
                                                                    selectedClientNotifier
                                                                            .value ==
                                                                        "${item["nom"]} ${item["prenom"]}";
                                                                final bool
                                                                    shouldDisplay =
                                                                    clientName
                                                                        .contains(
                                                                  searchController4
                                                                      .text
                                                                      .toLowerCase(),
                                                                );

                                                                return shouldDisplay
                                                                    ? Center(
                                                                        child:
                                                                            ListTile(
                                                                          onTap:
                                                                              () {
                                                                            final box =
                                                                                GetStorage();
                                                                            String
                                                                                clientid =
                                                                                item['id'].toString();
                                                                            box.write('clientId',
                                                                                clientid);
                                                                            final IdClient =
                                                                                box.read('clientId');
                                                                            print('Client in Storage for filter: $IdClient');
                                                                            selectedClientNotifier.value =
                                                                                "${item["nom"]} ${item["prenom"]}";
                                                                            Navigator.pop(context);
                                                                          },
                                                                          title:
                                                                              Row(
                                                                            children: [
                                                                              Text(item["nom"]),
                                                                              SizedBox(width: 5),
                                                                              Text(item["prenom"]),
                                                                            ],
                                                                          ),
                                                                          trailing: isSelected
                                                                              ? Icon(
                                                                                  Icons.check,
                                                                                  color: Colors.blue,
                                                                                )
                                                                              : null,
                                                                        ),
                                                                      )
                                                                    : SizedBox
                                                                        .shrink();
                                                              },
                                                            ),
                                                    ),
                                                  ],
                                                ),
                                              )),
                                        );
                                      });
                                    });
                              }
                            },
                            child: Container(
                              width: 280,
                              height: 45,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                              child: Center(
                                child: ValueListenableBuilder<String>(
                                  valueListenable: selectedClientNotifier,
                                  builder: (context, selectedRegion, _) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(width: 20),
                                        if (selectedClientNotifier.value !=
                                            "CLIENT")
                                          GestureDetector(
                                              onTap: () {
                                                selectedClientNotifier.value =
                                                    "CLIENT";
                                              },
                                              child: Image.asset(
                                                'assets/images/cross2.png',
                                                color: Colors.red,
                                                scale: 1.5,
                                              )),
                                        SizedBox(width: 5),
                                        Text(
                                          selectedRegion,
                                          style: TextStyle(
                                            color:
                                                selectedClientNotifier.value !=
                                                        "CLIENT"
                                                    ? Colors.blue
                                                    : Color(0xFF524D4D),
                                            fontSize: 14,
                                            fontFamily: 'Kanit',
                                            fontWeight: FontWeight.w400,
                                            height: 0,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
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
                                      primary: Color(0xFF3954A4),
                                    ),
                                    child: Text('Valider'),
                                    onPressed: () {
                                      setState(() {
                                        isFiltered = true;
                                      });
                                      print(
                                          '==================================================');
                                      filteredListAdmin();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
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
                                        primary: Colors.grey,
                                      ),
                                      child: Text('Reset'),
                                      onPressed: () {
                                        resetValues();
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        }).whenComplete(() => () {
          setState(() {
            isRefreshed = true;
          });
          Future.delayed(Duration(milliseconds: 500), () {
            setState(() {
              isRefreshed = false;
            });
          });
        });
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
                  )),
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

  Future<dynamic> annulerBottomSheet(
    BuildContext context,
  ) async {
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
          final box = GetStorage();
          List<dynamic> tripData = box.read('AdminToday');

          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: SizedBox(
              height: MediaQuery.of(context).size.height / 2,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 45,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Annuler Affectation',
                            style: TextStyle(
                              color: Color(0xFF524D4D),
                              fontSize: 18,
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.w500,
                              height: 0.05,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 95,
                    ),
                    Divider(
                      thickness: 0.5,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      height: 9,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        decoration: ShapeDecoration(
                          color: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Text()
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Divider(
                      thickness: 0.5,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text(
                                'Client Absent',
                                style: TextStyle(
                                  color: Color(0xFF524D4D),
                                  fontSize: 18,
                                  fontFamily: 'Kanit',
                                  fontWeight: FontWeight.w500,
                                  height: 0.05,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<dynamic> returnBottomSheet(BuildContext context) {
    void clearTextField5() {
      assignController.text = '';
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
              height: MediaQuery.of(context).size.height / 2,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 45,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'ReturnTrip',
                            style: TextStyle(
                              color: Color(0xFF524D4D),
                              fontSize: 18,
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.w500,
                              height: 0.05,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 95,
                    ),
                    Divider(
                      thickness: 0.5,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      height: 9,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          print('Ontap 2 Triggered..!!');
                          annulerBottomSheet(context);
                        },
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: Text(
                              'Return Ride',
                              style: TextStyle(
                                color: Color(0xFF524D4D),
                                fontSize: 18,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w500,
                                height: 0.05,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Divider(
                      thickness: 0.5,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          print('Ontap 2 Triggered..!!');
                        },
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: Text(
                              'Client Absent',
                              style: TextStyle(
                                color: Color(0xFF524D4D),
                                fontSize: 18,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w500,
                                height: 0.05,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).whenComplete(clearTextField5);
  }

  Future<List<Map<String, dynamic>>> TripListToday() async {
    final box = GetStorage();
    final _token = box.read('token') ?? '';
    final storage = GetStorage();

    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final gestionBaseUrl = configJson['planning_baseUrl'];
    final gestionApiKey = configJson['planning_apiKey'];

    final gestionMainUrl = gestionBaseUrl + "mob/course-all-aujourdhui";

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

      List<Map<String, dynamic>> AdminToday = [];
      for (var courses in apiData['courses']) {
        int id = courses['id'];
        // String start = courses['start'];
        int nombrePassager = courses['nombrePassager'];
        String commentaire = courses['commentaire'];
        String paiement = courses['paiement'];
        int client = courses['client'];
        String status1 = courses['affectationCourses'][0]['status1'];
        String status2 = courses['affectationCourses'][0]['status2'];
        String reference = courses['reference'];

        String backgroundColor = courses['backgroundColor'];
        String dateCourse = courses['dateCourse'];
        String nom = courses['clientDetails']['nom'];
        String prenom = courses['clientDetails']['prenom'];
        String telephone = courses['clientDetails']['tel1'];
        int region = courses['region'];

        int imgType = courses['clientDetails']['typeClient']['id'] ?? "";
        AdminToday.add({
          'id': id,
          // 'start': start,
          'nombrePassager': nombrePassager,
          'commentaire': commentaire,
          'paiement': paiement,
          'reference': reference,
          'dateCourse': dateCourse,
          'client': client,
          'region': region,
          'status1': status1,
          'status2': status2,
          'backgroundColor': backgroundColor,
          'nom': nom,
          'prenom': prenom,
          'telephone': telephone,
          'imgType': imgType,
        });
      }

      print(AdminToday);
      box.write('AdminToday5', AdminToday);
      List<dynamic> AdminToday2 = box.read('AdminToday5');
      print('Admin Today in storage with refernce and date : $AdminToday2');

      return AdminToday;
    } else {
      print(response.reasonPhrase);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> TripListFutureAdmin() async {
    final box = GetStorage();
    final _token = box.read('token') ?? '';
    final storage = GetStorage();
    final UserID = storage.read('user_id');

    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final gestionBaseUrl = configJson['planning_baseUrl'];
    final gestionApiKey = configJson['planning_apiKey'];

    final gestionMainUrl = gestionBaseUrl + "mob/course-all-avenir";

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

      List<Map<String, dynamic>> AdminAvenir = [];
      for (var courses in apiData['courses']) {
        int id = courses['id'];
        // String start = courses['start'];
        int nombrePassager = courses['nombrePassager'];
        String commentaire = courses['commentaire'];
        String paiement = courses['paiement'];
        int client = courses['client'];
        String status1 = courses['affectationCourses'][0]['status1'];
        String status2 = courses['affectationCourses'][0]['status2'];
        String reference = courses['reference'];

        String backgroundColor = courses['backgroundColor'];
        String dateCourse = courses['dateCourse'];
        String nom = courses['clientDetails']['nom'];
        String prenom = courses['clientDetails']['prenom'];
        String telephone = courses['clientDetails']['tel1'];
        int region = courses['region'];

        int imgType = courses['clientDetails']['typeClient']['id'] ?? "";
        AdminAvenir.add({
          'id': id,
          // 'start': start,
          'nombrePassager': nombrePassager,
          'commentaire': commentaire,
          'paiement': paiement,
          'reference': reference,
          'dateCourse': dateCourse,
          'client': client,
          'region': region,
          'status1': status1,
          'status2': status2,
          'backgroundColor': backgroundColor,
          'nom': nom,
          'prenom': prenom,
          'telephone': telephone,
          'imgType': imgType,
        });
      }

      print('Admin AVenir with reference: $AdminAvenir');
      box.write('AdminAvenir5', AdminAvenir);

      return AdminAvenir;
    } else {
      print(response.reasonPhrase);
    }
    return [];
  }

  bool isFiltered = false;

  Future<List<Map<String, dynamic>>> filteredListAdmin() async {
    final box = GetStorage();
    final _token = box.read('token') ?? '';
    final regionId = box.read('regionId');
    final typeId = box.read('typeId');
    final driverId = box.read('driverId');
    final clientId = box.read('clientId');

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
      "client": clientId,
      "chauffeur": driverId,
      if (isToday) "passeAvenirToday": today.toString(),
      if (isFuture) "passeAvenirToday": future.toString(),
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
        // int status1 = courses['statusCourse'];
        // String status2 = courses['affectationCourses'][0]['status2'];
        String reference = courses['reference'];
        String backgroundColor = courses['backgroundColor'];
        String dateCourse = courses['dateCourse'];
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
      box.write('filteredList5', Filteredlist);
      List<dynamic> filteredAdmin = box.read('filteredList5');
      print('Filtered list in Storage: $filteredAdmin');
      Navigator.of(context).pop();

      return Filteredlist;
    } else {
      print(response.reasonPhrase);
    }

    return [];
  }

  ScrollController controller = ScrollController();

  int currentPage = 1;
  int itemsPerPage = 10;
  bool isAtEndOfList = false;

  Future<void> _scrollListener() async {
    if (controller.position.pixels == controller.position.maxScrollExtent) {
      setState(() {
        isAtEndOfList = true;
      });

      // Simulate a delay before loading more items (adjust the duration as needed)
      await Future.delayed(Duration(seconds: 2));

      // Load additional items
      setState(() {
        currentPage++;
        isAtEndOfList = false;
      });
    }
  }

  int calculateItemCount() {
    int itemCount = 0;

    if (isToday || isFuture) {
      itemCount += isAtEndOfList
          ? (currentPage * itemsPerPage) + 1
          : (currentPage * itemsPerPage);
    }

    return itemCount;
  }

  bool shouldShowLoader(int index) {
    return isAtEndOfList && index == calculateItemCount() - 1;
  }

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    List<dynamic>? AdminToday = box.read('AdminToday5') ?? [];
    bool AdminToday2 = AdminToday.contains('');
    List<dynamic>? AdminFuture2 = box.read('AdminAvenir5') ?? [];
    bool AdminFuture3 = AdminToday.contains('');
    List<dynamic>? FilteredList = box.read('filteredList5') ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: 180,
                  decoration: BoxDecoration(color: Color(0xFF3954A4)),
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 25,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 10, top: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Text(
                                'Planning',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontFamily: 'Kanit',
                                  fontWeight: FontWeight.w600,
                                  height: 0,
                                ),
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  Get.to(() => Profile());
                                },
                                icon: Icon(
                                  Icons.person_outline,
                                  color: Colors.white,
                                  size: 30,
                                ))
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.height / 45,
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 10,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        adminFilter(context);
                                      },
                                      child: Image.asset(
                                          'assets/images/filter.png'),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    (isFiltered)
                                        ? GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                isRefreshed = true;
                                                isFiltered = false;
                                              });
                                              Future.delayed(
                                                  Duration(milliseconds: 600),
                                                  () {
                                                setState(() {
                                                  isRefreshed = false;
                                                });
                                              });
                                              setState(() {
                                                isFiltered = false;
                                              });
                                            },
                                            child: Center(
                                              child: Image.asset(
                                                'assets/images/cross3.png',
                                              ),
                                            ),
                                          )
                                        : Container()
                                  ],
                                )
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 45,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
              Positioned(
                bottom: -15,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () {
                              _changeTodayContainerColor();
                            },
                            child: Container(
                              width: 150,
                              height: 43,
                              decoration: BoxDecoration(
                                  color: todayContainerColor,
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
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    "Today",
                                    style: TextStyle(
                                      color: Color(0xFF524D4D),
                                      fontSize: 14,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.w400,
                                      height: 0.11,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: GestureDetector(
                            onTap: () {
                              _changeFutureContainerColor();
                            },
                            child: Container(
                              width: 150,
                              height: 43,
                              decoration: BoxDecoration(
                                  color: futureContainerColor,
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
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    "Future",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.w400,
                                      height: 0.11,
                                    ),
                                  ),
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
          SizedBox(
            height: 20,
          ),
          (AdminFuture2.isEmpty && !isToday)
              ? Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(child: Image.asset('assets/images/noTrip.png')),
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
          (AdminToday.isEmpty && !isFuture)
              ? Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(child: Image.asset('assets/images/noTrip.png')),
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
            child: Container(
              height: 650,
              child: LiquidPullToRefresh(
                backgroundColor: Color(0xFF3954A4),
                height: 80,
                animSpeedFactor: 2,
                showChildOpacityTransition: false,
                color: Colors.white,
                onRefresh: handleRefresh,
                child: ((AdminFuture2.isEmpty && !isToday) ||
                        (AdminToday.isEmpty && !isFuture))
                    ? Container()
                    : isRefreshed
                        ? Center(
                            child: CircularProgressIndicator(
                            color: Color(0xFF3954A4),
                          ))
                        : ListView.builder(
                            controller: controller,
                            itemCount: calculateItemCount(),
                            itemBuilder: (context, index) {
                              var item;
                              if (isToday) {
                                item = (index >= 0 && index < AdminToday.length)
                                    ? AdminToday[index]
                                    : null;
                              } else if (isFuture) {
                                item =
                                    (index >= 0 && index < AdminFuture2.length)
                                        ? AdminFuture2[index]
                                        : null;
                              } else {
                                item = null;
                              }

                              String status1 = item['status1'] ?? '';
                              String status2 = item['status2'] ?? '';
                              String date = item['dateCourse'];
                              String imgType = item['imgType'].toString();
                              DateTime dateTime = DateTime.parse(date);
                              tz.TZDateTime parisDateTime = tz.TZDateTime.from(
                                  dateTime, tz.getLocation('Europe/Paris'));

                              String formattedDate =
                                  DateFormat('dd-MMM').format(parisDateTime);

                              print(
                                  'Image type for vehicle image in card trip: $imgType');
                              Image? getImageBasedOnType(String imgType) {
                                switch (imgType) {
                                  case "1":
                                    return Image.asset(
                                        'assets/images/taxiCart.png');
                                  case "2":
                                    return Image.asset(
                                        'assets/images/ambulanceVCart.png');
                                  case "3":
                                    return Image.asset(
                                        'assets/images/schoolbusCart.png');
                                  default:
                                    return null;
                                }
                              }

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

                              if (shouldShowLoader(index)) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 15),
                                    width: 411,
                                    height:
                                        isOptionsAndCommentVisible ? 350 : 220,
                                    decoration: ShapeDecoration(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
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
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Text(
                                                item['id'].toString(),
                                                style: TextStyle(
                                                  color: Color(0xFF3954A4),
                                                  fontSize: 16,
                                                  fontFamily: 'Kanit',
                                                  fontWeight: FontWeight.w500,
                                                  height: 0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        ListTile(
                                          visualDensity: VisualDensity(
                                              vertical: -4, horizontal: -4),
                                          minLeadingWidth: 0,
                                          leading: getImageBasedOnType(imgType),
                                          title: Text(
                                            '${item['nom']} ${item['prenom']}',
                                            style: TextStyle(
                                              color: Color(0xFF524D4D),
                                              fontSize: 18,
                                              fontFamily: 'Kanit',
                                              fontWeight: FontWeight.w400,
                                              height: 0,
                                            ),
                                          ),
                                          trailing: IconButton(
                                              onPressed: () async {
                                                final call = Uri.parse(
                                                    'tel:${item['telephone']}');
                                                if (await canLaunchUrl(call)) {
                                                  launchUrl(call);
                                                } else {
                                                  throw 'Could not launch $call';
                                                }
                                              },
                                              icon: Icon(
                                                Icons.phone,
                                                color: Colors.black,
                                                size: 30,
                                              )),
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              width: 30,
                                              height: 93,
                                              decoration: ShapeDecoration(
                                                color: Color(0xFFEA690C),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(50),
                                                    bottomRight:
                                                        Radius.circular(50),
                                                  ),
                                                ),
                                              ),
                                              child: RotatedBox(
                                                quarterTurns: 1,
                                                child: Center(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10, top: 10),
                                                    child: (isFiltered)
                                                        ? Text(
                                                            "Status",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Kanit',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                              height: 0.12,
                                                            ),
                                                          )
                                                        : Text(
                                                            statusText,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Kanit',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                              height: 0.12,
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 15,
                                            ),
                                            Flexible(
                                              child: Column(
                                                children: [
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            1.15,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        Image.asset(
                                                            'assets/images/location3.png'),
                                                        SizedBox(
                                                          width: 15,
                                                        ),
                                                        Text(
                                                          'Address to be fetched',
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF524D4D),
                                                            fontSize: 14,
                                                            fontFamily: 'Kanit',
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            height: 0,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              9.9,
                                                        ),
                                                        Flexible(
                                                          child: IconButton(
                                                              onPressed: () {
                                                                Get.to(
                                                                    () =>
                                                                        TripDetails(),
                                                                    arguments: [
                                                                      item['id']
                                                                          .toString(),
                                                                    ]);
                                                              },
                                                              icon: Icon(
                                                                Icons
                                                                    .error_outline,
                                                                color: Colors
                                                                    .black,
                                                                size: 30,
                                                              )),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Image.asset(
                                                          'assets/images/location4.png'),
                                                      SizedBox(
                                                        width: 15,
                                                      ),
                                                      Text(
                                                        'Address to be fetched',
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xFF524D4D),
                                                          fontSize: 14,
                                                          fontFamily: 'Kanit',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          height: 0,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        ListTile(
                                          leading: Image.asset(
                                              'assets/images/arrow.png'),
                                          title: Text(
                                            'Options and Comment :',
                                            style: TextStyle(
                                              color: Color(0xFF524D4D),
                                              fontSize: 14,
                                              fontFamily: 'Kanit',
                                              fontWeight: FontWeight.w400,
                                              height: 0,
                                            ),
                                          ),
                                          onTap: () {
                                            setState(() {
                                              isOptionsAndCommentVisible =
                                                  !isOptionsAndCommentVisible;
                                            });
                                          },
                                          trailing: GestureDetector(
                                            onTap: () {
                                              final regionId2 = item['region'];
                                              final courseId2 = item['id'];
                                              print(
                                                  'Region Id in Future $regionId2');
                                              print(
                                                  'Course Id in Future $courseId2');
                                              box.write('regionId3', regionId2);
                                              String id = box
                                                  .read('regionId3')
                                                  .toString();
                                              print(
                                                  'Region Id in Storage for API $id');
                                              box.write('courseId2', courseId2);
                                              // regionList();
                                              showModalBottomSheet(
                                                  backgroundColor:
                                                      Color(0xFFE6F7FD),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                      top: Radius.circular(38),
                                                    ),
                                                  ),
                                                  isScrollControlled: true,
                                                  context: context,
                                                  builder: (context) {
                                                    return Padding(
                                                      padding:
                                                          MediaQuery.of(context)
                                                              .viewInsets,
                                                      child: SizedBox(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            2,
                                                        child: Center(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height /
                                                                    45,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child: Text(
                                                                      'ReturnTrip',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color(
                                                                            0xFF524D4D),
                                                                        fontSize:
                                                                            18,
                                                                        fontFamily:
                                                                            'Kanit',
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        height:
                                                                            0.05,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height /
                                                                    95,
                                                              ),
                                                              Divider(
                                                                thickness: 0.5,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                              SizedBox(
                                                                height: 9,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    print(
                                                                        'Ontap 2 Triggered..!!');
                                                                    showModalBottomSheet(
                                                                        backgroundColor:
                                                                            Color(
                                                                                0xFFE6F7FD),
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.vertical(
                                                                            top:
                                                                                Radius.circular(38),
                                                                          ),
                                                                        ),
                                                                        isScrollControlled:
                                                                            true,
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) {
                                                                          final TextEditingController
                                                                              _controller =
                                                                              TextEditingController();
                                                                          String?
                                                                              _selectedValue;
                                                                          List<dynamic>
                                                                              driverList3 =
                                                                              box.read('driver2');
                                                                          DateTime
                                                                              parsedDate =
                                                                              DateTime.parse(item['dateCourse']);
                                                                          DateTime
                                                                              utcDate =
                                                                              parsedDate.toUtc();
                                                                          return Padding(
                                                                            padding:
                                                                                MediaQuery.of(context).viewInsets,
                                                                            child:
                                                                                SizedBox(
                                                                              height: MediaQuery.of(context).size.height / 2,
                                                                              child: Center(
                                                                                child: Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  children: [
                                                                                    SizedBox(
                                                                                      height: MediaQuery.of(context).size.height / 45,
                                                                                    ),
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.all(8.0),
                                                                                          child: Text(
                                                                                            'Annuler Affectation',
                                                                                            style: TextStyle(
                                                                                              color: Color(0xFF524D4D),
                                                                                              fontSize: 18,
                                                                                              fontFamily: 'Kanit',
                                                                                              fontWeight: FontWeight.w500,
                                                                                              height: 0.05,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(
                                                                                      height: MediaQuery.of(context).size.height / 95,
                                                                                    ),
                                                                                    Divider(
                                                                                      thickness: 0.5,
                                                                                      color: Colors.grey,
                                                                                    ),
                                                                                    SizedBox(
                                                                                      height: 9,
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: EdgeInsets.symmetric(horizontal: 20),
                                                                                      child: Container(
                                                                                        width: MediaQuery.of(context).size.width,
                                                                                        height: 50,
                                                                                        decoration: ShapeDecoration(
                                                                                          color: Colors.grey.shade200,
                                                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                                                                        ),
                                                                                        child: Flexible(
                                                                                          child: Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                            children: [
                                                                                              if (item['reference'] == "") Text("No Reference"),
                                                                                              Text(item['reference']),
                                                                                              Text('-'),
                                                                                              Text(DateFormat('dd-MM-yyyy         -         hh:mm a').format(utcDate)),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    SizedBox(
                                                                                      height: 15,
                                                                                    ),
                                                                                    Container(
                                                                                      decoration: BoxDecoration(
                                                                                        borderRadius: BorderRadius.circular(15),
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
                                                                                          controller: reassign,
                                                                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                                                                          decoration: InputDecoration(
                                                                                              filled: true,
                                                                                              fillColor: Colors.white,
                                                                                              border: InputBorder.none,
                                                                                              errorBorder: OutlineInputBorder(
                                                                                                borderRadius: BorderRadius.circular(10),
                                                                                                borderSide: const BorderSide(color: Colors.red, width: 1.2),
                                                                                              ),
                                                                                              labelText: "Motif d'annulation",
                                                                                              labelStyle: TextStyle(
                                                                                                fontWeight: FontWeight.w900,
                                                                                                color: Color(0xFFA4A4A4),
                                                                                              ) // Placeholder text
                                                                                              ),
                                                                                          validator: (value) {
                                                                                            if (value!.isEmpty) {
                                                                                              return 'Please Enter Motif';
                                                                                            }
                                                                                            return null;
                                                                                          },
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    SizedBox(
                                                                                      height: 15,
                                                                                    ),
                                                                                    Container(
                                                                                      decoration: BoxDecoration(
                                                                                        borderRadius: BorderRadius.circular(15),
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
                                                                                        child: DropdownButtonFormField<String>(
                                                                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                                                                          decoration: InputDecoration(
                                                                                            filled: true,
                                                                                            fillColor: Colors.white,
                                                                                            border: InputBorder.none,
                                                                                            errorBorder: OutlineInputBorder(
                                                                                              borderRadius: BorderRadius.circular(10),
                                                                                              borderSide: const BorderSide(color: Colors.red, width: 1.2),
                                                                                            ),
                                                                                            labelText: "Choisir Chauffeur",
                                                                                            labelStyle: TextStyle(
                                                                                              fontWeight: FontWeight.w900,
                                                                                              color: Color(0xFFA4A4A4),
                                                                                            ),
                                                                                          ),
                                                                                          value: _selectedValue,
                                                                                          items: driverList3.map((dynamic item) {
                                                                                            return DropdownMenuItem<String>(
                                                                                              value: item['nom'].toString() + item['prenom'].toString(),
                                                                                              child: Row(
                                                                                                children: [
                                                                                                  Text(item['nom'].toString()),
                                                                                                  Text(item['prenom'].toString()),
                                                                                                ],
                                                                                              ),
                                                                                            );
                                                                                          }).toList(),
                                                                                          onChanged: (String? value) {
                                                                                            setState(() {
                                                                                              _selectedValue = value;
                                                                                              _controller.text = value ?? '';
                                                                                            });
                                                                                          },
                                                                                          validator: (value) {
                                                                                            if (value == null || value.isEmpty) {
                                                                                              return 'Please Choose an Option';
                                                                                            }
                                                                                            return null;
                                                                                          },
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    SizedBox(
                                                                                      height: 20,
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
                                                                                                style: ElevatedButton.styleFrom(primary: Color(0xFF3954A4)),
                                                                                                child: Text('Confirmer'),
                                                                                                onPressed: () {
                                                                                                  returnRide2();
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
                                                                        }).whenComplete(() => reassign
                                                                            .text =
                                                                        "");
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    height: 50,
                                                                    width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        'Return Ride',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Color(0xFF524D4D),
                                                                          fontSize:
                                                                              18,
                                                                          fontFamily:
                                                                              'Kanit',
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          height:
                                                                              0.05,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 5,
                                                              ),
                                                              Divider(
                                                                thickness: 0.5,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                              SizedBox(
                                                                height: 5,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    print(
                                                                        'Ontap 2 Triggered..!!');
                                                                    showModalBottomSheet(
                                                                        backgroundColor:
                                                                            Color(
                                                                                0xFFE6F7FD),
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.vertical(
                                                                            top:
                                                                                Radius.circular(38),
                                                                          ),
                                                                        ),
                                                                        isScrollControlled:
                                                                            true,
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) {
                                                                          // final TextEditingController
                                                                          //     _controller =
                                                                          //     TextEditingController();
                                                                          // String?
                                                                          //     _selectedValue;
                                                                          // List<dynamic>
                                                                          //     driverList2 =
                                                                          //     box.read('driver2');
                                                                          DateTime
                                                                              parsedDate =
                                                                              DateTime.parse(item['dateCourse']);
                                                                          DateTime
                                                                              utcDate =
                                                                              parsedDate.toUtc();
                                                                          return Padding(
                                                                            padding:
                                                                                MediaQuery.of(context).viewInsets,
                                                                            child:
                                                                                SizedBox(
                                                                              height: MediaQuery.of(context).size.height / 2,
                                                                              child: Center(
                                                                                child: Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  children: [
                                                                                    SizedBox(
                                                                                      height: MediaQuery.of(context).size.height / 45,
                                                                                    ),
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.all(8.0),
                                                                                          child: Text(
                                                                                            'Client Absent',
                                                                                            style: TextStyle(
                                                                                              color: Color(0xFF524D4D),
                                                                                              fontSize: 18,
                                                                                              fontFamily: 'Kanit',
                                                                                              fontWeight: FontWeight.w500,
                                                                                              height: 0.05,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(
                                                                                      height: MediaQuery.of(context).size.height / 95,
                                                                                    ),
                                                                                    Divider(
                                                                                      thickness: 0.5,
                                                                                      color: Colors.grey,
                                                                                    ),
                                                                                    SizedBox(
                                                                                      height: 9,
                                                                                    ),
                                                                                    Container(
                                                                                      decoration: BoxDecoration(
                                                                                        borderRadius: BorderRadius.circular(15),
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
                                                                                          controller: reassign,
                                                                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                                                                          decoration: InputDecoration(
                                                                                              filled: true,
                                                                                              fillColor: Colors.white,
                                                                                              border: InputBorder.none,
                                                                                              errorBorder: OutlineInputBorder(
                                                                                                borderRadius: BorderRadius.circular(10),
                                                                                                borderSide: const BorderSide(color: Colors.red, width: 1.2),
                                                                                              ),
                                                                                              labelText: "Commentaire",
                                                                                              labelStyle: TextStyle(
                                                                                                fontWeight: FontWeight.w900,
                                                                                                color: Color(0xFFA4A4A4),
                                                                                              ) // Placeholder text
                                                                                              ),
                                                                                          validator: (value) {
                                                                                            if (value!.isEmpty) {
                                                                                              return 'Please Enter Comment';
                                                                                            }
                                                                                            return null;
                                                                                          },
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    SizedBox(
                                                                                      height: 20,
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
                                                                                                style: ElevatedButton.styleFrom(primary: Color(0xFF3954A4)),
                                                                                                child: Text('Confirmer'),
                                                                                                onPressed: () {
                                                                                                  // returnRide();
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
                                                                        });
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    height: 50,
                                                                    width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        'Client Absent',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Color(0xFF524D4D),
                                                                          fontSize:
                                                                              18,
                                                                          fontFamily:
                                                                              'Kanit',
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          height:
                                                                              0.05,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 20,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }).whenComplete(() => setState(
                                                      () {
                                                    isRefreshed = true;
                                                    Future.delayed(
                                                        Duration(
                                                            milliseconds: 300),
                                                        () {
                                                      setState(() {
                                                        isRefreshed = false;
                                                      });
                                                    });
                                                  }));
                                              DriverList2();
                                            },
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                Image.asset(
                                                    'assets/images/cont.png'),
                                                Positioned(
                                                    top: 5,
                                                    left: 3,
                                                    child: Text(
                                                      'Daniel Union 3',
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF3954A4),
                                                        fontSize: 14,
                                                        fontFamily: 'Kanit',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        height: 0,
                                                      ),
                                                    )),
                                                Positioned(
                                                  bottom: 3,
                                                  left: 9,
                                                  child: Container(
                                                    width: 95,
                                                    height: 26,
                                                    decoration: ShapeDecoration(
                                                      color: Color(0xFFFCA263),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                    bottom: 0,
                                                    left: 40,
                                                    child: Image.asset(
                                                        'assets/images/hand.png'))
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (isOptionsAndCommentVisible)
                                          Visibility(
                                            visible: isOptionsAndCommentVisible,
                                            child: Column(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.zero,
                                                  width: double.infinity,
                                                  height:
                                                      80, // Adjust the height as needed
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      left: 8,
                                                      right: 8,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Container(
                                                          height: 50,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              1.08,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8),
                                                            child: TextField(
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade400,
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    'Kanit',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                              decoration:
                                                                  InputDecoration(
                                                                suffix: Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .euro_symbol_outlined,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade400,
                                                                    ),
                                                                  ],
                                                                ),
                                                                hintText:
                                                                    'Tarif',
                                                                hintStyle:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade400,
                                                                  fontSize: 16,
                                                                  fontFamily:
                                                                      'Kanit',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 17),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        'Commentaire',
                                                        style: TextStyle(
                                                          color: Colors
                                                              .grey.shade400,
                                                          fontSize: 16,
                                                          fontFamily: 'Kanit',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Flexible(
                                                        child: Container(
                                                          height: 45,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              1.58,
                                                          color: Colors
                                                              .grey.shade200,
                                                          child: Center(
                                                            child: Text(
                                                              item[
                                                                  'commentaire'],
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    'Kanit',
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
