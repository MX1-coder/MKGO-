import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fr.innoyadev.mkgodev/homeScreen/AdminPlanning.dart';
import 'package:fr.innoyadev.mkgodev/homeScreen/DriverPlanning.dart';
import 'package:fr.innoyadev.mkgodev/login/login.dart';
import 'package:timezone/timezone.dart' as tz;

class LoginUser {
  String email;
  String password;

  LoginUser({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthController authController = Get.find();

  var data = {}.obs;

  List<dynamic> trips = [];
  List<dynamic> tripsPresent = [];
  List<dynamic> tripsFuture = [];
  List<dynamic> tripsAdminToday = [];
  List<dynamic> tripsAdminFuture = [];

  GetStorage box = GetStorage();
  Future<List<Map<String, dynamic>>> tripListPast() async {
    print('past wala chal rha hai>...');
    print('chal rha hai login par');
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
      print('chal rha hai login par 200 aa gya');
      print('past wala chal rha hai>...');
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
        String distanceTrajet = courses['distanceTrajet'];
        String dureeTrajet = courses['dureeTrajet'];
        String nom = courses['clientDetails']['nom'];
        String prenom = courses['clientDetails']['prenom'];
        String telephone = courses['clientDetails']['tel1'];
        String depart = courses['depart'] ?? '';
        String arrive = courses['arrive'] ?? '';
        int imgType = courses['clientDetails']['typeClient']['id'] ?? "";

        String dateCRude = courses['dateCourse'] ?? "";

        DateTime dateTime = DateTime.parse(dateCRude);
        tz.TZDateTime parisDateTime =
            tz.TZDateTime.from(dateTime, tz.getLocation('Europe/Paris'));

        String formattedDate = DateFormat('dd-MMM.hh:MM').format(parisDateTime);

        print('Formatted Date in APi: $formattedDate');

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
          'formattedDate': formattedDate,
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

      print("TripPast Before Storage: $tripList");
      print('==================================================================');
      box.write('tripList', tripList);
      print('==================================================================');
      List<dynamic> trips = box.read('tripList') ?? [];
      print('==================================================================');
      print('Past from APi in storage : $trips');
      print('==================================================================');

      return tripList;
    } else {
      print(response.reasonPhrase);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> tripListPresent() async {
    print('chal rha hai login par present');
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
      print('chal rha hai login par 200 aa gya');
      final responseBody = await response.stream.bytesToString();
      final apiData = jsonDecode(responseBody);

      print(apiData);

      List<Map<String, dynamic>> tripPresent = [];
      for (var courses in apiData['courses']) {
        print('============================PRESENT======================================');
        int id = courses['id'];
        // String start = courses['start'];
        int nombrePassager = courses['nombrePassager'];
        String commentaire = courses['commentaire'];
        String paiement = courses['paiement'];
        int client = courses['client'];
        String status1 = courses['affectationCourses'][0]['status1'];
        String status2 = courses['affectationCourses'][0]['status2'];
        String backgroundColor = courses['backgroundColor'];
        // String dateCourse = courses['dateCourse'];
        String distanceTrajet = courses['distanceTrajet'];
        String dureeTrajet = courses['dureeTrajet'];
        String nom = courses['clientDetails']['nom'];
        String prenom = courses['clientDetails']['prenom'];
        String telephone = courses['clientDetails']['tel1'];
        String depart = courses['depart'] ?? '';
        String arrive = courses['arrive'] ?? '';
        int imgType = courses['clientDetails']['typeClient']['id'] ?? "";

        String dateCRude = courses['dateCourse'] ?? "";

        DateTime dateTime = DateTime.parse(dateCRude);
        tz.TZDateTime parisDateTime =
            tz.TZDateTime.from(dateTime, tz.getLocation('Europe/Paris'));

        String formattedDate = DateFormat('dd-MMM.hh:MM').format(parisDateTime);

        print('Formatted Date in APi: $formattedDate');

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
          'formattedDate': formattedDate,
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
      print('==================================================================');
      print(tripPresent);
      print('==================================================================');
      box.write('present', tripPresent);
      print('==================================================================');
      List<dynamic> tripsPresent = box.read('present') ?? [];
      print('==================================================================');
      print('Present List from APi in storage : $tripsPresent');
      print('==================================================================');

      return tripPresent;
    } else {
      print(response.reasonPhrase);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> tripListFuture() async {
    print('chal rha hai login par future');
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
      print('chal rha hai login par 200 aa gya');
      final responseBody = await response.stream.bytesToString();
      final apiData = jsonDecode(responseBody);

      List<Map<String, dynamic>> tripFuture = [];
      for (var courses in apiData['courses']) {
        print('===============================FUTURE===================================');
        int id = courses['id'];
        // String start = courses['start'];
        int nombrePassager = courses['nombrePassager'];
        String commentaire = courses['commentaire'];
        String paiement = courses['paiement'];
        int client = courses['client'];
        String status1 = courses['affectationCourses'][0]['status1'];
        String status2 = courses['affectationCourses'][0]['status2'];
        String backgroundColor = courses['backgroundColor'];
        // String dateCourse = courses['dateCourse'];
        String distanceTrajet = courses['distanceTrajet'];
        String dureeTrajet = courses['dureeTrajet'];
        String nom = courses['clientDetails']['nom'];
        String prenom = courses['clientDetails']['prenom'];
        String telephone = courses['clientDetails']['tel1'];
        String depart = courses['depart'] ?? '';
        String arrive = courses['arrive'] ?? '';
        int imgType = courses['clientDetails']['typeClient']['id'] ?? "";

        String dateCRude = courses['dateCourse'] ?? "";

        DateTime dateTime = DateTime.parse(dateCRude);
        tz.TZDateTime parisDateTime =
            tz.TZDateTime.from(dateTime, tz.getLocation('Europe/Paris'));

        String formattedDate = DateFormat('dd-MMM.hh:MM').format(parisDateTime);

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
          'formattedDate': formattedDate,
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

      print('==================================================================');
      print(tripFuture);
      print('==================================================================');
      box.write('future', tripFuture);
      print('==================================================================');
      List<dynamic> tripFuture2 = box.read('future') ?? [];
      print('==================================================================');
      print('Future List from APi in storage : $tripFuture2');
      print('==================================================================');

      return tripFuture;
    } else {
      print(response.reasonPhrase);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> TripListToday() async {
    print('=============================ADMINFUTURE=====================================');
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
        print('=============================== ADMIN Future after 200 ===================================');
        int id = courses['id'];
        // String start = courses['start'];
        int nombrePassager = courses['nombrePassager'];
        String commentaire = courses['commentaire'];
        String paiement = courses['paiement'];
        int client = courses['client'];
        String status1 = courses['affectationCourses'][0]['status1'];
        String status2 = courses['affectationCourses'][0]['status2'];
        String reference = courses['reference'];
        int tarif = courses['tarif'];
        String backgroundColor = courses['backgroundColor'];
        String dateCourse = courses['dateCourse'];
        String nom = courses['clientDetails']['nom'];
        String prenom = courses['clientDetails']['prenom'];
        String telephone = courses['clientDetails']['tel1'];
        int region = courses['region'];
        String depart = courses['depart'] ?? '';
        String arrive = courses['arrive'] ?? '';

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
          'depart': depart,
          'arrive': arrive,
          'tarif': tarif
        });
      }

      print('==================================================================');  
      print(AdminToday);
      print('==================================================================');
      box.write('AdminToday5', AdminToday);
      print('==================================================================');
      List<dynamic> AdminToday2 = box.read('AdminToday5');
      print('==================================================================');
      print('Admin Today in storage with refernce and date : $AdminToday2');
      print('==================================================================');

      return AdminToday;
    } else {
      print(response.reasonPhrase);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> TripListFutureAdmin() async {
    print('================================ADMINFUTURE==================================');
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
        print('==============================Admin Future after 200====================================');
        int id = courses['id'];
        // String start = courses['start'];
        int nombrePassager = courses['nombrePassager'];
        String commentaire = courses['commentaire'];
        String paiement = courses['paiement'];
        int client = courses['client'];
        String status1 = courses['affectationCourses'][0]['status1'];
        String status2 = courses['affectationCourses'][0]['status2'];
        String reference = courses['reference'];
        int tarif = courses['tarif']; 
        String backgroundColor = courses['backgroundColor'];
        String dateCourse = courses['dateCourse'];
        String nom = courses['clientDetails']['nom'];
        String prenom = courses['clientDetails']['prenom'];
        String telephone = courses['clientDetails']['tel1'];
        int region = courses['region'];
        String depart = courses['depart'] ?? '';
        String arrive = courses['arrive'] ?? '';

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
          'depart': depart,
          'arrive': arrive,
          'tarif': tarif,
        });

        print('================================= depart: $depart');
        print('================================= arrive: $arrive');
      }
      print('==================================================================');
      print('Admin AVenir with reference: $AdminAvenir');
      print('==================================================================');
      box.write('AdminAvenir5', AdminAvenir);
      print('==================================================================');

      return AdminAvenir;
    } else {
      print(response.reasonPhrase);
    }
    return [];
  }

  String today = "";
  String future = "";
  String passer = "";

  void loadInitialData() {
    print('loadmoredata fucntion is calling');

    trips = box.read('tripList') ?? [];
    tripsPresent = box.read('present') ?? [];
    tripsFuture = box.read('future') ?? [];
    tripsAdminToday = box.read('AdminToday5') ?? [];
    tripsAdminFuture = box.read('AdminAvenir5') ?? [];
    // filteredList = box.read('filteredListDriver');

    // print('Past Trips in loadmore : $trips');
  }

  Future<void> handleRefresh() async {
    await Future.delayed(Duration(milliseconds: 500), () {
      tripListPast();
      tripListPresent();
      tripListFuture();
      // loadInitialData();
      // filteredListDriver();
    });
  }

  

  Future<void> login() async {
    final box = GetStorage();
    final Storagepassword = box.write(
      'password',
      passwordController.text,
    );
    print('Password in Storage : $Storagepassword');

    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final gestionBaseUrl = configJson['gestion_baseUrl'];
    final gestionApiKey = configJson['gestion_apiKey'];

    final gestionAuthUrl = gestionBaseUrl + "mob/auth";

    var headers = {
      'x-api-key': '$gestionApiKey',
      'Content-Type': 'application/json'
    };
    var request = http.Request('GET', Uri.parse(gestionAuthUrl));
    request.body = json.encode(
        {"email": emailController.text, "password": passwordController.text});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      if (box.hasData('tripList') ||
          box.hasData('present') ||
          box.hasData('future')) {
        print('if chal rha hia idhar');
        trips.clear();
        tripsPresent.clear();
        tripsFuture.clear();
        // box.write('tripList', []);
        // box.write('present', []);
        // box.write('future', []);
        print('Data is clear at login : $trips');
        print('Data is clear at login : $tripsPresent');
        print('Data is clear at login : $tripsFuture');
      }
      final responseBody = await response.stream.bytesToString();
      final responseJson = json.decode(responseBody);

      if (responseJson.containsKey('token')) {
        final token = responseJson['token'];
        Get.find<AuthController>().setToken(token);

        // Save user credentials in shared preferences
        saveUserCredentials(responseJson);

        print('Generated Token is set: $token');
      } else {
        print('Token not found in the response');
      }

      if (responseJson.containsKey('user')) {
        final userJson = responseJson['user'];
        final user = UserModel(
            id: userJson['id'],
            nom: userJson['nom'],
            prenom: userJson['prenom'],
            email: userJson['email'],
            telephone: userJson['telephone'],
            address: userJson['adresse'],
            roles: List<String>.from(userJson['roles']),
            date: userJson['dateNaissance'],
            employeId: userJson['typeEmploye'] != null
                ? userJson['typeEmploye']['id']
                : 0,
            region: userJson['region'] != null ? userJson['region']['id'] : 0);

        Get.find<UserController>().setUser(user);
        print(
            "User Data: ${user.id}, ${user.nom}, ${user.prenom}, ${user.email}, ${user.roles}, ${user.address}, ${user.date}, ${user.employeId}, ${user.region}");

        if (user.roles.contains('ROLE_CHAUFFEUR')) {
          Future.delayed(Duration(milliseconds: 500), () {
            print('==================================================================');
            tripListPast();
            print('==================================================================');
            tripListPresent();
            print('==================================================================');
            tripListFuture();
            print('==================================================================');
            TripListToday();
            print('==================================================================');
            TripListFutureAdmin();
            print('==================================================================');
            loadInitialData();
            print('==================================================================');
            print('Data called again on basis of new user after 200 : $trips');
            print('==================================================================');
            Get.to(
              () => LandingScreen2(),
            )?.then((value) {
              emailController.text = "";
              passwordController.text = "";
            });
          });
        }
        if (user.roles.contains('ROLE_ADMIN')) {
          Get.to(
            () => LandingScreen1(),
          )?.then((value) {
            emailController.text = "";
            passwordController.text = "";
          });
        }
        // box.write('tripsList', []);
        // box.write('present', []);
        // box.write('future', []);
        // handleRefresh();
      } else {
        print('User data not found in the response');
      }
    } else {
      print(response.reasonPhrase);
      Get.snackbar(
        colorText: Colors.white,
        'Error',
        'Login failed',
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
          'Login failed',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
      );
    }
  }

