import 'dart:async';

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

  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      if (mounted) {
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    if (!applicationBaseController.pendingPayment.value) {
      await applicationBaseController.getUserPendingPayments();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left_rounded, size: 21,),
        ),
        title: LocalizationController.getInstance()
            .getTranslatedValue("Pending Payments"),
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
        centerTitle: true,
        actions: [
          Row(
            children: [
              const Icon(Icons.payment_outlined, color: Colors.white, size: 16),
              commonBoldText(
                  text: ' - ${appLoadController.loggedUserData.value.ucurrency!}',
                  color: Colors.white,
                  fontSize: 12),
              const SizedBox(width: 10)
            ],
          )
        ],
      ),
      body: Obx(() {
      // Show loading indicator
      if (applicationBaseController.pendingPayment.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // Show error if exists
      if (applicationBaseController.pendingPaymentsError.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 70,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  applicationBaseController.pendingPaymentsError.value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red[700],
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
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
            ],
          ),
        );
      }

      // Show empty state
      if (applicationBaseController.pendingPaymentsList.isEmpty) {
        return const Center(child: Text("No pending payments"));
      }

      // Show list of payments
      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: applicationBaseController.pendingPaymentsList.length,
          itemBuilder: (context, index) {
            final payment = applicationBaseController.pendingPaymentsList[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PaymentCard(payment: payment),
            );
          },
        ),
      );
    }),
    );
  }
}

class PaymentCard extends StatelessWidget {
  final PendingPaymentList payment;

  PaymentCard({super.key, required this.payment});

  final PaymentController paymentController =
  Get.put(PaymentController.getInstance(), permanent: true);

  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  Color getRequestTypeColor(String type) {
    switch (type) {
      case "7":
        return Colors.blue;
      case "2":
        return Colors.green;
      default:
        return Colors.orange;
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

  String formatIndianRupees(double amount) {
    double roundedAmount = (amount * 100).round() / 100;
    NumberFormat indianRupeesFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    String formattedAmount = indianRupeesFormat
        .format(roundedAmount)
        .replaceAll('₹', '')
        .trim();
    return formattedAmount;
  }

  double taxCalc(double tax1, double tax2, double tax3) {
    return tax1 + tax2 + tax3;
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    DateFormat formatter = DateFormat("MMMM dd, yyyy");
    return formatter.format(dateTime);
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left color indicator
            Container(
              width: 8,
              decoration: BoxDecoration(
                color: getRequestTypeColor(payment.requestType.toString()),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Request type and details
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Request Type Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: getRequestTypeColor(payment.requestType.toString())
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              findReqType(payment.requestType.toString()),
                              style: TextStyle(
                                color: getRequestTypeColor(
                                    payment.requestType.toString()),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            payment.name ?? "Not Available",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DetailRow(
                            label: 'Chart ID',
                            value: payment.hid.toString(),
                          ),
                          DetailRow(
                            label: 'Creation Date',
                            value: formatDate(payment.creationDate.toString()),
                          ),
                          DetailRow(
                            label: 'Request ID',
                            value: payment.requestId.toString(),
                          ),
                          DetailRow(
                            label: 'Charge',
                            value:
                            '${payment.currency} ${formatIndianRupees(payment.amount!)}',
                          ),
                          DetailRow(
                            label: 'Tax',
                            value:
                            '${payment.currency} ${formatIndianRupees(taxCalc(payment.tax1Amount ?? 0, payment.tax2Amount ?? 0, payment.tax3Amount ?? 0))}',
                          ),
                        ],
                      ),
                    ),
                    // Amount and Pay Now button
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Total Amount',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${payment.currency} ${formatIndianRupees(payment.totalAmount!)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 180, // Fixed maximum width
                            ),
                            child: GradientButton(
                              title: LocalizationController.getInstance()
                                  .getTranslatedValue("Pay Now"),
                              buttonHeight: 36,
                              textColor: Colors.white,
                              buttonColors: const [
                                Color(0xFFf2b20a),
                                Color(0xFFf34509)
                              ],
                              onPressed: (Offset buttonOffset) async {
                                if (appLoadController.loggedUserData!.value.ucurrency!
                                    .toLowerCase()
                                    .compareTo('INR'.toLowerCase()) ==
                                    0) {
                                  paymentController.payByUpi(
                                      payment.userId!,
                                      payment.requestId!,
                                      payment.totalAmount!,
                                      appLoadController.loggedUserData.value.token!,
                                      context);
                                }else if (appLoadController.loggedUserData!.value.ucurrency!
                                    .toLowerCase()
                                    .compareTo('AED'.toLowerCase()) ==
                                    0) {
                                  paymentController.payByStripe(
                                      payment.userId!,
                                      payment.requestId!,
                                      payment.totalAmount!,
                                      appLoadController.loggedUserData.value.token!,
                                      context);
                                } else {
                                  paymentController.payByStripe(
                                      payment.userId!,
                                      payment.requestId!,
                                      payment.totalAmount!,
                                      appLoadController.loggedUserData.value.token!,
                                      context);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}