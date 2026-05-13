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
import 'package:planetcombo/screens/services/add_travelInfo.dart';
import 'package:planetcombo/screens/dashboard.dart';

import '../../common/place_autocomple_mobile.dart';
import 'package:planetcombo/common/app_logger.dart';


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

  String normalizeValue(String value){
    if(value.endsWith('.0')){
      return value.replaceAll('.0', '');
    }else{
      return value;
    }

  }
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
        addHoroscopeController.horoscopeBirthDateAlert.value = false;
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
        addHoroscopeController.horoscopeBirthTimeAlert.value = false;
      });
    }
  }

  bool get _hasBirthDate =>
      selectedDate != null ||
          addHoroscopeController.addHoroscopeBirthSelectedDate != null;

  bool get _hasBirthTime =>
      selectedTime != null ||
          addHoroscopeController.addHoroscopeBirthSelectedTime != null;

  // Keeps the original commonBoldText look — just swaps the colour
  // between red (when its alert flag is on) and black87 (filled).
  Widget _mandatoryLabel({required String text, required bool alert}) {
    return commonBoldText(
      text: LocalizationController.getInstance().getTranslatedValue(text),
      fontSize: 12,
      color: alert ? Colors.red : Colors.black87,
      textAlign: TextAlign.start,
    );
  }

  // Re-evaluates every "required" field and toggles its alert flag.
  // Returns true if every required field is filled.
  bool _runMandatoryValidation() {
    final c = addHoroscopeController;
    c.horoscopeNameAlert.value = c.horoscopeName.text.trim().isEmpty;
    c.horoscopeBirthDateAlert.value = !_hasBirthDate;
    c.horoscopeBirthTimeAlert.value = !_hasBirthTime;
    c.horoscopeBirthStateAlert.value =
        c.placeStateCountryOfBirth.text.trim().isEmpty;
    c.horoscopeBirthLandmarkAlert.value =
        c.landmarkOfBirth.text.trim().isEmpty;
    return !(c.horoscopeNameAlert.value ||
        c.horoscopeBirthDateAlert.value ||
        c.horoscopeBirthTimeAlert.value ||
        c.horoscopeBirthStateAlert.value ||
        c.horoscopeBirthLandmarkAlert.value);
  }

  // Function to check if the user is below 12 years old
  bool isBelow12Years(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;

    // Check if birthday hasn't occurred this year yet
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age < 12;
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
                            _mandatoryLabel(
                              text: 'Name or Nickname',
                              alert: addHoroscopeController.horoscopeNameAlert.value,
                            ),
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
                              AppLogger.d('selected value is $value');
                              addHoroscopeController.addHoroscopeGender.value = value!;
                            }),
                            SizedBox(height: 5),
                            _mandatoryLabel(
                              text: 'Birth Date',
                              alert: addHoroscopeController.horoscopeBirthDateAlert.value,
                            ),
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
                                      AppLogger.d('change $date');
                                    },
                                    onConfirm: (date) {
                                      AppLogger.d('onConfirmed date $date');
                                      setState(() {
                                        selectedDate = date;
                                        addHoroscopeController.horoscopeBirthDateAlert.value = false;
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
                                          color: addHoroscopeController.horoscopeBirthDateAlert.value
                                              ? Colors.red
                                              : appLoadController.appMidColor,
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
                                          color: addHoroscopeController.horoscopeBirthDateAlert.value
                                              ? Colors.red
                                              : Colors.black54,
                                        )
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Icon(
                                        Icons.calendar_today,
                                        size: 18,
                                        color: addHoroscopeController.horoscopeBirthDateAlert.value
                                            ? Colors.red
                                            : appLoadController.appMidColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            _mandatoryLabel(
                              text: 'Time of Birth',
                              alert: addHoroscopeController.horoscopeBirthTimeAlert.value,
                            ),
                            SizedBox(height: 5),
                            InkWell(
                              onTap: () {
                                if(kIsWeb){
                                  _selectWebTime(context);
                                }else{
                                  // Seed a default so tapping OK without
                                  // scrolling still captures a time.
                                  final initial = DateTime.now();
                                  TimeOfDay pendingTime =
                                      TimeOfDay.fromDateTime(initial);
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
                                                    initialDateTime: initial,
                                                    onDateTimeChanged: (DateTime dateTime) {
                                                      pendingTime =
                                                          TimeOfDay.fromDateTime(dateTime);
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
                                                          setState(() {
                                                            selectedTime = pendingTime;
                                                            addHoroscopeController
                                                                .horoscopeBirthTimeAlert
                                                                .value = false;
                                                          });
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
                                            color: addHoroscopeController.horoscopeBirthTimeAlert.value
                                                ? Colors.red
                                                : appLoadController.appMidColor,
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
                                            color: addHoroscopeController.horoscopeBirthTimeAlert.value
                                                ? Colors.red
                                                : Colors.black54
                                        )
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Icon(
                                        Icons.access_time,
                                        size: 18,
                                        color: addHoroscopeController.horoscopeBirthTimeAlert.value
                                            ? Colors.red
                                            : appLoadController.appMidColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            _mandatoryLabel(
                              text: 'City of Birth, Country of Birth',
                              alert: addHoroscopeController.horoscopeBirthStateAlert.value,
                            ),
                            kIsWeb ?
                            PlaceAutocompleteWebInput(
                              hintText: LocalizationController.getInstance().getTranslatedValue('City of Birth, Country of Birth'),
                              controller: addHoroscopeController.placeStateCountryOfBirth,
                              borderColor: appLoadController.appMidColor,
                              onChange: (v) {
                                AppLogger.d('onChange callback with value: $v');
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
                                AppLogger.d('onChange callback with value: $v');
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
                            _mandatoryLabel(
                              text: 'Nearest landmark for place of birth (example:hospital Name etc..)',
                              alert: addHoroscopeController.horoscopeBirthLandmarkAlert.value,
                            ),
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
                            ReusableDropdown(
                              options: const ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'],
                              currentValue: addHoroscopeController.birthOrder.value.isEmpty
                                  ? '1'
                                  : normalizeValue(addHoroscopeController.birthOrder.value),
                              onChanged: (value) {
                                addHoroscopeController.birthOrder.value = value ?? '';
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: GradientButton(
                          title: LocalizationController.getInstance().getTranslatedValue("Next"),buttonHeight: 45, textColor: Colors.white, buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)], onPressed: (Offset buttonOffset){
                        // Mirror freshly-picked date/time into the
                        // controller's persistent observables so the next
                        // page can read them.
                        if (selectedDate != null) {
                          addHoroscopeController.addHoroscopeBirthSelectedDate ??=
                              DateTime.now().obs;
                          addHoroscopeController
                              .addHoroscopeBirthSelectedDate!.value = selectedDate!;
                        }
                        if (selectedTime != null) {
                          addHoroscopeController.addHoroscopeBirthSelectedTime ??=
                              TimeOfDay.now().obs;
                          addHoroscopeController
                              .addHoroscopeBirthSelectedTime!.value = selectedTime!;
                        }

                        // Always re-check every required field — this is
                        // what flips labels back from red to black once
                        // the user has fixed them, and what surfaces any
                        // still-missing fields in red on submit.
                        final allFilled = _runMandatoryValidation();
                        final formOk = formKey.currentState?.validate() ?? false;

                        if (!allFilled || !formOk) {
                          showFailedToast('Please fill the mandatory fields');
                          return;
                        }

                        final actualBirthDate = selectedDate ??
                            addHoroscopeController
                                .addHoroscopeBirthSelectedDate!.value;

                        if (isBelow12Years(actualBirthDate)) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddTravelInfo()),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddMarriageInfo()),
                          );
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