import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/api/api_callings.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:planetcombo/common/constant.dart';
import 'package:http/http.dart' as http;
import 'package:payu_checkoutpro_flutter/payu_checkoutpro_flutter.dart';
import 'package:payu_checkoutpro_flutter/PayUConstantKeys.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import '../screens/payments/payment_progress.dart';

class PaymentController extends GetxController implements PayUCheckoutProProtocol {
  static PaymentController? _instance;

  static PaymentController getInstance() {
    _instance ??= PaymentController();
    return _instance!;
  }

  final ApplicationBaseController applicationBaseController =
  Get.put(ApplicationBaseController.getInstance(), permanent: true);

  late PayUCheckoutProFlutter _checkoutPro; // ✅ PayU instance

  @override
  void onInit() {
    super.onInit();
    _checkoutPro = PayUCheckoutProFlutter(this); // ✅ Initialize PayU SDK
  }

  /// ===================== **PayU Payment Flow** ===================== ///
  void payByUpi(String userId, int reqId, double amount, String token, BuildContext context) async {
    CustomDialog.showLoading(context, 'Please wait');

    try {
      var response = await APICallings.payByUpi(
        token: token,
        amount: amount,
        reqId: reqId,
        userId: userId,
      );

      print(response!.body);
      var jsonBody = json.decode(response.body);
      print('PayU Response: $jsonBody');

      if (jsonBody != null && jsonBody.containsKey('paymentUrl')) {
        // Ensure all required parameters are present
        if (!jsonBody.containsKey('key') ||
            !jsonBody.containsKey('txnId') ||
            !jsonBody.containsKey('amount') ||
            !jsonBody.containsKey('productInfo') ||
            !jsonBody.containsKey('firstName') ||
            !jsonBody.containsKey('email') ||
            !jsonBody.containsKey('phone') ||
            !jsonBody.containsKey('surl') ||
            !jsonBody.containsKey('furl') ||
            !jsonBody.containsKey('hash')) {
          throw Exception("Mandatory parameters are missing from PayU response.");
        }

        if (kIsWeb) {
          // ✅ Web: Submit Form Data via HTML
          String paymentForm = '''
          <html>
          <body onload="document.forms['payuForm'].submit()">
            <form name="payuForm" method="post" action="${jsonBody['paymentUrl']}">
              <input type="hidden" name="key" value="${jsonBody['key']}">
              <input type="hidden" name="txnid" value="${jsonBody['txnId']}">
              <input type="hidden" name="amount" value="${jsonBody['amount']}">
              <input type="hidden" name="productinfo" value="${jsonBody['productInfo']}">
              <input type="hidden" name="firstname" value="${jsonBody['firstName']}">
              <input type="hidden" name="email" value="${jsonBody['email']}">
              <input type="hidden" name="phone" value="${jsonBody['phone']}">
              <input type="hidden" name="surl" value="${jsonBody['surl']}">
              <input type="hidden" name="furl" value="${jsonBody['furl']}">
              <input type="hidden" name="hash" value="${jsonBody['hash']}">
            </form>
          </body>
          </html>
        ''';

          // Open in a new tab using Blob URL
          final blob = html.Blob([paymentForm], 'text/html');
          final url = html.Url.createObjectUrlFromBlob(blob);
          html.window.open(url, "_blank");

        } else {
          // ✅ Mobile: Use PayU SDK
          Map<String, dynamic> additionalParams = {
            "payment_related_details_for_mobile_sdk": jsonBody['hash'],
          };

          Map<String, dynamic> payUPaymentParams = {
            PayUPaymentParamKey.key: jsonBody['key'],
            PayUPaymentParamKey.transactionId: jsonBody['txnId'],
            PayUPaymentParamKey.amount: jsonBody['amount'].toString(),
            PayUPaymentParamKey.productInfo: jsonBody['productInfo'],
            PayUPaymentParamKey.firstName: jsonBody['firstName'],
            PayUPaymentParamKey.email: jsonBody['email'],
            PayUPaymentParamKey.phone: jsonBody['phone'],
            PayUPaymentParamKey.android_surl: jsonBody['surl'],
            PayUPaymentParamKey.android_furl: jsonBody['furl'],
            PayUPaymentParamKey.ios_surl: jsonBody['surl'],
            PayUPaymentParamKey.ios_furl: jsonBody['furl'],
            PayUPaymentParamKey.environment: "0",
            PayUPaymentParamKey.additionalParam: additionalParams,
            PayUPaymentParamKey.userCredential: null,
          };

          print('Sending PayU Params: ${payUPaymentParams.toString()}');

          _checkoutPro.openCheckoutScreen(
            payUPaymentParams: payUPaymentParams,
            payUCheckoutProConfig: {},
          );
        }

        CustomDialog.cancelLoading(context);
      } else {
        throw Exception("Invalid response from server.");
      }
    } catch (e) {
      CustomDialog.cancelLoading(context);
      print("Error in PayU Payment: $e");
      CustomDialog.showAlert(context, "An error occurred. Please try again later.", false, 14);
    }
  }