  // Save user credentials in shared preferences
  void saveUserCredentials(Map<String, dynamic> responseJson) {
    final storage = GetStorage();

    final userJson = responseJson['user'];
    final user = UserModel(
        id: userJson['id'],
        nom: userJson['nom'],
        prenom: userJson['prenom'],
        email: userJson['email'],
        telephone: userJson['telephone'],
        address: userJson['adresse'],
        roles: List<String>.from(userJson['roles']),
        date: userJson['dateNaissance'],
        employeId:
            userJson['typeEmploye'] != null ? userJson['typeEmploye']['id'] : 0,
        region: userJson['region'] != null ? userJson['region']['id'] : 0);

    storage.write('user_id', user.id);
    storage.write('user_nom', user.nom);
    storage.write('user_prenom', user.prenom);
    storage.write('user_email', user.email);
    storage.write('user_roles', user.roles);
    storage.write('user_telephone', user.telephone);
    storage.write('user_adresse', user.address);
    storage.write('user_DOB', user.date);
    storage.write('user_employe_Id', user.employeId);
    storage.write('user_region_Id', user.region);
  }
}

class AuthController extends GetxController {
  final box = GetStorage();
  RxString token = ''.obs;

  @override
  void onInit() {
    super.onInit();
    token.value = box.read('token') ?? '';
  }

