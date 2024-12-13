import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geocoding/geocoding.dart' hide kIsWeb;
import 'package:planetcombo/common/app_widgets.dart';

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
  TextEditingController specialRequest = TextEditingController();
  String _address = 'Loading...';

  @override
  void initState() {
    super.initState();
    currentTime = DateTime.now();
    _getAddressFromLatLng();
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
                style: const TextStyle(fontSize: 15),
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
        title: LocalizationController.getInstance()
            .getTranslatedValue("Ask Life Guidance Question"),
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
                        LocalizationController.getInstance()
                            .getTranslatedValue('Place'),
                        _address,
                      ),
                      _buildInfoRow(
                        LocalizationController.getInstance()
                            .getTranslatedValue('Date'),
                        DateFormat('MMMM dd, yyyy').format(todayDate!),
                      ),
                      _buildInfoRow(
                        LocalizationController.getInstance()
                            .getTranslatedValue('Local Time'),
                        DateFormat('hh:mm:ss a').format(currentTime),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocalizationController.getInstance().getTranslatedValue(
                          "What would you like to know about your future? (2 questions max)"),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    PrimaryInputText(
                      hintText: 'Please ask your question here...',
                      controller: specialRequest,
                      onValidate: (v) => null,
                      maxLines: 6,
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
                        LocalizationController.getInstance()
                            .getTranslatedValue("Cancel"),
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 150,
                    child: GradientButton(
                      title: LocalizationController.getInstance()
                          .getTranslatedValue("Save"),
                      buttonHeight: 45,
                      textColor: Colors.white,
                      buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
                      onPressed: (Offset buttonOffset) async {
                        if (specialRequest.text.isEmpty) {
                          showFailedToast('Please enter the request');
                        } else {
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
                            specialReq: '${specialRequest.text}| ${DateFormat('MMMM dd, yyyy').format(todayDate!)} | ${DateFormat('hh:mm:ss a').format(currentTime)}',
                          );

                          if (result != null) {
                            CustomDialog.cancelLoading(context);
                            var chargeData = json.decode(result);
                            if (chargeData['status'] == 'Success') {
                              specialRequest.text = "";
                              AppWidgets().multiTextAlignYesOrNoDialog(
                                iconUrl: 'assets/images/headletters.png',
                                context: context,
                                dialogMessage:
                                'Special Prediction is created please Pay Now Or Pay Later',
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
                                cancelText: 'Pay Later',
                                okText: 'Pay Now',
                                cancelAction: () {
                                  Navigator.pop(context);
                                  applicationBaseController.updateHoroscopeUiList();
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const HoroscopeServices()),
                                        (Route<dynamic> route) => false,
                                  );
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
                                      context,
                                    );
                                  } else {
                                    paymentController.payByStripe(
                                      appLoadController
                                          .loggedUserData.value!.userid!,
                                      chargeData['data']['requestId'],
                                      chargeData['data']['total_amount'],
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
      ),
    );
  }
}