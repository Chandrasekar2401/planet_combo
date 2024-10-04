import 'dart:convert';
import 'package:get/get.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/api/api_callings.dart';

import 'package:planetcombo/models/get_request.dart';
import 'package:planetcombo/models/preictions_list.dart';

class HoroscopeServiceController extends GetxController {
  static HoroscopeServiceController? _instance;

  static HoroscopeServiceController getInstance() {
    _instance ??= HoroscopeServiceController();
    return _instance!;
  }

  RxBool isLoading = false.obs;
  RxBool requestLoaded = false.obs;

  Rx<RequestList> requestInfo = RequestList().obs;

  RxList<PredictionData> predictions = <PredictionData>[].obs;

  RxList<RequestHistory> requestHistory = <RequestHistory>[].obs;

  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  getUserPredictions(String hid) async{
    try{
      var response = await APICallings.getUserPredictions(userId: appLoadController.loggedUserData.value.userid!,hid: hid, token: appLoadController.loggedUserData.value.token!);
      print('the response is ');
      print(response);
      if(response != null){
        var jsonBody = json.decode(response);
        if (jsonBody['Status'] == 'Success') {
          print('iam launching here $response');
          requestInfo.value = RequestList.fromJson(jsonBody);
          requestHistory.value = requestInfo.value.data!;
        }
      }
    }catch(error){
      print(error);
      requestHistory.value = [];
    }
  }

  List<PredictionDetail> getParsedDetails(prDetails) {
    if (prDetails is String) {
      List<dynamic> jsonList = json.decode(prDetails);
      return jsonList.map((json) => PredictionDetail.fromJson(json)).toList();
    } else if (prDetails is List) {
      return prDetails.map((json) => PredictionDetail.fromJson(json)).toList();
    }
    return [];
  }

  getUserPredictionsList(String hid, String requestId) async {
    try {
      var response = await APICallings.getUserAllPredictions(
          userId: appLoadController.loggedUserData.value.userid!,
          hid: hid,
          requestId: requestId,
          token: appLoadController.loggedUserData.value.token!
      );
      print('the response is ');
      print(response);
      var jsonBody = json.decode(response!);
      if (response != null && jsonBody['Data'] != null) {
        if (jsonBody['Data'] is List) {
          // If Data is already a list
          List<dynamic> data = jsonBody['Data'];
          predictions.value = data.map((item) => PredictionData.fromJson(item)).toList();
          print('predictions legth of the data ${predictions.value[0].prDetails![0].description}');
        } else if (jsonBody['Data'] is Map<String, dynamic>) {
          // If Data is a single item
          PredictionData singlePrediction = PredictionData.fromJson(jsonBody['Data']);
          predictions.value = [singlePrediction];
          print('the prediction value of map length is ${predictions.value.length}');
        } else {
          print('Unexpected data type for response["Data"]');
          predictions.value = [];
        }
      } else {
        predictions.value = [];
      }
    } catch (error) {
      print(error);
      predictions.value = [];
    }
  }

  updateComment(String hid, String reqId, int seqNo, pReqFlag,String prCustomCom, String prHComments){
    Map<String, dynamic> updatePredictions = {
      "PRUSERID": appLoadController.loggedUserData.value.userid,
      "PRHID": hid,
      "PRREQUESTID": reqId,
      "PRREQUESTIDSEQ": seqNo,
      "PRFEEDFLAG": pReqFlag,
      "PRCUSTOMERCOM": prCustomCom,
      "PRHCOMMENTS": prHComments,
    };
    try {
      var response = APICallings.updatePredictions(updatePrediction: updatePredictions, token: appLoadController.loggedUserData.value.token!);
      return response;
    }catch(error){
      print(error);
    }
  }
}