import 'dart:convert';
import 'package:get/get.dart';
import 'package:planetcombo/controllers/apiCalling_controllers.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/models/horoscope_list.dart';
import 'package:planetcombo/models/messages_list.dart';
import 'package:planetcombo/api/api_callings.dart';
import 'package:planetcombo/models/payment_records.dart';
import 'package:planetcombo/models/get_request.dart';
import 'package:planetcombo/models/pending_payment_list.dart';

import '../api/api_endpoints.dart';

class ApplicationBaseController extends GetxController {
  static ApplicationBaseController? _instance;

  static ApplicationBaseController getInstance() {
    _instance ??= ApplicationBaseController();
    return _instance!;
  }

  RxDouble deviceLatitude = 0.0.obs;
  RxDouble deviceLongitude = 0.0.obs;

  RxList<HoroscopesList> horoscopeList = <HoroscopesList>[].obs;

  RxList<PendingPaymentList> pendingPaymentsList = <PendingPaymentList>[].obs;

  RxList<MessageHistory> messagesHistory = <MessageHistory>[].obs;

  Rx<MessagesList> messagesInfo = MessagesList().obs;

  RxList<PaymentRecord> paymentHistory = <PaymentRecord>[].obs;

  RxBool horoscopeListPageLoad = false.obs;

  RxBool pendingPayment = false.obs;

  RxString termsAndConditionsLink = ''.obs;

  RxString getTimeZone = ''.obs;

  RxBool paymentForHoroscope = false.obs;

  RxDouble userAccountBalance = 12.0.obs;


  //Error Responses
  RxString invoiceListApiError = ''.obs;
  RxString pendingPaymentsError = ''.obs;
  RxString horoscopeListError = ''.obs;

  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  final ApiCallingsController apiCallingsController =
  Get.put(ApiCallingsController.getInstance(), permanent: true);

  void initializeApplication(){
    _getUserHoroscopeList();
    _getUserPendingPayments();
    _getTermsAndConditions();
    _getTimeZone();
    _getInvoiceList();
  }

  String formatDecimalString(dynamic input) {
    String val = input.toString();
    List<String> parts = val.split('.');
    if (parts.length == 1) {
      return '$val.00';
    } else {
      String decimal = parts[1];
      if (decimal.length == 1) {
        return '${val}0';  // Fixed: Changed '$val0' to '${val}0'
      } else {
        return '${parts[0]}.${decimal.substring(0, 2)}';
      }
    }
  }

  void updateHoroscopeUiList(){
    _getUserHoroscopeList();
    _getUserPendingPayments();
    _getInvoiceList();
  }

