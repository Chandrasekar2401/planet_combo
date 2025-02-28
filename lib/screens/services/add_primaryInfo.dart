import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/common/place_autocomplete.dart';
import 'package:planetcombo/controllers/add_horoscope_controller.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:planetcombo/screens/services/add_marriageInfo.dart';
import 'package:planetcombo/screens/dashboard.dart';

import '../../common/place_autocomple_mobile.dart';


class AddPrimary extends StatefulWidget {
  const AddPrimary({Key? key}) : super(key: key);

  @override
  _AddPrimaryState createState() => _AddPrimaryState();
}

class _AddPrimaryState extends State<AddPrimary> {
  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  final AddHoroscopeController addHoroscopeController =
  Get.put(AddHoroscopeController.getInstance(), permanent: true);

  final LocalizationController localizationController =
  Get.put(LocalizationController.getInstance(), permanent: true);

  var formKey = GlobalKey<FormState>();

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
      body: SingleChildScrollView(
        child: Obx(() =>
            Padding(
              padding: const EdgeInsets.all(0),
              child: Form(
          key: formKey,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Name or Nickname'), fontSize: 12, color: addHoroscopeController.horoscopeNameAlert.value == true ? Colors.red : Colors.black87, textAlign: TextAlign.start),
                        PrimaryStraightInputText(
                          allowOnlyLetters: true,
                          onValidate: (v) {
                            if (v == null || v.isEmpty) {
                              addHoroscopeController.horoscopeNameAlert.value = true;
                            }else{
                              addHoroscopeController.horoscopeNameAlert.value = false;
                            }
                            return null;
                          },
                          onChange: (v){
                            if (v == null || v.isEmpty) {
                              addHoroscopeController.horoscopeNameAlert.value = true;
                            }else{
                              addHoroscopeController.horoscopeNameAlert.value = false;
                            }
                            return null;
                          },
                          hintText: LocalizationController.getInstance().getTranslatedValue('Name or Nickname'),
                          controller: addHoroscopeController.horoscopeName,
                        ),
                        SizedBox(height: 15),
                        commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Gender'), fontSize: 12, color: Colors.black87, textAlign: TextAlign.start),
                        ReusableDropdown(options: [
                          LocalizationController.getInstance().getTranslatedValue('Male'),
                          LocalizationController.getInstance().getTranslatedValue('Female'),
                          LocalizationController.getInstance().getTranslatedValue('Transgender')
                        ], currentValue: addHoroscopeController.addHoroscopeGender.value, onChanged: (value){
                          print('selected value is $value');
                          addHoroscopeController.addHoroscopeGender.value = value!;
                        }),
                        SizedBox(height: 5),
                        commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Birth Date'), fontSize: 12, color: addHoroscopeController.horoscopeBirthDateAlert.value == true ? Colors.red : Colors.black87, textAlign: TextAlign.start),
                        SizedBox(height: 5),
                        InkWell(
                          onTap: () {
                            if (kIsWeb) {
                              _selectWebDate(context);
                            } else {
                              // Use DatePicker for mobile platforms (Android & iOS)
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
                                  // addHoroscopeController.addHoroscopeBirthSelectedDate!.value = date;
                                  addHoroscopeController.horoscopeBirthDateAlert.value = false;
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
                                Text(
                                    (selectedDate == null && addHoroscopeController.addHoroscopeBirthSelectedDate == null)
                                        ? LocalizationController.getInstance().getTranslatedValue('Please select date')
                                        : '${LocalizationController.getInstance().getTranslatedValue('Selected date')} : '
                                        ' ${selectedDate == null ? DateFormat('MMMM dd, yyyy').format(addHoroscopeController.addHoroscopeBirthSelectedDate!.value) : DateFormat('MMMM dd, yyyy').format(selectedDate!)}',
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
                        commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Time of Birth'), fontSize: 12, color:addHoroscopeController.horoscopeBirthTimeAlert.value == true ? Colors.red : Colors.black87, textAlign: TextAlign.start),
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
                                                addHoroscopeController.horoscopeBirthTimeAlert.value = false;
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
                            Text(
                                (selectedTime == null && addHoroscopeController.addHoroscopeBirthSelectedTime == null)
                                  ? LocalizationController.getInstance().getTranslatedValue('Please Select Time of Birth')
                                  : '${LocalizationController.getInstance().getTranslatedValue('Selected Time')} : ${selectedTime == null ? DateFormat('h:mm a').format(DateTime(2021, 1, 1, addHoroscopeController.addHoroscopeBirthSelectedTime!.value.hour, addHoroscopeController.addHoroscopeBirthSelectedTime!.value.minute)) : DateFormat('h:mm a').format(DateTime(2021, 1, 1, selectedTime!.hour, selectedTime!.minute))}',
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
                        commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('City of Birth, Country of Birth'), fontSize: 12, color: addHoroscopeController.horoscopeBirthStateAlert.value == true ? Colors.red : Colors.black87, textAlign: TextAlign.start),
                        kIsWeb ?
                        PlaceAutocompleteWebInput(
                          hintText: LocalizationController.getInstance().getTranslatedValue('City of Birth, Country of Birth'),
                          controller: addHoroscopeController.placeStateCountryOfBirth,
                          borderColor: appLoadController.appMidColor,
                          onChange: (v) {
                            print('onChange callback with value: $v');
                            if (v == null || v.isEmpty) {
                              addHoroscopeController.horoscopeBirthStateAlert.value = true;
                            } else {
                              addHoroscopeController.horoscopeBirthStateAlert.value = false;
                              addHoroscopeController.update(); // Force GetX update
                            }
                          },
                          onValidate: (v) {
                            if (v == null || v.isEmpty) {
                              addHoroscopeController.horoscopeBirthStateAlert.value = true;
                            } else {
                              addHoroscopeController.horoscopeBirthStateAlert.value = false;
                            }
                            return null;
                          },
                        ) :
                        PlaceAutocompleteMobileInput(
                          hintText: LocalizationController.getInstance().getTranslatedValue('City of Birth, Country of Birth'),
                          controller: addHoroscopeController.placeStateCountryOfBirth,
                          borderColor: appLoadController.appMidColor,
                          onChange: (v) {
                            print('onChange callback with value: $v');
                            if (v == null || v.isEmpty) {
                              addHoroscopeController.horoscopeBirthStateAlert.value = true;
                            } else {
                              addHoroscopeController.horoscopeBirthStateAlert.value = false;
                              addHoroscopeController.update(); // Force GetX update
                            }
                          },
                          onValidate: (v) {
                            if (v == null || v.isEmpty) {
                              addHoroscopeController.horoscopeBirthStateAlert.value = true;
                            } else {
                              addHoroscopeController.horoscopeBirthStateAlert.value = false;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        commonBoldText(text:  LocalizationController.getInstance().getTranslatedValue('Nearest landmark for place of birth (example:hospital Name etc..)'), fontSize: 12, color: addHoroscopeController.horoscopeBirthLandmarkAlert.value == true ? Colors.red :  Colors.black87, textAlign: TextAlign.start),
                        PrimaryStraightInputText(hintText:
                        LocalizationController.getInstance().getTranslatedValue('Landmark'),
                          controller: addHoroscopeController.landmarkOfBirth,
                          onChange: (v){
                            if (v == null || v.isEmpty) {
                              addHoroscopeController.horoscopeBirthLandmarkAlert.value = true;
                            }else{
                              addHoroscopeController.horoscopeBirthLandmarkAlert.value = false;
                            }
                            return null;
                          },
                          onValidate: (v) {
                            if (v == null || v.isEmpty) {
                              addHoroscopeController.horoscopeBirthLandmarkAlert.value = true;
                            }else{
                              addHoroscopeController.horoscopeBirthLandmarkAlert.value = false;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Order Of birth (Are you the first or second or ...Child in the family)'), fontSize: 12, color: Colors.black87, textAlign: TextAlign.start),
                        ReusableDropdown(options: const ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'], currentValue: addHoroscopeController.birthOrder.value, onChanged: (value){
                          print('selected value is $value');
                          addHoroscopeController.birthOrder.value = value!;
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: GradientButton(
                      title: LocalizationController.getInstance().getTranslatedValue("Next"),buttonHeight: 45, textColor: Colors.white, buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)], onPressed: (Offset buttonOffset){
                    if(addHoroscopeController.hid.value == ''){
                      if(selectedDate == null && addHoroscopeController.addHoroscopeBirthSelectedDate == null){
                        addHoroscopeController.horoscopeBirthDateAlert.value = true;
                      }else{
                        addHoroscopeController.addHoroscopeBirthSelectedDate = DateTime.now().obs;
                        if(selectedDate == null){

                        }else{
                          addHoroscopeController.addHoroscopeBirthSelectedDate!.value = selectedDate!;
                        }
                      }
                      if(selectedTime == null && addHoroscopeController.addHoroscopeBirthSelectedTime == null){
                        addHoroscopeController.horoscopeBirthTimeAlert.value = true;
                      }else{
                        addHoroscopeController.addHoroscopeBirthSelectedTime = TimeOfDay.now().obs;
                        if(selectedTime == null){

                        }else{
                          addHoroscopeController.addHoroscopeBirthSelectedTime!.value = selectedTime!;
                        }
                      }
                      if(formKey.currentState!
                          .validate()){
                        print('validate for time $selectedTime');
                        if(addHoroscopeController.horoscopeName.text != '' && (selectedDate != null || addHoroscopeController.addHoroscopeBirthSelectedDate != null) && (selectedTime != null || addHoroscopeController.addHoroscopeBirthSelectedDate != null)
                            && addHoroscopeController.placeStateCountryOfBirth.text != '' && addHoroscopeController.landmarkOfBirth.text != '' && selectedTime != null){
                          Navigator.push(
                          context, MaterialPageRoute(builder: (context) => const AddMarriageInfo()));
                        }else{
                          showFailedToast('Please fill the mandatory fields');
                        }
                      }
                    }
                    else{
                      addHoroscopeController.horoscopeBirthDateAlert.value = false;
                      addHoroscopeController.horoscopeBirthTimeAlert.value = false;
                      if(selectedDate != null){
                        addHoroscopeController.addHoroscopeBirthSelectedDate = DateTime.now().obs;
                        addHoroscopeController.addHoroscopeBirthSelectedDate!.value = selectedDate!;
                      }
                      if(selectedTime != null){
                        addHoroscopeController.addHoroscopeBirthSelectedTime = TimeOfDay.now().obs;
                        addHoroscopeController.addHoroscopeBirthSelectedTime!.value = selectedTime!;
                      }
                      if(formKey.currentState!
                          .validate()){
                        print('validate true ${addHoroscopeController.horoscopeName.text}');
                        if(addHoroscopeController.horoscopeName.text != '' && (selectedDate != null || addHoroscopeController.addHoroscopeBirthSelectedDate != null) && (selectedTime != null || addHoroscopeController.addHoroscopeBirthSelectedDate != null)
                            && addHoroscopeController.placeStateCountryOfBirth.text != '' && addHoroscopeController.landmarkOfBirth.text != ''){
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) => const AddMarriageInfo()));
                        }else{
                          showFailedToast('Please fill the mandatory fields');
                        }
                      }
                    }
                  }) ,
                ),
                const SizedBox(height: 20),
              ],
          ),
        ),
            )),
      ),
    );
  }
}
