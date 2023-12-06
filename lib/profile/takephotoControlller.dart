// import 'dart:js';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mkgo_mobile/profile/profile.dart';




class TakePhotoController2 extends GetxController{


  final storage = GetStorage();

  RxString imageFileProfile = ''.obs; 
  RxBool isImageLoaded = false.obs;

  void takephoto2(ImageSource source, BuildContext context) async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file2Profile = await imagePicker.pickImage(
        source: source);
    if(file2Profile!=null) {
      final storage = GetStorage();
      storage.write('imagePath2', file2Profile.path);
      print('Image file path: ${file2Profile.path}');
      imageFileProfile.value = file2Profile.path; 
       print(imageFileProfile);

        isImageLoaded.value = true;

        storage.write('imagePath2', imageFileProfile.value);
        Navigator.of(context).popAndPushNamed('Profile');
    }
  }
}