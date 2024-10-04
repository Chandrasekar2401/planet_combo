import 'dart:ui';

import 'package:flutter/cupertino.dart';
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

class AddWhatsappInfo extends StatefulWidget {
  const AddWhatsappInfo({Key? key}) : super(key: key);

  @override
  _AddWhatsappInfoState createState() => _AddWhatsappInfoState();
}

class _AddWhatsappInfoState extends State<AddWhatsappInfo> {
  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  final AddHoroscopeController addHoroscopeController =
  Get.put(AddHoroscopeController.getInstance(), permanent: true);

  final LocalizationController localizationController =
  Get.put(LocalizationController.getInstance(), permanent: true);

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(onPressed: () { Navigator.pop(context); }, icon: Icon(Icons.chevron_left_rounded),),
        title: LocalizationController.getInstance().getTranslatedValue("Add Horoscope"),
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
                  commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Any call or Whatsapp Message or SMS received date')),
                  SizedBox(height: 20),
                  commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Date of receipt'), fontSize: 12, color: Colors.black87, textAlign: TextAlign.start),
                  SizedBox(height: 5),
                  InkWell(
                    onTap: () {
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
                          Text(
                              (selectedDate == null && addHoroscopeController.addSelectedMessageReceivedDate == null)
                                  ? LocalizationController.getInstance().getTranslatedValue('Please select date')
                                  : '${LocalizationController.getInstance().getTranslatedValue('Selected date')} :  ${selectedDate == null ?DateFormat('dd-MM-yyyy').format(addHoroscopeController.addSelectedMessageReceivedDate!.value): DateFormat('dd-MM-yyyy').format(selectedDate!)}',
                              style: GoogleFonts.lexend(
                                fontSize: 14,
                                color: Colors.black54,
                              )
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
                  commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Exact Time of receipt'), fontSize: 12, color: Colors.black87, textAlign: TextAlign.start),
                  SizedBox(height: 5),
                  InkWell(
                    onTap: () {
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
                          Text(
                              (selectedTime == null &&  addHoroscopeController.addSelectedMessageReceivedTime == null)
                                  ? LocalizationController.getInstance().getTranslatedValue('Please Select Time')
                                  : '${LocalizationController.getInstance().getTranslatedValue('Selected Time')} : ${selectedTime == null ? DateFormat('h:mm a').format(DateTime(2021, 1, 1, addHoroscopeController.addSelectedMessageReceivedTime!.value.hour, addHoroscopeController.addSelectedMessageReceivedTime!.value.minute)) : DateFormat('h:mm a').format(DateTime(2021, 1, 1, selectedTime!.hour, selectedTime!.minute))}',
                              style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  color: Colors.black54
                              )
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
                  commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Place, State and Country where received'), fontSize: 12, color: Colors.black87, textAlign: TextAlign.start),
                  PrimaryStraightInputText(hintText:
                  LocalizationController.getInstance().getTranslatedValue('Place, State and Country where received'),
                    controller: addHoroscopeController.whereMessageReceived,
                    onValidate: (v) {
                      if (v == null || v.isEmpty) {

                      }else{

                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
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
                        addHoroscopeController.addSelectedMessageReceivedDate = DateTime.now().obs;
                        addHoroscopeController.addSelectedMessageReceivedDate!.value = selectedDate!;
                      }
                      if(selectedTime != null){
                        addHoroscopeController.addSelectedMessageReceivedTime = TimeOfDay.now().obs;
                        addHoroscopeController.addSelectedMessageReceivedTime!.value = selectedTime!;
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
