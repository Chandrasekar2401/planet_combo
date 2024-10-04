import 'package:flutter/material.dart';

import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/screens/dashboard.dart';

class FactsMyths extends StatelessWidget {
  const FactsMyths({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(onPressed: () {
          Navigator.pop(context);
        }, icon: const Icon(Icons.chevron_left_rounded),),
        title: LocalizationController.getInstance().getTranslatedValue("Myths & Facts"),
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)], centerTitle: true,
        actions: [
          IconButton(onPressed: (){
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Dashboard()),
                  (Route<dynamic> route) => false,
            );
          }, icon: const Icon(Icons.home_outlined))
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(21.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            commonBoldText(text: 'Fact#1.'),
            SizedBox(height: 10),
            commonText(color: Colors.black54, fontSize: 14, text: "Life aspects are aligned as per dasa periods and appropriate planetary transits"),
            SizedBox(height: 10),
            Divider(color: Colors.black12),
            SizedBox(height: 10),
            commonBoldText(text: 'Fact#2.'),
            SizedBox(height: 10),
            commonText(color: Colors.black54, fontSize: 14, text: "The Practice of Nivarti or Prayachittam will not override a promise as per chart. They remain a matter of faith / belief."),
            SizedBox(height: 10),
            Divider(color: Colors.black12),
            SizedBox(height: 10),
            commonBoldText(text: 'Fact#3.'),
            SizedBox(height: 10),
            commonText(color: Colors.black54, fontSize: 14, text: "VC Pathathi does not consider Dosha, Yogam and Aspects of a chart as valid scientific approach. Hence common myths like mangal Dosha is a chart are not recognized  as valid by VC Pathathi approach. For e.g. a person with Mars in position 7/8 ( Mangal Dosha) can have a good married life depending on the chart and no dosha is considered."),
            SizedBox(height: 10),
            Divider(color: Colors.black12),
            SizedBox(height: 10),
            commonBoldText(text: 'Fact#4.'),
            SizedBox(height: 10),
            commonText(color: Colors.black54, fontSize: 14, text: "It is challenging to determine whether a chart owner is alive or not. Hence users are to provide birth charts of living individuals when seeking prediction."),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
