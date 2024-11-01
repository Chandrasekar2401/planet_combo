import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geocoding/geocoding.dart' hide kIsWeb;

import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/screens/dashboard.dart';
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
    const apiKey = 'AIzaSyCXAw8BQBx4OPMOWyNaI4bv7gh5GUXa0lQ'; // Replace with your actual API key
    // final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';
    final url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=3';
  print('the api url bady for maps $url');
    try {
      final response = await http.get(Uri.parse(url));
      print('the location response ${response.body}');
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        final address =  decodedResponse['address']['country'] ?? 'Unknown';
        return address;
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
        return '${place.locality}, ${place.administrativeArea}, ${place.country}';
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
  TextEditingController specialRequest = TextEditingController();
  String _address = 'Loading...';

  String formatDateWithTimezone(DateTime date, String timezone) {
    DateFormat formatter = DateFormat("yyyy-MM-dd HH:mm:ss.SSS");
    String formattedDate = formatter.format(date);
    return '$formattedDate$timezone';
  }

  double taxCalc(double tax1, double tax2, double tax3) {
    return tax1 + tax2 + tax3;
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GradientAppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          title: LocalizationController.getInstance().getTranslatedValue("Ask Life Guidance Question"),
          colors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
          centerTitle: true,
          actions: [
            Row(
              children: [
                const Icon(Icons.payment_outlined, color: Colors.white, size: 16),
                // commonBoldText(text: 'Currency(', color: Colors.white, fontSize: 12),
                commonBoldText(text: ' - ${appLoadController.loggedUserData.value.ucurrency!}', color: Colors.white, fontSize: 12),
                const SizedBox(width: 10)
              ],
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Obx(() => Column(
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
                    SizedBox(width: MediaQuery.of(context).size.width * 0.4, child: commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Country'))),
                    Expanded(child: commonBoldText(text: ':  $_address'))
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    SizedBox(width: MediaQuery.of(context).size.width * 0.4, child: commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Local Time'))),
                    commonBoldText(text: ':  ${DateFormat('hh:mm:ss a').format(currentTime)}')
                  ],
                ),
                const SizedBox(height: 15),
                commonText(fontSize: 14, color: Colors.black54, text: LocalizationController.getInstance().getTranslatedValue("What would you like to know about your future? (2 questions max)")),
                const SizedBox(height: 15),
                PrimaryInputText(
                    hintText: 'Please ask your question here...',
                    controller: specialRequest,
                    onValidate: (v) {
                      return null;
                    },
                    maxLines: 6
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: 150,
                        child: GradientButton(
                            title: LocalizationController.getInstance().getTranslatedValue("Cancel"),
                            buttonHeight: 45,
                            textColor: Colors.white,
                            buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
                            onPressed: (Offset buttonOffset) {
                              Navigator.pop(context);
                            }
                        ),
                      ),
                      SizedBox(width: 20),
                      SizedBox(
                        width: 150,
                        child: GradientButton(
                            title: LocalizationController.getInstance().getTranslatedValue("Save"),
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
                                    latitude: applicationBaseController.deviceLatitude.value.toString(),
                                    longitude: applicationBaseController.deviceLongitude.value.toString(),
                                    reqDate: formatDateWithTimezone(currentTime, applicationBaseController.getTimeZone.value),
                                    timestamp: DateTime.now().toString(),
                                    specialReq: specialRequest.text
                                );
                                print('the result after adding the special req ${result.toString()}');
                                if (result != null) {
                                  CustomDialog.cancelLoading(context);
                                  var chargeData = json.decode(result);
                                  if (chargeData['status'] == 'Success') {
                                    specialRequest.text = "";
                                    multiTextYesOrNoDialog(
                                        context: context,
                                        dialogMessage: 'Special Prediction is created please Pay Now Or Pay Later',
                                        subText1Key: 'Amount',
                                        subText1Value: '${appLoadController.loggedUserData.value.ucurrency} ${applicationBaseController.formatDecimalString(chargeData['data']['amount'])}',
                                        subText2Key: 'Tax Amount',
                                        subText2Value: '${appLoadController.loggedUserData.value.ucurrency} ${taxCalc(chargeData['data']['tax1_amount'], chargeData['data']['tax3_amount'], chargeData['data']['tax3_amount'])}',
                                        subText3Key: 'Total Amount',
                                        subText3Value: '${appLoadController.loggedUserData.value.ucurrency} ${applicationBaseController.formatDecimalString(chargeData['data']['total_amount'])}',
                                        cancelText: 'Pay Later',
                                        okText: 'Pay Now',
                                        cancelAction: () {
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
                                            paymentController.payByUpi(
                                                appLoadController.loggedUserData.value!.userid!,
                                                chargeData['data']['requestId'],
                                                chargeData['data']['total_amount'],
                                                appLoadController.loggedUserData!.value.token!,
                                                context
                                            );
                                          }else{
                                            paymentController.payByPaypal(
                                                appLoadController.loggedUserData.value!.userid!,
                                                chargeData['data']['requestId'],
                                                chargeData['data']['total_amount'],
                                                appLoadController.loggedUserData!.value.token!,
                                                context
                                            );
                                          }
                                        }
                                    );
                                  } else if (chargeData['status'] == 'Failure') {
                                    CustomDialog.showAlert(context, chargeData['errorMessage'], null, 14);
                                  }
                                } else {
                                  CustomDialog.cancelLoading(context);
                                  CustomDialog.showAlert(context, 'Something went wrong', false, 14);
                                }
                              }
                            }
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
          ),
        )
    );
  }
}