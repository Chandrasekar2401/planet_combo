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
  final RxString selectedFilter = "3".obs; // Default to Daily Predictions

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
            MaterialPageRoute(builder: (context) => PredictionsHistory()));
      }
    }
  }

  String formatDate(String dateTimeString) {
    String date = dateTimeString.split('T')[0];
    DateTime parseDate = DateTime.parse(date);
    String formattedDate = DateFormat('MMMM dd, yyyy').format(parseDate);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        title: LocalizationController.getInstance().getTranslatedValue(
            "Predictions for ${horoscopeServiceController.requestHistory[0].horoname}"),
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {},
            icon: const Icon(Icons.refresh),
          )
        ],
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
                          borderRadius: BorderRadius.only(
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
                              child: commonBoldText(text: "Life Guidance Questions", color: Colors.white),
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
                              child: commonBoldText(text: "Daily Predictions", color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: horoscopeServiceController.requestHistory.length,
                itemBuilder: (context, index) {
                  if (horoscopeServiceController.requestHistory[index].reqcat !=
                      selectedFilter.value) {
                    return SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: GestureDetector(
                      onTap: () async {
                        horoscopeServiceController.requestHistory[index].reqcat == "3"
                            ? predictionsController.getSpecialPredictions(
                            horoscopeServiceController.requestHistory[index].rquserid!,
                            horoscopeServiceController.requestHistory[index].rqhid,
                            horoscopeServiceController.requestHistory[index].rqid!,
                            horoscopeServiceController.requestHistory[index].rqspecialdetails!,
                            context)
                            : Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DateListPage(
                                    userId: horoscopeServiceController.requestHistory[index].rquserid!,
                                    hid: horoscopeServiceController.requestHistory[index].rqhid,
                                    requestId: horoscopeServiceController.requestHistory[index].rqid!)));
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Color(0xff05704a).withOpacity(0.1)), // Subtle border
                        ),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                  colors: [
                                    Colors.white,
                                    Color(0xff05704a).withOpacity(0.05),
                                  ],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (horoscopeServiceController.requestHistory[index].reqcat == "2")
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Color(0xff05704a), Color(0xff048c5c)],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0xff05704a).withOpacity(0.2),
                                              blurRadius: 8,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(Icons.calendar_today,
                                                          size: 14,
                                                          color: Colors.white.withOpacity(0.9)),
                                                      SizedBox(width: 4),
                                                      commonText(
                                                        text: 'Start Date',
                                                        fontSize: 12,
                                                        color: Colors.white.withOpacity(0.9),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 6),
                                                  commonBoldText(
                                                    text: formatDate(horoscopeServiceController.requestHistory[index].rqsdate!),
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                  )
                                                ],
                                              ),
                                              Container(
                                                height: 30,
                                                child: Image.asset('assets/imgs/arrow_icon.png'),
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(Icons.event,
                                                          size: 14,
                                                          color: Colors.white.withOpacity(0.9)),
                                                      SizedBox(width: 4),
                                                      commonText(
                                                        text: 'End Date',
                                                        fontSize: 12,
                                                        color: Colors.white.withOpacity(0.9),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 6),
                                                  commonBoldText(
                                                    text: horoscopeServiceController.requestHistory[index].rqedate == null
                                                        ? "Ongoing"
                                                        : formatDate(horoscopeServiceController.requestHistory[index].rqedate!),
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    SizedBox(height: 16),
                                    if (horoscopeServiceController.requestHistory[index].reqcat != "2")
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.deepOrange.withOpacity(0.2)),
                                        ),
                                        padding: EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.question_answer,
                                                    size: 16,
                                                    color: Colors.deepOrange),
                                                SizedBox(width: 8),
                                                commonBoldText(
                                                  text: 'Question',
                                                  fontSize: 15,
                                                  color: Colors.deepOrange,
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            commonText(
                                              text: '${horoscopeServiceController.requestHistory[index].rqspecialdetails}',
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ],
                                        ),
                                      ),
                                    SizedBox(height: 16),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: EdgeInsets.all(12),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.numbers,
                                                      size: 16,
                                                      color: Color(0xff05704a)),
                                                  SizedBox(width: 8),
                                                  commonBoldText(
                                                    text: 'Request ID',
                                                    fontSize: 14,
                                                    color: Color(0xff05704a),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(right: 40),
                                                child: commonText(
                                                  text: horoscopeServiceController.requestHistory[index].rqid!.trim(),
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.access_time,
                                                      size: 16,
                                                      color: Color(0xff05704a)),
                                                  SizedBox(width: 8),
                                                  commonBoldText(
                                                    text: 'Created On',
                                                    fontSize: 14,
                                                    color: Color(0xff05704a),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(right: 40),
                                                child: commonText(
                                                  text: formatDate(horoscopeServiceController.requestHistory[index].reqcredate!),
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (horoscopeServiceController.requestHistory[index].reqcat == "3")
                              Positioned(
                                right: 12,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Color(0xff05704a),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xff05704a).withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            // Status indicator
                            Positioned(
                              top: horoscopeServiceController.requestHistory[index].reqcat == "2"
                                  ? 4
                                  : 14,
                              right: 12,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: horoscopeServiceController.requestHistory[index].reqcat == "2"
                                      ? Color(0xff05704a)
                                      : Colors.deepOrange,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  horoscopeServiceController.requestHistory[index].reqcat == "2"
                                      ? "Prediction"
                                      : "Question",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ),
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