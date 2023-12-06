// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
// import 'package:MKGO_mobile/Login/login.dart';

class versionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
        child: Container(
            color: Colors.white,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                  SizedBox(
                height: MediaQuery.of(context).size.height / 25,
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 10, right: 10,),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: Color(0xFF3954A4),
                          size: 30,
                        )),
                    Flexible(
                        child: Text("Version de I’application",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3954A4),
                            ))),
                  ],
                ),
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 25,
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  "assets/images/MKGOLogo.png",
                  width: 260,
                  height: 139,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 35,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("0.0.1",
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF3954A4),
                      ))
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 2.75,
              ),
              Flexible(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    "Copyright © 2023 - Innoya Services",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ]),
              ),
                   SizedBox(
                     height: 10,
                   )
            ])));
  }
}


