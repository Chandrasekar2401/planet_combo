import 'package:flutter/material.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/screens/dashboard.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/controllers/payment_controller.dart';
import 'package:get/get.dart';

class Pay extends StatefulWidget {
  const Pay({Key? key}) : super(key: key);

  @override
  _PayState createState() => _PayState();
}

class _PayState extends State<Pay> {
  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  final PaymentController paymentController =
  Get.put(PaymentController.getInstance(), permanent: true);

  TextEditingController emailController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    emailController.text = AppLoadController.getInstance().loggedUserData.value.useremail!;
    amountController.text = '10';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(onPressed: () { Navigator.pop(context); }, icon: Icon(Icons.chevron_left_rounded),),
        title: LocalizationController.getInstance().getTranslatedValue("Payment"),
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)], centerTitle: true,
        actions: [
          IconButton(onPressed: (){
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Dashboard()),
                  (Route<dynamic> route) => false,
            );
          }, icon: const Icon(Icons.home_outlined))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  commonText(color: Colors.black54, fontSize: 14, text: LocalizationController.getInstance().getTranslatedValue('We will generate an invoice (inclusive of taxes) and a payment link to your email ID')),
                  SizedBox(height: 10),
                  commonText(color: Colors.black54, fontSize: 14, text: LocalizationController.getInstance().getTranslatedValue('Part payments not allowed. Once paid no refunds are allowed and the paid amount (exclusive of taxes) can be used for headletter services as per the pricing sheet (gie hyperlink for pricing sheet)')),
                  SizedBox(height: 20),
                  PrimaryStraightInputText(hintText: 'Enter Amount',
                    controller: amountController,
                    onValidate: (String? value) {  },),
                  SizedBox(height: 20),
                  commonText(fontSize: 14, color: Colors.black54, text: LocalizationController.getInstance().getTranslatedValue("Or Choose the following amounts to pay")),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      commonSmallColorButton(title: '15', textColor: Colors.black, buttonColor: Colors.white, onPressed: (){
                        amountController.text = '15';
                      }),
                      commonSmallColorButton(title: '25', textColor: Colors.black, buttonColor: Colors.white, onPressed: (){
                          amountController.text = '25';
                      }),
                      commonSmallColorButton(title: '35', textColor: Colors.black, buttonColor: Colors.white, onPressed: (){
                          amountController.text = '35';
                      }),
                      commonSmallColorButton(title: '50', textColor: Colors.black, buttonColor: Colors.white, onPressed: (){
                          amountController.text = '50';
                      })
                    ],
                  ),
                  SizedBox(height: 20),
                  commonText(color: Colors.black54, fontSize: 14, text: LocalizationController.getInstance().getTranslatedValue('Your payment link and invoices send on this email id')),
                  SizedBox(height: 20),
                  PrimaryStraightInputText(hintText: 'Enter email',
                    controller: emailController,
                    onValidate: (String? value) {  },),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: GradientButton(
                            title: LocalizationController.getInstance().getTranslatedValue("Cancel"),buttonHeight: 45, textColor: Colors.white, buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)], onPressed: (Offset buttonOffset){
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const Dashboard()),
                                (Route<dynamic> route) => false,
                          );
                        }),
                      ),
                      SizedBox(width: 20),
                      Expanded(child: GradientButton(
                          title: LocalizationController.getInstance().getTranslatedValue("Send"),buttonHeight: 45, textColor: Colors.white, buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)], onPressed: (Offset buttonOffset){
                        print(emailController.text);
                        paymentController.addOfflineMoney(appLoadController.loggedUserData.value.userid!, emailController.text, amountController.text, appLoadController.loggedUserData.value.token!, context);
                      }))
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
