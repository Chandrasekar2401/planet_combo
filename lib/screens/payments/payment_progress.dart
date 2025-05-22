import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/api/api_endpoints.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:get/get.dart';
import 'package:planetcombo/screens/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/horoscope_services.dart';
import '../predictions/predictions.dart';
import '../services/horoscope_services.dart';

class PaymentProgressPage extends StatefulWidget {
  final String paymentType;
  final String paymentReferenceNumber;
  final Function(String) onPaymentComplete;

  const PaymentProgressPage({
    super.key,
    required this.paymentType,
    required this.paymentReferenceNumber,
    required this.onPaymentComplete,
  });

  @override
  _PaymentProgressPageState createState() => _PaymentProgressPageState();
}

class _PaymentProgressPageState extends State<PaymentProgressPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Timer _timer;
  late Timer _redirectTimer;
  String _paymentStatus = 'Pending';
  int _remainingSeconds = 240; // 4 minutes in seconds
  bool _canGoBack = true; // Allow back button by default

  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  final ApplicationBaseController applicationBaseController =
  Get.put(ApplicationBaseController.getInstance(), permanent: true);

  final HoroscopeServiceController horoscopeServiceController =
  Get.put(HoroscopeServiceController.getInstance(), permanent: true);

  String paymentResponse(String paymentType){
    if(paymentType == 'horoscope'){
      return 'Payment successful. Your horoscope will be ready in 24-36 hours';
    }else if(paymentType == 'daily'){
      return 'Payment successful. Your daily prediction request is created and you will be notified when it is ready';
    }else{
      return 'Payment successful. Your questions are saved,and you will be notified when predictions are ready';
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Start periodic payment status check
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkPaymentStatus();
    });

    // Start redirect timer
    _redirectTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _redirectTimer.cancel();
          _timer.cancel();
          _showTimeoutDialog();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    _redirectTimer.cancel();
    super.dispose();
  }

  Future<void> _checkPaymentStatus() async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "token": appLoadController.loggedUserData.value.token!
    };
    try {
      final response = await http.get(
          Uri.parse(APIEndPoints.paymentStatusCheck+widget.paymentReferenceNumber),
          headers: headers
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _paymentStatus = data['status'];
        });

        if (_paymentStatus.toLowerCase() == 'completed' || _paymentStatus.toLowerCase() == 'success') {
          _timer.cancel();
          _redirectTimer.cancel();
          setState(() {
            _canGoBack = false; // Prevent going back after success
          });
          _showPaymentCompleteToast();
          widget.onPaymentComplete(_paymentStatus);
        } else if (_paymentStatus.toLowerCase() == 'cancelled' || _paymentStatus.toLowerCase() == 'failed') {
          _timer.cancel();
          _redirectTimer.cancel();
          _showFailedToast();
          widget.onPaymentComplete(_paymentStatus);
        }
      }
    } catch (e) {
      print('Failed to check payment status: $e');
    }
  }

  void _showPaymentCompleteToast() async{
    final prefs = await SharedPreferences.getInstance();
    CustomDialog.okActionAlert(context, paymentResponse(widget.paymentType), 'OK', true, 14, (){
      applicationBaseController.updateHoroscopeUiList();
      if(widget.paymentType == 'horoscope'){
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HoroscopeServices()),
              (Route<dynamic> route) => false,
        );
      }else{
        String? hid = prefs.getString('paymentHid');
        _getUserPredictions(hid!);
      }

    });
  }

  Future<void> _getUserPredictions(String hid) async {
    horoscopeServiceController.isLoading.value = true;
    CustomDialog.showLoading(context, 'Please wait');
    try {
      bool result = await horoscopeServiceController.getUserPredictions(hid)
          .timeout(const Duration(seconds: 30));
      print('API Result: $result'); // Debug log

      if (mounted) {
        CustomDialog.cancelLoading(context);
        horoscopeServiceController.isLoading.value = false;

        if (result == true) {
          print('Navigating to Predictions');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Predictions()),
                (Route<dynamic> route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No prediction data available'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } on TimeoutException catch (_) {
      if (mounted) {
        CustomDialog.cancelLoading(context);
        horoscopeServiceController.isLoading.value = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Request timed out, please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        CustomDialog.cancelLoading(context);
        horoscopeServiceController.isLoading.value = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showFailedToast() {
    CustomDialog.okActionAlert(context, 'Payment failed please try again', 'OK', false, 14, (){
      Navigator.pop(context); // Go back to previous screen instead of dashboard
    });
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Payment Time Expired'),
          content: const Text('The payment session has timed out. Would you like to try again or return to the previous screen?'),
          actions: [
            TextButton(
              child: const Text('Return'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to previous screen
              },
            ),
            TextButton(
              child: Text('Try Again'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // Reset timers and status to try again
                setState(() {
                  _remainingSeconds = 240;
                  _paymentStatus = 'Pending';
                });
                _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
                  _checkPaymentStatus();
                });
                _redirectTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
                  setState(() {
                    if (_remainingSeconds > 0) {
                      _remainingSeconds--;
                    } else {
                      _redirectTimer.cancel();
                      _timer.cancel();
                      _showTimeoutDialog();
                    }
                  });
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmCancel() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Payment?'),
          content: Text('Are you sure you want to cancel this payment process?'),
          actions: [
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to previous screen
              },
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_canGoBack) {
          _confirmCancel();
          return false;
        }
        return false; // Prevent back navigation after successful payment
      },
      child: Scaffold(
        appBar: GradientAppBar(
          colors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
          centerTitle: true,
          title: "Payment Progress",
          leading: _canGoBack ? IconButton(
            icon: Icon(Icons.chevron_left_rounded, size: 21),
            onPressed: _confirmCancel,
          ) : null,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (_, child) {
                  return Transform.rotate(
                    angle: _controller.value * 2 * math.pi,
                    child: child,
                  );
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.orange, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'inr' ?
                    SizedBox(height: 35, child: SvgPicture.asset('assets/svg/upi-icon.svg')) :
                    SizedBox(height: 40, child: SvgPicture.asset('assets/svg/stripe.svg')),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Payment Reference: ${widget.paymentReferenceNumber}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                'Status: $_paymentStatus',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _paymentStatus.toLowerCase() == 'pending'
                      ? Colors.orange
                      : _paymentStatus.toLowerCase() == 'completed' || _paymentStatus.toLowerCase() == 'success'
                      ? Colors.green
                      : Colors.red,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Time remaining: ${_formatTime(_remainingSeconds)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  kIsWeb
                      ? 'Please complete the payment in the opened tab. Do not close or refresh this page until the payment is done.'
                      : 'Please complete the payment in the opened window. Do not close this app until the payment is done.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: GestureDetector(
                      onTap: () => _confirmCancel(),
                      child: commonText(
                          text: 'Cancel payment and return',
                          color: Colors.blue,
                          textDecoration: TextDecoration.underline,
                          fontSize: 14
                      )
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}