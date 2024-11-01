import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:planetcombo/api/api_callings.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:get/get.dart';
import 'package:flutter/rendering.dart';
import 'package:planetcombo/screens/predictions/predictions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
//controllers
import 'package:planetcombo/controllers/request_controller.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/controllers/add_horoscope_controller.dart';
import 'package:planetcombo/controllers/horoscope_services.dart';

//screens
import 'package:planetcombo/screens/Requests/daily_prediction.dart';
import 'package:planetcombo/screens/Requests/special_prediction.dart';
import 'package:planetcombo/screens/Requests/planet_transit.dart';
import 'package:planetcombo/screens/services/add_nativePhoto.dart';
import 'package:planetcombo/screens/services/add_primaryInfo.dart';
import 'package:planetcombo/screens/dashboard.dart';

import 'package:planetcombo/screens/messages/message_list.dart';




class HoroscopeServices extends StatefulWidget {
  const HoroscopeServices({Key? key}) : super(key: key);

  @override
  _HoroscopeServicesState createState() => _HoroscopeServicesState();
}

class _HoroscopeServicesState extends State<HoroscopeServices> {
  final double width = 32;
  final double height = 32;

  final LocalizationController localizationController =
  Get.put(LocalizationController.getInstance(), permanent: true);

  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  final ApplicationBaseController applicationBaseController =
  Get.put(ApplicationBaseController.getInstance(), permanent: true);

  final HoroscopeRequestController horoscopeRequestController =
  Get.put(HoroscopeRequestController.getInstance(), permanent: true);

  final AddHoroscopeController addHoroscopeController =
  Get.put(AddHoroscopeController.getInstance(), permanent: true);

  final HoroscopeServiceController horoscopeServiceController =
  Get.put(HoroscopeServiceController.getInstance(), permanent: true);

  @override
  void dispose() {
    // Ensure _isLoading is false when the widget is disposed
    horoscopeServiceController.isLoading.value = false;
    super.dispose();
  }

