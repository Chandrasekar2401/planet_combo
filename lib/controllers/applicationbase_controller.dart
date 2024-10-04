import 'dart:convert';
import 'package:get/get.dart';
import 'package:planetcombo/controllers/apiCalling_controllers.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/models/horoscope_list.dart';
import 'package:planetcombo/models/messages_list.dart';
import 'package:planetcombo/api/api_callings.dart';
import 'package:planetcombo/models/payment_records.dart';
import 'package:planetcombo/models/get_request.dart';

class ApplicationBaseController extends GetxController {
  static ApplicationBaseController? _instance;

  static ApplicationBaseController getInstance() {
    _instance ??= ApplicationBaseController();
    return _instance!;
  }

  RxDouble deviceLatitude = 0.0.obs;
  RxDouble deviceLongitude = 0.0.obs;

  RxList<HoroscopesList> horoscopeList = <HoroscopesList>[].obs;

  RxList<MessageHistory> messagesHistory = <MessageHistory>[].obs;

  Rx<MessagesList> messagesInfo = MessagesList().obs;

  Rx<PaymentRecords> paymentInfo = PaymentRecords().obs;

  RxList<PaymentHistory> paymentHistory = <PaymentHistory>[].obs;

  RxBool horoscopeListPageLoad = false.obs;

  RxString termsAndConditionsLink = ''.obs;

  RxString getTimeZone = ''.obs;

  RxDouble userAccountBalance = 12.0.obs;

  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  final ApiCallingsController apiCallingsController =
  Get.put(ApiCallingsController.getInstance(), permanent: true);

  void initializeApplication(){
    _getUserHoroscopeList();
    _getTermsAndConditions();
    _getTimeZone();
    _getUserMessages();
    _getUserWallet();
    _getInvoiceList();
  }

  _getTimeZone(){
    getTimezone();
  }

