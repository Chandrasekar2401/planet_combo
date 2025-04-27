import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/api/api_callings.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:planetcombo/common/constant.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'package:webview_flutter/webview_flutter.dart';
import '../screens/dashboard.dart';
import '../screens/payments/payment_progress.dart';

class PaymentController extends GetxController {
  static PaymentController? _instance;

  static PaymentController getInstance() {
    _instance ??= PaymentController();
    return _instance!;
  }

  final ApplicationBaseController applicationBaseController =
  Get.put(ApplicationBaseController.getInstance(), permanent: true);

  @override
  void onInit() {
    super.onInit();
  }

  /// ===================== **PayU Payment Flow** ===================== ///

  void payByUpi(String userId, int reqId, double amount, String token,String paymentType, BuildContext context) async {
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

        // Extract the transaction ID for payment reference
        String txnId = jsonBody['txnId'];

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

          // Navigate to PaymentProgressPage and remove all previous routes
          CustomDialog.cancelLoading(context);
          // Replace pushAndRemoveUntil with push to maintain the navigation stack
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PaymentProgressPage(
                paymentType: paymentType,
                paymentReferenceNumber: txnId,
                onPaymentComplete: (String status) {
                  if (status.toLowerCase() == 'completed' ||
                      status.toLowerCase() == 'success') {
                    onPaymentSuccess({'status': 'success'});
                  } else if (status.toLowerCase() == 'failed' ||
                      status.toLowerCase() == 'cancelled') {
                    onPaymentFailure({'status': 'failed'});
                  }
                },
              ),
            ),
          );
        } else {
          // ✅ Mobile: For iOS and Android
          CustomDialog.cancelLoading(context);

          // Create payment form HTML
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

          // Create WebView controller
          final WebViewController controller = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setBackgroundColor(const Color(0x00000000))
            ..setNavigationDelegate(
              NavigationDelegate(
                onProgress: (int progress) {
                  // You can show a loading indicator here if needed
                },
                onPageStarted: (String url) {
                  // Page loading started
                },
                onPageFinished: (String url) {
                  // Page finished loading
                },
                onWebResourceError: (WebResourceError error) {
                  // Handle errors
                  print("WebView error: ${error.description}");
                },
                onNavigationRequest: (NavigationRequest request) {
                  // Note: For mobile, we won't handle success/failure here
                  // Let the PaymentProgressPage handle the status checking
                  return NavigationDecision.navigate;
                },
              ),
            )
            ..loadHtmlString(paymentForm);

          // Show WebView in a full screen modal
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: const Text('Payment'),
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to PaymentProgressPage after closing WebView
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => PaymentProgressPage(
                            paymentType: paymentType,
                            paymentReferenceNumber: txnId,
                            onPaymentComplete: (String status) {
                              if (status.toLowerCase() == 'completed' ||
                                  status.toLowerCase() == 'success') {
                                onPaymentSuccess({'status': 'success'});
                              } else if (status.toLowerCase() == 'failed' ||
                                  status.toLowerCase() == 'cancelled') {
                                onPaymentFailure({'status': 'failed'});
                              }
                            },
                          ),
                        ),
                            (Route<dynamic> route) => false,
                      );
                    },
                  ),
                ),
                body: SafeArea(
                  child: WebViewWidget(controller: controller),
                ),
              ),
            ),
          );

          // After WebView is dismissed, navigate to PaymentProgressPage
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => PaymentProgressPage(
                paymentType: paymentType,
                paymentReferenceNumber: txnId,
                onPaymentComplete: (String status) {
                  if (status.toLowerCase() == 'completed' ||
                      status.toLowerCase() == 'success') {
                    onPaymentSuccess({'status': 'success'});
                  } else if (status.toLowerCase() == 'failed' ||
                      status.toLowerCase() == 'cancelled') {
                    onPaymentFailure({'status': 'failed'});
                  }
                },
              ),
            ),
                (Route<dynamic> route) => false,
          );
        }
      } else {
        throw Exception("Invalid response from server.");
      }
    } catch (e) {
      CustomDialog.cancelLoading(context);
      print("Error in PayU Payment: $e");
      CustomDialog.showAlert(context, "An error occurred. Please try again later.", false, 14);
    }
  }

  void onPaymentSuccess(dynamic response) {
    print("Payment Success: $response");
    Get.snackbar("Success", "Payment Successful!", backgroundColor: Colors.green);
  }

  void onPaymentFailure(dynamic response) {
    print("Payment Failure: $response");
    Get.snackbar("Failed", "Payment Failed! Try Again.", backgroundColor: Colors.red);
  }

  void onPaymentCancel(Map? response) {
    print("Payment Cancelled: $response");
    Get.snackbar("Cancelled", "Payment Cancelled.", backgroundColor: Colors.orange);
  }

  /// ===================== **Other Payment Methods (Unchanged)** ===================== ///
  void payByPaypal(String userId, int reqId, double amount,String paymentType, String token, context) async {
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
          builder: (_) => PaymentProgressPage(
             paymentType: paymentType,
              paymentReferenceNumber: paymentReferenceId,
              onPaymentComplete: (String) {}),
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

  void payByStripe(String userId, int reqId, double amount,String paymentType, String token, context) async {
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
          builder: (_) => PaymentProgressPage(paymentType: paymentType, paymentReferenceNumber: paymentReferenceId, onPaymentComplete: (String) {}),
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