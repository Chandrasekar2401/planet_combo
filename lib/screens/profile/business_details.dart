import 'package:flutter/material.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:get/get.dart';

class BusinessDetails extends StatelessWidget {
  BusinessDetails({super.key});

  final AppLoadController appLoadController = Get.put(AppLoadController.getInstance(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.chevron_left_rounded),
        ),
        title: "Business Details",
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(0),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFf2b20a), Color(0xFFf34509)],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  child: Column(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/images/headletters.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),

                // Details Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoRow('Legal Name',
                          appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'inr' ?
                          'VENKATARAMAN CHANDRASEKAR' : 'PLANETCOMBO FZCO'
                      ),
                      _buildDivider(),
                      _buildInfoRow('Address',
                          appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'inr' ?
                          '7, KANNADASAN SALAI. T NAGAR\nTHIYAGARAYA NAGAR\nCHENNAI':
                        '101 SILICON OASIS DDP A2 P.O.Box 342001 DUBAI, UNITED ARAB EMIRATES'
                      ),
                      if(appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'inr')_buildDivider(),
                      if(appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'inr')_buildInfoRow('State', 'TAMIL NADU'),
                      if(appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'inr')_buildDivider(),
                      if(appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'inr')_buildInfoRow('Postal Code', '600017'),
                      _buildDivider(),
                      _buildInfoRow('WhatsApp',
                          appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'inr' ?
                          '+919600031647' :
                          '+971504534409'
                      ),
                      _buildDivider(),
                      _buildInfoRow('Email', 'info@planetcombo.com', isEmail: true),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFf34509),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: isEmail ? Colors.blue : Colors.black87,
                decoration: isEmail ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.withOpacity(0.3),
      height: 1,
    );
  }
}