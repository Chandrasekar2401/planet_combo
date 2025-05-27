import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geocoding/geocoding.dart' hide kIsWeb;
import 'package:planetcombo/common/app_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/controllers/request_controller.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:get/get.dart';
import 'package:planetcombo/models/horoscope_list.dart';
import 'package:intl/intl.dart';
import 'package:planetcombo/api/api_callings.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';

import '../../controllers/payment_controller.dart';
import '../services/horoscope_services.dart';

class LocationService {
  static Future<String> getAddressFromLatLng(double latitude, double longitude) async {
    if (kIsWeb) {
      return _getAddressFromLatLngWeb(latitude, longitude);
    } else {
      return _getAddressFromLatLngMobile(latitude, longitude);
    }
  }

  static Future<String> _getAddressFromLatLngWeb(double latitude, double longitude) async {
    const apiKey = 'AIzaSyDRX8p3QXbJtS6vVpNgelztCe2RAQBgN44'; // Replace with your Google API key
    final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey&language=en';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        if (decodedResponse['results'] != null &&
            decodedResponse['results'].isNotEmpty) {

          final components = decodedResponse['results'][0]['address_components'];
          Map<String, String> addressParts = {
            'sublocality_level_1': '', // Area/Neighborhood
            'locality': '',           // City
            'administrative_area_level_1': '', // State
            'country': ''            // Country
          };

          // Extract address components
          for (var component in components) {
            final types = component['types'] as List;
            if (types.contains('sublocality_level_1')) {
              addressParts['sublocality_level_1'] = component['long_name'];
            } else if (types.contains('locality')) {
              addressParts['locality'] = component['long_name'];
            } else if (types.contains('administrative_area_level_1')) {
              addressParts['administrative_area_level_1'] = component['long_name'];
            } else if (types.contains('country')) {
              addressParts['country'] = component['long_name'];
            }
          }

          // Build address string
          List<String> formattedAddress = [];
          if (addressParts['sublocality_level_1']!.isNotEmpty) {
            formattedAddress.add(addressParts['sublocality_level_1']!);
          }
          if (addressParts['locality']!.isNotEmpty) {
            formattedAddress.add(addressParts['locality']!);
          }
          if (addressParts['administrative_area_level_1']!.isNotEmpty) {
            formattedAddress.add(addressParts['administrative_area_level_1']!);
          }
          if (addressParts['country']!.isNotEmpty) {
            formattedAddress.add(addressParts['country']!);
          }

          return formattedAddress.join(', ');
        }
      }
      return 'Unable to fetch location';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  static Future<String> _getAddressFromLatLngMobile(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        List<String> addressParts = [];

        // Add components in order: Area, City, State, Country
        if (place.subLocality?.isNotEmpty ?? false) addressParts.add(place.subLocality!);
        if (place.locality?.isNotEmpty ?? false) addressParts.add(place.locality!);
        if (place.administrativeArea?.isNotEmpty ?? false) addressParts.add(place.administrativeArea!);
        if (place.country?.isNotEmpty ?? false) addressParts.add(place.country!);

        // Remove duplicates while maintaining order
        final seen = <String>{};
        addressParts = addressParts.where((element) => seen.add(element)).toList();

        return addressParts.join(', ');
      }
      return 'Unable to fetch location';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}

class SpecialPredictions extends StatefulWidget {
  final HoroscopesList horoscope;
  const SpecialPredictions({super.key, required this.horoscope});

  @override
  _SpecialPredictionsState createState() => _SpecialPredictionsState();
}

class _SpecialPredictionsState extends State<SpecialPredictions> {
  final HoroscopeRequestController horoscopeRequestController =
  Get.put(HoroscopeRequestController.getInstance(), permanent: true);

  final ApplicationBaseController applicationBaseController =
  Get.put(ApplicationBaseController.getInstance(), permanent: true);

  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  final PaymentController paymentController =
  Get.put(PaymentController.getInstance(), permanent: true);

  DateTime currentTime = DateTime.now();
  DateTime? todayDate = DateTime.now();
  TextEditingController question1Controller = TextEditingController();
  TextEditingController question2Controller = TextEditingController();
  String _address = 'Loading...';

  @override
  void initState() {
    super.initState();
    currentTime = DateTime.now();
    _getAddressFromLatLng();
  }

  @override
  void dispose() {
    question1Controller.dispose();
    question2Controller.dispose();
    super.dispose();
  }

  Future<void> _getAddressFromLatLng() async {
    final latitude = applicationBaseController.deviceLatitude.value;
    final longitude = applicationBaseController.deviceLongitude.value;
    final address = await LocationService.getAddressFromLatLng(latitude, longitude);
    setState(() {
      _address = address;
    });
  }

  String formatDateWithTimezone(DateTime date, String timezone) {
    DateFormat formatter = DateFormat("yyyy-MM-dd HH:mm:ss.SSS");
    String formattedDate = formatter.format(date);
    return '$formattedDate$timezone';
  }

