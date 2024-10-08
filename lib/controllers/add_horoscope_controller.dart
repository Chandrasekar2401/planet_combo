import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:planetcombo/api/api_endpoints.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/controllers/payment_controller.dart';
import 'package:planetcombo/screens/dashboard.dart';
import 'package:planetcombo/screens/services/horoscope_services.dart';
import 'package:planetcombo/models/social_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_callings.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:planetcombo/models/horoscope_list.dart';


class AddHoroscopeController extends GetxController {
  static AddHoroscopeController? _instance;

  static AddHoroscopeController getInstance() {
    _instance ??= AddHoroscopeController();
    return _instance!;
  }


  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  final PaymentController paymentController =
  Get.put(PaymentController.getInstance(), permanent: true);

  final ApplicationBaseController applicationBaseController =
  Get.put(ApplicationBaseController.getInstance(), permanent: true);

  RxBool horoscopeNameAlert = false.obs;
  RxBool horoscopeBirthDateAlert = false.obs;
  RxBool horoscopeBirthTimeAlert = false.obs;
  RxBool horoscopeBirthStateAlert = false.obs;
  RxBool horoscopeBirthLandmarkAlert = false.obs;

  TextEditingController horoscopeName = TextEditingController();
  RxString addHoroscopeGender = "Male".obs;
  Rx<DateTime>? addHoroscopeBirthSelectedDate;
  Rx<TimeOfDay>? addHoroscopeBirthSelectedTime;
  TextEditingController placeStateCountryOfBirth = TextEditingController();
  TextEditingController landmarkOfBirth = TextEditingController();
  RxString birthOrder = "1".obs;


  TextEditingController placeStateCountryOfMarriage = TextEditingController();
  Rx<DateTime>? addSelectedMarriageDate;
  Rx<TimeOfDay>? addSelectedMarriageTime;

  TextEditingController placeStateCountryOfChildBirth = TextEditingController();
  Rx<DateTime>? addSelectedChildBirthDate;
  Rx<TimeOfDay>? addSelectedChildBirthTime;

  TextEditingController whereDidYouTraveled = TextEditingController();
  Rx<DateTime>? addSelectedTravelDate;
  Rx<TimeOfDay>? addSelectedTravelTime;

  TextEditingController whereMessageReceived = TextEditingController();
  Rx<DateTime>? addSelectedMessageReceivedDate;
  Rx<TimeOfDay>? addSelectedMessageReceivedTime;

  TextEditingController relationShipWithOwner = TextEditingController();
  Rx<DateTime>? addSelectedEventDate;
  Rx<TimeOfDay>? addSelectedEventTime;
  TextEditingController eventPlace = TextEditingController();

  RxString hNativePhoto = ''.obs;
  RxString hUserId = ''.obs;
  RxString hid = '0'.obs;
  RxString hHoroscopePhoto = ''.obs;
  RxString hMarriageAmPm = ''.obs;
  RxString hFirstChildTimeAMPM = ''.obs;
  RxString hAfFlightNo = ''.obs;
  RxString hRectifiedDate = ''.obs;
  RxString hRectifiedTime = ''.obs;
  RxString hRectifiedDst = ''.obs;
  RxString hRectifiedPlace = ''.obs;
  RxString hRectifiedLatitude = ''.obs;
  RxString hRectifiedLatitudeNS = ''.obs;
  RxString hRectifiedLongitude = ''.obs;
  RxString hRectifiedLongitudeEW = ''.obs;
  RxString hPdf = ''.obs;
  RxDouble lastRequestId = 0.0.obs;
  RxDouble lastMessageId = 0.0.obs;
  RxString lastWpDate = ''.obs;
  RxString lastDpDate = ''.obs;
  RxString hLocked = ''.obs;
  RxString hStatus = ''.obs;
  RxString hRecDeleted = ''.obs;
  RxString hCreationDate = ''.obs;
  RxString hRecDeletedD = ''.obs;



  ///Upload image
  RxList<XFile>? imageFileList = <XFile>[].obs;
  RxList<XFile>? editImageFileList = <XFile>[].obs;

  RxString? setHoroscopeWebProfileImageBase64 = ''.obs;

  RxList<XFile>? editProfileImageFileList = <XFile>[].obs;
  RxString? editProfileImageBase64 = ''.obs;

  XFile? image;

  void setImageFileListFromFile(XFile? value) {
    hNativePhoto.value = '';
    imageFileList!.value = (value == null ? null : <XFile>[value])!;
  }

  String mergeDateAndTime(String dateString, Rx<TimeOfDay>? rxTime) {
    DateTime date = DateTime.parse(dateString);
    TimeOfDay? time = rxTime?.value;

    if (time == null) {
      throw ArgumentError('Time cannot be null');
    }

    DateTime mergedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    // Format the DateTime to the desired string format
    return mergedDateTime.toString();
  }

  void setHoroscopeProfileWebImageBase64(String value) {
    setHoroscopeWebProfileImageBase64!.value = value;
  }