  void setToken(String newToken) {
    token.value = newToken;
    box.write('token', newToken);
    print('Token is set in Get Storage : $newToken');
  }

  void logout() {
    // Clear the token and user data when logging out
    token.value = '';
    box.remove('token');
    Get.find<UserController>().setUser(UserModel(
        id: 0,
        nom: '',
        prenom: '',
        email: '',
        telephone: '',
        address: '',
        roles: [],
        date: '',
        employeId: 0,
        region: 0));
    // You may also need to clear any other user-related data or perform additional cleanup
    // box.write('filteredListDriver', []);
    // box.write('tripList', []);
    // box.write('present', []);
    // box.write('future', []);
    // Navigate to the login screen
    Get.offAll(loginScreen());
  }
}

class UserModel {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String address;
  final List<String> roles;
  final String date;
  final int employeId;
  final int region;

  UserModel(
      {required this.id,
      required this.nom,
      required this.prenom,
      required this.email,
      required this.telephone,
      required this.address,
      required this.roles,
      required this.date,
      required this.employeId,
      required this.region});
}

class UserController extends GetxController {
  Rx<UserModel> user = UserModel(
          id: 0,
          nom: '',
          prenom: '',
          email: '',
          telephone: '',
          address: '',
          roles: [],
          date: '',
          employeId: 0,
          region: 0)
      .obs;

  @override
  void onInit() {
    super.onInit();
    loadUserFromStorage();
  }

  void loadUserFromStorage() {
    final storage = GetStorage();

    final newUser = UserModel(
      id: storage.read('user_id') ?? 0,
      nom: storage.read('user_nom') ?? '',
      prenom: storage.read('user_prenom') ?? '',
      email: storage.read('user_email') ?? '',
      telephone: storage.read('user_telephone') ?? '',
      address: storage.read('user_adresse') ?? '',
      roles: List<String>.from(storage.read('user_roles') ?? []),
      date: storage.read('user_DOB') ?? '',
      employeId: storage.read('user_employe_Id') ?? 0,
      region: storage.read('user_region_Id') ?? 0,
    );

    setUser(newUser);
  }

  void setUser(UserModel newUser) {
    user.value = newUser;
  }
}
