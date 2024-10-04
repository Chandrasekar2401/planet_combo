import 'package:flutter/material.dart';
import 'package:planetcombo/models/get_request.dart';

import '../../common/widgets.dart';
import '../../controllers/localization_controller.dart';

class SpecialPredictionResponse extends StatefulWidget {
  RequestHistory requestHistory;
  SpecialPredictionResponse({super.key, required this.requestHistory});

  @override
  State<SpecialPredictionResponse> createState() => _SpecialPredictionResponseState();
}

class _SpecialPredictionResponseState extends State<SpecialPredictionResponse> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(onPressed: () {
          Navigator.pop(context);
        }, icon: const Icon(Icons.chevron_left_rounded),),
        title: LocalizationController.getInstance().getTranslatedValue("Special Request"),
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)], centerTitle: true,
        actions: [
          IconButton(onPressed: () async{
          }, icon: const Icon(Icons.refresh))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      commonBoldText(text: 'Question'),
                      SizedBox(height: 10),
                      commonText(text: widget.requestHistory.rqspecialdetails!),
                      SizedBox(height: 20),
                      commonBoldText(text: 'Answer'),
                      SizedBox(height: 10),
                      commonText(text: widget.requestHistory.predictiondetail == null ? "Please wait you will get answer soon from our team" : widget.requestHistory.predictiondetail!),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
