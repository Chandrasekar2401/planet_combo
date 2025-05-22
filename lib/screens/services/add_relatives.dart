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

import '../../api/api_endpoints.dart';


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

  late List<Map<String, String>> confirmationData;

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

  void _showConfirmationPopup(BuildContext playContext) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600; // Threshold for wide screen

    // Group data by form type
    List<Map<String, String>> personalInfoData = [];
    List<Map<String, String>> marriageDetailsData = [];
    List<Map<String, String>> childInfoData = [];
    List<Map<String, String>> travelInfoData = [];
    List<Map<String, String>> relativesInfoData = [];

    // Personal Info data
    if (addHoroscopeController.horoscopeName.text.isNotEmpty) {
      personalInfoData.add({"Name": addHoroscopeController.horoscopeName.text});
    }
    if (addHoroscopeController.addHoroscopeGender.value.isNotEmpty) {
      personalInfoData.add({"Gender": addHoroscopeController.addHoroscopeGender.value});
    }
    if (addHoroscopeController.addHoroscopeBirthSelectedDate != null) {
      personalInfoData.add({"Birth Date": DateFormat('MMMM dd, yyyy').format(addHoroscopeController.addHoroscopeBirthSelectedDate!.value)});
    }
    if (addHoroscopeController.addHoroscopeBirthSelectedTime != null) {
      personalInfoData.add({"Birth Time": DateFormat('h:mm a').format(DateTime(2021, 1, 1, addHoroscopeController.addHoroscopeBirthSelectedTime!.value.hour, addHoroscopeController.addHoroscopeBirthSelectedTime!.value.minute))});
    }
    if (addHoroscopeController.placeStateCountryOfBirth.text.isNotEmpty) {
      personalInfoData.add({"City of Birth": addHoroscopeController.placeStateCountryOfBirth.text});
    }
    if (addHoroscopeController.birthOrder.value.isNotEmpty) {
      personalInfoData.add({"Order of Birth": addHoroscopeController.birthOrder.value});
    }
    if (addHoroscopeController.landmarkOfBirth.text.isNotEmpty) {
      personalInfoData.add({"Nearest landmark for place of birth": addHoroscopeController.landmarkOfBirth.text});
    }

    // Marriage Details data
    if (addHoroscopeController.addSelectedMarriageDate != null) {
      marriageDetailsData.add({"Date Of Marriage": DateFormat('MMMM dd, yyyy').format(addHoroscopeController.addSelectedMarriageDate!.value)});
    }
    if (addHoroscopeController.addSelectedMarriageTime != null) {
      marriageDetailsData.add({"Time Of Marriage": DateFormat('h:mm a').format(DateTime(2021, 1, 1, addHoroscopeController.addSelectedMarriageTime!.value.hour, addHoroscopeController.addSelectedMarriageTime!.value.minute))});
    }
    if (addHoroscopeController.placeStateCountryOfMarriage.text.isNotEmpty) {
      marriageDetailsData.add({"Place of Marriage": addHoroscopeController.placeStateCountryOfMarriage.text});
    }

    // Child Info data
    if (addHoroscopeController.addSelectedChildBirthDate != null) {
      childInfoData.add({"Date Of Child Birth": DateFormat('MMMM dd, yyyy').format(addHoroscopeController.addSelectedChildBirthDate!.value)});
    }
    if (addHoroscopeController.addSelectedChildBirthTime != null) {
      childInfoData.add({"Time Of Child Birth": DateFormat('h:mm a').format(DateTime(2021, 1, 1, addHoroscopeController.addSelectedChildBirthTime!.value.hour, addHoroscopeController.addSelectedChildBirthTime!.value.minute))});
    }
    if (addHoroscopeController.placeStateCountryOfChildBirth.text.isNotEmpty) {
      childInfoData.add({"Place of Child Birth": addHoroscopeController.placeStateCountryOfChildBirth.text});
    }

    // Travel Info data
    if (addHoroscopeController.addSelectedTravelDate != null) {
      travelInfoData.add({"Date Of Travel": DateFormat('MMMM dd, yyyy').format(addHoroscopeController.addSelectedTravelDate!.value)});
    }
    if (addHoroscopeController.addSelectedTravelTime != null) {
      travelInfoData.add({"Time Of Travel": DateFormat('h:mm a').format(DateTime(2021, 1, 1, addHoroscopeController.addSelectedTravelTime!.value.hour, addHoroscopeController.addSelectedTravelTime!.value.minute))});
    }
    if (addHoroscopeController.whereDidYouTraveled.text.isNotEmpty) {
      travelInfoData.add({"Place of Travel": addHoroscopeController.whereDidYouTraveled.text});
    }

    // Relatives Info data
    if (addHoroscopeController.relationShipWithOwner.text.isNotEmpty) {
      relativesInfoData.add({"Relationship": addHoroscopeController.relationShipWithOwner.text});
    }
    if (addHoroscopeController.addSelectedEventDate != null) {
      relativesInfoData.add({"Date Of Event": DateFormat('MMMM dd, yyyy').format(addHoroscopeController.addSelectedEventDate!.value)});
    }
    if (addHoroscopeController.addSelectedEventTime != null) {
      relativesInfoData.add({"Time Of Event": DateFormat('h:mm a').format(DateTime(2021, 1, 1, addHoroscopeController.addSelectedEventTime!.value.hour, addHoroscopeController.addSelectedEventTime!.value.minute))});
    }
    if (addHoroscopeController.eventPlace.text.isNotEmpty) {
      relativesInfoData.add({"Place of Event": addHoroscopeController.eventPlace.text});
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Personal Info Section
                      if (personalInfoData.isNotEmpty) _buildSectionHeader("Personal Data"),
                      if (personalInfoData.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: _buildDataSection(personalInfoData, isWideScreen),
                        ),

                      // Marriage Details Section
                      if (marriageDetailsData.isNotEmpty) _buildSectionHeader("Marriage Data"),
                      if (marriageDetailsData.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: _buildDataSection(marriageDetailsData, isWideScreen),
                        ),

                      // Child Info Section
                      if (childInfoData.isNotEmpty) _buildSectionHeader("First Child Data"),
                      if (childInfoData.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: _buildDataSection(childInfoData, isWideScreen),
                        ),

                      // Travel Info Section
                      if (travelInfoData.isNotEmpty) _buildSectionHeader("Travel Data"),
                      if (travelInfoData.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: _buildDataSection(travelInfoData, isWideScreen),
                        ),

                      // Relatives Info Section
                      if (relativesInfoData.isNotEmpty) _buildSectionHeader("Incident Data"),
                      if (relativesInfoData.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: _buildDataSection(relativesInfoData, isWideScreen),
                        ),

                      // Add padding at the bottom to ensure content doesn't get hidden behind buttons
                      SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Fixed buttons at the bottom
        actionsAlignment: MainAxisAlignment.end,
        actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Back',
                    style: GoogleFonts.lexend(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appLoadController.appMidColor,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    addHoroscopeController.addNewHoroscope(playContext);
                  },
                  child: Text(
                    'Confirm',
                    style: GoogleFonts.lexend(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Helper method to build section headers
  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Divider(
              color: appLoadController.appMidColor.withOpacity(0.7),
              thickness: 0.5,
              indent: 60,
              endIndent: 30,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: appLoadController.appMidColor,
            ),
          ),
          Expanded(
            child: Divider(
              color: appLoadController.appMidColor.withOpacity(0.7),
              thickness: 0.5,
              indent: 30,
              endIndent: 60,
            ),
          ),
        ],
      ),
    );
  }

