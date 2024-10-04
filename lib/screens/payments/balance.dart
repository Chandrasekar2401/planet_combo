import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:planetcombo/screens/dashboard.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:get/get.dart';

enum PaymentOption { upi, paypal }

class Balance extends StatefulWidget {
  const Balance({Key? key}) : super(key: key);

  @override
  _BalanceState createState() => _BalanceState();
}

class _BalanceState extends State<Balance> {

  final LocalizationController localizationController =
  Get.put(LocalizationController.getInstance(), permanent: true);

  final ApplicationBaseController applicationBaseController =
  Get.put(ApplicationBaseController.getInstance(), permanent: true);

  late PaymentOption _selectedOption;

  @override
  void initState() {
    // TODO: implement initState
    _selectedOption = PaymentOption.upi;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(onPressed: () {
          Navigator.pop(context);
        }, icon: const Icon(Icons.chevron_left_rounded),),
        title: LocalizationController.getInstance().getTranslatedValue("Balance"),
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
      body: Column(
        children: [
          Container(
            height: 65,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white24,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                    width: localizationController.currentLanguage.value == 'ta' ? 215 : 165,
                    child: GradientButton(title: LocalizationController.getInstance().getTranslatedValue("Send Statements"), textColor: Colors.white, buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)], onPressed: (Offset buttonOffset) {

                    }, materialIcon: Icons.send, materialIconSize: 16)),
                const SizedBox(width: 12)
              ],
            ),
          ),
          Expanded(child:
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFf2b20a), Color(0xFFf34509)],
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 25),
                        SvgPicture.asset('assets/svg/wallet.svg', width: 52,height: 52, color: Colors.white),
                        SizedBox(width: 25),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            commonBoldText(text:  LocalizationController.getInstance().getTranslatedValue("Your Balance"), fontSize: 18, color: Colors.white70),
                            SizedBox(height: 10),
                            commonBoldText(text: '₹ ${applicationBaseController.userAccountBalance.value}', fontSize: 21, color: Colors.white)
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Topup Wallet'), fontSize: 18),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: commonText(color: Colors.black54,fontSize: 14, text: LocalizationController.getInstance().getTranslatedValue('Part payments not allowed. Once paid no refunds are allowed and the paid amount (exclusive of taxes) can be used for headletter services as per the pricing sheet (gie hyperlink for pricing sheet)')),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: PrimaryInputText(hintText: 'Enter Amount', onValidate: (v){return null;}),
                  ),
                  SizedBox(height: 15),
                  commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Recommended'), fontSize: 16),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      commonSmallColorButton(title: '15', textColor: Colors.black, buttonColor: Colors.white, onPressed: (){}),
                      commonSmallColorButton(title: '25', textColor: Colors.black, buttonColor: Colors.white, onPressed: (){}),
                      commonSmallColorButton(title: '35', textColor: Colors.black, buttonColor: Colors.white, onPressed: (){}),
                      commonSmallColorButton(title: '50', textColor: Colors.black, buttonColor: Colors.white, onPressed: (){})
                    ],
                  ),
                  SizedBox(height: 15),
                  SizedBox(
                    width: 140,
                    child: ListTile(
                      title: SvgPicture.asset('assets/svg/upi-icon.svg',height: 32),
                      leading: Radio(
                        value: PaymentOption.upi,
                        groupValue: _selectedOption,
                        onChanged: (PaymentOption? value) {
                          setState(() {
                            _selectedOption = value!;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: ListTile(
                      title: SvgPicture.asset('assets/svg/paypal.svg',height: 32),
                      leading: Radio(
                        value: PaymentOption.paypal,
                        groupValue: _selectedOption,
                        onChanged: (PaymentOption? value) {
                          setState(() {
                            _selectedOption = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ))
        ],
      ),
      bottomNavigationBar: Container(
        height: 50,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFf2b20a),
              Color(0xFFf34509),
            ],
          ),
        ),
        child: GestureDetector(
          onTap: (){
            print('button clicked');
          },
          child: Center(child: commonBoldText(text: 'Topup Wallet', color: Colors.white70)),
        ),
      ),
    );
  }
}

