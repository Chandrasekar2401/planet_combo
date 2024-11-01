import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/add_horoscope_controller.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:planetcombo/screens/dashboard.dart';

import 'package:planetcombo/screens/services/add_relatives.dart';

class AddTravelInfo extends StatefulWidget {
  const AddTravelInfo({Key? key}) : super(key: key);

  @override
  _AddTravelInfoState createState() => _AddTravelInfoState();
}

class _AddTravelInfoState extends State<AddTravelInfo> {
  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  final AddHoroscopeController addHoroscopeController =
  Get.put(AddHoroscopeController.getInstance(), permanent: true);

  final LocalizationController localizationController =
  Get.put(LocalizationController.getInstance(), permanent: true);

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  void _selectWebDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      locale: appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'usd' ? const Locale('en', 'US') : const Locale('en', 'GB'),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectWebTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _resetTravelDate() {
    setState(() {
      selectedDate = null;
      addHoroscopeController.addSelectedTravelDate = null;
    });
  }

  void _resetTravelTime() {
    setState(() {
      selectedTime = null;
      addHoroscopeController.addSelectedTravelTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(onPressed: () { Navigator.pop(context); }, icon: Icon(Icons.chevron_left_rounded),),
        title: LocalizationController.getInstance().getTranslatedValue("Add Horoscope (${appLoadController.loggedUserData.value.username})"),
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)], centerTitle: true,
        actions: [
          IconButton(onPressed: (){
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Dashboard()),
                  (Route<dynamic> route) => false,
            );
          }, icon: const Icon(Icons.home_outlined))
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Any abroad travel date (if applicable)')),
                  SizedBox(height: 20),
                  commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Date of Travel'), fontSize: 12, color: Colors.black87, textAlign: TextAlign.start),
                  SizedBox(height: 5),
                  InkWell(
                    onTap: () {
                      if(kIsWeb){
                        _selectWebDate(context);
                      }else{
                        DatePicker.showDatePicker(
                          context,
                          showTitleActions: true,
                          minTime: DateTime(1920),
                          maxTime: DateTime.now(),
                          onChanged: (date) {
                            print('change $date');
                          },
                          onConfirm: (date) {
                            print('onConfirmed date $date');
                            setState(() {
                              selectedDate = date;
                            });
                          },
                          currentTime: DateTime.now(),
                          locale: LocaleType.en,
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: appLoadController.appMidColor,
                                width: 1
                            )
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                  (selectedDate == null && addHoroscopeController.addSelectedTravelDate == null)
                                      ? LocalizationController.getInstance().getTranslatedValue('Please select date')
                                      : '${LocalizationController.getInstance().getTranslatedValue('Selected date')} :  ${selectedDate == null ?DateFormat('MMMM dd, yyyy').format(addHoroscopeController.addSelectedTravelDate!.value): DateFormat('MMMM dd, yyyy').format(selectedDate!)}',
                                  style: GoogleFonts.lexend(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  )
                              ),
                              if (selectedDate != null ||
                                  addHoroscopeController
                                      .addSelectedTravelDate !=
                                      null)
                                IconButton(
                                  onPressed: _resetTravelDate,
                                  icon: const Icon(Icons.refresh),
                                  iconSize: 14,
                                  color: Colors.red,
                                )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(Icons.calendar_today, size: 18, color: appLoadController.appMidColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Approximate take off time'), fontSize: 12, color:Colors.black87, textAlign: TextAlign.start),
                  SizedBox(height: 5),
                  InkWell(
                    onTap: () {
                      if(kIsWeb){
                        _selectWebTime(context);
                      }else{
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext builder) {
                            return LayoutBuilder(
                              builder: (BuildContext context, BoxConstraints constraints) {
                                return SizedBox(
                                  height: constraints.maxHeight,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: CupertinoDatePicker(
                                          mode: CupertinoDatePickerMode.time,
                                          initialDateTime: DateTime.now(),
                                          onDateTimeChanged: (DateTime dateTime) {
                                            setState(() {
                                              selectedTime = TimeOfDay.fromDateTime(dateTime);
                                            });
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        height: 50,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('OK'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: appLoadController.appMidColor,
                                  width: 1
                              )
                          )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                  (selectedTime == null && addHoroscopeController.addSelectedTravelTime == null)
                                      ? LocalizationController.getInstance().getTranslatedValue('Select a Time')
                                      : '${LocalizationController.getInstance().getTranslatedValue('Selected Time')} : ${selectedTime == null ? DateFormat('h:mm a').format(DateTime(2021, 1, 1, addHoroscopeController.addSelectedTravelTime!.value.hour, addHoroscopeController.addSelectedTravelTime!.value.minute)) : DateFormat('h:mm a').format(DateTime(2021, 1, 1, selectedTime!.hour, selectedTime!.minute))}',
                                  style: GoogleFonts.lexend(
                                      fontSize: 14,
                                      color: Colors.black54
                                  )
                              ),
                              if (selectedTime != null ||
                                  addHoroscopeController
                                      .addSelectedTravelTime !=
                                      null)
                                IconButton(
                                  onPressed: _resetTravelTime,
                                  icon: const Icon(Icons.refresh),
                                  iconSize: 14,
                                  color: Colors.red,
                                )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(Icons.access_time, size: 18, color: appLoadController.appMidColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Where did you travel from (recent abroad travel)'), fontSize: 12, color: Colors.black87, textAlign: TextAlign.start),
                  PrimaryStraightInputText(hintText:
                  LocalizationController.getInstance().getTranslatedValue('Where did you travel from (recent abroad travel)'),
                    controller: addHoroscopeController.whereDidYouTraveled,
                    onChange: (v){
                      if (v == null || v.isEmpty) {

                      }else{

                      }
                      return null;
                    },
                    onValidate: (v) {
                      if (v == null || v.isEmpty) {

                      }else{

                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: GradientButton(
                  title: LocalizationController.getInstance().getTranslatedValue("Next"),buttonHeight: 45, textColor: Colors.white, buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)], onPressed: (Offset buttonOffset){
                if(selectedDate != null){
                  addHoroscopeController.addSelectedTravelDate = DateTime.now().obs;
                  addHoroscopeController.addSelectedTravelDate!.value = selectedDate!;
                }
                if(selectedTime != null){
                  addHoroscopeController.addSelectedTravelTime = TimeOfDay.now().obs;
                  addHoroscopeController.addSelectedTravelTime!.value = selectedTime!;
                }
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const AddRelativesInfo()));
              }),
          ),
        ],
      ),
    );
  }
}