// Helper method to build data sections
  Widget _buildDataSection(List<Map<String, String>> data, bool isWideScreen) {
    if (isWideScreen) {
      // Two-column layout for wide screens
      return LayoutBuilder(
          builder: (context, constraints) {
            return Wrap(
              spacing: 16.0,
              runSpacing: 8.0,
              children: List.generate(
                data.length,
                    (index) => SizedBox(
                  width: (constraints.maxWidth - 16) / 2,
                  child: _buildDetailTile(
                    data[index].keys.first,
                    data[index].values.first,
                  ),
                ),
              ),
            );
          }
      );
    } else {
      // Single column layout for smaller screens
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: data.length,
        itemBuilder: (context, index) => _buildDetailTile(
          data[index].keys.first,
          data[index].values.first,
        ),
      );
    }
  }

// Helper method to build individual detail tiles
  Widget _buildDetailTile(String title, String value) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // This ensures the column takes minimum required height
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2), // Reduced spacing
            Text(
              value,
              style: GoogleFonts.lexend(
                fontSize: 12,
                color: Colors.black54,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(onPressed: () { Navigator.pop(context); }, icon: Icon(Icons.chevron_left_rounded),),
        title: LocalizationController.getInstance().getTranslatedValue("Add Horoscope (${appLoadController.loggedUserData.value.username})"),
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)], centerTitle: true,
        actions: [
          Row(
            children: [
              const Icon(Icons.payment_outlined, color: Colors.white, size: 16),
              commonBoldText(text: ' - ${appLoadController.loggedUserData.value.ucurrency!}', color: Colors.white, fontSize: 12),
              const SizedBox(width: 10)
            ],
          ),
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
                  commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Demise of close relatives (if applicable)')),
                  const SizedBox(height: 20),
                  commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Relationship with horoscope owner'), fontSize: 12, color: Colors.black87, textAlign: TextAlign.start),
                  PrimaryStraightInputText(hintText:
                  LocalizationController.getInstance().getTranslatedValue('Relationship with horoscope owner'),
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
                                      : '${LocalizationController.getInstance().getTranslatedValue('Selected date')} :  ${selectedDate == null ?DateFormat('MMMM dd, yyyy').format(addHoroscopeController.addSelectedEventDate!.value): DateFormat('MMMM dd, yyyy').format(selectedDate!)}',
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
                      MaterialPageRoute(builder: (context) => Dashboard()),
                          (Route<dynamic> route) => false,
                    );
                  }),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: GradientButton(
                      title: LocalizationController.getInstance().getTranslatedValue("Review"),buttonHeight: 45, textColor: Colors.white, buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)], onPressed: (Offset buttonOffset){
                    if(selectedDate != null){
                      addHoroscopeController.addSelectedEventDate = DateTime.now().obs;
                      addHoroscopeController.addSelectedEventDate!.value = selectedDate!;
                    }
                    if(selectedTime != null){
                      addHoroscopeController.addSelectedEventTime = TimeOfDay.now().obs;
                      addHoroscopeController.addSelectedEventTime!.value = selectedTime!;
                    }

                    confirmationData = [
                      {"Name": addHoroscopeController.horoscopeName.text},
                      {"Gender": addHoroscopeController.addHoroscopeGender.value},
                      {"Birth Date": DateFormat('MMMM dd, yyyy').format(addHoroscopeController.addHoroscopeBirthSelectedDate!.value)},
                      {"Birth Time": DateFormat('h:mm a').format(DateTime(2021, 1, 1, addHoroscopeController.addHoroscopeBirthSelectedTime!.value.hour, addHoroscopeController.addHoroscopeBirthSelectedTime!.value.minute))},
                      {"City of Birth": addHoroscopeController.placeStateCountryOfBirth.text},
                      {"Order of Birth": addHoroscopeController.birthOrder.value},
                      {"Nearest landmark for place of birth": addHoroscopeController.landmarkOfBirth.text},
                      if(addHoroscopeController.addSelectedMarriageDate != null){"Date Of Marriage": DateFormat('MMMM dd, yyyy').format(addHoroscopeController.addSelectedMarriageDate!.value)},
                      if(addHoroscopeController.addSelectedMarriageTime != null){"Time Of Marriage": DateFormat('h:mm a').format(DateTime(2021, 1, 1, addHoroscopeController.addSelectedMarriageTime!.value.hour, addHoroscopeController.addSelectedMarriageTime!.value.minute))},
                      if(addHoroscopeController.placeStateCountryOfMarriage != null && addHoroscopeController.placeStateCountryOfMarriage.text != ''){"Place, State and Country of Marriage": addHoroscopeController.placeStateCountryOfMarriage.text},
                      if(addHoroscopeController.addSelectedChildBirthDate != null){"Date Of Child Birth": DateFormat('MMMM dd, yyyy').format(addHoroscopeController.addSelectedChildBirthDate!.value)},
                      if(addHoroscopeController.addSelectedChildBirthTime != null){"Time Of Child Birth": DateFormat('h:mm a').format(DateTime(2021, 1, 1, addHoroscopeController.addSelectedChildBirthTime!.value.hour, addHoroscopeController.addSelectedChildBirthTime!.value.minute))},
                      if(addHoroscopeController.placeStateCountryOfChildBirth != null && addHoroscopeController.placeStateCountryOfChildBirth.text != ''){"Place, State and Country of Child Birth": addHoroscopeController.placeStateCountryOfChildBirth.text},
                      if(addHoroscopeController.addSelectedTravelDate != null){"Date Of Travel": DateFormat('MMMM dd, yyyy').format(addHoroscopeController.addSelectedTravelDate!.value)},
                      if(addHoroscopeController.addSelectedTravelTime != null){"Time Of Travel": DateFormat('h:mm a').format(DateTime(2021, 1, 1, addHoroscopeController.addSelectedTravelTime!.value.hour, addHoroscopeController.addSelectedTravelTime!.value.minute))},
                      if(addHoroscopeController.whereDidYouTraveled != null && addHoroscopeController.whereDidYouTraveled.text != ''){"Place of Travel": addHoroscopeController.whereDidYouTraveled.text},
                      if(addHoroscopeController.relationShipWithOwner != null && addHoroscopeController.relationShipWithOwner.text != ''){"Relationship with horoscope owner": addHoroscopeController.relationShipWithOwner.text},
                      if(addHoroscopeController.addSelectedEventDate != null){"Date Of Event": DateFormat('MMMM dd, yyyy').format(addHoroscopeController.addSelectedEventDate!.value)},
                      if(addHoroscopeController.addSelectedEventTime != null){"Time Of Event": DateFormat('h:mm a').format(DateTime(2021, 1, 1, addHoroscopeController.addSelectedEventTime!.value.hour, addHoroscopeController.addSelectedEventTime!.value.minute))},
                      if(addHoroscopeController.eventPlace != null && addHoroscopeController.eventPlace.text != ''){"Place, State and Country of event": addHoroscopeController.eventPlace.text},
                    ];

                    _showConfirmationPopup(context);
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
