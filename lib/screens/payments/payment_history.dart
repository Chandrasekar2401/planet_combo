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
    String pay = 'Not Available';
    if(paymentString == 'N'){
      pay = 'Pending';
    }else{
      pay = 'Paid';
    }
    return pay;
  }

  String formatIndianRupees(double amount) {
    // Round to 2 decimal places
    double roundedAmount = (amount * 100).round() / 100;

    // Create a number format for Indian Rupees
    NumberFormat indianRupeesFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    // Format the amount
    String formattedAmount = indianRupeesFormat.format(roundedAmount);

    // Remove the rupee symbol as we just need the number format
    formattedAmount = formattedAmount.replaceAll('₹', '');

    // Trim any leading whitespace
    formattedAmount = formattedAmount.trim();

    return formattedAmount;
  }

  String formatDate(String dateString) {
    // Parse the input string to a DateTime object
    DateTime dateTime = DateTime.parse(dateString);

    // Create a DateFormat object for the desired output format
    DateFormat formatter = DateFormat("yyyy-MM-dd '@' hh:mm a");

    // Format the date
    String formattedDate = formatter.format(dateTime);

    return formattedDate;
  }

  double taxCalc(double tax1, double tax2, double tax3){
    double totalTax = tax1 + tax2 + tax3;
    return totalTax;
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
                      commonBoldText(text: 'Name : ${applicationBaseController.paymentHistory[index].name ?? ""}', fontSize: 13),
                      const SizedBox(height: 7),
                      commonText(text: 'Amount: ${applicationBaseController.paymentHistory[index].currency}' ' ${formatIndianRupees(applicationBaseController.paymentHistory[index].amount ?? 0)}', fontSize: 13),
                      const SizedBox(height: 7),
                      commonText(text: 'Tax: ${applicationBaseController.paymentHistory[index].currency}' ' ${formatIndianRupees(taxCalc(applicationBaseController.paymentHistory[index].tax1Amount ?? 0, applicationBaseController.paymentHistory[index].tax2Amount ?? 0, applicationBaseController.paymentHistory[index].tax3Amount ?? 0))}', fontSize: 13),
                      const SizedBox(height: 7),
                      commonText(text: 'Total Amount: ${applicationBaseController.paymentHistory[index].currency}' ' ${formatIndianRupees(applicationBaseController.paymentHistory[index].totalAmount ?? 0)}', fontSize: 13),
                      SizedBox(height: 7),
                      commonText(
                          text: 'Payment method : ${applicationBaseController.paymentHistory[index].paymentChanel ?? "Not Updated".toString()}', fontSize: 13),
                    ],
                  ),
                  collapsedBackgroundColor: Colors.white,
                  backgroundColor: Colors.white,
                  initiallyExpanded: _expandedList[index],
                  expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                  childrenPadding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                  children: [
                    commonText(text: 'Reference Number : ${applicationBaseController.paymentHistory[index].paymentReference}', fontSize: 13),
                    SizedBox(height: 7),
                    commonText(text: 'Paid Date : ${formatDate(applicationBaseController.paymentHistory[index].paidDate.toString())}', fontSize: 13),
                    SizedBox(height: 7),
                    GestureDetector(
                      onTap: (){
                        if(applicationBaseController.paymentHistory[index].invoiceUrl != null || applicationBaseController.paymentHistory[index].invoiceUrl != ""){
                          launchUrl(Uri.parse(applicationBaseController.paymentHistory[index].invoiceUrl!));
                        }
                      },
                      child: commonText(fontSize: 12, text: 'Invoice/Receipt Link  : \$ ${applicationBaseController.paymentHistory[index].invoiceUrl ?? 'Link not received'}', color: Colors.blue),
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
