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
import 'package:planetcombo/screens/predictions/special_prediction_response.dart';
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: GestureDetector(
                      onTap: () async {
                        horoscopeServiceController
                            .requestHistory[index].reqcat ==
                            "3"
                            ?
                            predictionsController.getSpecialPredictions(
                                horoscopeServiceController.requestHistory[index].rquserid!,
                                horoscopeServiceController.requestHistory[index].rqhid,
                                horoscopeServiceController.requestHistory[index].rqid!,
                                horoscopeServiceController.requestHistory[index].rqspecialdetails!,
                                context)
                            :
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    DateListPage(userId: horoscopeServiceController.requestHistory[index].rquserid!,
                                      hid:  horoscopeServiceController.requestHistory[index].rqhid,
                                      requestId:      horoscopeServiceController.requestHistory[index].rqid!)));
                        // _getUserPredictionsList(
                        //     horoscopeServiceController
                        //         .requestHistory[index].rqhid
                        //         .toString(),
                        //     horoscopeServiceController
                        //         .requestHistory[index].rqid!);
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (horoscopeServiceController
                                  .requestHistory[index].reqcat ==
                                  "2")
                                Container(
                                  decoration: BoxDecoration(
                                      color: Color(0xff05704a),
                                      borderRadius: BorderRadius.circular(7)),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        12, 0, 12, 0),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            commonText(
                                                text: 'Prediction Start Date',
                                                fontSize: 10,
                                                color: Colors.white),
                                            SizedBox(height: 2),
                                            commonBoldText(
                                                text: formatDate(
                                                    horoscopeServiceController
                                                        .requestHistory[index]
                                                        .rqsdate!),
                                                fontSize: 12,
                                                color: Colors.white)
                                          ],
                                        ),
                                        Container(
                                            height: 50,
                                            child: Image.asset(
                                                'assets/imgs/arrow_icon.png')),
                                        Column(
                                          children: [
                                            commonText(
                                                text: 'Prediction End Date',
                                                fontSize: 10,
                                                color: Colors.white),
                                            SizedBox(height: 2),
                                            commonBoldText(
                                                text: horoscopeServiceController
                                                    .requestHistory[
                                                index]
                                                    .rqedate ==
                                                    null
                                                    ? ""
                                                    : formatDate(
                                                    horoscopeServiceController
                                                        .requestHistory[
                                                    index]
                                                        .rqedate!),
                                                fontSize: 12,
                                                color: Colors.white)
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              SizedBox(height: 7),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  commonBoldText(
                                      text: horoscopeServiceController
                                          .requestHistory[index]
                                          .reqcat ==
                                          "2"
                                          ? ""
                                          : 'Question',
                                      fontSize: 14,
                                      color: Colors.black54),
                                  commonText(
                                      text: horoscopeServiceController
                                          .requestHistory[index]
                                          .reqcat ==
                                          "2"
                                          ? ""
                                          : '${horoscopeServiceController
                                          .requestHistory[index]
                                          .rqspecialdetails}',
                                      fontSize: 14,
                                      color: horoscopeServiceController
                                          .requestHistory[index]
                                          .reqcat ==
                                          "2"
                                          ? Colors.green
                                          : Colors.deepOrange),
                                ],
                              ),
                              SizedBox(height: 7),
                              // Row(
                              //   mainAxisAlignment:
                              //   MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     commonBoldText(
                              //         text: 'Chart Owner Name',
                              //         fontSize: 14,
                              //         color: Colors.black54),
                              //     commonText(
                              //         text: horoscopeServiceController
                              //             .requestHistory[index]
                              //             .horoname ??
                              //             "",
                              //         fontSize: 14,
                              //         color: Colors.black54),
                              //   ],
                              // ),
                              // SizedBox(height: 7),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  commonBoldText(
                                      text: 'Request ID ',
                                      fontSize: 14,
                                      color: Colors.black54),
                                  commonText(
                                      text: horoscopeServiceController
                                          .requestHistory[index].rqid!
                                          .trim(),
                                      fontSize: 14,
                                      color: Colors.black54),
                                ],
                              ),
                              SizedBox(height: 7),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  commonBoldText(
                                      text: 'Request Created date',
                                      fontSize: 14,
                                      color: Colors.black54),
                                  commonText(
                                      text: formatDate(
                                          horoscopeServiceController
                                              .requestHistory[index]
                                              .reqcredate!),
                                      fontSize: 14,
                                      color: Colors.black54),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
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