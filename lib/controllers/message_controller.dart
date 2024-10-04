import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/api/api_callings.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';

class MessageController extends GetxController {
  static MessageController? _instance;

  static MessageController getInstance() {
    _instance ??= MessageController();
    return _instance!;
  }

  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  final ApplicationBaseController applicationBaseController =
  Get.put(ApplicationBaseController.getInstance(), permanent: true);


  addMessage(context, msgId, msgUserId, userMessage, messageStatus, messageRead) async{
    try{
      CustomDialog.showLoading(context, 'Adding Message');
      var response = await APICallings.addMessage(messageId: msgId, messageUserId: msgUserId, userMessage: userMessage, messageStatus: messageStatus, messageRead: messageRead, token: appLoadController.loggedUserData.value.token!);
      print(response!.body);
      CustomDialog.cancelLoading(context);
      var jsonBody = json.decode(response.body);
      if(jsonBody['Status'] == 'Success'){
        applicationBaseController.getUserMessages();
        CustomDialog.okActionAlert(context, jsonBody['Message'], 'Ok', true, 14, (){
          Navigator.pop(context);
          Navigator.pop(context);
        });
      }
    }catch(error){
      print(error);
      CustomDialog.cancelLoading(context);
      CustomDialog.showAlert(context, 'Please try after sometime', false, 14);
      return error;
    }
  }


  updateMessage(context, msgId, msgUserId, msgMsgId, userMessage, messageStatus, messageRead) async{
    try{
      CustomDialog.showLoading(context, 'Updating');
      var response = await APICallings.updateMessage(messageId: msgId, messageUserId: msgUserId, messageMessageId: msgMsgId, userMessage: userMessage, messageStatus: messageStatus, messageRead: messageRead, token: appLoadController.loggedUserData.value.token!);
      print(response!.body);
      CustomDialog.cancelLoading(context);
      var jsonBody = json.decode(response.body);
      if(jsonBody['Status'] == 'Success'){
        applicationBaseController.getUserMessages();
        CustomDialog.okActionAlert(context, jsonBody['Message'], 'Ok', true, 14, (){
          Navigator.pop(context);
          Navigator.pop(context);
        });
      }
    }catch(error){
      print(error);
      CustomDialog.cancelLoading(context);
      CustomDialog.showAlert(context, 'Please try after sometime', false, 14);
      return error;
    }
  }


  deleteMessage(context, msgId, hid, userId) async{
    try{
      CustomDialog.showLoading(context, 'Updating');
      var response = await APICallings.deleteMessage(msgId, hid, userId, appLoadController.loggedUserData.value.token!);
      print('where the response is ');
      print(response!.body);
      CustomDialog.cancelLoading(context);
      var jsonBody = json.decode(response.body);
      if(jsonBody['Status'] == 'Success'){
        applicationBaseController.getUserMessages();
        CustomDialog.okActionAlert(context, jsonBody['Message'], 'Ok', true, 14, (){
          Navigator.pop(context);
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