import 'dart:convert';
import 'package:get/get.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/api/api_callings.dart';
import 'package:planetcombo/common/constant.dart';

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

  void payByUpi(userId, email, amount, token, context) async{
    CustomDialog.showLoading(context, 'Please wait');
    int money = int.parse(amount);
    var response = await APICallings.payByUpi(currency: constants.currency, token: token, amount: money, email: email, userId: userId);
    print(response!.body);
    CustomDialog.cancelLoading(context);
    var jsonBody = json.decode(response.body);
    if(jsonBody['Status'] == 'Success'){
      CustomDialog.showAlert(context, jsonBody['Message'], true, 14);
    }
  }

}