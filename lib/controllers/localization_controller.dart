import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

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
    print("getLanguage()");
    print(currentLanguage);

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
    print("FileName : $fileName");
    String jsonStringValues = await rootBundle.loadString(fileName);
    print("we reacged");
    Map<String, dynamic> mappedJson = json.decode(jsonStringValues);
    print("loded");
    languageValue = mappedJson.map((key, value) => MapEntry(key, value.toString()));
    print("FileName Loaded : $fileName");
  }

  String getTranslatedValue(String key){
    if(languageValue.containsKey(key)) {
      return languageValue[key]!;
    }else {
      return key;
    }
  }

}
