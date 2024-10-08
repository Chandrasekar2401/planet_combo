import 'package:flutter/material.dart';
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
  String _paymentStatus = 'Pending';

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
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  Future<void> _checkPaymentStatus() async {
    // Replace this URL with your actual API endpoint
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "token": appLoadController.loggedUserData.value.token!
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
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

      if (_paymentStatus == 'Completed') {
        _timer.cancel();
        _showPaymentCompleteToast();
        widget.onPaymentComplete(_paymentStatus);
      }
    } else {
      print('Failed to check payment status');
    }
  }

  void _showPaymentCompleteToast() {
    CustomDialog.okActionAlert(context, 'Payment completed Successfully', 'OK', true, 14, (){
      applicationBaseController.updateHoroscopeUiList();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
            (Route<dynamic> route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent going back
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
                    child: Icon(Icons.attach_money, size: 50, color: Colors.orange),
                  ),
                ),
              ),
              SizedBox(height: 40),
              Text(
                'Payment Reference: ${widget.paymentReferenceNumber}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Status: $_paymentStatus',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  kIsWeb
                      ? 'Please complete the payment in the opened tab. Do not close or refresh this page until the payment is done.'
                      : 'Please complete the payment in the opened window. Do not close this app until the payment is done.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}