  void getTimezone(){
    DateTime now = DateTime.now();
    Duration offset = now.timeZoneOffset;
    getTimeZone.value = formatDuration(offset);
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.isNegative) {
      return '-${twoDigits(duration.inHours)}${twoDigitMinutes}${twoDigitSeconds}';
    } else {
      return '${twoDigits(duration.inHours)}${twoDigitMinutes}${twoDigitSeconds}';
    }
  }

  getUserHoroscopeList(){
    _getUserHoroscopeList();
  }

  getUserWallet(){
    _getUserWallet();
  }

  getUserMessages(){
    _getUserMessages();
  }

  _getUserMessages() async{
    try{
      var response = await APICallings.getUserMessages(userId: appLoadController.loggedUserData.value.userid!, token: appLoadController.loggedUserData.value.token!);
      print('the response is ');
      print(response);
      if(response != null){
        var jsonBody = json.decode(response);
        if (jsonBody['Status'] == 'Success') {
          print('iam launching here $response');
             messagesInfo.value = messagesListFromJson(response);
             messagesHistory.value = messagesInfo.value.data!;
          print('the recevied value of messages is ${messagesHistory.length}');
        }
      }
    }catch(error){
      print('Get all user messages error section reached');
      print(error);
        messagesHistory.value = [];
        print('the length of the message history is ${messagesHistory.length}');
    }
  }

  _getUserWallet() async{
    try{
      // Get the current date
      DateTime currentDate = DateTime.now();

      // Extract the month and year
      String month = currentDate.month.toString().padLeft(2, '0');
      String year = currentDate.year.toString().substring(2);

      // Combine month and year
      String formattedDate = month + year;
      var response = await APICallings.getWalletBalance(userId: appLoadController.loggedUserData.value.userid!, token: appLoadController.loggedUserData.value.token!, statementSEQ: formattedDate);
      print('the response of the wallet balance is');
      print(response);
      if(response != null){
        var jsonBody = json.decode(response);
        if (jsonBody['Status'] == 'Success') {
          print('the received user balance is $userAccountBalance');
          userAccountBalance.value = jsonBody['CloseCurrentBalance']['ACCOUNTBAL'];
          print('the received user balance is $userAccountBalance');
          // termsAndConditionsLink.value = jsonBody['Data'];
        }
      }
    }catch(error){
      print('terms and conditions have api reach error');
      print(error);
    }
  }

  getTermsAndConditions(){
    _getTermsAndConditions();
  }

  _getTermsAndConditions() async{
    try{
      var response = await APICallings.termsAndConditions(userId: appLoadController.loggedUserData.value.userid!, token: appLoadController.loggedUserData.value.token!);
      print('the response of Terms and condtions');
      print(response);
      if(response != null){
        var jsonBody = json.decode(response);
        if (jsonBody['Status'] == 'Success') {
          termsAndConditionsLink.value = jsonBody['Data'];
        }
      }
    }catch(error){
      print('terms and conditions have api reach error');
      print(error);
    }
  }

  _getInvoiceList() async{
    try{
      var response = await APICallings.getInvoiceList(userId: appLoadController.loggedUserData.value.userid!, token: appLoadController.loggedUserData.value.token!);
      print('the response of the invoice list');
      print(response);
      if(response != null){
        var jsonBody = json.decode(response);
        if (jsonBody['Status'] == 'Success') {
          paymentInfo.value = paymentListFromJson(response);
          paymentHistory.value = paymentInfo.value.data!;
          print('the recevied value of payment length is ${paymentHistory.length}');
        }
      }
    }catch(error){
      print('payment history have api reach error');
      print(error);
    }
  }

  // _getUserHoroscopeList() async{
  //   try{
  //     horoscopeListPageLoad.value = true;
  //     var response = await APICallings.getHoroscope(userId: appLoadController.loggedUserData.value.userid!, token: appLoadController.loggedUserData.value.token!);
  //     horoscopeListPageLoad.value = false;
  //     print("Get Horoscope List Response : $response");
  //     if (response != null) {
  //       var jsonBody = json.decode(response);
  //       if (jsonBody['Status'] == 'Success') {
  //         if(jsonBody['Data'] == null){
  //           print('the length of the horoscopes ${horoscopeList.length}');
  //           horoscopeList.value = [];
  //         }else{
  //           horoscopeList.value = horoscopesListFromJson(response);
  //           print('the length of the horoscopes ${horoscopeList.length}');
  //         }
  //       } else {
  //         horoscopeList.value = [];
  //         print(jsonBody['Message']);
  //       }
  //     }
  //   }finally {}
  // }

//Ai code
  _getUserHoroscopeList() async {
    try {
      horoscopeListPageLoad.value = true;
      var response = await APICallings.getHoroscope(
          userId: appLoadController.loggedUserData.value.userid!,
          token: appLoadController.loggedUserData.value.token!
      );
      horoscopeListPageLoad.value = false;
      print("Get Horoscope List Response : $response");
      if (response != null) {
        var jsonBody = json.decode(response);
        if (jsonBody['Status'] == 'Success') {
          if (jsonBody['Data'] == null) {
            print('the length of the horoscopes ${horoscopeList.length}');
            horoscopeList.value = [];
          } else {
            horoscopeList.value = horoscopesListFromJson(response);

            // Sort the horoscopeList by hcreationdate
            horoscopeList.value.sort((a, b) {
              // Parse the date strings to DateTime objects
              DateTime dateA = DateTime.parse(a.hcreationdate ?? "1970-01-01T00:00:00.00");
              DateTime dateB = DateTime.parse(b.hcreationdate ?? "1970-01-01T00:00:00.00");
              // Sort in descending order (latest first)
              return dateB.compareTo(dateA);
            });

            print('the length of the horoscopes ${horoscopeList.length}');
          }
        } else {
          horoscopeList.value = [];
          print(jsonBody['Message']);
        }
      }
    } catch (e) {
      print("Error in _getUserHoroscopeList: $e");
      horoscopeList.value = [];
    }
  }

}