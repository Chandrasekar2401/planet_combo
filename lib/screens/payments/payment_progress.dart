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

class PaymentProgressPage extends StatefulWidget {
  final String paymentReferenceNumber;
  final Function(String) onPaymentComplete;

  const PaymentProgressPage({
    super.key,
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
  int _remainingSeconds = 240; // 5 minutes in seconds

  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  final ApplicationBaseController applicationBaseController =
  Get.put(ApplicationBaseController.getInstance(), permanent: true);

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
          _redirectToDashboard();
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
    final response = await http.get(
        Uri.parse(APIEndPoints.paymentStatusCheck+widget.paymentReferenceNumber),
        headers: headers
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _paymentStatus = data['status'];
      });

      if (_paymentStatus.toLowerCase().compareTo('Completed'.toLowerCase()) == 0 || _paymentStatus.toLowerCase().compareTo('Success'.toLowerCase()) == 0 ) {
        _timer.cancel();
        _redirectTimer.cancel();
        _showPaymentCompleteToast();
        widget.onPaymentComplete(_paymentStatus);
      }else if(_paymentStatus.toLowerCase() == 'Cancelled' || _paymentStatus.toLowerCase() == 'Failed' ){
        _timer.cancel();
        _redirectTimer.cancel();
        _showFailedToast();
        widget.onPaymentComplete(_paymentStatus);
      }
    } else {
      print('Failed to check payment status');
    }
  }

  void _showPaymentCompleteToast() {
    CustomDialog.okActionAlert(context, 'Your Request Saved Successfully, Our Team Revert Shortly', 'OK', true, 14, (){
      applicationBaseController.updateHoroscopeUiList();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
            (Route<dynamic> route) => false,
      );
    });
  }


  void _showFailedToast() {
    CustomDialog.okActionAlert(context, 'Payment failed please try later', 'OK', false, 14, (){
      applicationBaseController.updateHoroscopeUiList();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
            (Route<dynamic> route) => false,
      );
    });
  }

  void _redirectToDashboard() {
    applicationBaseController.updateHoroscopeUiList();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Dashboard()),
          (Route<dynamic> route) => false,
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: GradientAppBar(
          colors: const [Color(0xFFf2b20a), Color(0xFFf34509)], centerTitle: true,
          title:  "Payment Progress",
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
                    child: appLoadController.loggedUserData.value.ucurrency!.toLowerCase().compareTo('INR'.toLowerCase()) == 0 ?
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
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
              const SizedBox(height: 20),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: GestureDetector(
                      onTap: _redirectToDashboard,
                      child: commonText(text: 'If You are facing any Issue, Please click here for dashboard', color: Colors.blue, textDecoration: TextDecoration.underline, fontSize: 12))
              ),
            ],
          ),
        ),
      ),
    );
  }
}