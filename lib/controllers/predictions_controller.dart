import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/api/api_callings.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/screens/predictions/special_prediction_response.dart';
import 'package:planetcombo/models/get_special_predictions.dart';
import 'package:planetcombo/models/prediction_details.dart';
import 'package:planetcombo/models/date_list.dart';

class PredictionsController extends GetxController {
  static PredictionsController? _instance;

  static PredictionsController getInstance() {
    _instance ??= PredictionsController();
    return _instance!;
  }

  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  Rx<SpecialPredictionList> requestInfo = SpecialPredictionList().obs;

  RxList<PredictionDetailItem> predictionItems = <PredictionDetailItem>[].obs;

  RxString initialQuestion = "".obs;
  RxString initialAnswer = "".obs;

  RxBool isLoading = false.obs;

  RxList<SpecialPredictionHistory> specialRequestHistory = <SpecialPredictionHistory>[].obs;

  RxList<DateItem> datesList = <DateItem>[].obs;

  getDailyPredictionDates(String userId, int hid, String requestId) async{
    try{
      var response = await APICallings.getDailyPredictionDates(userId, hid, requestId, appLoadController.loggedUserData.value.token!);
      var jsonBody = json.decode(response!.body);
      if (jsonBody is List) {
        datesList.value = jsonBody.map((item) => DateItem.fromJson(item)).toList();
      }
    }catch(error){
      print(error);
      return error;
    }
  }

  Future<bool> updatePredictionStatus(String userId, int hid, String reqId, int predictionId, String status, String date) async{
    try{
      var response = await APICallings.updatePredictionFlag(userId: userId, hid: hid, reqId: reqId,flagId:  predictionId,flag: status, token:  appLoadController.loggedUserData.value.token!);
      if(response!.statusCode == 200){
        var datePart = getDatePart(date);
        var response = await getDailyPredictionDateDetails(userId, hid, reqId, datePart);
        return true;
      }else{
        return false;
      }
    }catch(error){
      return false;
    }
  }

  getDailyPredictionDateDetails(String userId, int hid, String requestId, String date) async{
    try{
      var response = await APICallings.getDailyPredictionDateDetails(userId, hid, requestId, date, appLoadController.loggedUserData.value.token!);
      var jsonBody = json.decode(response!.body);
      return response.body;
    }catch(error){
      print(error);
      return error;
    }
  }

  getSpecialPredictions(String userId, int hid, String requestId,String? reqSpecialDetails, BuildContext context) async {
    try {
      initialQuestion.value = reqSpecialDetails ?? "";
      CustomDialog.showLoading(context, 'Please wait');
      var response = await APICallings.getSpecialPredictions(userId, hid, requestId, appLoadController.loggedUserData.value.token!);
      CustomDialog.cancelLoading(context);
      var jsonBody = json.decode(response!.body);
      if (jsonBody['status'] == 'Success') {
        if (jsonBody['message'] == "No data found") {
          CustomDialog.okActionAlert(context,
              "Your questions are under review, you will be notified once they are ready.",
              'Ok', true, 14, () async {
                Navigator.pop(context);
              });
        } else if (jsonBody['message'] == "Predictions Listing") {
          requestInfo.value = SpecialPredictionList.fromJson(jsonBody);
          specialRequestHistory.value = requestInfo.value.data!;
          print('the response data from the api is ${jsonBody['data']}');
          if (specialRequestHistory.isNotEmpty) {
            initialAnswer.value = specialRequestHistory[0].prdetails ?? "";
            var predictionId = specialRequestHistory[0].predictionId;
            print('the predictionId is $predictionId');
            if (predictionId != null) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SpecialPredictionResponse(predictionId: predictionId, initialQuestion: initialQuestion.value, initialAnswer: initialAnswer.value,)));
            } else {
              CustomDialog.okActionAlert(context,
                  'Please wait Prediction key need to generate', 'Ok', true, 14, () async {
                    Navigator.pop(context);
                  });
            }
          } else {
            CustomDialog.showAlert(context, 'No prediction data available', false, 14);
          }
        }
      } else {
        CustomDialog.showAlert(context, jsonBody['message'], false, 14);
      }
    } catch (error) {
      print('Error in getSpecialPredictions: $error');
      CustomDialog.cancelLoading(context);
      CustomDialog.showAlert(context, 'Please try after sometime', false, 14);
      return error;
    }
  }

  addSpecialRequestReply(int predictionId, message) async{
    try{
      var response = await APICallings.replySpecialPrediction(predictionId: predictionId, message: message, token: appLoadController.loggedUserData.value.token!);
      print('where the response is ');
      return response;
    }catch(error){
      return error;
    }
  }

  getSpecialRequestMessages(int predictionId) async{
    try{
      var response = await APICallings.getSpecialPredictionMessages(predictionId, appLoadController.loggedUserData.value.token!);
      print('where the response is ');
      print(response!.body);
      if(response.statusCode == 200){
        return response.body;
      }else{
        return null;
      }
    }catch(error){
      return error;
    }
  }

  String getDatePart(String date) {
    if (date.contains('T')) {
      return date.split('T')[0];
    } else if (date.contains(' ')) {
      return date.split(' ')[0];
    }
    return date; // Return the original string if neither 'T' nor space is found
  }

  onDateTap(String userId, int hid,String requestId, String date,BuildContext context) async {
    try {
      isLoading(true);
      var datePart = getDatePart(date);
      final response = await getDailyPredictionDateDetails(userId, hid, requestId, datePart);
      if (response != null) {
        final List<dynamic> jsonList = json.decode(response);
        final List<PredictionDetailItem> items = jsonList.map((json) => PredictionDetailItem.fromJson(json)).toList();
        print('Fetched items: ${items.length}');
        isLoading(false);
        if (items.isNotEmpty) {
          predictionItems.value = items;
        } else {
          predictionItems.value = [];
        }
      }
    } catch (e) {
      print('Error fetching prediction details: $e');
    } finally {
      isLoading(false);
    }
  }
}