  void setEditImageFileListFromFile(XFile? value) {
    editImageFileList!.value = (value == null ? null : <XFile>[value])!;
  }

  void setEditProfileImageFileListFromFile(XFile? value) {
    editProfileImageFileList!.value = (value == null ? null : <XFile>[value])!;
  }

  void setEditProfileImageBase64(String value) {
    editProfileImageBase64!.value = value;
  }

  String getCurrentDateTime() {
    DateTime now = DateTime.now();
    String formattedDate = now.toString();
    return formattedDate;
  }

  void resetHNativePhoto(){
    hNativePhoto.value = '';
  }

  editHoroscope(HoroscopesList horoscope){
    refreshForm();
    print(json.encode(horoscope));
    addHoroscopeBirthSelectedDate = DateTime.now().obs;
    addHoroscopeBirthSelectedTime = TimeOfDay.now().obs;
    horoscopeName.text = horoscope.hname!;
    hNativePhoto.value = horoscope.hnativephoto!;
    addHoroscopeGender.value = setGender(horoscope.hgender!)!;
    addHoroscopeBirthSelectedDate!.value = DateTime.parse(horoscope.hdobnative!);
    addHoroscopeBirthSelectedTime!.value =  TimeOfDay(hour: horoscope.hhours!.toInt(), minute: horoscope.hmin!.toInt());
    placeStateCountryOfBirth.text = horoscope.hplace!;
    landmarkOfBirth.text = horoscope.hlandmark!;
    birthOrder.value = horoscope.hbirthorder ?? "";
    hid.value = horoscope.hid!;
    hAfFlightNo.value = horoscope.haflightno ?? "";
    hMarriageAmPm.value = horoscope.hmarriageampm ?? "";
    hFirstChildTimeAMPM.value = horoscope.hfirstchildtimeampm ?? "";
    placeStateCountryOfMarriage.text = horoscope.hmarriageplace ?? "";
    if(horoscope.hmarriagedate != null){
      addSelectedMarriageDate = DateTime.now().obs;
      addSelectedMarriageDate!.value  = DateTime.parse(horoscope.hmarriagedate!);
    }
    if(horoscope.hmarriagetime != null){
      addSelectedMarriageTime = TimeOfDay.now().obs;
      String? time = horoscope.hmarriagetime;
      String? duration = horoscope.hmarriageampm;

      // Split the time string into date and time components
      List<String> dateTimeComponents = time!.split("T");
      String date = dateTimeComponents[0];
      String timeString = dateTimeComponents[1];

      // Split the time string into hours, minutes, and seconds
      List<String> timeComponents = timeString.split(":");
      int hours = int.parse(timeComponents[0]);
      int minutes = int.parse(timeComponents[1]);
      int seconds = int.parse(timeComponents[2]);

      // Convert the hours based on the duration
      if (duration!.substring(0,2) == 'PM') {
        hours += 12;
      }
      addSelectedMarriageTime!.value = TimeOfDay(hour: hours, minute: minutes);
    }

    placeStateCountryOfChildBirth.text = horoscope.hfirstchildplace ?? "";
    if(horoscope.hfirstchilddate != null){
      addSelectedChildBirthDate = DateTime.now().obs;
      addSelectedChildBirthDate!.value  = DateTime.parse(horoscope.hfirstchilddate!);
    }
    if(horoscope.hfirstchildtime != null){
      addSelectedChildBirthTime = TimeOfDay.now().obs;
      String? time = horoscope.hfirstchildtime;
      String? duration = horoscope.hfirstchildtimeampm;

      // Split the time string into date and time components
      List<String> dateTimeComponents = time!.split("T");
      String date = dateTimeComponents[0];
      String timeString = dateTimeComponents[1];

      // Split the time string into hours, minutes, and seconds
      List<String> timeComponents = timeString.split(":");
      int hours = int.parse(timeComponents[0]);
      int minutes = int.parse(timeComponents[1]);
      int seconds = int.parse(timeComponents[2]);

      // Convert the hours based on the duration
      if (duration!.substring(0,2) == 'PM') {
        hours += 12;
      }
      addSelectedChildBirthTime!.value = TimeOfDay(hour: hours, minute: minutes);
    }

    whereDidYouTraveled.text = horoscope.hatplace ?? "";
    if(horoscope.hatdate != null){
      addSelectedTravelDate = DateTime.now().obs;
      addSelectedTravelDate!.value  = DateTime.parse(horoscope.hatdate!);
    }
    if(horoscope.hattime != null){
      addSelectedTravelTime = TimeOfDay.now().obs;
      String? time = horoscope.hattime;
      String? duration = horoscope.hattampm;

      // Split the time string into date and time components
      List<String> dateTimeComponents = time!.split("T");
      String date = dateTimeComponents[0];
      String timeString = dateTimeComponents[1];

      // Split the time string into hours, minutes, and seconds
      List<String> timeComponents = timeString.split(":");
      int hours = int.parse(timeComponents[0]);
      int minutes = int.parse(timeComponents[1]);
      int seconds = int.parse(timeComponents[2]);

      // Convert the hours based on the duration
      if (duration!.substring(0,2) == 'PM') {
        hours += 12;
      }
      addSelectedTravelTime!.value = TimeOfDay(hour: hours, minute: minutes);
    }

    whereMessageReceived.text = horoscope.hcrplace ?? "";
    if(horoscope.hcrdate != null){
      addSelectedMessageReceivedDate = DateTime.now().obs;
      addSelectedMessageReceivedDate!.value  = DateTime.parse(horoscope.hcrdate!);
    }
    if(horoscope.hcrtime != null){
      addSelectedMessageReceivedTime = TimeOfDay.now().obs;
      String? time = horoscope.hcrtime;
      String? duration = horoscope.hcrtampm;

      // Split the time string into date and time components
      List<String> dateTimeComponents = time!.split("T");
      String date = dateTimeComponents[0];
      String timeString = dateTimeComponents[1];

      // Split the time string into hours, minutes, and seconds
      List<String> timeComponents = timeString.split(":");
      int hours = int.parse(timeComponents[0]);
      int minutes = int.parse(timeComponents[1]);
      int seconds = int.parse(timeComponents[2]);

      // Convert the hours based on the duration
      if (duration!.substring(0,2) == 'PM') {
        hours += 12;
      }
      addSelectedMessageReceivedTime!.value = TimeOfDay(hour: hours, minute: minutes);
    }

    relationShipWithOwner.text = horoscope.hdrr ?? "";
    eventPlace.text = horoscope.hdrrp ?? "";
    if(horoscope.hdrrd != null){
      addSelectedEventDate = DateTime.now().obs;
      addSelectedEventDate!.value  = DateTime.parse(horoscope.hdrrd!);
    }
    if(horoscope.hdrrt != null){
      addSelectedEventTime = TimeOfDay.now().obs;
      String? time = horoscope.hdrrt;
      String? duration = horoscope.hdrrtampm;

      // Split the time string into date and time components
      List<String> dateTimeComponents = time!.split("T");
      String date = dateTimeComponents[0];
      String timeString = dateTimeComponents[1];

      // Split the time string into hours, minutes, and seconds
      List<String> timeComponents = timeString.split(":");
      int hours = int.parse(timeComponents[0]);
      int minutes = int.parse(timeComponents[1]);
      int seconds = int.parse(timeComponents[2]);

      // Convert the hours based on the duration
      if (duration!.substring(0,2) == 'PM') {
        hours += 12;
      }
      addSelectedEventTime!.value = TimeOfDay(hour: hours, minute: minutes);
    }
  }


