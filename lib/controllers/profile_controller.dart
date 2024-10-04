import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/api/api_callings.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:planetcombo/screens/social_login.dart';


class ProfileController extends GetxController {
  static ProfileController? _instance;

  static ProfileController getInstance() {
    _instance ??= ProfileController();
    return _instance!;
  }

  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  final ApplicationBaseController applicationBaseController =
  Get.put(ApplicationBaseController.getInstance(), permanent: true);

  TextEditingController profileEmail = TextEditingController();
  TextEditingController profileLanguage = TextEditingController();

  deleteProfile(context, userId) async{
    try{
      CustomDialog.showLoading(context, 'Deleting');
      var response = await APICallings.deleteProfile(userId, appLoadController.loggedUserData.value.token!);
      print('where the response is ');
      print(response!.body);
      CustomDialog.cancelLoading(context);
      var jsonBody = json.decode(response.body);
      if(jsonBody['Status'] == 'Success'){
        CustomDialog.okActionAlert(context, jsonBody['Message'], 'Ok', true, 14, () async{
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.remove('UserInfo');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SocialLogin()),
                (Route<dynamic> route) => false,
          );
        });
      }else{
        CustomDialog.showAlert(context, jsonBody['Message'], false, 14);
      }
    }catch(error){
      print(error);
      CustomDialog.cancelLoading(context);
      CustomDialog.showAlert(context, 'Please try after sometime', false, 14);
      return error;
    }
  }

}