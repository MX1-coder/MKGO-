// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
// import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class Location extends StatefulWidget {
  const Location({super.key});

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {
  Set<dynamic> selectedItems = {};
  String selectedType = '';
  TextEditingController searchController1 = TextEditingController();
  TextEditingController searchController2 = TextEditingController();
  TextEditingController searchController3 = TextEditingController();
  TextEditingController searchController4 = TextEditingController();

  bool isRegionSelected = false;
  bool isRefreshed = false;
  bool isDriverSelected = false;

  TextEditingController searchController5 = TextEditingController();
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

        box.write('regionsLocation', regions);
        return regions;
      } else {
        print("API response does not contain 'collections'");
      }
    } else {
      print(response.reasonPhrase);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> DriverList() async {
    final box = GetStorage();
    final _token = box.read('token') ?? '';

    final regionId = box.read('regionIdLocation');
    print('Region id in API function: $regionId');

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
      box.write('driverLocation', driverList);

      return driverList;
    } else {
      print(response.reasonPhrase);
    }
    return [];
  }

  final box = GetStorage();

  late double? latitude;
  late double? longitude;
  late String driverName;
  late String Access_Token;
  late MapController mapController;

  String errorData = "";
  @override
  void initState() {
    super.initState();
    String errorData = '';
    locationData();
    regionList();
    // Initialize your variables here
    latitude = box.read('latitude') ?? 0.0;
    longitude = box.read('longitude') ?? 0.0;
    driverName = box.read('driverName') ?? "";
    Access_Token =
        'sk.eyJ1IjoiaW5ub3lhZGV2IiwiYSI6ImNsbWo4OHRvcTAxcWMydHBsdnUwNGQ2anMifQ.Kao3TfJPOHkw5MbAgbqu-Q';
    mapController = MapController();
    if (box.hasData('driverName')) {
      box.remove('driverName');
    }
  }

  String exist2 = "";

  Future<void> getLocation() async {
    final box = GetStorage();
    final token = box.read('token');
    final driverId = box.read('driverIdLocation');
    print('driver id for location in API function: $driverId');

    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final LocationBaseUrl = configJson['planning_baseUrl'];
    final LocationApiKey = configJson['planning_apiKey'];

    final LocationMainUrl = LocationBaseUrl + "get/location";

    var headers = {
      'x-api-key': '$LocationApiKey',
      'Authorization': 'Bearer ' + token
    };

    var request = http.Request('POST', Uri.parse(LocationMainUrl));
    request.body = json.encode({
      "chauffeur-id": driverId.toString(),
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseData = json.decode(await response.stream.bytesToString());

      late double? latitude = responseData['lat'] ?? 0.00;
      late double? longitude = responseData['long'] ?? 0.00;

      String exist = responseData['exist'];

      setState(() {
        exist2 = exist;
      });
      print('Exist in APi: $exist2');

      box.write('latitude', latitude);
      box.write('longitude', longitude);

      late double? lat = box.read('latitude') ?? 0.00;
      late double? long = box.read('longitude') ?? 0.00;

      print(
          'Location in storage for map services Latitude: $lat, Longitude: $long');
      // currentLocaionlaunchMap(latitude, longitude);
      // Navigator.of(context).pop();
      if (longitude == 0.00 && latitude == 0.00) {
        Get.snackbar(
          colorText: Colors.white,
          'Sorry..!!',
          'No Location Available for selected Driver',
          backgroundColor: const Color.fromARGB(255, 244, 114, 105),
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
            'No Location Available for selected Driver',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
        );
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> currentLocaionlaunchMap(
      double? latitude, double? longitude) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&latitude=$latitude&longitude=$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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

    final ValueNotifier<String> selectedDriverNotifier =
        ValueNotifier<String>("DRIVER");

    void resetValues() {
      selectedRegionNotifier.value = "REGION";
      selectedDriverNotifier.value = "DRIVER";
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
                height: MediaQuery.of(context).size.height / 1.5,
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
                                          (box.read('regionsLocation') ?? []);
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
                                                                          'regionIdLocation',
                                                                          Id);
                                                                      final idregion =
                                                                          box.read(
                                                                              'regionIdLocation');
                                                                      print(
                                                                          'id in storage for api: $idregion');
                                                                      DriverList();
                                                                      // ClientList();
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
                                        List<dynamic> allDrivers =
                                            (box.read('driverLocation') ?? []);

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
                                                                                    box.write('driverIdLocation', driverid);
                                                                                    selectedDriverNotifier.value = "${item["nom"]} ${item["prenom"]}";
                                                                                    box.write('driverName', selectedDriverNotifier.value);
                                                                                    setState(() {});
                                                                                    print('Driver Id for locattion:  $driverid');
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
                        SizedBox(
                          height: 40,
                        ),
                        Flexible(
                          child: Container(
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
                                        isDriverSelected = true;
                                      });
                                      print(
                                          '==================================================');
                                      // filteredListAdmin();
                                      getLocation().whenComplete(
                                          () => Navigator.of(context).pop());
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Flexible(
                          child: GestureDetector(
                            onTap: () {
                              print(
                                  '==================================================');
                            },
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
                                          exist2 = " ";
                                          isDriverSelected = false;
                                          GetStorage box = GetStorage();
                                          box.remove('driverName');
                                        });
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
          box.remove('driverLocation');
          box.remove('regionIdLocation');
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

  void showsnackbarforexist() {
    Get.snackbar(
      colorText: Colors.white,
      'Sorry..!!',
      'No Location Available for selected Driver',
      backgroundColor: const Color.fromARGB(255, 244, 114, 105),
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
        'No Location Available for selected Driver',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ),
    );
  }

  String MainUrl = "";
  String Token = "";

  Future<void> locationData() async {
    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final MapboxUrl = configJson['mapBox_styleUrl'];
    final AccessToken = configJson['mapBox_accessToken'];

    final MainMapUrl = MapboxUrl + AccessToken;

    setState(() {
      MainUrl = MainMapUrl;
      Token = Access_Token;
    });
  }

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    // List<dynamic> allDrivers = (box.read('driver') ?? []);
    // List<dynamic> filteredDrivers = List.from(allDrivers);
    late double? latitude = box.read('latitude') ?? 0.00;
    late double? longitude = box.read('longitude') ?? 0.00;
    String driverName = box.read('driverName') ?? "";

    String Access_Token =
        'pk.eyJ1IjoiYWRpdHlhMDQwNyIsImEiOiJjbHEyMDMwOGgwMGsyMnFtYXRvdTBwZjR6In0.aWjSjoDvn_vPo0vNCpop_A';
    MapController mapController = MapController();

    return Scaffold(
      body: Material(
        child: Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 25,
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
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Text(
                        'Location',
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
                  height: 15,
                ),
                ListTile(
                  title: GestureDetector(
                    onTap: () {
                      adminFilter(context);
                    },
                    child: Container(
                      width: 180,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF3954A4),
                            blurRadius: 4,
                            offset: Offset(0, 0),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (driverName.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    exist2 = "true";
                                    box.remove('driverName');
                                    box.remove('driverLocation');
                                    box.remove('regionIdLocation');
                                    isDriverSelected = false;
                                  });
                                },
                                child: Image.asset(
                                  'assets/images/cross2.png',
                                  color: Colors.red,
                                  scale: 1.6,
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                driverName.isNotEmpty
                                    ? driverName
                                    : 'Select Driver',
                                style: TextStyle(
                                  color: Color(0xFF524D4D),
                                  fontSize: 14,
                                  fontFamily: 'Kanit',
                                  fontWeight: FontWeight.w400,
                                  height: 0.11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  trailing: Container(
                    height: 45,
                    width: 45,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isRefreshed = true;
                        });

                        getLocation();

                        setState(() {
                          isRefreshed = false;
                        });
                      },
                      child: Image.asset(
                        'assets/images/reloading.png',
                        fit: BoxFit.cover,
                        color: Color(0xFF3954A4),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                (exist2 == "false")
                    ? Column(
                        children: [
                          SizedBox(
                            height: 80,
                          ),
                          Image.asset('assets/images/noLocation.png', color: Color(0xFF3954A4),),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                  child: Text(
                                'No Location Data is Available for selected Driver..!!',
                                style: TextStyle(
                                  color: Color(0xFF524D4D),
                                  fontSize: 16,
                                  fontFamily: 'Kanit',
                                  fontWeight: FontWeight.w400,
                                  height: 0.11,
                                ),
                              )),
                            ],
                          ),
                        ],
                      )
                    : isDriverSelected
                        ? isRefreshed
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF3954A4),
                                ),
                              )
                            : Flexible(
                                child: Container(
                                    height: 1000,
                                    child: FlutterMap(
                                      mapController: mapController,
                                      options: MapOptions(
                                        center: LatLng(latitude, longitude),
                                        minZoom: 5,
                                        maxZoom: 20,
                                        zoom: 18,
                                      ),
                                      children: [
                                        TileLayer(
                                          urlTemplate: '$MainUrl',
                                          additionalOptions: {
                                            'accessToken': '$Token',
                                            'id': 'mapbox/streets-v12',
                                          },
                                        ),
                                        MarkerLayer(markers: [
                                          Marker(
                                            point: LatLng(latitude, longitude),
                                            child: Icon(
                                              Icons.location_pin,
                                              color: Colors.red,
                                              size: 60,
                                            ),
                                          )
                                        ])
                                      ],
                                    )),
                              )
                        : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