  void refreshAlerts(){
    horoscopeNameAlert.value = false;
    horoscopeBirthDateAlert.value =false;
    horoscopeBirthTimeAlert.value= false;
    horoscopeBirthStateAlert.value = false;
    horoscopeBirthLandmarkAlert.value = false;
    refreshForm();
  }

  void refreshForm(){
    ///refresh Form
    print('refresh the form works');
    hNativePhoto.value = '';
    imageFileList!.value =  <XFile>[];

    horoscopeName.text = '';
    hid.value = '0';
    addHoroscopeGender.value = "Male";
    addHoroscopeBirthSelectedDate = null;
    addHoroscopeBirthSelectedTime = null;
    placeStateCountryOfBirth.text = '';
    landmarkOfBirth.text = '';
    birthOrder.value = '1';

    placeStateCountryOfMarriage.text = '';
    addSelectedMarriageDate = null;
    addSelectedMarriageTime = null;


    placeStateCountryOfChildBirth.text = '';
    addSelectedChildBirthDate = null;
    addSelectedChildBirthTime = null;


    whereDidYouTraveled.text = '';
    addSelectedTravelDate = null;
    addSelectedTravelTime = null;

    whereMessageReceived.text = '';
    addSelectedMessageReceivedDate = null;
    addSelectedMessageReceivedTime = null;

    relationShipWithOwner.text = '';
    addSelectedEventDate = null;
    addSelectedEventTime = null;
    eventPlace.text = '';
  }

  String convertTimeTo12HourFormat(int hour) {
    // Create a DateTime object with the given hour
    DateTime time = DateTime(2023, 1, 1, hour);

    // Format the time using the desired pattern
    String formattedTime = DateFormat('hh').format(time);

    return formattedTime;
  }

  String timeToCustomFormat(TimeOfDay time) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String hour = convertTimeTo12HourFormat(time.hour);
    String minute = twoDigits(time.minute);