  Future<void> _getUserPredictions(String hid) async {
      horoscopeServiceController.isLoading.value = true;
      CustomDialog.showLoading(context, 'Please wait');
      try {
        var result = await horoscopeServiceController.getUserPredictions(hid).timeout(Duration(seconds: 30));
      } on TimeoutException catch (_) {
        // Handle timeout
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request timed out, please try again.')),
        );
      } catch (error) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $error')),
        );
      } finally {
        if (mounted) {
          CustomDialog.cancelLoading(context);
          horoscopeServiceController.isLoading.value = false;
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Predictions()));
        }
      }
    }

  void deleteHoroscope(String userId, String hid) async{
    CustomDialog.showLoading(context, 'Please wait');
    var result = await APICallings.deleteHoroscope(userId: userId, hId: hid.trim(), token: appLoadController.loggedUserData!.value.token!);
    CustomDialog.cancelLoading(context);
    var jsondata = jsonDecode(result!);
    print('The recevied result is $jsondata');
    applicationBaseController.updateHoroscopeUiList();
  }

  void viewHoroscope(String userId, String hid) async{
    CustomDialog.showLoading(context, 'Please wait');
    var result = await APICallings.viewHoroscopeChart(userId: userId, hId: hid.trim(), token: appLoadController.loggedUserData!.value.token!);
    print('the value of result is $result');
    CustomDialog.cancelLoading(context);
    var jsondata = jsonDecode(result!);
    if(jsondata['status'] == 'Success'){
      if(jsondata['data'] == 'undefined' || jsondata['data'] == null || jsondata['data'] == ""){
        CustomDialog.showAlert(context, 'Chart is not ready yet', false, 14);
      }else{
          String htmlLink = jsondata['data'];
          if (!await launchUrl(Uri.parse(htmlLink))) {
            throw Exception('Could not launch $htmlLink');
          }
      }
    }
  }

  void emailHoroscope(String userId, String hid) async {
    CustomDialog.showLoading(context, 'Please wait');

    try {
      var result = await APICallings.emailChart(
          userId: userId,
          hId: hid.trim(),
          token: appLoadController.loggedUserData!.value.token!
      );

      print('The value of result is $result');

      CustomDialog.cancelLoading(context);

      if (result.startsWith('2')) { // Successful response
        var jsonData = json.decode(result);
        if (jsonData['status'] == 'Success') {
          CustomDialog.showAlert(context, jsonData['message'], true, 14);
        } else {
          CustomDialog.showAlert(context, jsonData['errorMessage'] ?? 'Unknown error occurred', false, 14);
        }
      } else {
        // Handle various error scenarios
        switch (result) {
          case '403 Forbidden: Server denied access':
            CustomDialog.showAlert(context, 'Access denied. Please check your credentials.', false, 14);
            break;
          case '404 Not Found: The requested resource could not be found':
            CustomDialog.showAlert(context, 'The requested chart could not be found.', false, 14);
            break;
          case '500 Internal Server Error: Something went wrong on the server':
            CustomDialog.showAlert(context, 'Server error. Please try again later.', false, 14);
            break;
          case 'Request timed out after 10 seconds':
            CustomDialog.showAlert(context, 'The request timed out. Please check your internet connection and try again.', false, 14);
            break;
          default:
            if (result.startsWith('Network error:')) {
              CustomDialog.showAlert(context, 'Network error. Please check your internet connection.', false, 14);
            } else if (result == 'Invalid response format from the server') {
              CustomDialog.showAlert(context, 'Received an invalid response from the server. Please try again.', false, 14);
            } else {
              CustomDialog.showAlert(context, 'An unexpected error occurred: $result', false, 14);
            }
        }
      }
    } catch (e) {
      CustomDialog.cancelLoading(context);
      CustomDialog.showAlert(context, 'An unexpected error occurred: $e', false, 14);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  String convertDateFormat(String inputDate) {
    // Parse the input date string
    DateTime parsedDate = DateTime.parse(inputDate);

    // Format the date into dd/MM/yyyy format

    String formattedDate = DateFormat('MMMM dd, yyyy').format(parsedDate);

    return formattedDate;
  }


  @override
  Widget build(BuildContext context) {
    return Builder(builder: (BuildContext buttonContext){
      return PopScope(
        canPop: true,
        child: Scaffold(
          appBar: GradientAppBar(
            leading: IconButton(onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Dashboard()),
                    (Route<dynamic> route) => false,
              );
            }, icon: const Icon(Icons.chevron_left_rounded),),
            title: LocalizationController.getInstance().getTranslatedValue("Horoscope Services (${appLoadController.loggedUserData.value.username})"),
            colors: const [Color(0xFFf2b20a), Color(0xFFf34509)], centerTitle: true,
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
          body: Obx(() =>
              applicationBaseController.horoscopeListPageLoad.value == true ? const Center(child: CircularProgressIndicator()):
              Column(
            children: [
              Container(
                height: 65,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 3,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                        width: localizationController.currentLanguage.value == 'ta' ? 215 : 165,
                        child: GradientButton(title: LocalizationController.getInstance().getTranslatedValue("Add Horoscope"), textColor: Colors.white, buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)], onPressed: (Offset buttonOffset) {
                          addHoroscopeController.refreshAlerts();
                          // Navigator.push(
                          //     context, MaterialPageRoute(builder: (context) => const AddNativePhoto()));
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) => const AddPrimary()));
                        }, materialIcon: Icons.add, materialIconSize: 21)),
                    const SizedBox(width: 15)
                  ],
                ),
              ),
              applicationBaseController.horoscopeList.isEmpty ? Expanded(
                child: Center(
                  child:
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    child: commonText(
                        textAlign: TextAlign.center,
                        text: 'Horoscope list is empty, please click the add button to add horoscope',
                        color: Colors.black26, fontSize: 12
                    ),
                  ),
                ),
              ): Expanded(
                child: ListView.builder(
                  itemCount: applicationBaseController.horoscopeList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey,
                            width: 0.2, // Specify the thickness of the border
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 7),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: applicationBaseController.horoscopeList[index].hnativephoto!,
                                    width: width,
                                    height: height,
                                    placeholder: (context, url) => Image.network(
                                      'https://thumbs.dreamstime.com/b/default-avatar-profile-icon-vector-social-media-user-portrait-176256935.jpg',
                                      width: width,
                                      height: height,
                                      fit: BoxFit.cover,
                                    ),
                                    errorWidget: (context, url, error) => Image.network(
                                      'https://thumbs.dreamstime.com/b/default-avatar-profile-icon-vector-social-media-user-portrait-176256935.jpg',
                                      width: width,
                                      height: height,
                                      fit: BoxFit.cover,
                                    ),
                                    imageBuilder: (context, imageProvider) => Container(
                                      width: width,
                                      height: height,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    commonBoldText(text: applicationBaseController.horoscopeList[index].hname!, fontSize: 14),
                                    commonText(text: 'DOB: ${convertDateFormat(applicationBaseController.horoscopeList[index].hdobnative!.substring(0, applicationBaseController.horoscopeList[index].hdobnative!.indexOf("T")))}', color: Colors.black38, fontSize: 11)
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: GradientButton(title: LocalizationController.getInstance().getTranslatedValue("Plans"),buttonHeight: 30, textColor: Colors.white, buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)], onPressed: (Offset buttonOffset) async{
                                      if(applicationBaseController.horoscopeList[index].hstatus == '5'){
                                       if(horoscopeRequestController.deviceCurrentLocationFound.value == true){
                                         final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
                                         final RelativeRect position = RelativeRect.fromRect(
                                           Rect.fromPoints(
                                             buttonOffset,
                                             buttonOffset + buttonOffset, // buttonSize is the size of the button
                                           ),
                                           Offset.zero & overlay.size, // Overlay size
                                         );
                                         final selectedValue = await showMenu(
                                           context: context,
                                           position: position,
                                           items: [
                                             PopupMenuItem(
                                               value: 1,
                                               child: commonText(text: LocalizationController.getInstance().getTranslatedValue("90-day Prediction"), fontSize: 14),
                                             ),
                                             PopupMenuItem(
                                               value: 3,
                                               child: commonText(text: LocalizationController.getInstance().getTranslatedValue("Life Guidance Questions"), fontSize: 14),
                                             )
                                           ],
                                         );

                                         if (selectedValue != null) {
                                           switch (selectedValue) {
                                             case 1:
                                               horoscopeRequestController.selectedRequest.value = 1;
                                               Navigator.push(
                                                 context,
                                                 MaterialPageRoute(builder: (context) => DailyPredictions(horoscope: applicationBaseController.horoscopeList[index])),
                                               );
                                               break;
                                             case 2:
                                               horoscopeRequestController.selectedRequest.value = 2;
                                               Navigator.push(
                                                 context,
                                                 MaterialPageRoute(builder: (context) => DailyPredictions(horoscope: applicationBaseController.horoscopeList[index])),
                                               );
                                               break;
                                             case 3:
                                               horoscopeRequestController.selectedRequest.value = 3;
                                               Navigator.push(
                                                 context,
                                                 MaterialPageRoute(builder: (context) => SpecialPredictions(horoscope: applicationBaseController.horoscopeList[index])),
                                               );
                                               break;
                                             case 4:
                                               horoscopeRequestController.selectedRequest.value = 4;
                                               Navigator.push(
                                                 context,
                                                 MaterialPageRoute(builder: (context) => PlanetTransit(horoscope: applicationBaseController.horoscopeList[index])),
                                               );
                                               break;
                                             case 5:
                                               Navigator.push(
                                                 context,
                                                 MaterialPageRoute(builder: (context) => MessagesList(horoscopeId: applicationBaseController.horoscopeList[index].hid!,)),
                                               );
                                               break;
                                             case 6:
                                               horoscopeRequestController.selectedRequest.value = 6;
                                               Navigator.push(
                                                 context,
                                                 MaterialPageRoute(builder: (context) => PlanetTransit(horoscope: applicationBaseController.horoscopeList[index])),
                                               );
                                               break;
                                             case 7:
                                               horoscopeRequestController.selectedRequest.value = 7;
                                               Navigator.push(
                                                 context,
                                                 MaterialPageRoute(builder: (context) => PlanetTransit(horoscope: applicationBaseController.horoscopeList[index])),
                                               );
                                               break;
                                             case 8:
                                               horoscopeRequestController.selectedRequest.value = 8;
                                               Navigator.push(
                                                 context,
                                                 MaterialPageRoute(builder: (context) => PlanetTransit(horoscope: applicationBaseController.horoscopeList[index])),
                                               );
                                               break;
                                             case 9:
                                               horoscopeRequestController.selectedRequest.value = 9;
                                               Navigator.push(
                                                 context,
                                                 MaterialPageRoute(builder: (context) => PlanetTransit(horoscope: applicationBaseController.horoscopeList[index])),
                                               );
                                               break;
                                             case 10:
                                               horoscopeRequestController.selectedRequest.value = 10;
                                               Navigator.push(
                                                 context,
                                                 MaterialPageRoute(builder: (context) => PlanetTransit(horoscope: applicationBaseController.horoscopeList[index])),
                                               );
                                               break;
                                           }
                                         }
                                       }else{
                                         CustomDialog.showLoading(context, 'Please wait');
                                        var request = await horoscopeRequestController.getCurrentLocation(context);
                                        print('the received value of request $request');
                                        if(request == true){
                                          print('the true value is occured');
                                          final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
                                          final RelativeRect position = RelativeRect.fromRect(
                                            Rect.fromPoints(
                                              buttonOffset,
                                              buttonOffset + buttonOffset, // buttonSize is the size of the button
                                            ),
                                            Offset.zero & overlay.size, // Overlay size
                                          );
                                          final selectedValue = await showMenu(
                                            context: context,
                                            position: position,
                                            items: [
                                              PopupMenuItem(
                                                value: 1,
                                                child: commonText(text: LocalizationController.getInstance().getTranslatedValue("90-day Prediction"), fontSize: 14),
                                              ),
                                              PopupMenuItem(
                                                value: 3,
                                                child: commonText(text: LocalizationController.getInstance().getTranslatedValue("Life Guidance Questions"), fontSize: 14),
                                              ),
                                            ],
                                          );

                                          if (selectedValue != null) {
                                            switch (selectedValue) {
                                              case 1:
                                                horoscopeRequestController.selectedRequest.value = 2;
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => DailyPredictions(horoscope: applicationBaseController.horoscopeList[index])),
                                                );
                                                break;
                                              case 2:
                                                horoscopeRequestController.selectedRequest.value = 3;
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => DailyPredictions(horoscope: applicationBaseController.horoscopeList[index])),
                                                );
                                                break;
                                              case 3:
                                                horoscopeRequestController.selectedRequest.value = 3;
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => SpecialPredictions(horoscope: applicationBaseController.horoscopeList[index])),
                                                );
                                                break;
                                              case 4:
                                                horoscopeRequestController.selectedRequest.value = 4;
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => PlanetTransit(horoscope: applicationBaseController.horoscopeList[index])),
                                                );
                                                break;
                                              case 5:
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => MessagesList(horoscopeId: applicationBaseController.horoscopeList[index].hid!,)),
                                                );
                                                break;
                                              case 6:
                                                horoscopeRequestController.selectedRequest.value = 6;
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => PlanetTransit(horoscope: applicationBaseController.horoscopeList[index])),
                                                );
                                                break;
                                              case 7:
                                                horoscopeRequestController.selectedRequest.value = 7;
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => PlanetTransit(horoscope: applicationBaseController.horoscopeList[index])),
                                                );
                                                break;
                                              case 8:
                                                horoscopeRequestController.selectedRequest.value = 8;
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => PlanetTransit(horoscope: applicationBaseController.horoscopeList[index])),
                                                );
                                                break;
                                              case 9:
                                                horoscopeRequestController.selectedRequest.value = 9;
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => PlanetTransit(horoscope: applicationBaseController.horoscopeList[index])),
                                                );
                                                break;
                                              case 10:
                                                horoscopeRequestController.selectedRequest.value = 10;
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => PlanetTransit(horoscope: applicationBaseController.horoscopeList[index])),
                                                );
                                                break;
                                            }
                                          }
                                        }
                                       }
                                      }else{
                                        CustomDialog.showAlert(context, LocalizationController.getInstance().getTranslatedValue("Chart is not ready yet"),null, 14);
                                      }
                                  }),
                                ),
                                Expanded(
                                  child: GradientButton(title: LocalizationController.getInstance().getTranslatedValue("Predictions"), buttonHeight: 30, textColor: Colors.white, buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)], onPressed: (Offset buttonOffset) async{
                                    if(applicationBaseController.horoscopeList[index].hstatus == '5'){
                                           _getUserPredictions(applicationBaseController.horoscopeList[index].hid!.trim());
                                      }else{
                                      CustomDialog.showAlert(context, LocalizationController.getInstance().getTranslatedValue("Prediction is yet to be generated"),null, 14);
                                    }
                                  }),
                                ),
                                Expanded(
                                  child: GradientButton(title: LocalizationController.getInstance().getTranslatedValue("Chart"),buttonHeight: 30, textColor: Colors.white, buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
                                      onPressed: (Offset buttonOffset) async {
                                        final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
                                        final RelativeRect position = RelativeRect.fromRect(
                                          Rect.fromPoints(
                                            buttonOffset,
                                            buttonOffset + buttonOffset, // buttonSize is the size of the button
                                          ),
                                          Offset.zero & overlay.size, // Overlay size
                                        );
                                        final selectedValue = await showMenu(
                                          context: context,
                                          position: position,
                                          items: [
                                            PopupMenuItem(
                                              value: 1,
                                              child: commonText(text: LocalizationController.getInstance().getTranslatedValue('Show Horoscope'), fontSize: 14),
                                            ),
                                            PopupMenuItem(
                                              value: 2,
                                              child: commonText(text: LocalizationController.getInstance().getTranslatedValue('Edit Horoscope'), fontSize: 14),
                                            ),
                                            PopupMenuItem(
                                              value: 3,
                                              child: commonText(text: LocalizationController.getInstance().getTranslatedValue('Email Horoscope'), fontSize: 14),
                                            ),
                                            if(applicationBaseController.horoscopeList[index].isPaid != "true")PopupMenuItem(
                                              value: 4,
                                              child: commonText(text: LocalizationController.getInstance().getTranslatedValue('Delete Horoscope'), fontSize: 14),
                                            ),
                                            if(applicationBaseController.horoscopeList[index].isPaid == "true")PopupMenuItem(
                                              value: 5,
                                              child: commonText(text: LocalizationController.getInstance().getTranslatedValue('Messages'), fontSize: 14),
                                            ),
                                          ],
                                        );
                                  
                                        if (selectedValue != null) {
                                          switch (selectedValue) {
                                            case 1:
                                              print('selected value is 1 ${applicationBaseController.horoscopeList[index].hid}');
                                              // Handle Menu 1 option
                                              viewHoroscope(
                                                applicationBaseController.horoscopeList[index].huserid!,
                                                applicationBaseController.horoscopeList[index].hid!.trim(),
                                              );
                                              break;
                                            case 2:
                                              if(applicationBaseController.horoscopeList[index].hstatus == "1"){
                                                addHoroscopeController.editHoroscope(applicationBaseController.horoscopeList[index]);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => const AddPrimary()),
                                                );
                                              }else{
                                                CustomDialog.showAlert(context, "You cant edit this chart because chart already generated", false, 12);
                                              }
                                              break;
                                            case 3:
                                              print('selected value is 3');
                                              // Handle Menu 3 option
                                              emailHoroscope(
                                                applicationBaseController.horoscopeList[index].huserid!,
                                                applicationBaseController.horoscopeList[index].hid!.trim(),
                                              );
                                              break;
                                            case 4:
                                              print('selected value is 4');
                                              yesOrNoDialog(
                                                context: context,
                                                cancelAction: (){
                                                  Navigator.pop(context);
                                                },
                                                dialogMessage: 'Are you sure you want to delete this horoscope?',
                                                cancelText: 'No',
                                                okText: 'Yes',
                                                okAction: () {
                                                  Navigator.pop(context);
                                                  deleteHoroscope(
                                                    applicationBaseController.horoscopeList[index].huserid!,
                                                    applicationBaseController.horoscopeList[index].hid!.trim(),
                                                  );
                                                },
                                              );
                                              // Handle Menu 3 option
                                              break;
                                            case 5:
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => MessagesList(horoscopeId: applicationBaseController.horoscopeList[index].hid!)),
                                                );
                                          }
                                        }
                                      }),
                                ),
                                ],
                            ),
                            const SizedBox(height: 6),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          )),
        ),
      );
    });
  }
}