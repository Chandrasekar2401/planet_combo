import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/predictions_controller.dart';
import 'package:planetcombo/screens/predictions/display_dailyPredictions.dart';

class DateListPage extends StatefulWidget {
  final String userId;
  final int hid;
  final String requestId;

  const DateListPage({super.key, required this.userId, required this.hid, required this.requestId});

  @override
  _DateListPageState createState() => _DateListPageState();
}

class _DateListPageState extends State<DateListPage> {


  final PredictionsController predictionsController =
  Get.put(PredictionsController.getInstance(), permanent: true);

  @override
  void initState() {
    super.initState();
    predictionsController.getDailyPredictionDates(widget.userId, widget.hid, widget.requestId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: "Predictions List",
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
        centerTitle: true,
      ),
      body: Obx(() {
        if (predictionsController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else if (predictionsController.datesList.isEmpty) {
          return Center(child: Text('No dates available'));
        } else {
          return ListView.builder(
            itemCount: predictionsController.datesList.length,
            itemBuilder: (context, index) {
              final date = predictionsController.datesList[index];
              final formattedDate = DateFormat('MMMM d, yyyy').format(date.date);
              final dayOfWeek = DateFormat('EEEE').format(date.date);
              return Column(
                children: [
                  ListTile(
                    leading: commonBoldText(text: ' ${index + 1}'),
                    title: commonBoldText(text: '$formattedDate ($dayOfWeek)'),
                    onTap: () async{
                      predictionsController.onDateTap(date.userId,date.hid,date.requestId,  date.date.toString(), context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PredictionDetailsPage(title : '$formattedDate ($dayOfWeek)')));
                      // if(predictionItems != null){
                      //   Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //           builder: (context) => Dashboard()));
                      // }
                      },
                  ),
                  Divider(height: 0.2),
                ],
              );
            },
          );
        }
      }),
    );
  }

  @override
  void dispose() {
    Get.delete<PredictionsController>();
    super.dispose();
  }
}