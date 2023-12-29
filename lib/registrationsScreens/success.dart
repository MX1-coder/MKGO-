// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fr.innoyadev.mkgodev/login/login.dart';

class SuccessRegistrationScreen extends StatefulWidget {
  const SuccessRegistrationScreen({super.key});

  @override
  State<SuccessRegistrationScreen> createState() => _SuccessSState();
}

class _SuccessSState extends State<SuccessRegistrationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF18B59A),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Image.asset('assets/images/success.png')),
          SizedBox(
            height: 30,
          ),
          Text(
            'Thank you very much',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w500,
              height: 0,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'You have successfully registered. please wait for acceptance ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w500,
              height: 0,
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Text(
            'from one of the officials',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w500,
              height: 0,
            ),
          ),
          SizedBox(
            height: 35,
          ),
          GestureDetector(
            onTap: () {
              Get.to(()=> loginScreen());
            },
            child: Container(
              width: 269,
              height: 64,
              decoration: ShapeDecoration(
                color: Color(0x00D9D9D9),
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: Colors.white),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Kanit',
                    fontWeight: FontWeight.w500,
                    height: 0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
