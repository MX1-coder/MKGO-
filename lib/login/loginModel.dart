import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mkgo_mobile/homeScreen/AdminPlanning.dart';
import 'package:mkgo_mobile/homeScreen/DriverPlanning.dart';
import 'package:mkgo_mobile/login/login.dart';

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
          Get.to(
            () => LandingScreen2(),
          )?.then((value) {
            emailController.text = "";
            passwordController.text = "";
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
