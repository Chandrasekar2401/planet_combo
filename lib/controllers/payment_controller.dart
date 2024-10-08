import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/api/api_callings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:planetcombo/common/constant.dart';

import '../screens/payments/payment_progress.dart';

class PaymentController extends GetxController {
  static PaymentController? _instance;

  static PaymentController getInstance() {
    _instance ??= PaymentController();
    return _instance!;
  }

  Constants constants = Constants();

  void addOfflineMoney(userId, email, amount, token, context) async{
      CustomDialog.showLoading(context, 'Please wait');
      int money = int.parse(amount);
      var response = await APICallings.addOfflineMoney(currency: constants.currency, token: token, amount: money, email: email, userId: userId);
      print(response!.body);
      CustomDialog.cancelLoading(context);
      var jsonBody = json.decode(response.body);
      if(jsonBody['Status'] == 'Success'){
        CustomDialog.showAlert(context, jsonBody['Message'], true, 14);
      }
  }

  void payByPaypal(String userId, int reqId, double amount, String token, context) async {
    try {
      CustomDialog.showLoading(context, 'Please wait');

      var response = await APICallings.payByPaypal(token: token, amount: amount, reqId: reqId, userId: userId);
      print(response!.body);
      var jsonBody = json.decode(response.body);
      if (jsonBody['approvalUrl'] != null) {
        String approvalUrl = jsonBody['approvalUrl'];
        String paymentReferenceId = jsonBody['paymentReferenceId'];
        // Store the paymentReferenceId if needed for later verification
        // You might want to save this in a state management solution or pass it to the next screen
        CustomDialog.cancelLoading(context);
        // Open the PayPal approval URL
        await launchUrl(Uri.parse(approvalUrl));
        // After opening the URL, you might want to navigate to a confirmation page
        // or set up a listener for the PayPal callback
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => PaymentProgressPage(paymentReferenceNumber: paymentReferenceId, onPaymentComplete: (String ) {  },)));
      } else {
        CustomDialog.cancelLoading(context);
        CustomDialog.showAlert(context, 'Payment initialization failed. Please try again or use an alternative payment method.', true, 14);
      }
    } catch (e) {
      CustomDialog.cancelLoading(context);
      print('Error in payByPaypal: $e');
      CustomDialog.showAlert(context, 'An error occurred. Please try again later.', false, 14);
    }
  }

  void payByUpi(String userId, int reqId, double amount, String token, context) async {
    try {
      CustomDialog.showLoading(context, 'Please wait');
      var response = await APICallings.payByUpi(token: token, amount: amount, reqId: reqId, userId: userId);
      print(response!.body);
      var jsonBody = json.decode(response.body);
      if (jsonBody['data'] != null) {
        var data = jsonBody['data'];
        var data1 = data['data'];
        String approvalUrl = data1['payment_url'];
        var paymentId = jsonBody['paymentId'];
        String paymentReferenceId = paymentId.toString();
        // Store the paymentReferenceId if needed for later verification
        // You might want to save this in a state management solution or pass it to the next screen
        CustomDialog.cancelLoading(context);
        // Open the PayPal approval URL
        await launchUrl(Uri.parse(approvalUrl));
        // After opening the URL, you might want to navigate to a confirmation page
        // or set up a listener for the PayPal callback
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => PaymentProgressPage(paymentReferenceNumber: paymentReferenceId, onPaymentComplete: (String ) {  },)));
      } else {
        CustomDialog.cancelLoading(context);
        CustomDialog.showAlert(context, 'Payment initialization failed. Please try again or use an alternative payment method.', false, 14);
      }
    } catch (e) {
      CustomDialog.cancelLoading(context);
      print('Error in Upi Payment: $e');
      CustomDialog.showAlert(context, 'An error occurred. Please try again later.', false, 14);
    }
  }

}