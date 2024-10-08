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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(21.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              commonBoldText(text: 'Fact#1.'),
              const SizedBox(height: 10),
              commonText(color: Colors.black54, fontSize: 14, text: "Scientifically, it is not possible to determine from a horoscope whether the chart owner is deceased or alive. The app assumes that the chart owner is alive and seeks guidance."),
              const SizedBox(height: 10),
              const Divider(color: Colors.black12),
              const SizedBox(height: 10),
              commonBoldText(text: 'Fact#2.'),
              const SizedBox(height: 10),
              commonText(color: Colors.black54, fontSize: 14, text: ""
                  "According to experts, astrology is a predictive science that isn’t purely scientific. This app demonstrates that its predictions rely on two key factors: a) planetary calculations based on the Ephemeris supplied by NASA, and b) a prediction engine developed using chart and transitory positions following event rules. Notably, there is no manual intervention, aligning with the universality of methods across charts."
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.black12),
              const SizedBox(height: 10),
              commonBoldText(text: 'Fact#3.'),
              const SizedBox(height: 10),
              commonText(color: Colors.black54, fontSize: 14, text: "Planet Combo has developed a birth time adjustment methodology that aligns effectively with the predictive approach. Accurate data is crucial for chart generation; otherwise, predictions may be inaccurate. PLANETCOMBO offers a 30-day free service to verify predictions. Once validated, the chart is certified for full use."
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.black12),
              const SizedBox(height: 10),
              commonBoldText(text: 'Fact#4.'),
              const SizedBox(height: 10),
              commonText(color: Colors.black54, fontSize: 14, text:
              "Traditional Vedic astrology draws upon concepts such as Doshams, Yogams, Uttcham, and Neecham of houses and planets to make life predictions. CP Astrology, which builds upon the extended and expanded rules of KP Astrology, is actively researching Vedic principles further. PLANETCOMBO remains committed to this research."
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.black12),
              const SizedBox(height: 10),
              commonBoldText(text: 'Fact#5.'),
              const SizedBox(height: 10),
              commonText(color: Colors.black54, fontSize: 14, text:
                  "Can the PLANETCOMBO app be used without birth details? The answer is NO. However, PLANETCOMBO will try to create a chart based on past life events and explore options for generating the chart. Even in such cases, having the place and date is critical, and efforts will be made to determine the exact time."
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
