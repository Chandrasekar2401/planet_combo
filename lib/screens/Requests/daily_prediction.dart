import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:planetcombo/api/api_callings.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/common/constant.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/models/horoscope_list.dart';
import 'package:planetcombo/screens/dashboard.dart';
import 'package:planetcombo/controllers/request_controller.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DailyPredictions extends StatefulWidget {
  final HoroscopesList horoscope;
  const DailyPredictions({Key? key, required  this.horoscope}) : super(key: key);

  @override
  _DailyPredictionsState createState() => _DailyPredictionsState();
}

class _DailyPredictionsState extends State<DailyPredictions> {


  final HoroscopeRequestController horoscopeRequestController =
  Get.put(HoroscopeRequestController.getInstance(), permanent: true);

  final ApplicationBaseController applicationBaseController =
  Get.put(ApplicationBaseController.getInstance(), permanent: true);

  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);


  DateTime currentTime = DateTime.now();

  DateTime? selectedDate = DateTime.now().add(Duration(days: 1));

  DateTime endDate = DateTime.now().add(Duration(days: 30));

  Constants constants = Constants();

  DateTime getAfterSevenDays(DateTime inputDate) {
    DateTime afterSevenDays = inputDate.add(const Duration(days: 7));
    return afterSevenDays;
  }

  void _selectWebDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year, now.month, now.day + 1)
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    currentTime = DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(onPressed: () { Navigator.pop(context); }, icon: const Icon(Icons.chevron_left_rounded),),
        title: horoscopeRequestController.selectedRequest.value == 1 ? LocalizationController.getInstance().getTranslatedValue("Daily Request") : LocalizationController.getInstance().getTranslatedValue("Weekly Request"),
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)], centerTitle: true,
        actions: [
          IconButton(onPressed: (){
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Dashboard()),
                  (Route<dynamic> route) => false,
            );
          }, icon: const Icon(Icons.home_outlined))
        ],),
      body: Obx(() =>
          Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(width: MediaQuery.of(context).size.width * 0.4, child: commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Latitude'))),
                commonBoldText(text: ':  ${applicationBaseController.deviceLatitude.toString()}')
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                SizedBox(width: MediaQuery.of(context).size.width * 0.4, child: commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Longitude'))),
                commonBoldText(text: ':  ${applicationBaseController.deviceLongitude.toString()}')
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                SizedBox(width: MediaQuery.of(context).size.width * 0.4, child: commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Local Time'))),
                commonBoldText(text: ':  ${DateFormat('hh:mm:ss a').format(currentTime)}')
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(width: MediaQuery.of(context).size.width * 0.4, child: commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Select Date'))),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // _selectWebDate(context);
                      },
                      child: commonBoldText(text: selectedDate != null
                          ? ':  ${DateFormat('dd-MM-yy').format(selectedDate!)}'
                          : ':  Select Date'),
                    ),
                    SizedBox(width: 5),
                    const Icon(Icons.arrow_drop_down, size: 34, color: Colors.black26,)
                  ],
                )
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(width: MediaQuery.of(context).size.width * 0.4, child: commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('End Date'))),
                Row(
                  children: [
                    commonBoldText(text: endDate != null
                        ? ':  ${DateFormat('dd-MM-yy').format(endDate!)}'
                        : ':  '),
                  ],
                )
              ],
            ),
            SizedBox(height: horoscopeRequestController.selectedRequest.value == 2 ? 15 : 0),
            horoscopeRequestController.selectedRequest.value == 1 ? commonText(fontSize: 14, color: Colors.black54, text: LocalizationController.getInstance().getTranslatedValue("Prediction of event is based on the above Latitude and Longitude. If you change timezone there will be difference in prediction")):const SizedBox(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: 150,
                    child: GradientButton(
                        title: LocalizationController.getInstance().getTranslatedValue("Cancel"),buttonHeight: 45, textColor: Colors.white, buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)], onPressed: (Offset buttonOffset){
                      Navigator.pop(context);
                    }),
                  ),
                  SizedBox(width: 20),
                  SizedBox(
                    width: 150,
                    child: GradientButton(
                        title: LocalizationController.getInstance().getTranslatedValue("Save"),buttonHeight: 45, textColor: Colors.white, buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)], onPressed: (Offset buttonOffset) async{
                          CustomDialog.showLoading(context, 'Please wait');
                          print('the data is');
                          print(DateFormat('ddMMyy${applicationBaseController.getTimeZone.value}').format(selectedDate!));
                          print(horoscopeRequestController.selectedRequest.value);
                          String req = '1';
                          String reqStDate = DateFormat('ddMMyy${applicationBaseController.getTimeZone.value}').format(selectedDate!);
                          String reqEnDate = '';
                          if(horoscopeRequestController.selectedRequest.value == 1){
                            req = '2';
                            reqEnDate = DateFormat('ddMMyy${applicationBaseController.getTimeZone.value}').format(selectedDate!);
                          }else{
                            req = '1';
                            reqEnDate = DateFormat('ddMMyy${applicationBaseController.getTimeZone.value}').format(endDate!);
                          }
                          print(req);
                            var response = await APICallings.getDuplicateRequest(userId: widget.horoscope.huserid!, hId: widget.horoscope.hid!, rsqDate: reqStDate, reqDate: reqEnDate, rqCat: req, token: appLoadController.loggedUserData!.value.token!);
                          print(response);
                          if(response != null){
                            var jsonData = json.decode(response);
                            if(jsonData['Status'] == 'Success'){
                              if(jsonData['Data'] == 'n' ){
                                  // var result = await APICallings.getDailyCharge(rqCat: req, currency: constants.currency, token: appLoadController.loggedUserData!.value.token!, );
                                  // CustomDialog.cancelLoading(context);
                                  // if(result != null){
                                  //   var chargeData = json.decode(result);
                                  //   if(chargeData['Status'] == 'Success'){
                                  //     if(chargeData['Data'] != null){
                                  //
                                  //     }else{
                                  //       CustomDialog.showAlert(context, chargeData['ErrorMessage'], null, 14);
                                  //     }
                                  //   }
                                  // }
                                var result = await APICallings.addDailyRequest(
                                  token: appLoadController.loggedUserData!.value.token!,
                                  hid: widget.horoscope.hid!.trim(),
                                  userId: widget.horoscope.huserid!,
                                  latitude: applicationBaseController.deviceLatitude.value.toString(),
                                  longitude: applicationBaseController.deviceLongitude.value.toString(),
                                  startDate: DateFormat('ddMMyy${applicationBaseController.getTimeZone.value}').format(selectedDate!),
                                  endDate: DateFormat('ddMMyy${applicationBaseController.getTimeZone.value}').format(endDate!),
                                  timestamp:  DateTime.now().toString()
                                );
                                CustomDialog.cancelLoading(context);
                                print(result);
                                if(result != null){
                                  var chargeData = json.decode(result);
                                  if(chargeData['Status'] == 'Success'){
                                    if(chargeData['Data'] != null){
                                      CustomDialog.okActionAlert(context,  chargeData['Message'], 'Ok', true, 14, () {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(builder: (context) => const Dashboard()),
                                              (Route<dynamic> route) => false,
                                        );
                                      });
                                    }else{
                                      CustomDialog.showAlert(context, chargeData['ErrorMessage'], null, 14);
                                    }
                                  }else if(chargeData['Status'] == 'Failure'){
                                    CustomDialog.showAlert(context, chargeData['ErrorMessage'], null, 14);
                                  }
                                }
                              }else{
                                CustomDialog.cancelLoading(context);
                                CustomDialog.showAlert(context, jsonData['Message'], null, 14);
                              }
                            }else{
                              CustomDialog.cancelLoading(context);
                              CustomDialog.showAlert(context, 'Something went wrong , please try later', null, 14);
                            }
                          }else{
                            CustomDialog.cancelLoading(context);
                            CustomDialog.showAlert(context, 'Something went wrong , please try later', null, 14);
                          }

                        }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ))
    );
  }
}
