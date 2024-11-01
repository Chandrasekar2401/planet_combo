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

import '../../controllers/payment_controller.dart';
import '../services/horoscope_services.dart';

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


  final PaymentController paymentController =
  Get.put(PaymentController.getInstance(), permanent: true);


  DateTime currentTime = DateTime.now();

  DateTime? selectedDate = DateTime.now().add(const Duration(days: 1));

  DateTime endDate = DateTime.now().add(const Duration(days: 90));

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

  String formatDateWithTimezone(DateTime date, String timezone) {
    // Create a DateFormat object for the desired output format
    DateFormat formatter = DateFormat("yyyy-MM-dd HH:mm:ss.SSS");

    // Format the date
    String formattedDate = formatter.format(date);

    // Append the timezone
    return '$formattedDate$timezone';
  }

  double taxCalc(double tax1, double tax2, double tax3){
    double totalTax = tax1 + tax2 + tax3;
    return totalTax;
  }

  @override
  void initState() {
    // TODO: implement initState
    currentTime = DateTime.now();
    super.initState();
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const Text(
              ':',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRow(String label, String value, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const Text(
              ':',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: onTap,
                child: Row(
                  children: [
                    Text(
                      value,
                      style: const TextStyle(fontSize: 15),
                    ),
                    if (onTap != null) ...[
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GradientAppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          title: horoscopeRequestController.selectedRequest.value == 2
              ? LocalizationController.getInstance().getTranslatedValue("Add Prediction")
              : LocalizationController.getInstance().getTranslatedValue("Add Prediction"),
          colors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  const Icon(Icons.payment_outlined, color: Colors.white, size: 16),
                  commonBoldText(
                    text: ' - ${appLoadController.loggedUserData.value.ucurrency!}',
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ],
              ),
            )
          ],
        ),
        body: Obx(
              () => SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            LocalizationController.getInstance().getTranslatedValue('Latitude'),
                            applicationBaseController.deviceLatitude.toString(),
                          ),
                          _buildInfoRow(
                            LocalizationController.getInstance().getTranslatedValue('Longitude'),
                            applicationBaseController.deviceLongitude.toString(),
                          ),
                          _buildDateRow(
                            LocalizationController.getInstance().getTranslatedValue('Start Date'),
                            selectedDate != null
                                ? DateFormat('MMMM dd, yyyy').format(selectedDate!)
                                : 'Select Date',
                          ),
                          _buildDateRow(
                            LocalizationController.getInstance().getTranslatedValue('End Date'),
                            DateFormat('MMMM dd, yyyy').format(endDate),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
              Container(
              padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            LocalizationController.getInstance().getTranslatedValue(
              "Prediction of event is based on the above Latitude and Longitude. If you change timezone there will be difference in prediction",
            ),
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
            children: [
        Expanded(
        child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          ),
          ),
          child: Text(
          LocalizationController.getInstance().getTranslatedValue("Cancel"),
          style: const TextStyle(color: Colors.black87),
          ),
          ),
          ),
    const SizedBox(width: 16),
                        SizedBox(
                          width: 150,
                          child: GradientButton(
                              title: LocalizationController.getInstance().getTranslatedValue("Save"),buttonHeight: 45, textColor: Colors.white, buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)], onPressed: (Offset buttonOffset) async{
                            print(formatDateWithTimezone(selectedDate!, applicationBaseController.getTimeZone.value));
                            CustomDialog.showLoading(context, 'Please wait');
                            String reqStartDate = formatDateWithTimezone(selectedDate!, applicationBaseController.getTimeZone.value);
                            String reqEndDate = formatDateWithTimezone(endDate!, applicationBaseController.getTimeZone.value);
                            var response = await APICallings.getDuplicateRequest(userId: widget.horoscope.huserid!, hId: widget.horoscope.hid!, rsqDate: reqStartDate, reqDate: reqEndDate, rqCat: horoscopeRequestController.selectedRequest.value.toString(), token: appLoadController.loggedUserData!.value.token!);
                            print(response);
                            if(response != null){
                              var jsonData = json.decode(response);
                              if(jsonData['status'] == 'Success'){
                                if(jsonData['data'] == 'n' ){
                                  var result = await APICallings.addDailyRequest(
                                      token: appLoadController.loggedUserData!.value.token!,
                                      hid: widget.horoscope.hid!.trim(),
                                      userId: widget.horoscope.huserid!,
                                      latitude: applicationBaseController.deviceLatitude.value.toString(),
                                      longitude: applicationBaseController.deviceLongitude.value.toString(),
                                      startDate: formatDateWithTimezone(selectedDate!, applicationBaseController.getTimeZone.value),
                                      endDate: formatDateWithTimezone(endDate!, applicationBaseController.getTimeZone.value),
                                      timestamp:  DateTime.now().toString()
                                  );
                                  CustomDialog.cancelLoading(context);
                                  print(result);
                                  if(result != null){
                                    var chargeData = json.decode(result);
                                    if(chargeData['status'] == 'Success'){
                                      if(chargeData['data'] != null){
                                        multiTextYesOrNoDialog(
                                            context: context,
                                            dialogMessage: 'Daily Prediction is created please Pay Now Or Do Pay Later',
                                            subText1Key: 'Amount',
                                            subText1Value: '${appLoadController.loggedUserData.value.ucurrency} ${applicationBaseController.formatDecimalString(chargeData['data']['amount'])}',
                                            subText2Key: 'Tax Amount',
                                            subText2Value: '${appLoadController.loggedUserData.value.ucurrency} ${taxCalc(chargeData['data']['tax1_amount'], chargeData['data']['tax3_amount'], chargeData['data']['tax3_amount'])}',
                                            subText3Key: 'Total Amount',
                                            subText3Value: '${appLoadController.loggedUserData.value.ucurrency} ${applicationBaseController.formatDecimalString(chargeData['data']['total_amount'])}',
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
                                              if(appLoadController.loggedUserData!.value.ucurrency!.toLowerCase() == 'inr'){
                                                paymentController.payByUpi(appLoadController.loggedUserData.value!.userid!, chargeData['data']['requestId'], chargeData['data']['total_amount'], appLoadController.loggedUserData!.value.token!, context);
                                              }else{
                                                paymentController.payByPaypal(appLoadController.loggedUserData.value!.userid!, chargeData['data']['requestId'], chargeData['data']['total_amount'], appLoadController.loggedUserData!.value.token!, context);
                                              }
                                            });
                                      }else{
                                        CustomDialog.showAlert(context, chargeData['errorMessage'], null, 14);
                                      }
                                    }else if(chargeData['status'] == 'Failure'){
                                      CustomDialog.showAlert(context, chargeData['errorMessage'], null, 14);
                                    }
                                  }
                                }else{
                                  CustomDialog.cancelLoading(context);
                                  CustomDialog.showAlert(context, jsonData['message'], null, 14);
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
                ],
              ),
            ))
        ));
  }
}