  void getInvoice(){
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

  getPendingPayments(){
    _getUserPendingPayments();
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
        if (jsonBody['status'] == 'Success') {
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

  Future<void> getUserMessagesForHoroscope(String horoscopeId) async {
    try {
      var result = await APICallings.getUserMessagesForHoroscope(
          userId: appLoadController.loggedUserData!.value.useremail!,
          horoscopeId: horoscopeId,
          token: appLoadController.loggedUserData!.value.token!
      );

      if (result != null) {
        var jsonData = jsonDecode(result);
        if (jsonData['status'] == 'Success') {
          List<MessageHistory> messagesList = [];
          if (jsonData['data'] != null) {
            for (var item in jsonData['data']) {
              messagesList.add(MessageHistory.fromJson(item));
            }
          }
          messagesHistory.value = messagesList;
        } else {
          messagesHistory.value = [];
        }
      }
    } catch (e) {
      print('Error getting horoscope messages: $e');
      messagesHistory.value = [];
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

  void _getTermsAndConditions(){
    print('the value of Ucurrency for terms and conditions ${appLoadController.loggedUserData.value.ucurrency}');
    if(appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'inr'){
      termsAndConditionsLink.value = '${APIEndPoints.baseUrl}api/File/INR%2FTerms%20and%20Conditions_Launch.pdf';
    }else if(appLoadController.loggedUserData.value.ucurrency.toString() == 'aed'){
      termsAndConditionsLink.value = '${APIEndPoints.baseUrl}api/File/AED%2FTerms%20and%20Conditions_Launch.pdf';
    }else{
      termsAndConditionsLink.value = '${APIEndPoints.baseUrl}api/File/USD%2FTerms%20and%20Conditions_Launch.pdf';
    }
  }

  getInvoiceList(){
    _getInvoiceList();
  }

  _getInvoiceList() async {
    invoiceListApiError.value = '';
    try {
      var response = await APICallings.getInvoiceList(
          userId: appLoadController.loggedUserData.value.userid!,
          token: appLoadController.loggedUserData.value.token!
      );
      print('The response of the invoice list:');
      print(response);
      if (response != null) {
        var jsonBody = json.decode(response);
        if (jsonBody is List) {
          paymentHistory.value = paymentRecordsFromJson(response);
        } else if (jsonBody is Map && jsonBody['status'] == 'Success' && jsonBody['data'] is List) {
          paymentHistory.value = paymentRecordsFromJson(json.encode(jsonBody['data']));
        } else {
          invoiceListApiError.value = 'Error: Unexpected API response format';
          paymentHistory.clear(); // Clear the list when there's an error
        }
      } else {
        invoiceListApiError.value = 'Error: Unable to fetch payment records';
        paymentHistory.clear();
      }
    } catch (error) {
      print('Payment history API request error:');
      print(error);
      invoiceListApiError.value = error.toString();
      paymentHistory.clear();
    }
  }

  getUserPendingPayments(){
    _getUserPendingPayments();
  }

  Future<void> _getUserPendingPayments() async {
    try {
      pendingPayment.value = true;
      pendingPaymentsError.value = ''; // Reset error message

      var response = await APICallings.getPendingPayments(
          userId: appLoadController.loggedUserData.value.userid!,
          token: appLoadController.loggedUserData.value.token!
      );

      if (response != null) {
        var jsonBody = json.decode(response);
        pendingPaymentsList.value = pendingPaymentListFromJson(response);

        // Sort the pending payments list by date
        pendingPaymentsList.value.sort((a, b) {
          final dateA = a.creationDate;
          final dateB = b.creationDate;
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateB.compareTo(dateA);
        });
      } else {
        pendingPaymentsList.value = [];
      }
    } catch (error) {
      print("Error in _getUserPendingPayments: $error");
      pendingPaymentsError.value = error.toString();
      pendingPaymentsList.value = [];
    } finally {
      pendingPayment.value = false;
    }
  }

  Future<void> _getUserHoroscopeList() async {
    try {
      horoscopeListError.value = '';
      horoscopeListPageLoad.value = true;
      var response = await APICallings.getHoroscope(
          userId: appLoadController.loggedUserData.value.userid!,
          token: appLoadController.loggedUserData.value.token!
      );

      if (response != null) {
        var jsonBody = json.decode(response);
        if (jsonBody['status'] == 'Success') {
          if (jsonBody['data'] == null) {
            horoscopeList.value = [];
          } else {
            horoscopeList.value = horoscopesListFromJson(response);
            horoscopeList.value.sort((a, b) {
              DateTime dateA = DateTime.parse(a.hcreationdate ?? "1970-01-01T00:00:00.00");
              DateTime dateB = DateTime.parse(b.hcreationdate ?? "1970-01-01T00:00:00.00");
              return dateB.compareTo(dateA);
            });
          }
        } else {
          horoscopeList.value = [];
          horoscopeListError.value = jsonBody['Message'] ?? 'Unknown error occurred';
        }
      }
    } catch (e) {
      print("Error in _getUserHoroscopeList: $e");
      horoscopeListError.value = e.toString();
      horoscopeList.value = [];
    } finally {
      horoscopeListPageLoad.value = false;
    }
  }

}