  String taxCalc(double tax1, double tax2, double tax3) {
    double totalTax = tax1 + tax2 + tax3;
    return applicationBaseController.formatDecimalString(totalTax);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        title: LocalizationController.getInstance()
            .getTranslatedValue("Ask Life Guidance Questions"),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocalizationController.getInstance().getTranslatedValue(
                              "What would you like to know about your future?"),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF6A1B9A),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Question 1
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            commonBoldText(text:
                              "Question 1:",
                              fontSize: 12,
                              color: Colors.grey.shade800,
                            ),
                            const SizedBox(height: 3),
                            PrimaryInputText(
                              hintText: 'Enter your first question here...',
                              controller: question1Controller,
                              onValidate: (v) => null,
                              maxLines: 2,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Question 2
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            commonBoldText(text:
                              "Question 2:",
                              fontSize: 12,
                              color: Colors.grey.shade800,
                            ),
                            const SizedBox(height: 6),
                            PrimaryInputText(
                              hintText: 'Enter your second question here...',
                              controller: question2Controller,
                              onValidate: (v) => null,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
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
                            text: "Life Guidance Questions",
                            fontSize: 18,
                            color: const Color(0xFF6A1B9A),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              commonBoldText(
                                text: appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'inr'
                                    ? "₹ 399"
                                    : (appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'aed'
                                    ? "AED 50"
                                    : "\$ 20"),
                                color: const Color(0xFF6A1B9A),
                                fontSize: 24,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle, color: Color(0xFF6A1B9A), size: 17),
                              const SizedBox(width: 8),
                              Expanded(
                                child: commonText(
                                  text: "Ask up to 2 questions about your future",
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
                              const Icon(Icons.check_circle, color: Color(0xFF6A1B9A), size: 17),
                              const SizedBox(width: 8),
                              Expanded(
                                child: commonText(
                                  text: "Get expert astrological guidance for life decisions",
                                  color: Colors.black87,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
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
                            LocalizationController.getInstance()
                                .getTranslatedValue("Cancel"),
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GradientButton(
                          title: LocalizationController.getInstance()
                              .getTranslatedValue("Make Payment"),
                          buttonHeight: 45,
                          textColor: Colors.white,
                          buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
                          onPressed: (Offset buttonOffset) async {
                            if (question1Controller.text.isEmpty && question2Controller.text.isEmpty) {
                              showFailedToast('Please enter at least one question');
                            } else {
                              // Format questions as "1. [q1] 2. [q2]" format
                              String formattedQuestions = "";

                              if (question1Controller.text.isNotEmpty) {
                                formattedQuestions += "1. ${question1Controller.text}";
                              }

                              if (question2Controller.text.isNotEmpty) {
                                if (formattedQuestions.isNotEmpty) {
                                  formattedQuestions += " 2. ${question2Controller.text}";
                                } else {
                                  formattedQuestions += "2. ${question2Controller.text}";
                                }
                              }

                              CustomDialog.showLoading(context, 'Please wait');
                              var result = await APICallings.addSpecialRequest(
                                token: appLoadController.loggedUserData!.value.token!,
                                hid: widget.horoscope.hid!.trim(),
                                userId: widget.horoscope.huserid!,
                                latitude: applicationBaseController.deviceLatitude.value
                                    .toString(),
                                longitude: applicationBaseController.deviceLongitude
                                    .value
                                    .toString(),
                                reqDate: formatDateWithTimezone(currentTime,
                                    applicationBaseController.getTimeZone.value),
                                timestamp: DateTime.now().toString(),
                                specialReq: '${formattedQuestions}| ${DateFormat('MMMM dd, yyyy').format(todayDate!)} | ${DateFormat('hh:mm:ss a').format(currentTime)}',
                              );

                              if (result != null) {
                                CustomDialog.cancelLoading(context);
                                var chargeData = json.decode(result);
                                if (chargeData['status'] == 'Success') {
                                  AppWidgets().multiTextAlignYesOrNoDialog(
                                    iconUrl: 'assets/images/headletters.png',
                                    context: context,
                                    dialogMessage: 'Make payment to unravel the life guidance queries',
                                    subText1Key: 'Amount',
                                    subText1Value:
                                    appLoadController.loggedUserData.value.ucurrency,
                                    subText1Value1: applicationBaseController
                                        .formatDecimalString(
                                        chargeData['data']['amount']),
                                    subText2Key: 'Tax Amount',
                                    subText2Value:
                                    appLoadController.loggedUserData.value.ucurrency,
                                    subText2Value2: taxCalc(
                                        chargeData['data']['tax1_amount'],
                                        chargeData['data']['tax3_amount'],
                                        chargeData['data']['tax3_amount']),
                                    subText3Key: 'Total Amount',
                                    subText3Value:
                                    appLoadController.loggedUserData.value.ucurrency,
                                    subText3Value3: applicationBaseController
                                        .formatDecimalString(
                                        chargeData['data']['total_amount']),
                                    cancelText: 'Cancel',
                                    okText: 'Pay Now',
                                    cancelAction: () {
                                      Navigator.pop(context);
                                    },
                                    okAction: () {
                                      if (appLoadController.loggedUserData!.value
                                          .ucurrency!.toLowerCase() ==
                                          'inr') {
                                        paymentController.payByUpi(
                                          appLoadController
                                              .loggedUserData.value!.userid!,
                                          chargeData['data']['requestId'],
                                          chargeData['data']['total_amount'],
                                          appLoadController.loggedUserData!.value.token!,
                                          'special',
                                          context,
                                        );
                                      } else {
                                        paymentController.payByStripe(
                                          appLoadController
                                              .loggedUserData.value!.userid!,
                                          chargeData['data']['requestId'],
                                          chargeData['data']['total_amount'],
                                          'special',
                                          appLoadController.loggedUserData!.value.token!,
                                          context,
                                        );
                                      }
                                    },
                                  );
                                } else if (chargeData['status'] == 'Failure') {
                                  CustomDialog.showAlert(
                                      context, chargeData['errorMessage'], null, 14);
                                }
                              } else {
                                CustomDialog.cancelLoading(context);
                                CustomDialog.showAlert(
                                    context, 'Something went wrong', false, 14);
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}