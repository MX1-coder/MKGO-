// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:fr.innoyadev.mkgodev/download/download.dart';
import 'package:http/http.dart' as http;
import 'package:fr.innoyadev.mkgodev/profile/profile.dart';
import 'package:timezone/timezone.dart' as tz;

GetStorage box = GetStorage();

class ExpenseReport extends StatefulWidget {
  const ExpenseReport({super.key});

  @override
  State<ExpenseReport> createState() => _ExpenseReportState();
}

class _ExpenseReportState extends State<ExpenseReport> {
  TextEditingController title = TextEditingController();
  TextEditingController amount = TextEditingController();
  @override
  void initState() {
    super.initState();
    setState(() {
      isRefreshed = true;
    });
    getExpenseReport();
    Future.delayed(
      Duration(milliseconds: 500),
      () {
        setState(
          () {
            isRefreshed = false;
          },
        );
      },
    );
  }

  Future<dynamic> editReport(BuildContext context) async {
    return showModalBottomSheet(
      backgroundColor: Color(0xFFE6F7FD),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(38),
        ),
      ),
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height / 1.2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              Text(
                'Edit Report',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Divider(
                thickness: 0.5,
                color: Colors.black,
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey, width: 0.5),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: TextField(
                      controller: title,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Title",
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey, width: 0.5),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: amount,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Amount",
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFF3954A4),
                        ),
                        child: Text('Edit'),
                        onPressed: () async {
                          putExpenseReport();
                          await getExpenseReport();
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(
      () => () {
        setState(
          () {
            amount.text = "";
            title.text = "";
            isRefreshed = true;
          },
        );
        getExpenseReport();
        Future.delayed(
          Duration(milliseconds: 500),
          () {
            setState(
              () {
                isRefreshed = false;
              },
            );
          },
        );
      },
    );
  }

  // Future<void> getExpenseReport() async {
  //   final box = GetStorage();
  //   final _token = box.read('token') ?? '';
  //   print("token called: $_token");
  //   final storage = GetStorage();
  //   final UserID = storage.read('user_id');
  //   final configData = await rootBundle.loadString('assets/config/config.json');
  //   final configJson = json.decode(configData);
  //   final gestionBaseUrl = configJson['compta_baseUrl'];
  //   final gestionApiKey = configJson['compta_apiKey'];
  //   final gestionMainUrl =
  //       gestionBaseUrl + "note-frais/search/" + UserID.toString();
  //   var headers = {
  //     'x-api-key': '$gestionApiKey',
  //     'Authorization': 'Bearer ' + _token
  //
  //   var request = http.Request('GET', Uri.parse(gestionMainUrl),);
  //   request.headers.addAll(headers);
  //   http.StreamedResponse response = await request.send();
  //   if (response.statusCode == 200) {
  //     print(await response.stream.bytesToString(),);
  //   } else {
  //     print(response.reasonPhrase);
  //   }
  // }

  Future<void> putExpenseReport() async {
    final box = GetStorage();
    final _token = box.read('token') ?? '';
    print("token called: $_token");

    final id = box.read('reportId');
    print('Report Id for the edit: $id');

    final storage = GetStorage();
    final UserID = storage.read('user_id');

    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final gestionBaseUrl = configJson['compta_baseUrl'];
    final gestionApiKey = configJson['compta_apiKey'];

    final gestionMainUrl = gestionBaseUrl + "note-frais/" + id.toString();

    var headers = {
      'x-api-key': '$gestionApiKey',
      'Authorization': 'Bearer ' + _token,
      'Content-Type': 'application/json'
    };

    var request = http.Request(
      'PUT',
      Uri.parse(gestionMainUrl),
    );
    request.body = json.encode({
      "montant": amount.text,
      "titre": title.text,
      "updatedBy": UserID.toString()
    });
    request.headers.addAll(headers);

    print('Data for the body is: ${amount.text}, ${title.text}, $UserID');

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(
        await response.stream.bytesToString(),
      );
      getExpenseReport();
      Get.snackbar(
        colorText: Colors.white,
        'Success',
        'Expense Report is Edited Successfully',
        backgroundColor: Color.fromARGB(255, 92, 246, 92),
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
          'Expense Report is Edited Successfully',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
      );
      setState(
        () {
          amount.text = "";
          title.text = "";
        },
      );
    } else {
      print(response.reasonPhrase);
    }

    // var request = http.Request('PUT', Uri.parse(gestionMainUrl),);
    // request.body = json.encode({
    //   "montant": amount.text.toString(),
    //   "titre": title.text,
    //   "updatedBy": UserID.toString()
    // });
    // request.headers.addAll(headers);
    // http.StreamedResponse response = await request.send();
    // if (response.statusCode == 200) {
    //   print(await response.stream.bytesToString(),);
    // getExpenseReport();
    // Get.snackbar(
    //   colorText: Colors.white,
    //   'Success',
    //   'Expense Report is Edited Successfully',
    //   backgroundColor: Color.fromARGB(255, 92, 246, 92),
    //   snackStyle: SnackStyle.FLOATING,
    //   margin: const EdgeInsets.all(10),
    //   borderRadius: 10,
    //   isDismissible: true,
    //   dismissDirection: DismissDirection.up,
    //   forwardAnimationCurve: Curves.easeOutBack,
    //   reverseAnimationCurve: Curves.easeInCirc,
    //   duration: const Duration(seconds: 3),
    //   barBlur: 0,
    //   messageText: const Text(
    //     'Expense Report is Edited Successfully',
    //     style: TextStyle(
    //       color: Colors.white,
    //       fontSize: 16.0,
    //     ),
    //   ),
    // );
    // setState(() {
    //   amount.text = "";
    //   title.text = "";
    // });
    // } else {
    //   print(response.reasonPhrase);
    // }
  }

  Future<void> delExpenseReport() async {
    final box = GetStorage();
    final _token = box.read('token') ?? '';
    print("token called: $_token");

    final id = box.read('reportId');
    print('Report Id for the delete: $id');

    final storage = GetStorage();
    final UserID = storage.read('user_id');

    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final gestionBaseUrl = configJson['compta_baseUrl'];
    final gestionApiKey = configJson['compta_apiKey'];

    final gestionMainUrl = gestionBaseUrl + "note-frais/" + id.toString();

    var headers = {
      'x-api-key': '$gestionApiKey',
      'Authorization': 'Bearer ' + _token
    };

    var request = http.Request(
      'DELETE',
      Uri.parse(gestionMainUrl),
    );
    request.body = json.encode({"deletedBy": UserID.toString()});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(
        await response.stream.bytesToString(),
      );
      getExpenseReport();
      Get.snackbar(
        colorText: Colors.white,
        'Success',
        'Expense Report is Deleted Successfully',
        backgroundColor: Color.fromARGB(255, 92, 246, 92),
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
          'Expense Report is Deleted Successfully',
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

  void showDeleteReportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Color(0xFFE6F7FD),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(38),
        ),
      ),
      isScrollControlled: true,
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
                    'Delete Report',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  delExpenseReport();
                  getExpenseReport();
                  Navigator.of(context).pop();
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
                  Navigator.of(context).pop();
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
    ).whenComplete(
      () => () {
        setState(
          () {
            isRefreshed = true;
          },
        );
        getExpenseReport();
        Future.delayed(
          Duration(milliseconds: 500),
          () {
            setState(
              () {
                isRefreshed = false;
              },
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> expenseList = [];

  Future<List<Map<String, dynamic>>> getExpenseReport() async {
    final box = GetStorage();
    final _token = box.read('token') ?? '';
    final storage = GetStorage();
    final UserID = storage.read('user_id');

    final configData = await rootBundle.loadString('assets/config/config.json');
    final configJson = json.decode(configData);

    final gestionBaseUrl = configJson['compta_baseUrl'];
    final gestionApiKey = configJson['compta_apiKey'];

    final gestionMainUrl =
        gestionBaseUrl + "note-frais/search/" + UserID.toString();

    var headers = {
      'x-api-key': '$gestionApiKey',
      'Authorization': 'Bearer ' + _token
    };

    var request = http.Request(
      'GET',
      Uri.parse(gestionMainUrl),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final apiData = jsonDecode(responseBody);

      print('Expense Reports from the API :$apiData');

      List<Map<String, dynamic>> expenseReport = [];
      if (apiData['collections'] != null) {
        for (var collections in apiData['collections']) {
          int id = collections['id'] ?? 0;
          String title = collections['titre'] ?? '';
          String updatedDate = collections['createdAt'] ?? '';
          expenseReport.add({
            'id': id,
            'title': title,
            'date': updatedDate,
          });
        }
      } else {
        print('Collections data is null');
      }

      print('List of expense report after populating the data: $expenseReport');
      box.write('expenseList', expenseReport);

      setState(() {
        expenseList = expenseReport;
      });
    } else {
      print(response.reasonPhrase);
    }
    return [];
  }

  bool isRefreshed = false;

  Future<void> handleRefresh() async {
    setState(() {
      isRefreshed = true;
    });
    await Future.delayed(
      Duration(milliseconds: 500),
      () {
        // tripListPast();
        // tripListPresent();
        // tripListFuture();
        // loadInitialData();
        // filteredListDriver();
        getExpenseReport();
        List<dynamic> expenseList = box.read('expenseList');
        setState(
          () {
            expenseList = expenseList.toList();
            isRefreshed = false;
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // List<dynamic> expenseList = box.read('expenseList');

    return Material(
      child: Container(
        color: Colors.white,
        child: Column(
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Profile(),
                          ),
                        );
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
                    'Note des frais',
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
              height: MediaQuery.of(context).size.height / 70,
            ),
            GestureDetector(
              onTap: () {
                Get.to(
                  () => Download(),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.green.shade300,
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  )
                ],
              ),
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
                            color: Color(0xFF3954A4),
                          ),
                        )
                      : ListView.builder(
                          itemCount: expenseList.length,
                          itemBuilder: (context, index) {
                            final item = expenseList[index];

                            String date = item['date'];

                            DateTime dateTime = DateTime.parse(date);
                            tz.TZDateTime parisDateTime = tz.TZDateTime.from(
                              dateTime,
                              tz.getLocation('Europe/Paris'),
                            );

                            String formattedDate =
                                DateFormat('dd-MMM-yyyy - hh:mm')
                                    .format(parisDateTime);

                            if (expenseList.isEmpty) {
                              Center(
                                child: Text(
                                    'No Expense Report available currently..!!'),
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  right: 8,
                                  bottom: 8,
                                ),
                                child: Container(
                                  width: 391,
                                  height: 100,
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: Color(0xFFEBE9E9),
                                      ),
                                    ),
                                    shadows: [
                                      BoxShadow(
                                        color: Color(0x11000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 3),
                                        spreadRadius: 0,
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'ID : ${item['id'].toString()}',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontFamily: 'Kanit',
                                                fontWeight: FontWeight.w400,
                                                height: 0.05,
                                              ),
                                            ),
                                            Text(
                                              formattedDate,
                                              style: TextStyle(
                                                color: Color(0xFF524D4D),
                                                fontSize: 14,
                                                fontFamily: 'Kanit',
                                                fontWeight: FontWeight.w500,
                                                height: 0,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              item['title'],
                                              style: TextStyle(
                                                color: Color(0xFF524D4D),
                                                fontSize: 14,
                                                fontFamily: 'Kanit',
                                                fontWeight: FontWeight.w300,
                                                height: 0.09,
                                              ),
                                            ),
                                            Container(
                                              width: 60,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      box.write(
                                                        'reportId',
                                                        item['id'].toString(),
                                                      );
                                                      final id =
                                                          box.read('reportId');
                                                      print(
                                                          'Report Id for the edit: $id');

                                                      editReport(context);
                                                    },
                                                    child: Image.asset(
                                                        'assets/images/edit.png'),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      box.write(
                                                        'reportId',
                                                        item['id'].toString(),
                                                      );
                                                      final id =
                                                          box.read('reportId');
                                                      print(
                                                          'Report Id for the edit: $id');

                                                      showDeleteReportBottomSheet(
                                                          context);
                                                    },
                                                    child: Image.asset(
                                                        'assets/images/delete.png'),
                                                  ),
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
                        )
                  //  ListView(
                  //   scrollDirection: Axis.vertical,
                  //   children: [
                  //             Padding(
                  //               padding: const EdgeInsets.all(15),
                  //               child: Row(
                  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                 children: [
                  //                   Text(
                  //                     'Titrel',
                  //                     style: TextStyle(
                  //                       color: Color(0xFF524D4D),
                  //                       fontSize: 14,
                  //                       fontFamily: 'Kanit',
                  //                       fontWeight: FontWeight.w300,
                  //                       height: 0.09,
                  //                     ),
                  //                   ),
                  //                   Container(
                  //                       width: 60,
                  //                       child: Row(
                  //                         mainAxisAlignment:
                  //                             MainAxisAlignment.spaceBetween,
                  //                         children: [
                  //                           GestureDetector(
                  //                               onTap: () {
                  //                                 editReport(context);
                  //                               },
                  //                               child: Image.asset(
                  //                                   'assets/images/edit.png'),),
                  //                           GestureDetector(
                  //                               onTap: () {
                  //                                 showDeleteReportBottomSheet(
                  //                                     context);
                  //                               },
                  //                               child: Image.asset(
                  //                                   'assets/images/delete.png'),),
                  //                         ],
                  //                       ),)
                  //                 ],
                  //               ),
                  //             )
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //     Padding(
                  //       padding: const EdgeInsets.only(
                  //         left: 8,
                  //         right: 8,
                  //         bottom: 8,
                  //       ),
                  //       child: Container(
                  //         width: 391,
                  //         height: 100,
                  //         decoration: ShapeDecoration(
                  //           color: Colors.white,
                  //           shape: RoundedRectangleBorder(
                  //             side: BorderSide(color: Color(0xFFEBE9E9),),
                  //           ),
                  //           shadows: [
                  //             BoxShadow(
                  //               color: Color(0x11000000),
                  //               blurRadius: 4,
                  //               offset: Offset(0, 3),
                  //               spreadRadius: 0,
                  //             )
                  //           ],
                  //         ),
                  //         child: Column(
                  //           children: [
                  //             Padding(
                  //               padding: const EdgeInsets.all(15),
                  //               child: Row(
                  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                 children: [
                  //                   Text(
                  //                     'ID : 50',
                  //                     style: TextStyle(
                  //                       color: Colors.black,
                  //                       fontSize: 16,
                  //                       fontFamily: 'Kanit',
                  //                       fontWeight: FontWeight.w400,
                  //                       height: 0.05,
                  //                     ),
                  //                   ),
                  //                   Text(
                  //                     '17 Sept 2023 - 18:22',
                  //                     style: TextStyle(
                  //                       color: Color(0xFF524D4D),
                  //                       fontSize: 14,
                  //                       fontFamily: 'Kanit',
                  //                       fontWeight: FontWeight.w500,
                  //                       height: 0,
                  //                     ),
                  //                   )
                  //                 ],
                  //               ),
                  //             ),
                  //             Padding(
                  //               padding: const EdgeInsets.all(15),
                  //               child: Row(
                  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                 children: [
                  //                   Text(
                  //                     'Titrel',
                  //                     style: TextStyle(
                  //                       color: Color(0xFF524D4D),
                  //                       fontSize: 14,
                  //                       fontFamily: 'Kanit',
                  //                       fontWeight: FontWeight.w300,
                  //                       height: 0.09,
                  //                     ),
                  //                   ),
                  //                   Container(
                  //                       width: 60,
                  //                       child: Row(
                  //                         mainAxisAlignment:
                  //                             MainAxisAlignment.spaceBetween,
                  //                         children: [
                  //                           Image.asset('assets/images/edit.png'),
                  //                           Image.asset('assets/images/delete.png'),
                  //                         ],
                  //                       ),)
                  //                 ],
                  //               ),
                  //             )
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //     Padding(
                  //       padding: const EdgeInsets.only(
                  //         left: 8,
                  //         right: 8,
                  //         bottom: 8,
                  //       ),
                  //       child: Container(
                  //         width: 391,
                  //         height: 100,
                  //         decoration: ShapeDecoration(
                  //           color: Colors.white,
                  //           shape: RoundedRectangleBorder(
                  //             side: BorderSide(color: Color(0xFFEBE9E9),),
                  //           ),
                  //           shadows: [
                  //             BoxShadow(
                  //               color: Color(0x11000000),
                  //               blurRadius: 4,
                  //               offset: Offset(0, 3),
                  //               spreadRadius: 0,
                  //             )
                  //           ],
                  //         ),
                  //         child: Column(
                  //           children: [
                  //             Padding(
                  //               padding: const EdgeInsets.all(15),
                  //               child: Row(
                  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                 children: [
                  //                   Text(
                  //                     'ID : 50',
                  //                     style: TextStyle(
                  //                       color: Colors.black,
                  //                       fontSize: 16,
                  //                       fontFamily: 'Kanit',
                  //                       fontWeight: FontWeight.w400,
                  //                       height: 0.05,
                  //                     ),
                  //                   ),
                  //                   Text(
                  //                     '17 Sept 2023 - 18:22',
                  //                     style: TextStyle(
                  //                       color: Color(0xFF524D4D),
                  //                       fontSize: 14,
                  //                       fontFamily: 'Kanit',
                  //                       fontWeight: FontWeight.w500,
                  //                       height: 0,
                  //                     ),
                  //                   )
                  //                 ],
                  //               ),
                  //             ),
                  //             Padding(
                  //               padding: const EdgeInsets.all(15),
                  //               child: Row(
                  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                 children: [
                  //                   Text(
                  //                     'Titrel',
                  //                     style: TextStyle(
                  //                       color: Color(0xFF524D4D),
                  //                       fontSize: 14,
                  //                       fontFamily: 'Kanit',
                  //                       fontWeight: FontWeight.w300,
                  //                       height: 0.09,
                  //                     ),
                  //                   ),
                  //                   Container(
                  //                       width: 60,
                  //                       child: Row(
                  //                         mainAxisAlignment:
                  //                             MainAxisAlignment.spaceBetween,
                  //                         children: [
                  //                           Image.asset('assets/images/edit.png'),
                  //                           Image.asset('assets/images/delete.png'),
                  //                         ],
                  //                       ),)
                  //                 ],
                  //               ),
                  //             )
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //     Padding(
                  //       padding: const EdgeInsets.only(
                  //         left: 8,
                  //         right: 8,
                  //         bottom: 8,
                  //       ),
                  //       child: Container(
                  //         width: 391,
                  //         height: 100,
                  //         decoration: ShapeDecoration(
                  //           color: Colors.white,
                  //           shape: RoundedRectangleBorder(
                  //             side: BorderSide(color: Color(0xFFEBE9E9),),
                  //           ),
                  //           shadows: [
                  //             BoxShadow(
                  //               color: Color(0x11000000),
                  //               blurRadius: 4,
                  //               offset: Offset(0, 3),
                  //               spreadRadius: 0,
                  //             )
                  //           ],
                  //         ),
                  //         child: Column(
                  //           children: [
                  //             Padding(
                  //               padding: const EdgeInsets.all(15),
                  //               child: Row(
                  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                 children: [
                  //                   Text(
                  //                     'ID : 50',
                  //                     style: TextStyle(
                  //                       color: Colors.black,
                  //                       fontSize: 16,
                  //                       fontFamily: 'Kanit',
                  //                       fontWeight: FontWeight.w400,
                  //                       height: 0.05,
                  //                     ),
                  //                   ),
                  //                   Text(
                  //                     '17 Sept 2023 - 18:22',
                  //                     style: TextStyle(
                  //                       color: Color(0xFF524D4D),
                  //                       fontSize: 14,
                  //                       fontFamily: 'Kanit',
                  //                       fontWeight: FontWeight.w500,
                  //                       height: 0,
                  //                     ),
                  //                   )
                  //                 ],
                  //               ),
                  //             ),
                  //             Padding(
                  //               padding: const EdgeInsets.all(15),
                  //               child: Row(
                  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                 children: [
                  //                   Text(
                  //                     'Titrel',
                  //                     style: TextStyle(
                  //                       color: Color(0xFF524D4D),
                  //                       fontSize: 14,
                  //                       fontFamily: 'Kanit',
                  //                       fontWeight: FontWeight.w300,
                  //                       height: 0.09,
                  //                     ),
                  //                   ),
                  //                   Container(
                  //                       width: 60,
                  //                       child: Row(
                  //                         mainAxisAlignment:
                  //                             MainAxisAlignment.spaceBetween,
                  //                         children: [
                  //                           Image.asset('assets/images/edit.png'),
                  //                           Image.asset('assets/images/delete.png'),
                  //                         ],
                  //                       ),)
                  //                 ],
                  //               ),
                  //             )
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  ),
            )
          ],
        ),
      ),
    );
  }
}
