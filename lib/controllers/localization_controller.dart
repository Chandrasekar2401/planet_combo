import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:planetcombo/common/app_logger.dart';

class LocalizationController extends GetxController {
  static LocalizationController? _instance;
  RxString currentLanguage = "en".obs;

  static LocalizationController getInstance() {
    _instance ??= LocalizationController();
    return _instance!;
  }
  late Map<String, String> languageValue;
  bool isRTL = false;


  //Constructor
  LocalizationController() {
    //getLanguage();
  }

  Future<void> getLanguage() async {
    AppLogger.d("getLanguage()");
    AppLogger.d(currentLanguage);

    if(currentLanguage == "ta") {
      isRTL=false;
      await load("lib/Globalization/languages/ta.json");
    }else if(currentLanguage == "en"){
      isRTL=false;
      await load("lib/Globalization/languages/en.json");
    }else if(currentLanguage == "hi") {
      isRTL=false;
      await load("lib/Globalization/languages/hi.json");
    }

  }


  Future load(String fileName) async {
    AppLogger.d("FileName : $fileName");
    String jsonStringValues = await rootBundle.loadString(fileName);
    AppLogger.d("we reacged");
    Map<String, dynamic> mappedJson = json.decode(jsonStringValues);
    AppLogger.d("loded");
    languageValue = mappedJson.map((key, value) => MapEntry(key, value.toString()));
    AppLogger.d("FileName Loaded : $fileName");
  }

  String getTranslatedValue(String key){
    if(languageValue.containsKey(key)) {
      return languageValue[key]!;
    }else {
      return key;
    }
  }

}