  @override
  generateHash(Map response) {
    // This method will be called by PayU to get the hash from your server
    Map<String, String> hashResponse = {
      response[PayUHashConstantsKeys.hashName]: "GENERATED_HASH_FROM_BACKEND"
    };
    _checkoutPro.hashGenerated(hash: hashResponse);
  }

  @override
  onPaymentSuccess(dynamic response) {
    print("Payment Success: $response");
    Get.snackbar("Success", "Payment Successful!", backgroundColor: Colors.green);
  }

  @override
  onPaymentFailure(dynamic response) {
    print("Payment Failure: $response");
    Get.snackbar("Failed", "Payment Failed! Try Again.", backgroundColor: Colors.red);
  }

  @override
  onPaymentCancel(Map? response) {
    print("Payment Cancelled: $response");
    Get.snackbar("Cancelled", "Payment Cancelled.", backgroundColor: Colors.orange);
  }

  @override
  onError(Map? response) {
    print("Payment Error: $response");
    Get.snackbar("Error", "An Error Occurred!", backgroundColor: Colors.red);
  }

  /// ===================== **Other Payment Methods (Unchanged)** ===================== ///
  void payByPaypal(String userId, int reqId, double amount, String token, context) async {
    try {
      CustomDialog.showLoading(context, 'Please wait');

      var response = await APICallings.payByPaypal(token: token, amount: amount, reqId: reqId, userId: userId);
      print(response!.body);
      var jsonBody = json.decode(response.body);
      if (jsonBody['approvalUrl'] != null) {
        String approvalUrl = jsonBody['approvalUrl'];
        String paymentReferenceId = jsonBody['paymentReferenceId'];
        CustomDialog.cancelLoading(context);
        await launchUrl(Uri.parse(approvalUrl));

        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => PaymentProgressPage(paymentReferenceNumber: paymentReferenceId, onPaymentComplete: (String) {}),
        ));
      } else {
        CustomDialog.cancelLoading(context);
        CustomDialog.showAlert(context, 'Payment initialization failed. Please try again.', true, 14);
      }
    } catch (e) {
      CustomDialog.cancelLoading(context);
      print('Error in PayPal: $e');
      CustomDialog.showAlert(context, 'An error occurred. Please try again later.', false, 14);
    }
  }

  void payByStripe(String userId, int reqId, double amount, String token, context) async {
    try {
      CustomDialog.showLoading(context, 'Please wait');
      var response = await APICallings.payByStripe(token: token, amount: amount, reqId: reqId, userId: userId);
      print(response!.body);
      var jsonBody = json.decode(response.body);
      if (jsonBody['url'] != null) {
        String approvalUrl = jsonBody['url'];
        var paymentId = jsonBody['referenceId'] ?? "ID value not received";
        String paymentReferenceId = paymentId.toString();
        CustomDialog.cancelLoading(context);
        await launchUrl(Uri.parse(approvalUrl));

        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => PaymentProgressPage(paymentReferenceNumber: paymentReferenceId, onPaymentComplete: (String) {}),
        ));
      } else {
        CustomDialog.cancelLoading(context);
        CustomDialog.showAlert(context, 'Payment initialization failed. Please try again.', false, 14);
      }
    } catch (e) {
      CustomDialog.cancelLoading(context);
      print('Error in Stripe: $e');
      CustomDialog.showAlert(context, 'An error occurred. Please try again later.', false, 14);
    }
  }
}
