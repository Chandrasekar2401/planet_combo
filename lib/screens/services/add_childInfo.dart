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
import 'package:planetcombo/screens/services/add_travelInfo.dart';

class AddChildInfo extends StatefulWidget {
  const AddChildInfo({Key? key}) : super(key: key);

  @override
  _AddChildInfoState createState() => _AddChildInfoState();
}

class _AddChildInfoState extends State<AddChildInfo> {
  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  final AddHoroscopeController addHoroscopeController =
  Get.put(AddHoroscopeController.getInstance(), permanent: true);

  final LocalizationController localizationController =
  Get.put(LocalizationController.getInstance(), permanent: true);

  DateTime? selectedChildBirthDate;
  TimeOfDay? selectedChildBirthTime;

  void _selectWebChildBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedChildBirthDate,
      firstDate: DateTime(addTwelveYears(addHoroscopeController.addHoroscopeBirthSelectedDate!.value)),
      lastDate: DateTime.now(),
      locale: appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'usd' ? const Locale('en', 'US') : const Locale('en', 'GB'),
    );

    if (picked != null && picked != selectedChildBirthDate) {
      setState(() {
        selectedChildBirthDate = picked;
      });
    }
  }

  int addTwelveYears(DateTime date) {
    return date.year + 12;
  }

  Future<void> _selectWebChildBirthTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
    );

    if (picked != null && picked != selectedChildBirthTime) {
      setState(() {
        selectedChildBirthTime = picked;
      });
    }
  }

  void _resetSelectedChildBirthDate() {
    setState(() {
      selectedChildBirthDate = null;
      addHoroscopeController.addSelectedChildBirthDate = null;
    });
  }

  void _resetSelectedChildBirthTime() {
    setState(() {
      selectedChildBirthTime = null;
      addHoroscopeController.addSelectedChildBirthTime = null;
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
              MaterialPageRoute(builder: (context) => Dashboard()),
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
                  commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('First Child (if applicable)')),
                  SizedBox(height: 20),
                  commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Birth Date'), fontSize: 12, color: Colors.black87, textAlign: TextAlign.start),
                  SizedBox(height: 5),
                  InkWell(
                    onTap: () {
                        if(kIsWeb){
                          _selectWebChildBirthDate(context);
                        }else{
                          DatePicker.showDatePicker(
                            context,
                            showTitleActions: true,
                            minTime: DateTime(addTwelveYears(addHoroscopeController.addHoroscopeBirthSelectedDate!.value)),
                            maxTime: DateTime.now(),
                            onChanged: (date) {
                              print('change $date');
                            },
                            onConfirm: (date) {
                              print('onConfirmed date $date');
                              setState(() {
                                selectedChildBirthDate = date;
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
                                  (selectedChildBirthDate == null && addHoroscopeController.addSelectedChildBirthDate == null)
                                      ? LocalizationController.getInstance().getTranslatedValue('Please select date')
                                      : '${LocalizationController.getInstance().getTranslatedValue('Selected date')} :  ${selectedChildBirthDate == null ?DateFormat(
                                      'MMMM dd, yyyy'
                                  ).format(addHoroscopeController.addSelectedChildBirthDate!.value): DateFormat(
                                     'MMMM dd, yyyy'
                                  ).format(selectedChildBirthDate!)}',
                                  style: GoogleFonts.lexend(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  )
                              ),
                              if (selectedChildBirthDate != null ||
                                  addHoroscopeController
                                      .addSelectedChildBirthDate !=
                                      null)
                                IconButton(
                                  onPressed: _resetSelectedChildBirthDate,
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
                  commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Time of Birth'), fontSize: 12, color: Colors.black87, textAlign: TextAlign.start),
                  SizedBox(height: 5),
                  InkWell(
                    onTap: () {
                     if(kIsWeb){
                       _selectWebChildBirthTime(context);
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
                                             selectedChildBirthTime = TimeOfDay.fromDateTime(dateTime);
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
                                  (selectedChildBirthTime == null &&  addHoroscopeController.addSelectedChildBirthTime == null)
                                      ? LocalizationController.getInstance().getTranslatedValue('Please Select Time of Birth')
                                      : '${LocalizationController.getInstance().getTranslatedValue('Selected Time')} : ${selectedChildBirthTime == null ? DateFormat('h:mm a').format(DateTime(2021, 1, 1, addHoroscopeController.addSelectedChildBirthTime!.value.hour, addHoroscopeController.addSelectedChildBirthTime!.value.minute)) : DateFormat('h:mm a').format(DateTime(2021, 1, 1, selectedChildBirthTime!.hour, selectedChildBirthTime!.minute))}',
                                  style: GoogleFonts.lexend(
                                      fontSize: 14,
                                      color: Colors.black54
                                  )
                              ),
                              if (selectedChildBirthTime != null ||
                                  addHoroscopeController
                                      .addSelectedChildBirthTime !=
                                      null)
                                IconButton(
                                  onPressed: _resetSelectedChildBirthTime,
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
                  commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Place, State and Country of Birth'), fontSize: 12, color: Colors.black87, textAlign: TextAlign.start),
                  PrimaryStraightInputText(hintText:
                  LocalizationController.getInstance().getTranslatedValue('Place, State and Country of Birth'),
                    controller: addHoroscopeController.placeStateCountryOfChildBirth,
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
                    if(selectedChildBirthDate != null){
                      addHoroscopeController.addSelectedChildBirthDate = DateTime.now().obs;
                      addHoroscopeController.addSelectedChildBirthDate!.value = selectedChildBirthDate!;
                    }
                    if(selectedChildBirthTime != null){
                      addHoroscopeController.addSelectedChildBirthTime = TimeOfDay.now().obs;
                      addHoroscopeController.addSelectedChildBirthTime!.value = selectedChildBirthTime!;
                    }
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => const AddTravelInfo()));
                    }),
          ),
        ],
      ),
    );
  }
}
