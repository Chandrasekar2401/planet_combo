import 'dart:async';

import 'package:flutter/material.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/controllers/horoscope_services.dart';
import 'package:get/get.dart';
import 'package:planetcombo/screens/predictions/predictions_history.dart';
import 'package:intl/intl.dart';
//models
import 'package:planetcombo/models/preictions_list.dart';
import 'package:planetcombo/screens/predictions/list_dates.dart';


//controllers
import 'package:planetcombo/controllers/predictions_controller.dart';

import '../services/horoscope_services.dart';

class Predictions extends StatefulWidget {
  const Predictions({Key? key}) : super(key: key);

  @override
  _PredictionsState createState() => _PredictionsState();
}

class _PredictionsState extends State<Predictions> {
  final HoroscopeServiceController horoscopeServiceController =
  Get.put(HoroscopeServiceController.getInstance(), permanent: true);

  final PredictionsController predictionsController =
  Get.put(PredictionsController.getInstance(), permanent: true);

  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);
  // Add this variable to track the selected filter
  final RxString selectedFilter = "3".obs; // Default to Life Guidance Questions

  Future<void> _getUserPredictionsList(String hid, String requestId) async {
    print('passing request id $requestId');
    horoscopeServiceController.isLoading.value = true;
    CustomDialog.showLoading(context, 'Please wait');
    try {
      var result = await horoscopeServiceController
          .getUserPredictionsList(hid, requestId)
          .timeout(Duration(seconds: 30));

      if (result != null && result['data'] != null) {
        List<dynamic> data = result['data'];
        horoscopeServiceController.predictions.value =
            data.map((item) => PredictionData.fromJson(item)).toList();
        print(
            'the length of the predictions data ${horoscopeServiceController.predictions.length}');
      }
    } on TimeoutException catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request timed out, please try again.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    } finally {
      if (mounted) {
        CustomDialog.cancelLoading(context);
        horoscopeServiceController.isLoading.value = false;
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const PredictionsHistory()));
      }
    }
  }

  // Function to format date
  String formatDate(String dateTimeString) {
    String date = dateTimeString.split('T')[0];
    DateTime parseDate = DateTime.parse(date);
    String formattedDate = DateFormat('MMMM dd, yyyy').format(parseDate);
    return formattedDate;
  }

  // Function to format time
  String formatTime(String dateTimeString) {
    try {
      String time = dateTimeString.split('T')[1].split('.')[0];
      // Convert 24-hour format to 12-hour format
      DateFormat inputFormat = DateFormat('HH:mm:ss');
      DateFormat outputFormat = DateFormat('hh:mm a');
      DateTime dateTime = inputFormat.parse(time);
      return outputFormat.format(dateTime);
    } catch (e) {
      return "";
    }
  }

  // Function to parse question and date-time from special request
  Map<String, dynamic> parseQuestionAndDateTime(String specialDetails) {
    Map<String, dynamic> result = {
      'question': '',
      'date': '',
      'time': ''
    };

    try {
      if (specialDetails.contains('|')) {
        List<String> parts = specialDetails.split('|');

        if (parts.length >= 1) {
          result['question'] = parts[0].trim();
        }

        if (parts.length >= 2) {
          result['date'] = parts[1].trim();
        }

        if (parts.length >= 3) {
          result['time'] = parts[2].trim();
        }
      } else {
        result['question'] = specialDetails;
      }

      return result;
    } catch (e) {
      return result;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left_rounded, size: 21),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HoroscopeServices()),
                    (Route<dynamic> route) => false,
              );
            }
          },
        ),
        title: LocalizationController.getInstance().getTranslatedValue(
            horoscopeServiceController.requestHistory.isNotEmpty
                ? "Predictions - ${horoscopeServiceController.requestHistory[0].horoname}"
                : "Predictions"),
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Obx(
              () => Column(
            children: [
              // Custom switch button
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: selectedFilter.value == "3"
                                ? [Color(0xFFf2b20a), Color(0xFFf34509)] // Gradient for selected state
                                : [Colors.black12, Colors.black26],// Solid color for unselected state
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(7),
                            bottomLeft: Radius.circular(7),
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => selectedFilter.value = "3",
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(7),
                              bottomLeft: Radius.circular(7),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(7, 0, 0, 0),
                                child: commonBoldText(text: "Life Guidance Questions",textAlign:TextAlign.center, fontSize: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: selectedFilter.value == "2"
                                ? [Color(0xFFf2b20a), Color(0xFFf34509)] // Gradient for selected state
                                : [Colors.black12, Colors.black26], // Solid color for unselected state
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(7),
                            bottomRight: Radius.circular(7),
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => selectedFilter.value = "2",
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(7),
                              bottomRight: Radius.circular(7),
                            ),
                            child: Center(
                              child: commonBoldText(text: "Daily Predictions",fontSize: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Check if filtered list is empty
              Builder(
                builder: (context) {
                  // Create filtered list based on selected filter
                  final filteredList = horoscopeServiceController.requestHistory
                      .where((item) => item.reqcat == selectedFilter.value)
                      .toList();

                  // If list is empty, show empty state
                  if (filteredList.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Icon(
                              Icons.assignment_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 20),
                            commonBoldText(
                              text: "You don't have any active request",
                              color: Colors.grey[700],
                              fontSize: 18,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            commonText(
                              text: selectedFilter.value == "3"
                                  ? "Create a Life Guidance request to get personalized answers"
                                  : "Create a Daily Prediction request to know about your day",
                              color: Colors.grey[600],
                              fontSize: 14,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Otherwise, show the regular list
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: horoscopeServiceController.requestHistory.length,
                    itemBuilder: (context, index) {
                      if (horoscopeServiceController.requestHistory[index].reqcat != selectedFilter.value) {
                        return SizedBox();
                      }

                      // Life Guidance Questions Card
                      if (horoscopeServiceController.requestHistory[index].reqcat == "3") {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: GestureDetector(
                            onTap: () {
                              predictionsController.getSpecialPredictions(
                                  horoscopeServiceController.requestHistory[index].rquserid!,
                                  horoscopeServiceController.requestHistory[index].rqhid,
                                  horoscopeServiceController.requestHistory[index].rqid!,
                                  horoscopeServiceController.requestHistory[index].rqspecialdetails!,
                                  context
                              );
                            },
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Title and badge
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Color(0xFF6A1B9A),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: commonBoldText(text:
                                              "Life Guidance",
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 12),

                                        // Question section
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Color(0xFF6A1B9A).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(Icons.question_answer,
                                                  color: Color(0xFF6A1B9A),
                                                  size: 20
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  commonBoldText(text:
                                                  "Question",
                                                    fontSize: 14,
                                                    color: Color(0xFF6A1B9A),
                                                  ),
                                                  SizedBox(height: 4),
                                                  horoscopeServiceController.requestHistory[index].rqspecialdetails != null
                                                      ? Builder(
                                                      builder: (context) {
                                                        Map<String, dynamic> parsedData = parseQuestionAndDateTime(
                                                            horoscopeServiceController.requestHistory[index].rqspecialdetails!
                                                        );

                                                        // Format questions for display
                                                        List<Widget> questionWidgets = [];
                                                        String questionText = parsedData['question'];

                                                        if (questionText.contains("1.") && questionText.contains("2.")) {
                                                          List<String> questions = [];

                                                          // Split by "2." to get the first question
                                                          List<String> parts = questionText.split("2.");
                                                          if (parts.length > 0) {
                                                            String q1Part = parts[0].trim();
                                                            // Remove the "1." prefix
                                                            if (q1Part.startsWith("1.")) {
                                                              questions.add(q1Part.substring(2).trim());
                                                            } else {
                                                              questions.add(q1Part);
                                                            }

                                                            // Add the second question if it exists
                                                            if (parts.length > 1) {
                                                              questions.add(parts[1].trim());
                                                            }
                                                          }

                                                          // Create widgets for each question
                                                          for (int i = 0; i < questions.length; i++) {
                                                            questionWidgets.add(
                                                                Padding(
                                                                  padding: EdgeInsets.only(bottom: i < questions.length - 1 ? 8 : 0),
                                                                  child: Row(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      commonBoldText(text:
                                                                      "${i + 1}.",
                                                                        fontSize: 14,
                                                                        color: Color(0xFF6A1B9A),
                                                                      ),
                                                                      SizedBox(width: 4),
                                                                      Expanded(
                                                                        child: commonText(text:
                                                                        questions[i],
                                                                          fontSize: 14,
                                                                          color: Colors.black87,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                            );
                                                          }
                                                        } else {
                                                          // Just display the single question
                                                          questionWidgets.add(
                                                              commonText(text:
                                                              questionText,
                                                                fontSize: 14,
                                                                color: Colors.black87,
                                                                maxLines: 3,
                                                                textOverflow: TextOverflow.ellipsis,
                                                              )
                                                          );
                                                        }

                                                        return Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: questionWidgets,
                                                        );
                                                      }
                                                  )
                                                      : commonText(text:
                                                  "Question details not available",
                                                    fontSize: 14,
                                                    color: Colors.black54,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 24), // Space for arrow
                                          ],
                                        ),

                                        SizedBox(height: 16),

                                        // ID and Date/Time from parsed data
                                        Builder(
                                            builder: (context) {
                                              Map<String, dynamic> parsedData = parseQuestionAndDateTime(
                                                  horoscopeServiceController.requestHistory[index].rqspecialdetails ?? ""
                                              );

                                              return Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(Icons.numbers,
                                                          size: 14,
                                                          color: Colors.grey[700]
                                                      ),
                                                      SizedBox(width: 4),
                                                      commonText(text:
                                                      "ID: ${horoscopeServiceController.requestHistory[index].rqid!.trim()}",
                                                        fontSize: 12,
                                                        color: Colors.grey[700],
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.calendar_today,
                                                          size: 14,
                                                          color: Colors.grey[700]
                                                      ),
                                                      SizedBox(width: 4),
                                                      commonText(text:
                                                      parsedData['date'].isNotEmpty
                                                          ? parsedData['date']
                                                          : formatDate(horoscopeServiceController.requestHistory[index].reqcredate!),
                                                        fontSize: 12,
                                                        color: Colors.grey[700],
                                                      ),
                                                      SizedBox(width: 8),
                                                      Icon(Icons.access_time,
                                                          size: 14,
                                                          color: Colors.grey[700]
                                                      ),
                                                      SizedBox(width: 4),
                                                      commonText(text:
                                                      parsedData['time'].isNotEmpty
                                                          ? parsedData['time']
                                                          : formatTime(horoscopeServiceController.requestHistory[index].reqcredate!),
                                                        fontSize: 12,
                                                        color: Colors.grey[700],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            }
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Right arrow
                                  Positioned(
                                    right: 16,
                                    top: 0,
                                    bottom: 0,
                                    child: Center(
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: Color(0xFF6A1B9A),
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      // Daily Predictions Card
                      else {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DateListPage(
                                          userId: horoscopeServiceController.requestHistory[index].rquserid!,
                                          hid: horoscopeServiceController.requestHistory[index].rqhid,
                                          requestId: horoscopeServiceController.requestHistory[index].rqid!
                                      )
                                  )
                              );
                            },
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Title and badge
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFf34509),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: commonBoldText(text:
                                              "Daily Prediction",
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 12),

                                        // Date range section - highlighted
                                        Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFFf2b20a).withOpacity(0.1),
                                                Color(0xFFf34509).withOpacity(0.05),
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Color(0xFFf2b20a).withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    commonBoldText(text:
                                                    "Start Date",
                                                      fontSize: 12,
                                                      color: Color(0xFFf34509),
                                                    ),
                                                    SizedBox(height: 4),
                                                    commonBoldText(text:
                                                    formatDate(horoscopeServiceController.requestHistory[index].rqsdate!),
                                                      fontSize: 14,
                                                      color: Colors.black87,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: 24,
                                                height: 24,
                                                child: Icon(
                                                  Icons.arrow_forward,
                                                  color: Color(0xFFf34509),
                                                  size: 20,
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    commonBoldText(text:
                                                    "End Date",
                                                      fontSize: 12,
                                                      color: Color(0xFFf34509),
                                                    ),
                                                    SizedBox(height: 4),
                                                    commonBoldText(text:
                                                    horoscopeServiceController.requestHistory[index].rqedate == null
                                                        ? "Ongoing"
                                                        : formatDate(horoscopeServiceController.requestHistory[index].rqedate!),
                                                      fontSize: 14,
                                                      color: Colors.black87,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        SizedBox(height: 16),

                                        // Request ID and Creation Date
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.numbers,
                                                    size: 14,
                                                    color: Colors.grey[700]
                                                ),
                                                SizedBox(width: 4),
                                                commonText(text:
                                                "ID: ${horoscopeServiceController.requestHistory[index].rqid!.trim()}",
                                                  fontSize: 12,
                                                  color: Colors.grey[700],
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Icon(Icons.calendar_today,
                                                    size: 14,
                                                    color: Colors.grey[700]
                                                ),
                                                SizedBox(width: 4),
                                                commonText(text:
                                                formatDate(horoscopeServiceController.requestHistory[index].reqcredate!),
                                                  fontSize: 12,
                                                  color: Colors.grey[700],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Right arrow for daily predictions
                                  Positioned(
                                    right: 16,
                                    top: 0,
                                    bottom: 0,
                                    child: Center(
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFf34509),
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}