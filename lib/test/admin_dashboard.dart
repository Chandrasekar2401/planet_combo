import 'package:flutter/material.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:get/get.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: commonBoldText(text: 'Welcome Admin', color: Colors.white),
        backgroundColor: appLoadController.appPrimaryColor,
      ),
    );
  }
}
