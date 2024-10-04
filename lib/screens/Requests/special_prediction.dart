import 'dart:convert';

import 'package:flutter/material.dart';

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

class SpecialPredictions extends StatefulWidget {
  final HoroscopesList horoscope;
  const SpecialPredictions({Key? key, required  this.horoscope}) : super(key: key);

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


  DateTime currentTime = DateTime.now();

  TextEditingController specialRequest = TextEditingController();

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
        title: LocalizationController.getInstance().getTranslatedValue("Special Predictions"),
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
                  SizedBox(width: MediaQuery.of(context).size.width * 0.4, child: commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Local Time'))),
                  commonBoldText(text: ':  ${DateFormat('hh:mm:ss a').format(currentTime)}')
                ],
              ),
              const SizedBox(height: 15),
              commonText(fontSize: 14, color: Colors.black54, text: LocalizationController.getInstance().getTranslatedValue("Please ask two questions in same category (eg Marriage, Health etc)")),
              const SizedBox(height: 15),
              PrimaryInputText(hintText: '',
                  controller: specialRequest,
                  onValidate: (v){
                return null;
              }, maxLines: 6),
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
                            if(specialRequest.text.isEmpty){
                              showFailedToast('Please enter the request');
                            }else{
                              CustomDialog.showLoading(context, 'Please wait');
                              var result = await APICallings.addSpecialRequest(
                                  token: appLoadController.loggedUserData!.value.token!,
                                  hid: widget.horoscope.hid!.trim(),
                                  userId: widget.horoscope.huserid!,
                                  latitude: applicationBaseController.deviceLatitude.value.toString(),
                                  longitude: applicationBaseController.deviceLongitude.value.toString(),
                                  reqDate: DateFormat('ddMMyy${applicationBaseController.getTimeZone.value}').format(currentTime!),
                                  timestamp:  DateTime.now().toString(),
                                  specialReq: specialRequest.text
                              );
                              CustomDialog.cancelLoading(context);
                              print(result);
                              if(result != null){
                                var chargeData = json.decode(result);
                                if(chargeData['Status'] == 'Success'){
                                  specialRequest.text = "";
                                  if(chargeData['Data'] != null){
                                    CustomDialog.showAlert(context, chargeData['Message'], true, 14);
                                  }else{
                                    CustomDialog.showAlert(context, chargeData['ErrorMessage'], null, 14);
                                  }
                                }else if(chargeData['Status'] == 'Failure'){
                                  CustomDialog.showAlert(context, chargeData['ErrorMessage'], null, 14);
                                }
                              }
                            }
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ))
        ),
      )
    );
  }
}
