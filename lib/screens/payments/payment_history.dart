import 'package:flutter/material.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
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

  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String formattedDate = DateFormat('MMMM dd, yyyy').format(dateTime);
    String formattedTime = DateFormat('hh:mm a').format(dateTime);
    return '$formattedDate at $formattedTime';
  }

  String paymentStatus(String paymentString) {
    return paymentString == 'N' ? 'Pending' : 'Paid';
  }

  String formatIndianRupees(double amount) {
    double roundedAmount = (amount * 100).round() / 100;
    NumberFormat indianRupeesFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    return indianRupeesFormat.format(roundedAmount).replaceAll('₹', '').trim();
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    DateFormat formatter = DateFormat("MMMM dd, yyyy '|' hh:mm a");
    return formatter.format(dateTime);
  }

  double taxCalc(double tax1, double tax2, double tax3) {
    return tax1 + tax2 + tax3;
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
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        title: LocalizationController.getInstance()
            .getTranslatedValue("Payment Records"),
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Dashboard()),
                    (Route<dynamic> route) => false,
              );
            },
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: applicationBaseController.paymentHistory.isEmpty
          ? Center(
        child: commonText(text: 'No Records found', color: Colors.grey),
      )
          : Obx(
            () => ListView.builder(
          itemCount: applicationBaseController.paymentHistory.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 8, horizontal: 15),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ExpansionTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      commonBoldText(
                        text:
                        'Name: ${applicationBaseController.paymentHistory[index].name ?? ""}',
                        fontSize: 14,
                      ),
                      const SizedBox(height: 6),
                      commonText(
                        text:
                        'Amount: ${applicationBaseController.paymentHistory[index].currency} ${formatIndianRupees(applicationBaseController.paymentHistory[index].amount ?? 0)}',
                        fontSize: 14,
                      ),
                      const SizedBox(height: 6),
                      commonText(
                        text:
                        'Tax: ${applicationBaseController.paymentHistory[index].currency} ${formatIndianRupees(taxCalc(applicationBaseController.paymentHistory[index].tax1Amount ?? 0, applicationBaseController.paymentHistory[index].tax2Amount ?? 0, applicationBaseController.paymentHistory[index].tax3Amount ?? 0))}',
                        fontSize: 14,
                      ),
                      const SizedBox(height: 6),
                      commonText(
                        text:
                        'Total: ${applicationBaseController.paymentHistory[index].currency} ${formatIndianRupees(applicationBaseController.paymentHistory[index].totalAmount ?? 0)}',
                        fontSize: 14,
                      ),
                      const SizedBox(height: 6),
                      commonText(
                        text:
                        'Method: ${applicationBaseController.paymentHistory[index].paymentChanel ?? "Not Updated"}',
                        fontSize: 14,
                      ),
                    ],
                  ),
                  collapsedBackgroundColor: Colors.white,
                  backgroundColor: Colors.white,
                  initiallyExpanded: _expandedList[index],
                  expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                  childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  children: [
                    commonText(
                      text:
                      'Reference: ${applicationBaseController.paymentHistory[index].paymentReference}',
                      fontSize: 13,
                    ),
                    const SizedBox(height: 8),
                    commonText(
                      text:
                      'Paid Date: ${formatDate(applicationBaseController.paymentHistory[index].paidDate.toString())}',
                      fontSize: 13,
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        final url = applicationBaseController
                            .paymentHistory[index].invoiceUrl;
                        if (url != null && url.isNotEmpty) {
                          launchUrl(Uri.parse(url));
                        }
                      },
                      child: commonText(
                        text:
                        'Invoice/Receipt: ${applicationBaseController.paymentHistory[index].invoiceUrl ?? 'Link not available'}',
                        fontSize: 13,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                  onExpansionChanged: (bool expanded) {
                    setState(() {
                      _expandedList[index] = expanded;
                    });
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
