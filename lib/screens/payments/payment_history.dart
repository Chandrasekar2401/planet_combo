import 'package:flutter/material.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:get/get.dart';
import 'package:planetcombo/screens/dashboard.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentHistory extends StatefulWidget {
  const PaymentHistory({Key? key}) : super(key: key);

  @override
  _PaymentHistoryState createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory> {
  late List<bool> _expandedList;

  final ApplicationBaseController applicationBaseController =
  Get.put(ApplicationBaseController.getInstance(), permanent: true);

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
    String formattedTime = DateFormat('hh:mm a').format(dateTime);

    String formatted = '$formattedDate at $formattedTime';
    return formatted;
  }
  
  String paymentStatus(String paymentString){
    String pay = 'Not Paid';
    if(paymentString == 'N'){
      pay = 'Pending';
    }else{
      pay = 'Paid';
    }
    return pay;
  }



  @override
  void initState() {
    super.initState();
    _expandedList = List<bool>.generate(20, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(onPressed: () { Navigator.pop(context); }, icon: Icon(Icons.chevron_left_rounded),),
        title: LocalizationController.getInstance().getTranslatedValue("Payment Records"),
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
      body: applicationBaseController.paymentHistory.isEmpty ?
      Center(
        child: commonText(text: 'No Records found', color: Colors.grey),
      ) :
      Obx(() => ListView.builder(
        itemCount: applicationBaseController.paymentHistory.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2.0,
                    blurRadius: 4.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Theme(
                data: ThemeData().copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      commonText(text: 'Invoice date : ${formatDateTime(applicationBaseController.paymentHistory[index].invoicedate!)}', color: Colors.grey, fontSize: 13),
                      SizedBox(height: 7),
                      commonText(text: 'Requested Amount : \$ ${applicationBaseController.paymentHistory[index].paymentrequest}', color: Colors.grey, fontSize: 13),
                      SizedBox(height: 7),
                      commonText(text: 'Total Invoice Amount : \$ ${applicationBaseController.paymentHistory[index].totalinvocieamount}', color: Colors.grey, fontSize: 13),
                      SizedBox(height: 7),
                      commonText(
                          text: 'Paid Status : ${paymentStatus(applicationBaseController.paymentHistory[index].paidstatus!)}',
                          color: applicationBaseController.paymentHistory[index].paidstatus == 'N' ? Colors.grey : Colors.blueGrey,
                          fontSize: 13),
                    ],
                  ),
                  collapsedBackgroundColor: Colors.white,
                  backgroundColor: Colors.white,
                  initiallyExpanded: _expandedList[index],
                  expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                  childrenPadding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                  children: [
                    commonText(text: 'Paypal reference number : ${applicationBaseController.paymentHistory[index].pprefnumber}', color: Colors.grey, fontSize: 13),
                    SizedBox(height: 7),
                    commonText(text: 'Taxes : \$ ${applicationBaseController.paymentHistory[index].paidamount}', color: Colors.grey, fontSize: 13),
                    SizedBox(height: 7),
                    commonText(text: 'Service Charge : & ${applicationBaseController.paymentHistory[index].paidamount}', color: Colors.grey, fontSize: 13),
                    SizedBox(height: 7),
                    commonText(text: 'Paid date :  ${formatDateTime(applicationBaseController.paymentHistory[index].invoicedate!)}', color: Colors.grey, fontSize: 13),
                    SizedBox(height: 7),
                    commonText(text: 'Payment link reference number : ', color: Colors.grey, fontSize: 13),
                    GestureDetector(
                      onTap: (){
                        launchUrl(Uri.parse(applicationBaseController.paymentHistory[index].paymentlinkrefnumber!));
                      },
                      child: commonText(fontSize: 12, text: '${applicationBaseController.paymentHistory[index].paymentlinkrefnumber}', color: Colors.blue),
                    )
                  ],
                  onExpansionChanged: (bool expanded) {
                    setState(() {
                      _expandedList[index] = expanded;
                    });
                  },
                ),
              ),
            ),
          );
        },
      ))
    );
  }
}
