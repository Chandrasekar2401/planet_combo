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
import '../screens/services/horoscope_services.dart';
import 'package:planetcombo/common/app_logger.dart';

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

      AppLogger.d(response!.body);
      var jsonBody = json.decode(response.body);
      AppLogger.d('PayU Response: $jsonBody');

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

          // surl = success url, furl = failure/cancel url. Once PayU
          // redirects to either, our backend handles the webhook and
          // returns a non-renderable response (which is what was showing
          // up as a blank/white page in the WebView). Detect those URLs
          // in the navigation delegate and pop out of the WebView before
          // the user ever sees the blank response.
          final String surlHost = Uri.parse(jsonBody['surl']).host;
          final String surlPath = Uri.parse(jsonBody['surl']).path;
          final String furlHost = Uri.parse(jsonBody['furl']).host;
          final String furlPath = Uri.parse(jsonBody['furl']).path;

          // Use a result flag so we know whether the user actually went
          // through a payment attempt (success / failure) or simply
          // cancelled before submitting anything.
          String? paymentOutcome; // 'success' | 'failed' | null

          // Guard against popping the WebView twice (e.g. surl arrives just
          // after the user-launched UPI flow also tries to pop).
          bool webviewPopped = false;
          void popWebviewOnce(String outcome) {
            if (webviewPopped) return;
            paymentOutcome = outcome;
            webviewPopped = true;
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          }

          late final WebViewController controller;
          controller = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setBackgroundColor(const Color(0x00000000))
            ..setNavigationDelegate(
              NavigationDelegate(
                onWebResourceError: (WebResourceError error) {
                  AppLogger.d("WebView error: ${error.description}");
                },
                onNavigationRequest: (NavigationRequest request) {
                  final uri = Uri.tryParse(request.url);
                  if (uri != null) {
                    // PayU emits UPI deep links (upi://, phonepe://, tez://,
                    // paytmmp://, intent://...) when the user picks a UPI
                    // app. WebView itself can't resolve those schemes —
                    // hand them off to the OS so the UPI chooser opens
                    // GPay / PhonePe / Paytm / BHIM.
                    final scheme = uri.scheme.toLowerCase();
                    final isWebScheme = scheme == 'http' ||
                        scheme == 'https' ||
                        scheme == 'about' ||
                        scheme == 'data' ||
                        scheme == 'blob' ||
                        scheme.isEmpty;
                    if (!isWebScheme) {
                      launchUrl(uri, mode: LaunchMode.externalApplication)
                          .then((opened) {
                        if (!opened) {
                          showFailedToast(
                              'No UPI app found. Install GPay, PhonePe, Paytm or BHIM and try again.');
                          return;
                        }
                        // UPI app is now in foreground for the user. The
                        // WebView is dead weight (PayU's web SDK is waiting
                        // on a JS callback that never arrives via the
                        // external app), so close it and hand off to
                        // PaymentProgressPage — it will poll the backend
                        // and show the same success-alert / redirect flow
                        // the web QR path uses.
                        popWebviewOnce('success');
                      }).catchError((e) {
                        showFailedToast(
                            'Unable to open UPI app: ${e.toString()}');
                        return false;
                      });
                      return NavigationDecision.prevent;
                    }

                    final isSurl = uri.host == surlHost && uri.path == surlPath;
                    final isFurl = uri.host == furlHost && uri.path == furlPath;
                    if (isSurl || isFurl) {
                      // Pop the WebView Scaffold; the awaiting code below
                      // will then continue with the right destination.
                      popWebviewOnce(isSurl ? 'success' : 'failed');
                      return NavigationDecision.prevent;
                    }
                  }
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
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                body: SafeArea(
                  child: WebViewWidget(controller: controller),
                ),
              ),
            ),
          );

          // After WebView is dismissed:
          //  - If the user got far enough that PayU redirected to surl/furl,
          //    open PaymentProgressPage (kept on top of Dashboard).
          //  - Otherwise the user cancelled before submitting. For horoscope
          //    payments the record is already created on the backend, so
          //    route them to the services list (with the new record visible
          //    and editable later) instead of leaving them on the add flow.
          if (paymentOutcome != null) {
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
          } else if (paymentType == 'horoscope' && context.mounted) {
            applicationBaseController.updateHoroscopeUiList();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HoroscopeServices()),
              (Route<dynamic> route) => false,
            );
          }
        }
      } else {
        throw Exception("Invalid response from server.");
      }
    } catch (e) {
      CustomDialog.cancelLoading(context);
      AppLogger.d("Error in PayU Payment: $e");
      CustomDialog.showAlert(context, "An error occurred. Please try again later.", false, 14);
    }
  }

  void onPaymentSuccess(dynamic response) {
    AppLogger.d("Payment Success: $response");
    Get.snackbar("Success", "Payment Successful!", backgroundColor: Colors.green);
  }

  void onPaymentFailure(dynamic response) {
    AppLogger.d("Payment Failure: $response");
    Get.snackbar("Failed", "Payment Failed! Try Again.", backgroundColor: Colors.red);
  }

  void onPaymentCancel(Map? response) {
    AppLogger.d("Payment Cancelled: $response");
    Get.snackbar("Cancelled", "Payment Cancelled.", backgroundColor: Colors.orange);
  }

  /// ===================== **Other Payment Methods (Unchanged)** ===================== ///
  void payByPaypal(String userId, int reqId, double amount,String paymentType, String token, context) async {
    try {
      CustomDialog.showLoading(context, 'Please wait');

      var response = await APICallings.payByPaypal(token: token, amount: amount, reqId: reqId, userId: userId);
      AppLogger.d(response!.body);
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
      AppLogger.d('Error in PayPal: $e');
      CustomDialog.showAlert(context, 'An error occurred. Please try again later.', false, 14);
    }
  }

  void payByStripe(String userId, int reqId, double amount,String paymentType, String token, context) async {
    try {
      CustomDialog.showLoading(context, 'Please wait');
      var response = await APICallings.payByStripe(token: token, amount: amount, reqId: reqId, userId: userId);
      AppLogger.d(response!.body);
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
      AppLogger.d('Error in Stripe: $e');
      CustomDialog.showAlert(context, 'An error occurred. Please try again later.', false, 14);
    }
  }
}