import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/api/api_callings.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/controllers/request_controller.dart';
import 'package:planetcombo/controllers/planet_transit_controller.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:planetcombo/models/horoscope_list.dart';
import 'package:planetcombo/models/planet_transit.dart';

class PlanetTransit extends StatefulWidget {
  final HoroscopesList horoscope;
  const PlanetTransit({Key? key, required this.horoscope}) : super(key: key);

  @override
  _PlanetTransitState createState() => _PlanetTransitState();
}

class _PlanetTransitState extends State<PlanetTransit> {

  final double width = 32;
  final double height = 32;

  DateTime currentTime = DateTime.now();

  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  final PlanetTransitController planetTransitController =
  Get.put(PlanetTransitController.getInstance(), permanent: true);

  final ApplicationBaseController applicationBaseController =
  Get.put(ApplicationBaseController.getInstance(), permanent: true);

  final HoroscopeRequestController horoscopeRequestController =
  Get.put(HoroscopeRequestController.getInstance(), permanent: true);

  getTitle(){
    if(horoscopeRequestController.selectedRequest.value == 4){
      planetTransitController.sentPlanet.value == 'JU';
      return LocalizationController.getInstance().getTranslatedValue("Transit of Jupiter");
    }else if(horoscopeRequestController.selectedRequest.value == 5){
      planetTransitController.sentPlanet.value == 'SA';
      return LocalizationController.getInstance().getTranslatedValue("Transit of Saturn");
    }else if(horoscopeRequestController.selectedRequest.value == 6){
      planetTransitController.sentPlanet.value == 'RA';
      return LocalizationController.getInstance().getTranslatedValue("Transit of Rahu");
    }else if(horoscopeRequestController.selectedRequest.value == 7){
      planetTransitController.sentPlanet.value == 'KE';
      return LocalizationController.getInstance().getTranslatedValue("Transit of Ketu");
    }else if(horoscopeRequestController.selectedRequest.value == 8){
      planetTransitController.sentPlanet.value == 'MA';
      return LocalizationController.getInstance().getTranslatedValue("Transit of Mars");
    }else if(horoscopeRequestController.selectedRequest.value == 9){
      planetTransitController.sentPlanet.value == 'SU';
      return LocalizationController.getInstance().getTranslatedValue("Transit of Sun");
    }else if(horoscopeRequestController.selectedRequest.value == 10){
      planetTransitController.sentPlanet.value == 'ME';
      return LocalizationController.getInstance().getTranslatedValue("Transit of Mercury");
    }
  }

  getTransit(String planet) async{
    CustomDialog.showLoading(context, 'Please wait');
    var result = await APICallings.getPlanetTransit(planet: planet, token: appLoadController.loggedUserData!.value.token!);
    CustomDialog.cancelLoading(context);
    print(result);
    if(result != null){
      var jsonData = json.decode(result);
      if(jsonData['Status'] == 'Success'){
        if(jsonData['Data'] != null){
            planetTransitController.planet.value = PlanetTransitModel.fromJson(jsonData['Data']);
        }else{
          CustomDialog.showAlert(context, jsonData['Message'], null, 14);
        }
      }else{
        CustomDialog.showAlert(context, 'Something went wrong , please try later', null, 14);
      }
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    currentTime = DateTime.now();
    super.initState();
    if(horoscopeRequestController.selectedRequest.value == 4){
      planetTransitController.sentPlanet.value = 'JU';
    }else if(horoscopeRequestController.selectedRequest.value == 5){
      planetTransitController.sentPlanet.value = 'SA';
    }else if(horoscopeRequestController.selectedRequest.value == 6){
      planetTransitController.sentPlanet.value = 'RA';
    }else if(horoscopeRequestController.selectedRequest.value == 7){
      planetTransitController.sentPlanet.value = 'KE';
    }else if(horoscopeRequestController.selectedRequest.value == 8){
      planetTransitController.sentPlanet.value = 'MA';
    }else if(horoscopeRequestController.selectedRequest.value == 9){
      planetTransitController.sentPlanet.value = 'SU';
    }else if(horoscopeRequestController.selectedRequest.value == 10){
      planetTransitController.sentPlanet.value = 'ME';
    }
    Timer(Duration(milliseconds: 3), () {
      getTransit(planetTransitController.sentPlanet.value);
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(onPressed: () {
          Navigator.pop(context);
        }, icon: const Icon(Icons.chevron_left_rounded),),
        title: getTitle(),
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)], centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            height: 70,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black26,  // Specify your desired color here
                  width: 0.5,          // Specify the width of the border
                ),
              ),
            ),
            child:   Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: widget.horoscope.hnativephoto!,
                      width: width,
                      height: height,
                      placeholder: (context, url) => Image.network(
                        'https://img.freepik.com/free-icon/user_318-159711.jpg',
                        width: width,
                        height: height,
                      ),
                      errorWidget: (context, url, error) => Image.network(
                        'https://img.freepik.com/free-icon/user_318-159711.jpg',
                        width: width,
                        height: height,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  commonBoldText(text: widget.horoscope.hname!, fontSize: 16),
                ],
              ),
            ),
          ),
          Obx(() =>
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(width: MediaQuery.of(context).size.width * 0.4, child: commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Start Date'))),
                        commonBoldText(text: ':  ${DateFormat('MMMM dd, yyyy').format(DateTime.parse(planetTransitController.planet.value.trsdate!))}')
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        SizedBox(width: MediaQuery.of(context).size.width * 0.4, child: commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('End Date'))),
                        commonBoldText(text: ':  ${DateFormat('MMMM dd, yyyy').format(DateTime.parse(planetTransitController.planet.value.tredate!))}')
                      ],
                    ),
                    const SizedBox(height: 15),
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
                    SizedBox(height: 20),
                    Row(
                      children: [
                        commonBoldText(text: '${LocalizationController.getInstance().getTranslatedValue('Details')} :')
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        commonText(text: LocalizationController.getInstance().getTranslatedValue(planetTransitController.planet.value.trdetails!), color: Colors.grey)
                      ],
                    ),
                  ],
                ),
              ))
        ],
      ),
      floatingActionButton: GradientFloatingActionButton(
          onPressed: () {
            // Add your message code here
            print('Message');
            // Navigator.push(
            //     context, MaterialPageRoute(builder: (context) => const AddMessages()));
          },
          gradient: const LinearGradient(
            colors: [Color(0xFFf2b20a), Color(0xFFf34509)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child:
          const Icon(Icons.add, color: Colors.white, size: 24,)
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class GradientFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Gradient gradient;

  GradientFloatingActionButton({
    required this.onPressed,
    required this.child,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(25.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.6),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        child: child,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
