import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/screens/dashboard.dart';
import 'package:planetcombo/models/horoscope_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:planetcombo/api/api_callings.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:get/get.dart';


class Promises extends StatefulWidget {
  final HoroscopesList horoscope;
  const Promises({Key? key, required this.horoscope}) : super(key: key);

  @override
  _PromisesState createState() => _PromisesState();
}

class _PromisesState extends State<Promises> {
  final double width = 32;
  final double height = 32;

  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  getPromises(String userId, String hid) async{
    CustomDialog.showLoading(context, 'Please wait');
    var result = await APICallings.getPromise(userId: userId, hId: hid.trim(), token: appLoadController.loggedUserData!.value.token!);
    CustomDialog.cancelLoading(context);
    if(result != null){
      var jsonData = json.decode(result);
      if(jsonData['Status'] == 'Success'){
        if(jsonData['Data'] != null){
          
        }else{
          CustomDialog.showAlert(context, jsonData['Message'], null, 14);
        }
      }else{
        CustomDialog.showAlert(context, 'Something went wrong , please try later', null, 14);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // getPromises(widget.horoscope.huserid!, widget.horoscope.hid!);
    getPromise();
  }

  void getPromise() {
    print('Start');
    Timer(Duration(milliseconds: 3), () {
      getPromises(widget.horoscope.huserid!, widget.horoscope.hid!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(onPressed: () { Navigator.pop(context); }, icon: Icon(Icons.chevron_left_rounded),),
        title: LocalizationController.getInstance().getTranslatedValue("Promise"),
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
      body: Column(
        children: [
          Container(
            height: 70,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black26,  // Specify your desired color here
                  width: 0.5,          // Specify the width of the border
                ),
              ),
            ),
            child:   Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: widget.horoscope.hnativephoto!,
                      width: width,
                      height: height,
                      placeholder: (context, url) => Image.network(
                        'https://img.freepik.com/free-icon/user_318-159711.jpg',
                        width: width,
                        height: height,
                      ),
                      errorWidget: (context, url, error) => Image.network(
                        'https://img.freepik.com/free-icon/user_318-159711.jpg',
                        width: width,
                        height: height,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  commonBoldText(text: widget.horoscope.hname!, fontSize: 16),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
