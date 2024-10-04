import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/controllers/horoscope_services.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:planetcombo/screens/predictions/view_comments.dart';

import '../../models/preictions_list.dart';

class PredictionsHistory extends StatefulWidget {
  const PredictionsHistory({super.key});
  @override
  _PredictionsHistoryState createState() => _PredictionsHistoryState();
}

List<PredictionDetail> getParsedDetails(prDetails) {
  if (prDetails is String) {
    List<dynamic> jsonList = json.decode(prDetails);
    return jsonList.map((json) => PredictionDetail.fromJson(json)).toList();
  } else if (prDetails is List) {
    return prDetails.map((json) => PredictionDetail.fromJson(json)).toList();
  }
  return [];
}

class _PredictionsHistoryState extends State<PredictionsHistory> {

  final TextEditingController _commentController = TextEditingController();

  final HoroscopeServiceController horoscopeServiceController =
  Get.put(HoroscopeServiceController.getInstance(), permanent: true);

  void _showCommentDialog(hid, reqId, seqNo, pReqFlag, prCustomCom, prHComments) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: commonBoldText(text: 'Enter Comment'),
          content: TextField(
            controller: _commentController,
            decoration: InputDecoration(hintText: "Enter your comment here", hintStyle: GoogleFonts.lexend(
              fontWeight: FontWeight.w500,
            )),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Handle cancel action
                _commentController.clear();
                Navigator.of(context).pop();
              },
              child: commonBoldText(text: 'Cancel'),
            ),
            TextButton(
              onPressed: () async{
                try{
                  CustomDialog.showLoading(context, 'Please wait');
                  var result = await horoscopeServiceController.updateComment(hid, reqId, seqNo, pReqFlag, _commentController.text, prHComments);
                  print('the result from update comments');
                  if(result != null){
                    var result2 = await horoscopeServiceController.getUserPredictionsList(hid, reqId);
                    _commentController.clear();
                    Navigator.of(context).pop();
                    CustomDialog.cancelLoading(context);
                  }else{
                    CustomDialog.cancelLoading(context);
                  }
                }catch(error){
                  CustomDialog.cancelLoading(context);
                  CustomDialog.showAlert(context, error.toString(), false, 14);
                }
                },
              child: commonBoldText(text: 'Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(onPressed: () {
          Navigator.pop(context);
        }, icon: const Icon(Icons.chevron_left_rounded),),
        title: LocalizationController.getInstance().getTranslatedValue("Predictions"),
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)], centerTitle: true,
        actions: [
          IconButton(onPressed: () async{
          }, icon: const Icon(Icons.refresh))
        ],
      ),
      body: Obx(() =>
      horoscopeServiceController.predictions.isEmpty ? 
          Center(
            child: commonText(text: 'Predictions not yet generated', color: Colors.black26, fontSize: 13),
          ) : 
          ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: horoscopeServiceController.predictions.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFf2b20a), Color(0xFFf34509)], // Gradient colors
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          borderRadius: BorderRadius.circular(12)
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: commonBoldText(text: DateFormat('dd MMM yyyy').format(horoscopeServiceController.predictions[index].prDate!), textAlign: TextAlign.center, color: Colors.white),
                      ),
                      SizedBox(height: 150,
                      child: ListView.builder(
                        itemCount: horoscopeServiceController.predictions[index].prDetails!.length,
                          itemBuilder: (context, subIndex){
                         return Padding(
                           padding: const EdgeInsets.all(4.0),
                           child: commonText(textAlign: TextAlign.center, text: horoscopeServiceController.predictions[index].prDetails![subIndex].description, fontSize: 14),
                         );
                      }),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        child: Container(height: 0.2 , decoration: const BoxDecoration(
                          color: Colors.black12
                        ),),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                Radio(
                                  value: true,
                                  groupValue: horoscopeServiceController.predictions[index].prFeedFlag == 'T' ? true : null,
                                  onChanged: (value) {
                                    print('value from the true side is $value');
                                    if (value == true) {
                                      horoscopeServiceController.predictions[index].prFeedFlag = 'T';
                                      _showCommentDialog(
                                          horoscopeServiceController.predictions[index].prHId,
                                          horoscopeServiceController.predictions[index].prRequestId,
                                          horoscopeServiceController.predictions[index].prRequestIdSeq,
                                          horoscopeServiceController.predictions[index].prFeedFlag,
                                        _commentController.value,
                                          horoscopeServiceController.predictions[index].prHComments
                                      );
                                    }
                                  },
                                ),
                                commonBoldText(text: 'True', fontSize: 12),
                              ],
                            ),
                            Row(
                              children: [
                                Radio(
                                  value: false,
                                  groupValue: horoscopeServiceController.predictions[index].prFeedFlag == 'F' ? false : null,
                                  onChanged: (value) {
                                    // Handle radio button state change
                                    print('value from the false side is $value');
                                    if (value == false) {
                                      horoscopeServiceController.predictions[index].prFeedFlag = 'F';
                                      _showCommentDialog(
                                          horoscopeServiceController.predictions[index].prHId,
                                          horoscopeServiceController.predictions[index].prRequestId,
                                          horoscopeServiceController.predictions[index].prRequestIdSeq,
                                          horoscopeServiceController.predictions[index].prFeedFlag,
                                          _commentController.value,
                                          horoscopeServiceController.predictions[index].prHComments
                                      );
                                    }
                                  },
                                ),
                                commonBoldText(text: 'False', fontSize: 12),
                              ],
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        child: Container(height: 0.2 , decoration: const BoxDecoration(
                            color: Colors.black12
                        ),),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton(onPressed: (){
                              _showCommentDialog(
                                  horoscopeServiceController.predictions[index].prHId,
                                  horoscopeServiceController.predictions[index].prRequestId,
                                  horoscopeServiceController.predictions[index].prRequestIdSeq,
                                  horoscopeServiceController.predictions[index].prFeedFlag,
                                  _commentController.value,
                                  horoscopeServiceController.predictions[index].prHComments
                              );
                            }, child: commonBoldText(text: 'Comment', fontSize: 12, color: Colors.black54,textAlign: TextAlign.right)),
                            TextButton(onPressed: (){
                              print(horoscopeServiceController.predictions[index].prHComments!);
                              Navigator.push(
                                  context, MaterialPageRoute(builder: (context) => ViewComments(comments:horoscopeServiceController.predictions[index].prHComments!)));
                            }, child: commonBoldText(text: 'View Comments', fontSize: 12, color: Colors.black54,textAlign: TextAlign.right)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
      ),
    );
  }
}
