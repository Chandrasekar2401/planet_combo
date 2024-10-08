import 'package:flutter/material.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:planetcombo/controllers/payment_controller.dart';
import 'package:planetcombo/models/pending_payment_list.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PendingPaymentsPage extends StatefulWidget {
  const PendingPaymentsPage({super.key});

  @override
  State<PendingPaymentsPage> createState() => _PendingPaymentsPageState();
}

class _PendingPaymentsPageState extends State<PendingPaymentsPage> {

  final ApplicationBaseController applicationBaseController =
  Get.put(ApplicationBaseController.getInstance(), permanent: true);
  
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
        title: LocalizationController.getInstance().getTranslatedValue("Pending Payments"),
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // Add home button functionality
            },
            icon: const Icon(Icons.home_outlined),
          )
        ],
      ),
      body: Obx(() {
        if (applicationBaseController.pendingPaymentsList.isEmpty) {
          return Center(child: Text("No pending payments"));
        }
        return ListView.builder(
          itemCount: applicationBaseController.pendingPaymentsList.length,
          itemBuilder: (context, index) {
            final payment = applicationBaseController.pendingPaymentsList[index];
            return PaymentListItem(payment: payment);
          },
        );
      }),
    );
  }
}

class PaymentListItem extends StatelessWidget {
  final  PendingPaymentList payment; // Change to the actual type of your payment item
  PaymentListItem({super.key, required this.payment});

  final PaymentController paymentController =
  Get.put(PaymentController.getInstance(), permanent: true);

  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  String findReqType(String type){
    if(type == "7"){
      return "Chart Request";
    }else if(type == "2"){
      return "Daily Request";
    }else{
      return "Special Request";
    }
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

  double taxCalc(double tax1, double tax2, double tax3){
    double totalTax = tax1 + tax2 + tax3;
    return totalTax;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 0.2,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 17),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 150, child: commonBoldText(text:'Name ', fontSize: 14)),
                    commonBoldText(text: "-  ${payment.name ?? "Not Available"}", fontSize: 14)
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    SizedBox(width: 150, child: commonText(text: 'Type ',  color: Colors.black87, fontSize: 11)),
                    commonText(text: '-  ${findReqType(payment.requestType.toString())}', fontSize: 11),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    SizedBox(width: 150, child: commonText(text: 'Req Id ',  color: Colors.black87, fontSize: 11)),
                    commonText(text: '-  ${payment.requestId.toString()}', fontSize: 11),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width:150, child: commonText(text:'Charge ', color: Colors.black87, fontSize: 11)),
                    commonText(text:'-  ${payment.currency}' ' ${formatIndianRupees(payment.amount!)}', fontSize: 11),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 150, child: commonText(text: 'Tax ', color: Colors.black87, fontSize: 11)),
                    commonText(text: '-  ${payment.currency}' ' ${formatIndianRupees(taxCalc(payment.tax1Amount ?? 0, payment.tax2Amount ?? 0, payment.tax3Amount ?? 0))}', fontSize: 11),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                        width: 150,
                        child: commonText(text: 'Payable amount ', fontSize: 12)),
                    commonText(text: '-  ${payment.currency} ' ' ${formatIndianRupees(payment.totalAmount!)}', color: Colors.green, fontSize: 12),
                  ],
                ),
              ],
            ),
            GradientButton(
              title: LocalizationController.getInstance().getTranslatedValue("Pay Now"),
              buttonHeight: 30,
              textColor: Colors.white,
              buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
              onPressed: (Offset buttonOffset) async {
                // Implement payment logic here
                // paymentController.payByUpi(payment.userId!, payment.requestId!, payment.amount!, appLoadController.loggedUserData.value.token!, context);
                paymentController.payByPaypal(payment.userId!, payment.requestId!, payment.amount!, appLoadController.loggedUserData.value.token!, context);
              },
            )
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No date';
    return '${date.month}/${date.day}/${date.year}';
  }
}