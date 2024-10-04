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


class AddRelativesInfo extends StatefulWidget {
  const AddRelativesInfo({Key? key}) : super(key: key);

  @override
  _AddRelativesInfoState createState() => _AddRelativesInfoState();
}

class _AddRelativesInfoState extends State<AddRelativesInfo> {
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
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _resetEventDate() {
    setState(() {
      selectedDate = null;
      addHoroscopeController.addSelectedEventDate = null;
    });
  }

  void _resetEventTime() {
    setState(() {
      selectedTime = null;
      addHoroscopeController.addSelectedEventTime = null;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Demise of close relatives (if applicable)')),
                  const SizedBox(height: 20),
                  commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Relationship with chart owner'), fontSize: 12, color: Colors.black87, textAlign: TextAlign.start),
                  PrimaryStraightInputText(hintText:
                  LocalizationController.getInstance().getTranslatedValue(''),
                    controller: addHoroscopeController.relationShipWithOwner,
                    onValidate: (v) {
                      if (v == null || v.isEmpty) {

                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Date of event'), fontSize: 12, color: addHoroscopeController.horoscopeBirthDateAlert.value == true ? Colors.red : Colors.black87, textAlign: TextAlign.start),
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
                                  (selectedDate == null && addHoroscopeController.addSelectedEventDate == null)
                                      ? LocalizationController.getInstance().getTranslatedValue('Please select date')
                                      : '${LocalizationController.getInstance().getTranslatedValue('Selected date')} :  ${selectedDate == null ?DateFormat('dd-MM-yyyy').format(addHoroscopeController.addSelectedEventDate!.value): DateFormat('dd-MM-yyyy').format(selectedDate!)}',
                                  style: GoogleFonts.lexend(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  )
                              ),
                              if (selectedDate != null ||
                                  addHoroscopeController
                                      .addSelectedEventDate !=
                                      null)
                                IconButton(
                                  onPressed: _resetEventDate,
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
                  commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Approximate Time of Event'), fontSize: 12, color:addHoroscopeController.horoscopeBirthTimeAlert.value == true ? Colors.red : Colors.black87, textAlign: TextAlign.start),
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
                                  ( selectedTime == null && addHoroscopeController.addSelectedEventTime == null)
                                      ? LocalizationController.getInstance().getTranslatedValue('Please Select Time')
                                      : '${LocalizationController.getInstance().getTranslatedValue('Selected Time')} : ${selectedTime == null ? DateFormat('h:mm a').format(DateTime(2021, 1, 1, addHoroscopeController.addSelectedEventTime!.value.hour, addHoroscopeController.addSelectedEventTime!.value.minute)) : DateFormat('h:mm a').format(DateTime(2021, 1, 1, selectedTime!.hour, selectedTime!.minute))}',
                                  style: GoogleFonts.lexend(
                                      fontSize: 14,
                                      color: Colors.black54
                                  )
                              ),
                              if (selectedTime != null ||
                                  addHoroscopeController
                                      .addSelectedEventTime !=
                                      null)
                                IconButton(
                                  onPressed: _resetEventTime,
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
                  commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Place, State and Country of event'), fontSize: 12, color: addHoroscopeController.horoscopeBirthStateAlert.value == true ? Colors.red : Colors.black87, textAlign: TextAlign.start),
                  PrimaryStraightInputText(hintText:
                  LocalizationController.getInstance().getTranslatedValue('Place, State and Country of event'),
                    controller: addHoroscopeController.eventPlace,
                    onValidate: (v) {
                      if (v == null || v.isEmpty) {

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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: GradientButton(
                      title: LocalizationController.getInstance().getTranslatedValue("Cancel"),buttonHeight: 45, textColor: Colors.white, buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)], onPressed: (Offset buttonOffset){
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const Dashboard()),
                          (Route<dynamic> route) => false,
                    );
                  }),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: GradientButton(
                      title: LocalizationController.getInstance().getTranslatedValue("Save"),buttonHeight: 45, textColor: Colors.white, buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)], onPressed: (Offset buttonOffset){
                    if(selectedDate != null){
                      addHoroscopeController.addSelectedEventDate = DateTime.now().obs;
                      addHoroscopeController.addSelectedEventDate!.value = selectedDate!;
                    }
                    if(selectedTime != null){
                      addHoroscopeController.addSelectedEventTime = TimeOfDay.now().obs;
                      addHoroscopeController.addSelectedEventTime!.value = selectedTime!;
                    }
                    addHoroscopeController.addNewHoroscope(context);
                  }),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
