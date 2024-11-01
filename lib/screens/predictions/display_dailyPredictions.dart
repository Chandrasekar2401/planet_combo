import 'package:flutter/material.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/predictions_controller.dart';
import 'package:get/get.dart';

class PredictionDetailsPage extends StatefulWidget {
  String title;
  PredictionDetailsPage({super.key, required this.title});

  @override
  State<PredictionDetailsPage> createState() => _PredictionDetailsPageState();
}

class _PredictionDetailsPageState extends State<PredictionDetailsPage> {
  final PredictionsController predictionsController =
  Get.put(PredictionsController.getInstance(), permanent: true);

  int doubleToInt(double value) {
    return value.round();
  }

  int? stringToIntHandlingDecimals(String input) {
    try {
      // First, parse the string to a double
      double doubleValue = double.parse(input);

      // Check if the double is effectively a whole number
      if (doubleValue % 1 == 0) {
        // If it is, convert it to an int
        return doubleValue.toInt();
      } else {
        // If it's not a whole number, return null or throw an exception
        print("Error: '$input' is not a whole number.");
        return null;
      }
    } catch (e) {
      print("Error: Unable to parse '$input'. ${e.toString()}");
      return null;
    }
  }

  Future<void> refreshPredictions(userId, hid, requestId, date, context) async {
    await predictionsController.onDateTap(userId, hid, requestId, date, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: widget.title,
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: commonBoldText(
                    text:
                    'Predictions',
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: commonBoldText(
                    text:
                    'Happened',
                    textAlign: TextAlign.center,
                    fontSize: 12
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: commonBoldText(
                    text:"Didn't Happen",
                    textAlign: TextAlign.center,
                    fontSize: 12
                  ),
                ),
              ],
            ),
          ),
          // List of predictions
          Expanded(
            child: Obx(() => ListView.builder(
              itemCount: predictionsController.predictionItems.length,
              itemBuilder: (context, index) {
                final detail = predictionsController.predictionItems[index];
                bool isTrue = detail.prfeedflag == null || detail.prfeedflag == 'T';
                bool isFalse = detail.prfeedflag == 'F';

                return Column(
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: commonBoldText(text: detail.prdetails),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: Checkbox(
                                value: isTrue,
                                onChanged: (value) async{
                                  if (value == true) {
                                     var response = await predictionsController.updatePredictionStatus(
                                      detail.pruserid,
                                      detail.prhid,
                                      detail.prrequestid,
                                       doubleToInt(detail.prrequestidseq),
                                      'T',
                                      detail.prdate,
                                    );
                                     print('the value returned $response');
                                     if(response == true){
                                        refreshPredictions( detail.pruserid, detail.prhid,   detail.prrequestid, detail.prdate, context);
                                     }
                                  }
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: Checkbox(
                                value: isFalse,
                                onChanged: (value) async{
                                  if (value == true) {
                                    var response = await predictionsController.updatePredictionStatus(
                                      detail.pruserid,
                                      detail.prhid,
                                      detail.prrequestid,
                                      doubleToInt(detail.prrequestidseq),
                                      'F',
                                      detail.prdate,
                                    );
                                    print('the value returned $response');
                                    if(response == true){
                                      refreshPredictions( detail.pruserid, detail.prhid,   detail.prrequestid, detail.prdate, context);
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                );
              },
            )),
          ),
        ],
      ),
    );
  }
}