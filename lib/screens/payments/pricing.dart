import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/screens/dashboard.dart';
import 'package:get/get.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';

class PricingPage extends StatelessWidget {
  PricingPage({Key? key}) : super(key: key);

  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(onPressed: () { Navigator.pop(context); }, icon: Icon(Icons.chevron_left_rounded),),
        title: LocalizationController.getInstance().getTranslatedValue("Pricing"),
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
      body: Center(
        child: PhotoView(
          imageProvider: appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'inr' ? const AssetImage('assets/images/pricing.jpg'): const AssetImage('assets/images/pricingUSD.jpg'),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          initialScale: PhotoViewComputedScale.contained,
          backgroundDecoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
          ),
        ),
      ),
    );
  }
}