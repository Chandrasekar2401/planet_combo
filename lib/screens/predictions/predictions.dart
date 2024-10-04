import 'dart:async';

import 'package:flutter/material.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/controllers/horoscope_services.dart';
import 'package:get/get.dart';
import 'package:planetcombo/screens/predictions/predictions_history.dart';

//models
import 'package:planetcombo/models/preictions_list.dart';
import 'package:planetcombo/screens/predictions/special_prediction_response.dart';

class Predictions extends StatefulWidget {
  const Predictions({super.key});
  @override
  _PredictionsState createState() => _PredictionsState();
}

class _PredictionsState extends State<Predictions> {

  final HoroscopeServiceController horoscopeServiceController =
  Get.put(HoroscopeServiceController.getInstance(), permanent: true);

  Future<void> _getUserPredictionsList(String hid, String requestId) async {
    print('passing request id $requestId');
    horoscopeServiceController.isLoading.value = true;
    CustomDialog.showLoading(context, 'Please wait');
    try {
      var result = await horoscopeServiceController.getUserPredictionsList(hid, requestId).timeout(Duration(seconds: 30));

      if (result != null && result['Data'] != null) {
        List<dynamic> data = result['Data'];
        horoscopeServiceController.predictions.value = data.map((item) => PredictionData.fromJson(item)).toList();
        print('the length of the predictions data ${horoscopeServiceController.predictions.length}');
      }
    } on TimeoutException catch (_) {
      // Handle timeout
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request timed out, please try again.')),
      );
    } catch (error) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    } finally {
      if (mounted) {
        CustomDialog.cancelLoading(context);
        horoscopeServiceController.isLoading.value = false;
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => PredictionsHistory()));
      }
    }
  }

  String formatDate(String dateTimeString) {
    return dateTimeString.split('T')[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(onPressed: () {
          Navigator.pop(context);
        }, icon: const Icon(Icons.chevron_left_rounded),),
        title: LocalizationController.getInstance().getTranslatedValue("Choose Request"),
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)], centerTitle: true,
        actions: [
          IconButton(onPressed: () async{
          }, icon: const Icon(Icons.refresh))
        ],
      ),
      body: SingleChildScrollView(
        child: Obx(() =>
            Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: horoscopeServiceController.requestHistory.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: GestureDetector(
                    onTap: () async{
                      horoscopeServiceController.requestHistory[index].reqcat == "3" ?
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => SpecialPredictionResponse(requestHistory: horoscopeServiceController.requestHistory[index]))):
                        _getUserPredictionsList(horoscopeServiceController.requestHistory[index].rqhid!.trim(), horoscopeServiceController.requestHistory[index].rqid!.trim());
                    },
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                commonBoldText(text: 'Prediction Category ', fontSize: 14, color: Colors.black54),
                                commonText(text: horoscopeServiceController.requestHistory[index].reqcat == "2" ? "Daily Prediction" : 'Special prediction', fontSize: 14 , color: horoscopeServiceController.requestHistory[index].reqcat == "2" ? Colors.deepOrange : Colors.green),
                              ],
                            ),
                            SizedBox(height: 7),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                commonBoldText(text: 'Chart Owner Name', fontSize: 14, color: Colors.black54),
                                commonText(text: horoscopeServiceController.requestHistory[index].horoname!, fontSize: 14 , color: Colors.black54),
                              ],
                            ),
                            SizedBox(height: 7),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                commonBoldText(text: 'Request ID ', fontSize: 14, color: Colors.black54),
                                commonText(text: horoscopeServiceController.requestHistory[index].rqid!.trim(), fontSize: 14 , color: Colors.black54),
                              ],
                            ),
                            SizedBox(height: 7),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                commonBoldText(text: 'Request Created date', fontSize: 14, color: Colors.black54),
                                commonText(text: formatDate(horoscopeServiceController.requestHistory[index].reqcredate!), fontSize: 14 , color: Colors.black54),
                              ],
                            ),
                            SizedBox(height: 7),
                           if(horoscopeServiceController.requestHistory[index].reqcat == "2") Container(
                             decoration: BoxDecoration(
                               color: Colors.green,
                               borderRadius: BorderRadius.circular(7)
                             ),
                             child: Padding(
                               padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                               child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        commonText(text: 'Prediction Start Date', fontSize: 10, color: Colors.white),
                                        SizedBox(height: 2),
                                        commonBoldText(text: formatDate(horoscopeServiceController.requestHistory[index].rqsdate!), fontSize: 12, color: Colors.white)
                                      ],
                                    ),
                                    Container(
                                        height: 50,
                                        child: Image.asset('assets/imgs/arrow_icon.png')),
                                    Column(
                                      children: [
                                        commonText(text: 'Prediction End Date', fontSize: 10, color: Colors.white),
                                        SizedBox(height: 2),
                                        commonBoldText(text: formatDate(horoscopeServiceController.requestHistory[index].rqedate!), fontSize: 12, color: Colors.white)
                                      ],
                                    )
                                  ],
                                ),
                             ),
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
        )),
      ),
    );
  }
}
