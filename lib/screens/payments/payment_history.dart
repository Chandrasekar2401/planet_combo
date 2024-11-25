import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/screens/dashboard.dart';

class PaymentHistory extends StatefulWidget {
  const PaymentHistory({super.key});
  @override
  _PaymentHistoryState createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory> {
  late List<bool> _expandedList;

  final ApplicationBaseController applicationBaseController =
  Get.put(ApplicationBaseController.getInstance(), permanent: true);

  final RxBool isLoading = false.obs;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _expandedList = List<bool>.generate(20, (index) => false);
    _loadData();
    _startAutoRefresh();
  }

  Future<void> _loadData() async{
    isLoading.value = true;
    try {
      await applicationBaseController.getInvoiceList();
    } finally {
      isLoading.value = false;
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {  // Check if widget is still mounted
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
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

  String getPaymentMethod(String? channel) {
    if (channel == "1") {
      return "Paypal";
    } else if (channel == "0") {
      return "UPI";
    } else if (channel == "2") {
      return "Stripe";
    }else{
      return "Not Updated";
    }
  }

  Color getMethodColor(String method) {
    switch (method) {
      case "PayPal":
        return const Color(0xFF1546A0);  // Darker blue
      case "UPI":
        return const Color(0xFF6B0F8C);  // Darker purple
      default:
        return const Color(0xFF4A4A4A);  // Darker gray
    }
  }

  String findReqType(String type) {
    switch (type) {
      case "7":
        return "Chart Request";
      case "2":
        return "Daily Request";
      default:
        return "Special Request";
    }
  }

  double taxCalc(double tax1, double tax2, double tax3) {
    return tax1 + tax2 + tax3;
  }

  Widget buildPaymentCard(int index, dynamic payment) {
    final paymentMethod = getPaymentMethod(payment.paymentChanel.toString());
    final methodColor = getMethodColor(paymentMethod);

    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedList[index] = !_expandedList[index];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFF8F9FA),
                  const Color(0xFFF2F2F2),
                  const Color(0xFFECECEC),
                  const Color(0xFFE8E8E8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF8F9FA), Color(0xFFE8E8E8)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: const Radius.circular(20),
                      bottom: _expandedList[index] ? Radius.zero : const Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.payment_rounded,
                            color: methodColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              commonBoldText(
                                  text: payment.name,
                                  fontSize: 17,
                                  color: Colors.black87
                              ),
                              const SizedBox(height: 4),
                              commonBoldText(
                                text: '${payment.currency} ${formatIndianRupees(payment.totalAmount ?? 0)}',
                                fontSize: 14,
                                color: methodColor
                              ),
                              const SizedBox(height: 4),
                              commonText(
                                text: formatDate(payment.paidDate.toString()),
                                fontSize: 12,
                                color: Colors.black54
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _expandedList[index] ? Icons.expand_less : Icons.expand_more,
                          color: Colors.black,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: Container(),
                  secondChild: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.9),
                          Colors.white.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DetailRow(
                          icon: Icons.confirmation_number_outlined,
                          label: 'Chart ID',
                          value: payment.hid.toString(),
                          iconColor: const Color(0xFF4A4A4A),
                        ),
                        const SizedBox(height: 16),
                        DetailRow(
                          icon: Icons.payment_outlined,
                          label: 'Payment Method',
                          value: paymentMethod,
                          valueColor: methodColor,
                          iconColor: const Color(0xFF4A4A4A),
                        ),
                        const SizedBox(height: 16),
                        DetailRow(
                          icon: Icons.receipt_outlined,
                          label: 'Reference',
                          value: payment.paymentReference ?? '',
                          iconColor: const Color(0xFF4A4A4A),
                        ),
                        const SizedBox(height: 16),
                        if(payment.gatewayReference != '')DetailRow(
                          icon: Icons.receipt_outlined,
                          label: 'Gateway Reference',
                          value: payment.gatewayReference ?? '',
                          iconColor: const Color(0xFF4A4A4A),
                        ),
                        if(payment.gatewayReference != '')SizedBox(height: 16),
                        DetailRow(
                          icon: Icons.confirmation_number_outlined,
                          label: 'Request ID',
                          value: payment.requestId.toString() ?? '',
                          iconColor: const Color(0xFF4A4A4A),
                        ),
                        const SizedBox(height: 16),
                        DetailRow(
                          icon: Icons.category_outlined,
                          label: 'Request Type',
                          value: findReqType(payment.requestType.toString()),
                          iconColor: const Color(0xFF4A4A4A),
                        ),
                        const SizedBox(height: 16),
                        DetailRow(
                          icon: Icons.attach_money_outlined,
                          label: 'Amount',
                          value: '${payment.currency} ${formatIndianRupees(payment.amount ?? 0)}',
                          iconColor: const Color(0xFF4A4A4A),
                        ),
                        const SizedBox(height: 16),
                        DetailRow(
                          icon: Icons.calculate_outlined,
                          label: 'Tax',
                          value: '${payment.currency} ${formatIndianRupees(taxCalc(payment.tax1Amount ?? 0, payment.tax2Amount ?? 0, payment.tax3Amount ?? 0))}',
                          iconColor: const Color(0xFF4A4A4A),
                        ),
                        if (payment.invoiceUrl != null && payment.invoiceUrl.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  launchUrl(Uri.parse(payment.invoiceUrl));
                                },
                                icon: const Icon(
                                  Icons.receipt_long_outlined,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                label:  commonBoldText(text: 'View Invoice / Receipt', color: Colors.white, fontSize: 12),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: const Color(0xFFf34509),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  crossFadeState: _expandedList[index]
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFf2b20a), Color(0xFFf34509)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 14,),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          LocalizationController.getInstance()
              .getTranslatedValue("Payment Records"),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, color: Colors.white),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Dashboard()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: Obx(() {
      if (isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (applicationBaseController.invoiceListApiError.value.isNotEmpty ||
          applicationBaseController.paymentHistory.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                applicationBaseController.invoiceListApiError.value.isNotEmpty
                    ? Icons.error_outline
                    : Icons.receipt_long_outlined,
                size: 70,
                color: applicationBaseController.invoiceListApiError.value.isNotEmpty
                    ? Colors.red[400]
                    : Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: applicationBaseController.invoiceListApiError.value.isNotEmpty
                    ? BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                )
                    : null,
                child: Text(
                  applicationBaseController.invoiceListApiError.value.isNotEmpty
                      ? applicationBaseController.invoiceListApiError.value
                      : 'No Payment Records Found',
                  style: TextStyle(
                    fontSize: 16,
                    color: applicationBaseController.invoiceListApiError.value.isNotEmpty
                        ? Colors.red[700]
                        : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (applicationBaseController.invoiceListApiError.value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFf34509),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: applicationBaseController.paymentHistory.length,
          itemBuilder: (context, index) => buildPaymentCard(
            index,
            applicationBaseController.paymentHistory[index],
          ),
        ),
      );
    }),
    );
  }
}

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Color? iconColor;

  const DetailRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor ?? Colors.grey[600]),
        const SizedBox(width: 12),
        commonText(text:
          '$label: ',
          fontSize: 14,
          color: Colors.grey,
        ),
        Expanded(
          child: commonBoldText(text:
            value,
            fontSize: 14,
            color: valueColor ?? const Color(0xFF2D2D2D),
          ),
        ),
      ],
    );
  }
}