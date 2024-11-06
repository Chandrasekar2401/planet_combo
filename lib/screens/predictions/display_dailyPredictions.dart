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

  bool _isLoading = false;

  int doubleToInt(double value) {
    return value.round();
  }

  int? stringToIntHandlingDecimals(String input) {
    try {
      double doubleValue = double.parse(input);
      if (doubleValue % 1 == 0) {
        return doubleValue.toInt();
      } else {
        print("Error: '$input' is not a whole number.");
        return null;
      }
    } catch (e) {
      print("Error: Unable to parse '$input'. ${e.toString()}");
      return null;
    }
  }

  Future<void> refreshPredictions(userId, hid, requestId, date, context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await predictionsController.onDateTap(userId, hid, requestId, date, context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> handlePredictionUpdate(detail, String flag) async {
    setState(() {
      _isLoading = true;
    });

    try {
      var response = await predictionsController.updatePredictionStatus(
        detail.pruserid,
        detail.prhid,
        detail.prrequestid,
        doubleToInt(detail.prrequestidseq),
        flag,
        detail.prdate,
      );

      if (response == true) {
        await refreshPredictions(
          detail.pruserid,
          detail.prhid,
          detail.prrequestid,
          detail.prdate,
          context,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update prediction'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: GradientAppBar(
            title: widget.title,
            colors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
            centerTitle: true,
          ),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                color: Colors.grey[200],
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: commonBoldText(
                        text: 'Predictions',
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: commonBoldText(
                          text: 'Happened',
                          textAlign: TextAlign.center,
                          fontSize: 12
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: commonBoldText(
                          text: "Didn't Happen",
                          textAlign: TextAlign.center,
                          fontSize: 12
                      ),
                    ),
                  ],
                ),
              ),
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
                                    onChanged: _isLoading ? null : (value) async {
                                      if (value == true) {
                                        await handlePredictionUpdate(detail, 'T');
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
                                    onChanged: _isLoading ? null : (value) async {
                                      if (value == true) {
                                        await handlePredictionUpdate(detail, 'F');
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
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                    const SizedBox(height: 20),
                    commonText(
                      text: 'Updating Prediction...',
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}