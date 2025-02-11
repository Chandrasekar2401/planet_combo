import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/api/api_callings.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:planetcombo/common/constant.dart';

import '../screens/dashboard.dart';
import '../screens/payments/payment_progress.dart';

class PaymentController extends GetxController {
  static PaymentController? _instance;

  static PaymentController getInstance() {
    _instance ??= PaymentController();
    return _instance!;
  }

  Constants constants = Constants();

  final ApplicationBaseController applicationBaseController =
  Get.put(ApplicationBaseController.getInstance(), permanent: true);

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
      var response = await APICallings.payByUpi(
          token: token,
          amount: amount,
          reqId: reqId,
          userId: userId
      );
      print(response!.body);
      var jsonBody = json.decode(response.body);
      print('pay now url response is $jsonBody');

      if (jsonBody['data'] != null) {
        var data = jsonBody['data'];
        // Check status first
        if(data['status'] == "false") {
          CustomDialog.cancelLoading(context);
          CustomDialog.showAlert(
              context,
              'Payment initialization failed: Server returned null values. Please contact support if the issue persists.',
              false,
              14
          );
          return;
        }

        var data1 = data['data'];
        String approvalUrl = "";

        if(kIsWeb) {
          if(data1['payment_url'] == null) {
            CustomDialog.cancelLoading(context);
            CustomDialog.showAlert(
                context,
                'Payment initialization failed: Payment URL not available. Please try again later.',
                false,
                14
            );
            return;
          }
          approvalUrl = data1['payment_url'];
        } else {
          if(data1['upi_intent'] == null) {
            CustomDialog.cancelLoading(context);
            CustomDialog.showAlert(
                context,
                'Payment initialization failed: UPI payment options not available. Please try again later.',
                false,
                14
            );
            return;
          }
          var findUrl = data1['upi_intent'];
          if(findUrl['gpay_link'] == null) {
            CustomDialog.cancelLoading(context);
            CustomDialog.showAlert(
                context,
                'Payment initialization failed: GPay payment link not available. Please try again later.',
                false,
                14
            );
            return;
          }
          approvalUrl = findUrl['gpay_link'];
        }

        var paymentId = jsonBody['paymentId'];
        String paymentReferenceId = paymentId.toString();
        CustomDialog.cancelLoading(context);
        await launchUrl(Uri.parse(approvalUrl));
        Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => PaymentProgressPage(
                  paymentReferenceNumber: paymentReferenceId,
                  onPaymentComplete: (String ) {  },
                )
            )
        );
      } else {
        CustomDialog.cancelLoading(context);
        if(applicationBaseController.paymentForHoroscope.value == true) {
          CustomDialog.okActionAlert(
              context,
              'Payment initialization failed: Invalid response from server (null values received). Please try again later.',
              'Ok',
              false,
              14,
                  () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Dashboard()),
                      (Route<dynamic> route) => false,
                );
              }
          );
        } else {
          CustomDialog.showAlert(
              context,
              'Payment initialization failed: Invalid response from server (null values received). Please try again later.',
              false,
              14
          );
        }
      }
    } catch (e) {
      CustomDialog.cancelLoading(context);
      print('Error in Upi Payment: $e');
      if(applicationBaseController.paymentForHoroscope.value == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
              (Route<dynamic> route) => false,
        );
      } else {
        CustomDialog.showAlert(
            context,
            'An unexpected error occurred during payment initialization. Please try again later.',
            false,
            14
        );
      }
    }
  }

  void payByStripe(String userId, int reqId, double amount, String token, context) async {
    try {
      CustomDialog.showLoading(context, 'Please wait');
      var response = await APICallings.payByStripe(token: token, amount: amount, reqId: reqId, userId: userId);
      print(response!.body);
      var jsonBody = json.decode(response.body);
      if (jsonBody['url'] != null) {
        // var data = jsonBody['data'];
        // var data1 = data['data'];
        String approvalUrl = jsonBody['url'];
        var paymentId = jsonBody['referenceId'] ?? "ID value not received";
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
        if(applicationBaseController.paymentForHoroscope.value == true){
          CustomDialog.okActionAlert(context, 'Payment initialization failed. Please try later', 'Ok', false, 14, (){
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Dashboard()),
                  (Route<dynamic> route) => false,
            );
          });
        }else{
          CustomDialog.showAlert(context, 'Payment initialization failed. Please try again or use an alternative payment method.', false, 14);
        }
      }
    } catch (e) {
      CustomDialog.cancelLoading(context);
      print('Error in Upi Payment: $e');
      if(applicationBaseController.paymentForHoroscope.value == true){
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
              (Route<dynamic> route) => false,
        );
      }else{
        CustomDialog.showAlert(context, 'An error occurred. Please try again later.', false, 14);
      }
    }
  }

}