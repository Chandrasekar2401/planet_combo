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

  Future<bool> getUserPredictions(String hid) async {
    try {
      var response = await APICallings.getUserPredictions(
          userId: appLoadController.loggedUserData.value.userid!,
          hid: hid,
          token: appLoadController.loggedUserData.value.token!
      );
      print('API Response: $response'); // Debug log

      if (response != null) {
        var jsonBody = json.decode(response);
        print('JSON Body: $jsonBody'); // Debug log

        if (jsonBody['status'] == 'Success') {
          requestInfo.value = RequestList.fromJson(jsonBody);

          // Sort the data list based on createdate
          if (requestInfo.value.data != null) {
            requestInfo.value.data!.sort((a, b) {
              DateTime dateA = DateTime.parse(a.reqcredate!);
              DateTime dateB = DateTime.parse(b.reqcredate!);
              return dateB.compareTo(dateA);
            });
            requestHistory.value = requestInfo.value.data ?? [];
            print('Data processed successfully, returning true'); // Debug log
            return true;
          }
          // If we have success status but no data
          print('No data found in response'); // Debug log
          return false;
        } else {
          print('API returned non-success status'); // Debug log
          throw jsonBody['message'] ?? 'Unknown error occurred';
        }
      } else {
        print('Response is null'); // Debug log
        throw 'Server unreachable';
      }

    } catch (error) {
      print('API Error: $error');
      requestHistory.value = [];
      throw error.toString();
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
      print('the response of token ${appLoadController.loggedUserData.value.token!}');
      print(response);
      var jsonBody = json.decode(response!);
      if (response != null && jsonBody['data'] != null) {
        if (jsonBody['data'] is List) {
          // If Data is already a list
          List<dynamic> data = jsonBody['data'];
          predictions.value = data.map((item) => PredictionData.fromJson(item)).toList();
          print('predictions legth of the data ${predictions.value[0].prDetails![0].description}');
        } else if (jsonBody['data'] is Map<String, dynamic>) {
          // If Data is a single item
          PredictionData singlePrediction = PredictionData.fromJson(jsonBody['data']);
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