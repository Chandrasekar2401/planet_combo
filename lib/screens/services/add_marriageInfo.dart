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
import 'package:planetcombo/screens/services/add_childInfo.dart';

class AddMarriageInfo extends StatefulWidget {
  const AddMarriageInfo({Key? key}) : super(key: key);

  @override
  _AddMarriageInfoState createState() => _AddMarriageInfoState();
}

class _AddMarriageInfoState extends State<AddMarriageInfo> {
  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  final AddHoroscopeController addHoroscopeController =
  Get.put(AddHoroscopeController.getInstance(), permanent: true);

  final LocalizationController localizationController =
  Get.put(LocalizationController.getInstance(), permanent: true);

  DateTime? selectedMarriageDate;
  TimeOfDay? selectedMarriageTime;

  void _selectWebMarriageDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedMarriageDate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      locale: appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'usd' ? const Locale('en', 'US') : const Locale('en', 'GB'),
    );

    if (picked != null && picked != selectedMarriageDate) {
      setState(() {
        selectedMarriageDate = picked;
      });
    }
  }

  Future<void> _selectWebTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
    );

    if (picked != null && picked != selectedMarriageTime) {
      setState(() {
        selectedMarriageTime = picked;
      });
    }
  }

  void _resetMarriageDate() {
    setState(() {
      selectedMarriageDate = null;
      addHoroscopeController.addSelectedMarriageDate = null;
    });
  }

  void _resetMarriageTime() {
    setState(() {
      selectedMarriageTime = null;
      addHoroscopeController.addSelectedMarriageTime = null;
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
          icon: Icon(Icons.chevron_left_rounded),
        ),
        title: LocalizationController.getInstance().getTranslatedValue(
            "Add Horoscope (${appLoadController.loggedUserData.value.username})"),
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Dashboard()),
                    (Route<dynamic> route) => false,
              );
            },
            icon: const Icon(Icons.home_outlined),
          )
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
                  commonBoldText(
                      text: LocalizationController.getInstance()
                          .getTranslatedValue('Marriage details (if applicable)')),
                  SizedBox(height: 20),
                  commonBoldText(
                      text: LocalizationController.getInstance()
                          .getTranslatedValue('Date of Marriage'),
                      fontSize: 12,
                      color: Colors.black87,
                      textAlign: TextAlign.start),
                  SizedBox(height: 5),
                  InkWell(
                    onTap: () {
                      if (kIsWeb) {
                        _selectWebMarriageDate(context);
                      } else {
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
                              selectedMarriageDate = date;
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
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  (selectedMarriageDate == null &&
                                      addHoroscopeController
                                          .addSelectedMarriageDate ==
                                          null)
                                      ? LocalizationController.getInstance()
                                      .getTranslatedValue(
                                      'Please select date')
                                      : '${LocalizationController.getInstance().getTranslatedValue('Selected date')} :  ${selectedMarriageDate != null ? DateFormat(
                                      'MMMM dd, yyyy'
                                  ).format(selectedMarriageDate!) : (addHoroscopeController.addSelectedMarriageDate != null ? DateFormat(
                                    'MMMM dd, yyyy'
                                  ).format(addHoroscopeController.addSelectedMarriageDate!.value) : '')}',
                                  style: GoogleFonts.lexend(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (selectedMarriageDate != null ||
                                    addHoroscopeController
                                        .addSelectedMarriageDate !=
                                        null)
                                  IconButton(
                                    onPressed: _resetMarriageDate,
                                    icon: const Icon(Icons.refresh),
                                    iconSize: 14,
                                    color: Colors.red,
                                  )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(Icons.calendar_today,
                                size: 18, color: appLoadController.appMidColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  commonBoldText(
                      text: LocalizationController.getInstance()
                          .getTranslatedValue('Time of Marriage'),
                      fontSize: 12,
                      color: Colors.black87,
                      textAlign: TextAlign.start),
                  SizedBox(height: 5),
                  InkWell(
                    onTap: () {
                      if (kIsWeb) {
                        _selectWebTime(context);
                      } else {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext builder) {
                            return LayoutBuilder(
                              builder: (BuildContext context,
                                  BoxConstraints constraints) {
                                return SizedBox(
                                  height: constraints.maxHeight,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: CupertinoDatePicker(
                                          mode: CupertinoDatePickerMode.time,
                                          initialDateTime: DateTime.now(),
                                          onDateTimeChanged:
                                              (DateTime dateTime) {
                                            setState(() {
                                              selectedMarriageTime =
                                                  TimeOfDay.fromDateTime(
                                                      dateTime);
                                            });
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        height: 50,
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.end,
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
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  (selectedMarriageTime == null &&
                                      addHoroscopeController
                                          .addSelectedMarriageTime ==
                                          null)
                                      ? LocalizationController.getInstance()
                                      .getTranslatedValue(
                                      'Please Select Time of Marriage')
                                      : '${LocalizationController.getInstance().getTranslatedValue('Selected Time')} : ${selectedMarriageTime != null ? DateFormat('h:mm a').format(DateTime(2021, 1, 1, selectedMarriageTime!.hour, selectedMarriageTime!.minute)) : (addHoroscopeController.addSelectedMarriageTime != null ? DateFormat('h:mm a').format(DateTime(2021, 1, 1, addHoroscopeController.addSelectedMarriageTime!.value.hour, addHoroscopeController.addSelectedMarriageTime!.value.minute)) : '')}',
                                  style: GoogleFonts.lexend(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (selectedMarriageTime != null ||
                                    addHoroscopeController
                                        .addSelectedMarriageTime !=
                                        null)
                                  IconButton(
                                    onPressed: _resetMarriageTime,
                                    icon: const Icon(Icons.refresh),
                                    iconSize: 14,
                                    color: Colors.red,
                                  )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(Icons.access_time,
                                size: 18, color: appLoadController.appMidColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  commonBoldText(
                      text: LocalizationController.getInstance().getTranslatedValue(
                          'Place, State and Country of Marriage'),
                      fontSize: 12,
                      color: Colors.black87,
                      textAlign: TextAlign.start),
                  PrimaryStraightInputText(
                    hintText: LocalizationController.getInstance()
                        .getTranslatedValue(
                        'Place, State and Country of Marriage'),
                    controller:
                    addHoroscopeController.placeStateCountryOfMarriage,
                    onChange: (v) {
                      if (v == null || v.isEmpty) {
                      } else {}
                      return null;
                    },
                    onValidate: (v) {
                      if (v == null || v.isEmpty) {
                      } else {}
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: GradientButton(
              title: LocalizationController.getInstance()
                  .getTranslatedValue("Next"),
              buttonHeight: 45,
              textColor: Colors.white,
              buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
              onPressed: (Offset buttonOffset) {
                if (selectedMarriageDate != null) {
                  addHoroscopeController.addSelectedMarriageDate =
                      DateTime.now().obs;
                  addHoroscopeController.addSelectedMarriageDate!.value =
                  selectedMarriageDate!;
                }
                if (selectedMarriageTime != null) {
                  addHoroscopeController.addSelectedMarriageTime =
                      TimeOfDay.now().obs;
                  addHoroscopeController.addSelectedMarriageTime!.value =
                  selectedMarriageTime!;
                }
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const AddChildInfo()));
              },
            ),
          ),
        ],
      ),
    );
  }
}