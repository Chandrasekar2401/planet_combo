import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:planetcombo/api/api_callings.dart';
import 'package:planetcombo/common/app_widgets.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/common/constant.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/models/horoscope_list.dart';
import 'package:planetcombo/controllers/request_controller.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../controllers/payment_controller.dart';
import '../services/horoscope_services.dart';

class DailyPredictions extends StatefulWidget {
  final HoroscopesList horoscope;
  const DailyPredictions({Key? key, required this.horoscope}) : super(key: key);

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
  final Map<String, String> _placeNames = {};

  DateTime getAfterSevenDays(DateTime inputDate) {
    DateTime afterSevenDays = inputDate.add(const Duration(days: 7));
    return afterSevenDays;
  }

  void _selectWebDate(BuildContext context) async {
    final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));

    // Determine locale based on currency
    final bool isIndianFormat = appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'inr';
    final Locale locale = isIndianFormat ? const Locale('en', 'GB') : const Locale('en', 'US');

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? tomorrow,
      firstDate: tomorrow,
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: const DatePickerThemeData(
              // Theme customizations if needed
            ),
          ),
          child: Localizations.override(
            context: context,
            locale: locale, // Use the determined locale
            child: child!,
          ),
        );
      },
      initialEntryMode: DatePickerEntryMode.input,
      helpText: isIndianFormat ? 'Select Date (DD/MM/YYYY)' : 'Select Date (MM/DD/YYYY)',
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        endDate = picked.add(const Duration(days: 90));
      });
    }
  }

  Future<String> getPlaceName(double lat, double lng) async {
    if (lat == 0 && lng == 0) return 'Location not available';
    final String key = '$lat,$lng';
    if (_placeNames.containsKey(key)) return _placeNames[key]!;
    try {
      const String apiKey = 'AIzaSyDRX8p3QXbJtS6vVpNgelztCe2RAQBgN44'; // Replace with your actual API key
      final String url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('the location result from the data ${data['results']}');
        if (data['results'] != null && data['results'].isNotEmpty) {
          final String placeName = data['results'][0]['formatted_address'];
          _placeNames[key] = placeName;
          return placeName;
        }
        return 'Location not found';
      }
      return 'Error: ${response.statusCode}';
    } catch (e) {
      print('Error fetching location: $e');
      return 'Error fetching location';
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

  String taxCalc(double tax1, double tax2, double tax3) {
    double totalTax = tax1 + tax2 + tax3;
    return applicationBaseController.formatDecimalString(totalTax);
  }

  @override
  void initState() {
    // TODO: implement initState
    currentTime = DateTime.now();
    getPlaceName(
      applicationBaseController.deviceLatitude.value,
      applicationBaseController.deviceLongitude.value,
    );
    super.initState();
  }

  Widget _buildInfoRow(String label, dynamic value) {
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
              child: value is Future<String>
                  ? FutureBuilder<String>(
                future: value,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading...');
                  }
                  return Text(
                    snapshot.data ?? 'Not available',
                    style: const TextStyle(fontSize: 15),
                  );
                },
              )
                  : commonBoldText(
                  text: value.toString(),
                  fontSize: 15,
                  maxLines: 1,
                  textOverflow: TextOverflow.ellipsis),
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
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: onTap != null ? Colors.orange.shade50 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: onTap != null ? Colors.orange.shade300 : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 15,
                          color: onTap != null ? Colors.black87 : Colors.black54,
                        ),
                      ),
                      if (onTap != null)
                        const Icon(
                          Icons.calendar_today_rounded,
                          color: Colors.orange,
                          size: 16,
                        ),
                    ],
                  ),
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
              ? LocalizationController.getInstance().getTranslatedValue("90 days Prediction Request")
              : LocalizationController.getInstance().getTranslatedValue("90 days Prediction Request"),
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
        body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 1.5,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Start Date Row - Interactive
                          InkWell(
                            onTap: () => _selectWebDate(context),
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(4),
                                color: Theme.of(context).primaryColor.withOpacity(0.05),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    LocalizationController.getInstance().getTranslatedValue('Select Start Date'),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        selectedDate != null
                                            ? DateFormat('MMMM dd, yyyy').format(selectedDate!)
                                            : 'Select Date',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_drop_down_circle_outlined,
                                        size: 16,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // End Date Row - Non-interactive
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.grey.shade50,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  LocalizationController.getInstance().getTranslatedValue('End Date'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                Text(
                                  DateFormat('MMMM dd, yyyy').format(endDate),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE67E22).withOpacity(0.2),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          commonBoldText(
                            text: "90-Day Daily Predictions",
                            fontSize: 20,
                            color: const Color(0xFF6A1B9A),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              commonBoldText(
                                text: appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'inr'
                                    ? "₹ 699"
                                    : (appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'aed'
                                    ? "AED 45"
                                    : "\$ 20"),
                                color: const Color(0xFF6A1B9A),
                                fontSize: 24,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle, color: const Color(0xFF6A1B9A), size: 17),
                              const SizedBox(width: 8),
                              Expanded(
                                child: commonText(
                                  text: "Daily personalized astrological insights",
                                  color: Colors.black87,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle, color: const Color(0xFF6A1B9A), size: 17),
                              const SizedBox(width: 8),
                              Expanded(
                                child: commonText(
                                  text: "Career, health and relationship forecasts",
                                  color: Colors.black87,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle, color: const Color(0xFF6A1B9A), size: 17),
                              const SizedBox(width: 8),
                              Expanded(
                                child: commonText(
                                  text: "Favorable and challenging time periods",
                                  color: Colors.black87,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle, color: const Color(0xFF6A1B9A), size: 17),
                              const SizedBox(width: 8),
                              Expanded(
                                child: commonText(
                                  text: "Planet transit impact on your future",
                                  color: Colors.black87,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
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
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade800, size: 17),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            LocalizationController.getInstance().getTranslatedValue(
                              "A change in timezone may result in slight variations in your predictions",
                            ),
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
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
                      Expanded(
                        child: GradientButton(
                            title: LocalizationController.getInstance().getTranslatedValue("Make Payment"),
                            buttonHeight: 45,
                            textColor: Colors.white,
                            buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
                            onPressed: (Offset buttonOffset) async {
                              print(formatDateWithTimezone(selectedDate!, applicationBaseController.getTimeZone.value));
                              CustomDialog.showLoading(context, 'Please wait');
                              String reqStartDate = formatDateWithTimezone(selectedDate!, applicationBaseController.getTimeZone.value);
                              String reqEndDate = formatDateWithTimezone(endDate!, applicationBaseController.getTimeZone.value);
                              var response = await APICallings.getDuplicateRequest(
                                  userId: widget.horoscope.huserid!,
                                  hId: widget.horoscope.hid!,
                                  rsqDate: reqStartDate,
                                  reqDate: reqEndDate,
                                  rqCat: horoscopeRequestController.selectedRequest.value.toString(),
                                  token: appLoadController.loggedUserData!.value.token!);
                              print(response);
                              if (response != null) {
                                var jsonData = json.decode(response);
                                if (jsonData['status'] == 'Success') {
                                  if (jsonData['data'] == 'n') {
                                    var result = await APICallings.addDailyRequest(
                                        token: appLoadController.loggedUserData!.value.token!,
                                        hid: widget.horoscope.hid!.trim(),
                                        userId: widget.horoscope.huserid!,
                                        latitude: applicationBaseController.deviceLatitude.value.toString(),
                                        longitude: applicationBaseController.deviceLongitude.value.toString(),
                                        startDate: formatDateWithTimezone(selectedDate!, applicationBaseController.getTimeZone.value),
                                        endDate: formatDateWithTimezone(endDate!, applicationBaseController.getTimeZone.value),
                                        timestamp: DateTime.now().toString());
                                    CustomDialog.cancelLoading(context);
                                    print(result);
                                    if (result != null) {
                                      var chargeData = json.decode(result);
                                      if (chargeData['status'] == 'Success') {
                                        if (chargeData['data'] != null) {
                                          AppWidgets().multiTextAlignYesOrNoDialog(
                                              iconUrl: 'assets/images/headletters.png',
                                              context: context,
                                              dialogMessage: 'Complete payment to reveal your astrological future',
                                              subText1Key: 'Amount',
                                              subText1Value: appLoadController.loggedUserData.value.ucurrency,
                                              subText1Value1: applicationBaseController.formatDecimalString(chargeData['data']['amount']),
                                              subText2Key: 'Tax Amount',
                                              subText2Value: appLoadController.loggedUserData.value.ucurrency,
                                              subText2Value2: taxCalc(chargeData['data']['tax1_amount'], chargeData['data']['tax2_amount'],
                                                  chargeData['data']['tax3_amount']),
                                              subText3Key: 'Total Amount',
                                              subText3Value: appLoadController.loggedUserData.value.ucurrency,
                                              subText3Value3: applicationBaseController.formatDecimalString(chargeData['data']['total_amount']),
                                              cancelText: 'Cancel',
                                              okText: 'Pay Now',
                                              cancelAction: () {
                                                Navigator.pop(context);
                                                // applicationBaseController.updateHoroscopeUiList();
                                                // Navigator.pushAndRemoveUntil(
                                                //   context,
                                                //   MaterialPageRoute(builder: (context) => const HoroscopeServices()),
                                                //       (Route<dynamic> route) => false,
                                                // );
                                              },
                                              okAction: () {
                                                if (appLoadController.loggedUserData!.value.ucurrency!.toLowerCase() == 'inr') {
                                                  paymentController.payByUpi(appLoadController.loggedUserData.value!.userid!,
                                                      chargeData['data']['requestId'], chargeData['data']['total_amount'],
                                                      appLoadController.loggedUserData!.value.token!, 'daily',context);
                                                } else if (appLoadController.loggedUserData!.value.ucurrency!.toLowerCase() == 'aed') {
                                                  paymentController.payByStripe(appLoadController.loggedUserData.value!.userid!,
                                                      chargeData['data']['requestId'], chargeData['data']['total_amount'],
                                                      'daily',
                                                      appLoadController.loggedUserData!.value.token!, context);
                                                } else {
                                                  paymentController.payByStripe(appLoadController.loggedUserData.value!.userid!,
                                                      chargeData['data']['requestId'], chargeData['data']['total_amount'],
                                                      'daily',
                                                      appLoadController.loggedUserData!.value.token!, context);
                                                }
                                              });
                                        } else {
                                          CustomDialog.showAlert(context, chargeData['errorMessage'], null, 14);
                                        }
                                      } else if (chargeData['status'] == 'Failure') {
                                        CustomDialog.showAlert(context, chargeData['errorMessage'], null, 14);
                                      }
                                    }
                                  } else {
                                    CustomDialog.cancelLoading(context);
                                    CustomDialog.showAlert(context, jsonData['message'], null, 14);
                                  }
                                } else {
                                  CustomDialog.cancelLoading(context);
                                  CustomDialog.showAlert(context, 'Something went wrong , please try later', null, 14);
                                }
                              } else {
                                CustomDialog.cancelLoading(context);
                                CustomDialog.showAlert(context, 'Something went wrong , please try later', null, 14);
                              }
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            )));
  }
}