    return "000000$hour$minute""00";
  }

  String? findGender(){
      if(addHoroscopeGender.value == 'Male' || addHoroscopeGender.value == 'ஆண்' || addHoroscopeGender.value == 'पुरुष'){
        return 'M';
      }else if(addHoroscopeGender.value == 'Female' || addHoroscopeGender.value == 'பெண்' || addHoroscopeGender.value == 'महिला'){
        return 'F';
      }else if(addHoroscopeGender.value == 'Transgender' || addHoroscopeGender.value == 'திருநங்கை/மூன்றாம் பாலினத்தவர்' || addHoroscopeGender.value == 'ट्रांसजेंडर'){
        return 'T';
      }
      return null;
  }

  String? setGender(String gender){
    if(gender == 'M'){
      if(LocalizationController.getInstance().currentLanguage.value == 'ta'){
        return 'ஆண்';
      }else if(LocalizationController.getInstance().currentLanguage.value == 'hi'){
        return 'पुरुष';
      }else{
        return 'Male';
      }
    }else if(gender == 'F'){
      if(LocalizationController.getInstance().currentLanguage.value == 'ta'){
        return 'பெண்';
      }else if(LocalizationController.getInstance().currentLanguage.value == 'hi'){
        return 'महिला';
      }else{
        return 'Female';
      }
    }else if(gender == 'T'){
      if(LocalizationController.getInstance().currentLanguage.value == 'ta'){
        return 'திருநங்கை/மூன்றாம் பாலினத்தவர';
      }else if(LocalizationController.getInstance().currentLanguage.value == 'hi'){
        return 'ट्रांसजेंडर';
      }else{
        return 'Transgender';
      }
    }
  }

  String? findMarriageSession(TimeOfDay time){
    if(time!.period == DayPeriod.pm){
      return 'PM';
    }else if(time!.period == DayPeriod.am){
      return 'AM';
    }else{
      return null;
    }
  }

  
  String? returnIntDate(DateTime? date){
    print('return int Selected date is entered $date');
    if(date != null){
      var selectedDate = DateFormat('ddMMyy000000').format(date);
      return selectedDate;
    }else{
      return null;
    }
  }

  updateProfile(context ,String username) async{
    if(editProfileImageFileList!.isNotEmpty || editProfileImageBase64!.isNotEmpty){
        updateProfileWithImage(context, username);
    }else{
      Map<String, dynamic> updateProfile = {
          "USERID": appLoadController.loggedUserData.value.userid,
          "USERNAME": username,
          "USEREMAIL": appLoadController.loggedUserData.value.useremail,
          "USERIDD":  appLoadController.loggedUserData.value.useridd!.replaceAll(" ", ""),
          "USERMOBILE": appLoadController.loggedUserData.value.usermobile,
          "UCOUNTRY": appLoadController.loggedUserData.value.ucountry,
          "UCURRENCY": appLoadController.loggedUserData.value.ucurrency,
          "USERPDATE": getCurrentDateTime(),
          "USERPPLANG": appLoadController.loggedUserData.value.userpplang,
          "TOKENFACEBOOK": appLoadController.loggedUserData.value.tokenfacebook,
          "TOKENGOOGLE": appLoadController.loggedUserData.value.tokengoogle,
          "TOKENYAHOO": appLoadController.loggedUserData.value.tokenyahoo,
          "USERPHOTO": appLoadController.loggedUserData.value.userphoto,
          "TOUCHID": appLoadController.loggedUserData.value.touchid,
          "PASSWORD": appLoadController.loggedUserData.value.password,
          "TCCODE": appLoadController.loggedUserData.value.tccode,
      };
      print('the passing value $updateProfile');
      CustomDialog.showLoading(context, 'Please wait');
      var response = await APICallings.updateProfile(updateProfile: updateProfile, token: appLoadController.loggedUserData!.value.token!);
      CustomDialog.cancelLoading(context);
      if(response == 'Server down'){
        CustomDialog.showAlert(context, 'Server Down, please try after some time', false, 14);
      }else if(response == '500'){
        CustomDialog.showAlert(context, 'Something went wrong Error Code : 500', false, 14);
      }
      print('the received response of add horoscope $response');
      return response;
    }
  }


  addNewProfileWithoutImage(context) async{
    if(editImageFileList!.isNotEmpty){

    }else{
      Map<String, dynamic> addProfile = {
        "USERID": appLoadController.loggedUserData.value.userid,
        "USERNAME": appLoadController.loggedUserData.value.username,
        "USEREMAIL": appLoadController.loggedUserData.value.useremail,
        "USERIDD":  appLoadController.loggedUserData.value.useridd,
        "UCOUNTRY": appLoadController.loggedUserData.value.ucountry,
        "UCURRENCY": appLoadController.loggedUserData.value.ucurrency,
        "USERPDATE": appLoadController.loggedUserData.value.userpdate,
        "USERPPLANG": appLoadController.loggedUserData.value.userpplang,
        "TOKENGOOGLE": appLoadController.loggedUserData.value.tokengoogle,
        "USERPHOTO": appLoadController.loggedUserData.value.userphoto,
        "TOUCHID": appLoadController.loggedUserData.value.touchid,
        "PASSWORD": appLoadController.loggedUserData.value.password,
        "TCCODE": appLoadController.loggedUserData.value.tccode,
        "USERMOBILE": "",
        "TOKENFACEBOOK": "",
        "TOKENYAHOO":""
      };
      print('the passing value $addProfile');
      CustomDialog.showLoading(context, 'Please wait');
      var response = await APICallings.addProfile(addProfile: addProfile);
      print('add Profile response $response');
      CustomDialog.cancelLoading(context);
      String firstFiveLetters = response.substring(0, 5);
      if(response == 'Server down'){
        CustomDialog.showAlert(context, 'Server Down, please try after some time', false, 14);
      }else if(firstFiveLetters == 'ERROR'){
        CustomDialog.showAlert(context, 'Some thing went wrong $response', false, 14);
      }
      return response;
    }
  }

  String convertTo12HourFormat(int hour) {
    if (hour >= 0 && hour <= 23) {
      if (hour == 0) {
        return '12';
      } else if (hour <= 12) {
        return hour.toString().padLeft(2, '0');
      } else {
        return (hour - 12).toString().padLeft(2, '0');
      }
    } else {
      return 'Invalid hour';
    }
  }
  
  addNewHoroscope(context) async{
    if(imageFileList!.isNotEmpty || setHoroscopeWebProfileImageBase64!.isNotEmpty){
      uploadImage(context);
    }else{
      Map<String, dynamic> addNewHoroscope = {
        "HUSERID": appLoadController.loggedUserData.value.userid,
        "HID": hid.value != '0' ? hid.value : '0',
        "HNAME": horoscopeName.text,
        "HNATIVEPHOTO": hNativePhoto.value,
        "HGENDER": findGender(),
        "HDOBNATIVE": addHoroscopeBirthSelectedDate!.value.toString(),
        // mergeDateAndTime(addHoroscopeBirthSelectedDate!.value.toString(), addHoroscopeBirthSelectedTime),
        "HHOURS":convertTo12HourFormat(addHoroscopeBirthSelectedTime!.value.hour),
        "HMIN":addHoroscopeBirthSelectedTime!.value.minute.toString(),
        "HSS":"0",
        "HAMPM":addHoroscopeBirthSelectedTime!.value.period == DayPeriod.pm ? "PM": "AM",
        "HPLACE":placeStateCountryOfBirth.text,
        "HLANDMARK":landmarkOfBirth.text,
        "HMARRIAGEDATE":addSelectedMarriageDate != null ?addSelectedMarriageDate!.value.toString(): '',
        "HMARRIAGEPLACE":placeStateCountryOfMarriage.text,
        "HMARRIAGETIME":addSelectedMarriageTime != null ? timeToCustomFormat(addSelectedMarriageTime!.value) : '',
        "HMARRIAGEAMPM":addSelectedMarriageTime != null ? findMarriageSession(addSelectedMarriageTime!.value) : '',
        "HFIRSTCHILDDATE":addSelectedChildBirthDate != null ?addSelectedChildBirthDate!.value.toString() : '',
        "HFIRSTCHILDPLACE":placeStateCountryOfChildBirth.text,
        "HFIRSTCHILDTIME":addSelectedChildBirthTime != null ? timeToCustomFormat(addSelectedChildBirthTime!.value) : '',
        "HFIRSTCHILDTIMEAMPM":addSelectedChildBirthTime != null ? findMarriageSession(addSelectedChildBirthTime!.value) : '',
        "HATDATE":addSelectedTravelDate != null ?addSelectedTravelDate!.value.toString():'',
        "HATPLACE":whereDidYouTraveled.text,
        'HATTIME':addSelectedTravelTime != null ? timeToCustomFormat(addSelectedTravelTime!.value) : '',
        "HATTAMPM":addSelectedTravelTime != null ? findMarriageSession(addSelectedTravelTime!.value) : '',
        "HAFLIGHTNO":'',
        "HCRDATE":addSelectedMessageReceivedDate != null ?addSelectedMessageReceivedDate!.value.toString():'',
        "HCRTIME":addSelectedMessageReceivedTime != null ? timeToCustomFormat(addSelectedMessageReceivedTime!.value) : '',
        "HCRPLACE": whereMessageReceived.text,
        "HCRTAMPM":addSelectedMessageReceivedTime != null ? findMarriageSession(addSelectedMessageReceivedTime!.value) : '',
        "HDRR":relationShipWithOwner.text,
        "HDRRD":addSelectedEventDate != null ?addSelectedEventDate!.value.toString() : '',
        "HDRRT":addSelectedEventTime != null ? timeToCustomFormat(addSelectedEventTime!.value) : '',
        'HDRRP':eventPlace.text,
        'HDRRTAMPM':addSelectedEventTime != null ? findMarriageSession(addSelectedEventTime!.value): '',
        'RECTIFIEDDST':'',
        'RECTIFIEDDATE':'',
        'RECTIFIEDTIME':'',
        'RECTIFIEDPLACE':'',
        'RECTIFIEDLONGTITUDE':'',
        'RECTIFIEDLONGTITUDEEW':'',
        'RECTIFIEDLATITUDE':'',
        'RECTIFIEDLATITUDENS':'',
        'HPDF':'',
        'LASTREQUESTID':'',
        'LASTMESSAGEID':'',
        'LASTWPDATE':DateTime.now().toString(),
        "LASTDPDATE":DateTime.now().toString(),
        "HLOCKED":'',
        "HRECDELETED":'',
        "HCREATIONDATE":DateTime.now().toString(),
        "HRECDELETEDD":'',
        "HTOTALTRUE":'',
        "HTOTALFALSE":'',
        "HTOTALPARTIAL":'',
        "HUNIQUE":'',
        "HSTATUS": "1",
        "HBIRTHORDER": birthOrder.value
      };
      print('the passing value $addNewHoroscope');
      CustomDialog.showLoading(context, 'Please wait');
     if(hid.value == '0'){
       var response = await APICallings.addNewHoroscope(addNewHoroscope: addNewHoroscope, token: appLoadController.loggedUserData!.value.token!);
       CustomDialog.cancelLoading(context);
       print('the received response of add horoscope $response');
       if(response != null){
         var jsonResponse = json.decode(response);
         multiTextYesOrNoDialog(
             context: context,
             dialogMessage: 'Horoscope Created Successfully will you pay now or Later',
             subText1: 'Total Amount : ${jsonResponse['data']['total_amount']}',
             cancelText: 'Pay Later', okText: 'Pay Now',
             cancelAction: (){
              Navigator.pop(context);
              applicationBaseController.updateHoroscopeUiList();
               Navigator.pushAndRemoveUntil(
                 context,
                 MaterialPageRoute(builder: (context) => const HoroscopeServices()),
                     (Route<dynamic> route) => false,
               );
             },
             okAction: () {
             paymentController.payByPaypal(appLoadController.loggedUserData.value!.userid!, jsonResponse['data']['requestId'], jsonResponse['data']['total_amount'], appLoadController.loggedUserData!.value.token!, context);
         });
       }else{
         CustomDialog.showAlert(context, 'Something went wrong', false, 14);
       }
     }else{
       var response = await APICallings.updateHoroscope(updateHoroscope: addNewHoroscope, token: appLoadController.loggedUserData!.value.token!);
       CustomDialog.cancelLoading(context);
       if(response.success == true){
         CustomDialog.okActionAlert(context, 'Horoscope updated successfully', 'OK', true, 14, () {
           applicationBaseController.getUserHoroscopeList();
           CustomDialog.showLoading(context, 'Please wait');
           Future.delayed(Duration(seconds: 2), () {
             CustomDialog.cancelLoading(context);
             Navigator.pushAndRemoveUntil(
               context,
               MaterialPageRoute(builder: (context) => const HoroscopeServices()),
                   (Route<dynamic> route) => false,
             );
           });
         });
       }else{
         CustomDialog.showAlert(context, response.errorMessage.toString(), false, 14);
       }
     }
    }
  }

  Future<void> updateProfileWithImage(context, username) async {
    CustomDialog.showLoading(context, 'Please wait');
    String filename = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    Map<String, String> headers = {
      'TOKEN': appLoadController.loggedUserData.value.token!,
    };

    String fileKey = 'USERPHOTO';
    String url = '';
    if (appLoadController.addNewUser.value == 'YES') {
      url = '${APIEndPoints.baseUrl}api/profile/addProfile?fileKey=$fileKey';
    } else {
      url = '${APIEndPoints.baseUrl}api/profile/updateProfile?fileKey=$fileKey';
    }

    // Create the multipart request
    print('The post url is $url');
    var request = http.MultipartRequest('POST', Uri.parse(url));

    if (kIsWeb) {
      // Web-specific handling
      String base64Image = editProfileImageBase64!.value;
      Uint8List imageBytes = base64Decode(base64Image);
      var multipartFile = http.MultipartFile.fromBytes(
        fileKey,
        imageBytes,
        filename: filename,
        contentType: MediaType('image', 'jpeg'), // specify content type
      );
      request.files.add(multipartFile);
    } else {
      // Mobile handling (Android/iOS)
      var image = editProfileImageFileList![0];
      var multipartFile = await http.MultipartFile.fromPath(fileKey, image.path);
      request.files.add(multipartFile);
    }

    // Set the headers and parameters
    request.headers.addAll(headers);
    request.fields['USERID'] = appLoadController.loggedUserData.value.userid!;
    request.fields['USERNAME'] = username;
    request.fields['USEREMAIL'] = appLoadController.loggedUserData.value.useremail!;
    request.fields['USERIDD'] = appLoadController.loggedUserData.value.useridd!.replaceAll(" ", "");
    request.fields['USERMOBILE'] = appLoadController.loggedUserData.value.usermobile!;
    request.fields['UCOUNTRY'] = appLoadController.loggedUserData.value.ucountry!;
    request.fields['UCURRENCY'] = appLoadController.loggedUserData.value.ucurrency!;
    request.fields['USERPDATE'] = getCurrentDateTime();
    request.fields['USERPPLANG'] = appLoadController.loggedUserData.value.userpplang!;
    request.fields['TOKENFACEBOOK'] = appLoadController.loggedUserData.value.tokenfacebook!;
    request.fields['TOKENGOOGLE'] = appLoadController.loggedUserData.value.tokengoogle!;
    request.fields['TOKENYAHOO'] = appLoadController.loggedUserData.value.tokenyahoo!;
    request.fields['TOUCHID'] = appLoadController.loggedUserData.value.touchid!;
    request.fields['PASSWORD'] = appLoadController.loggedUserData.value.password!;
    request.fields['TCCODE'] = appLoadController.loggedUserData.value.tccode!;

    // Send the request and get the response
    var requestResponse = await request.send();

    print('the passing request response is ${requestResponse.statusCode}');

    requestResponse.stream.transform(utf8.decoder).listen((event) async{
      var jsonResponse = jsonDecode(event) as Map<String, dynamic>;
      print('the received profile response is ${jsonResponse['Data']}');
      print('the received profile response status code is ${requestResponse.statusCode}');
      if(requestResponse.statusCode == 200){
        SharedPreferences pref = await SharedPreferences.getInstance();
        await pref.setString('UserInfo', json.encode(jsonResponse['Data']));
        CustomDialog.cancelLoading(context);
        CustomDialog.okActionAlert(context, 'Profile Updated successfully', 'OK', true, 14, () async{
          CustomDialog.showLoading(context, 'Please wait');
          final prefs = await SharedPreferences.getInstance();
          String? jsonString = prefs.getString('UserInfo');
          var jsonBody = json.decode(jsonString!);
          appLoadController.loggedUserData.value = SocialLoginData.fromJson(jsonBody);
          Future.delayed(Duration(seconds: 2), () {
            CustomDialog.cancelLoading(context);
            if(appLoadController.addNewUser.value == 'YES'){
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Dashboard()),
                    (Route<dynamic> route) => false,
              );
            }else{
              Navigator.pop(context);
              Navigator.pop(context);
            }
          });
        });
      }else{
        print('the failed response code is ${requestResponse.statusCode}');
        CustomDialog.cancelLoading(context);
        CustomDialog.showAlert(context, 'Something went wrong ERROR CODE : ${requestResponse.statusCode}', false, 14);
      }
    });
  }

  Future<void> uploadImage(context) async {
    // Create a unique filename
    CustomDialog.showLoading(context, 'Please wait');
    String filename =
        '${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Get the image file (replace with your actual image file)
    // Replace this with your actual image file

    // Create the HTTP headers
    Map<String, String> headers = {
      'TOKEN': appLoadController.loggedUserData.value.token!,
    };
    String fileKey = 'hNativePhoto';
    String url = '';
    if(hid.value == '0'){
      url = '${APIEndPoints.baseUrl}api/horoscope/addNew?fileKey=$fileKey';
    }else{
      url = '${APIEndPoints.baseUrl}api/horoscope/updateHoroscope?fileKey=$fileKey';
    }


    // Create the multipart request
    var request = http.MultipartRequest('POST', Uri.parse(url));
    print('the value of imageFileList is ${imageFileList}');
    image = XFile(imageFileList![0].path);
    // Attach the image file to the request
    var fileStream = http.ByteStream(image!.openRead());
    var length = image!.length;

    print('fileStream is $fileStream');
    print('the file length is $length');

    // Set the headers and parameters
    request.headers.addAll(headers);
    request.fields['HUSERID'] = appLoadController.loggedUserData.value.userid!;
    request.fields["HID"] = hid.value == '0' ? '0' : hid.value.trim();
    request.fields["HNAME"]= horoscopeName.text;
    request.fields["HGENDER"]=findGender()!;
    request.fields["HDOBNATIVE"]=returnIntDate(addHoroscopeBirthSelectedDate!.value).toString();
    request.fields["HHOURS"]= convertTo12HourFormat(addHoroscopeBirthSelectedTime!.value.hour);
    request.fields["HMIN"]=addHoroscopeBirthSelectedTime!.value.minute.toString();
    request.fields["HSS"]="0";
    request.fields["HAMPM"]=addHoroscopeBirthSelectedTime!.value.period == DayPeriod.pm ? "PM": "AM";
    request.fields["HPLACE"]=placeStateCountryOfBirth.text;
    request.fields["HLANDMARK"]=landmarkOfBirth.text;
    request.fields["HMARRIAGEDATE"]=addSelectedMarriageDate != null ?addSelectedMarriageDate!.value.toString(): '';
    request.fields["HMARRIAGEPLACE"]=placeStateCountryOfMarriage.text;
    request.fields["HMARRIAGETIME"]=addSelectedMarriageTime != null ? timeToCustomFormat(addSelectedMarriageTime!.value) : '';
    request.fields["HMARRIAGEAMPM"]=(addSelectedMarriageTime != null ? findMarriageSession(addSelectedMarriageTime!.value) : '')!;
    request.fields["HFIRSTCHILDDATE"]=addSelectedChildBirthDate != null ?addSelectedChildBirthDate!.value.toString() : '';
    request.fields["HFIRSTCHILDPLACE"]=placeStateCountryOfChildBirth.text;
    request.fields["HFIRSTCHILDTIME"]=addSelectedChildBirthTime != null ? timeToCustomFormat(addSelectedChildBirthTime!.value) : '';
    request.fields["HFIRSTCHILDTIMEAMPM"]=(addSelectedChildBirthTime != null ? findMarriageSession(addSelectedChildBirthTime!.value) : '')!;
    request.fields["HATDATE"]=addSelectedTravelDate != null ?addSelectedTravelDate!.value.toString():'';
    request.fields["HATPLACE"]=whereDidYouTraveled.text;
    request.fields['HATTIME']=addSelectedTravelTime != null ? timeToCustomFormat(addSelectedTravelTime!.value) : '';
    request.fields["HATTAMPM"]=(addSelectedTravelTime != null ? findMarriageSession(addSelectedTravelTime!.value) : '')!;
    request.fields["HAFLIGHTNO"]='';
    request.fields["HCRDATE"]=addSelectedMessageReceivedDate != null ?addSelectedMessageReceivedDate!.value.toString():'';
    request.fields["HCRTIME"]=addSelectedMessageReceivedTime != null ? timeToCustomFormat(addSelectedMessageReceivedTime!.value) : '';
    request.fields["HCRPLACE"]= whereMessageReceived.text;
    request.fields["HCRTAMPM"]=(addSelectedMessageReceivedTime != null ? findMarriageSession(addSelectedMessageReceivedTime!.value) : '')!;
    request.fields["HDRR"]=relationShipWithOwner.text;
    request.fields["HDRRD"]=addSelectedEventDate != null ?addSelectedEventDate!.value.toString() : '';
    request.fields["HDRRT"]=addSelectedEventTime != null ? timeToCustomFormat(addSelectedEventTime!.value) : '';
    request.fields['HDRRP']=eventPlace.text;
    request.fields['HDRRTAMPM']=(addSelectedEventTime != null ? findMarriageSession(addSelectedEventTime!.value): '')!;
    request.fields['RECTIFIEDDST']='';
    request.fields['RECTIFIEDDATE']='';
    request.fields['RECTIFIEDTIME']='';
    request.fields['RECTIFIEDPLACE']='';
    request.fields['RECTIFIEDLONGTITUDE']='';
    request.fields['RECTIFIEDLONGTITUDEEW']='';
    request.fields['RECTIFIEDLATITUDE']='';
    request.fields['RECTIFIEDLATITUDENS']='';
    request.fields['HPDF']='';
    request.fields['LASTREQUESTID']='';
    request.fields['LASTMESSAGEID']='';
    request.fields['LASTWPDATE']=DateTime.now().toString();
    request.fields["LASTDPDATE"]=DateTime.now().toString();
    request.fields["HLOCKED"]='';
    request.fields["HRECDELETED"]='';
    request.fields["HCREATIONDATE"]=DateTime.now().toString();
    request.fields["HRECDELETEDD"]='';
    request.fields["HTOTALTRUE"]='';
    request.fields["HTOTALFALSE"]='';
    request.fields["HTOTALPARTIAL"]='';
    request.fields["HUNIQUE"]='';
    request.fields["HSTATUS"]= "1";
    request.fields["HBIRTHORDER"] = birthOrder.value;

    print('request sent received ${request.fields}');
    print('the passing image file is ${image!.path}');
    var multipartFile =await http.MultipartFile.fromPath('hNativePhoto', image!.path);
    request.files.add(multipartFile);

    // Send the request and get the response
    var requestResponse = await request.send();

    print('the passing request response is ${requestResponse.statusCode}');

    requestResponse.stream.transform(utf8.decoder).listen((event) {
      var jsonResponse = jsonDecode(event) as Map<String, dynamic>;
      if(requestResponse.statusCode == 200){
        CustomDialog.cancelLoading(context);
        CustomDialog.okActionAlert(context, 'Horoscope added successfully', 'OK', true, 14, () {
          applicationBaseController.getUserHoroscopeList();
          CustomDialog.showLoading(context, 'Please wait');
          Future.delayed(Duration(seconds: 2), () {
            CustomDialog.cancelLoading(context);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HoroscopeServices()),
                  (Route<dynamic> route) => false,
            );
          });
        });
      }else{
        print('the failed response code is ${requestResponse.statusCode}');
        CustomDialog.cancelLoading(context);
      }
    });
    // Check the response
  }

}