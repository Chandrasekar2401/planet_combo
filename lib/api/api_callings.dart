import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:planetcombo/api/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class APIResponse {
  final bool success;
  final dynamic data;
  final String? errorMessage;

  APIResponse({
    required this.success,
    this.data,
    this.errorMessage,
  });
}

class APICallings {
  ///Login Vendor
  static Future<String> socialLogin(
      {required String email,required String medium, required String password, required String tokenId}) async {
    Map<String, dynamic> registerObject = {
      "Email": email,
      "Medium": medium,
      "PASSWORD": password,
      "TokenId" : tokenId
    };
    var url = Uri.parse(APIEndPoints.socialLogin);
    print('URL : $url');
    print("Body: ${json.encode(registerObject)}");
    try{
      var response = await http.post(
        url,
        body: jsonEncode(registerObject),
        headers: {
          "Content-Type": "application/json",
        },
      );
      print('the response are crossed 2');
      print(response.statusCode);
      if(response.statusCode == 403){
        return 'false';
      }else if(response.statusCode == 200){
        var jsonResponse = json.decode(response.body);
        print('the json response from social login');
        print(jsonResponse);
        var string = 'true';
        if(jsonResponse['Status'] == 'Success'){
          if(jsonResponse['Message'] == 'No Data found'){
                string = 'No Data found';
          }else{
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('UserInfo', json.encode(jsonResponse['Data']));
              string = 'true';
          }
        }else{
            string = 'false';
        }
        print(string);
        return string;
      }else{
        return 'false';
      }
    }catch(error){
      print('the error reached the catch part');
        print(error);
        return 'false';
    }
  }

  ///Add and Update Horoscope
  static Future addNewHoroscope(
      {required Map<String, dynamic> addNewHoroscope,  required String token}) async {
    Map<String, dynamic> registerObject = addNewHoroscope;
    var url = Uri.parse(APIEndPoints.addNewHoroscope);
    print('URL : $url');
    print("Body: ${json.encode(registerObject)}");
    try{
      var response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            "token": token
          },
          body: registerObject
      );
      print('the response are crossed 3');
      print(response.statusCode);
      if(response.statusCode == 403){
        return '403 Error';
      }else if(response.statusCode == 200){
        var jsonResponse = json.decode(response.body);
        print(jsonResponse);
        if(jsonResponse['Status'] == 'Success'){
          return true;
        }else{
          return jsonResponse['ErrorMessage'];
        }
      }else{
        return 'Something went wrong';
      }
    }catch(error){
      print('catch error is');
      print(error);
      return 'Something went wrong';
    }
  }

  ///Update Profile
  static Future updateProfile(
      {required Map<String, dynamic> updateProfile,  required String token}) async {
    Map<String, dynamic> registerObject = updateProfile;
    var url = Uri.parse(APIEndPoints.updateProfile);
    print('URL : $url');
    print("Body: ${json.encode(registerObject)}");
    try{
      var response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            "token": token
          },
          body: registerObject
      );
      print('the response are crossed 4');
      print(response.statusCode);
      if(response.statusCode == 403){
        return '403 Error';
      }else if(response.statusCode == 200){
        var jsonResponse = json.decode(response.body);
        print(jsonResponse);
        if(jsonResponse['Status'] == 'Success'){
          return response.body;
        }else{
          return jsonResponse['ErrorMessage'];
        }
      }else if(response.statusCode == 500){
        return '500';
      }else{
        return response.body;
      }
    }catch(error){
      return error;
    }
  }


  ///Add New Profile
  static Future addProfile(
      {required Map<String, dynamic> addProfile}) async {
    Map<String, dynamic> registerObject = addProfile;
    var url = Uri.parse(APIEndPoints.addProfile);
    print('URL : $url');
    print("Body: ${json.encode(registerObject)}");
    try{
      var response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: registerObject
      );
      print('the response are crossed 5');
      print(response.body);
      if(response.statusCode == 403){
        return '403 Error';
      }else if(response.statusCode == 200){
        var jsonResponse = json.decode(response.body);
        print(jsonResponse);
        if(jsonResponse['Status'] == 'Success'){
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('UserInfo', json.encode(jsonResponse['Data']));
          return response.body;
        }else{
          if(jsonResponse['Message'] != null){
            return jsonResponse['Message'];
          }else{
            return jsonResponse['ErrorMessage'];
          }
        }
      }else{
        return 'ERROR CODE :${response.statusCode}';
      }
    }catch(error){
      print(error);
      return 'Server down';
    }
  }

  // static Future updateHoroscope(
  //     {required Map<String, dynamic> addNewHoroscope,  required String token}) async {
  //   Map<String, dynamic> registerObject = addNewHoroscope;
  //   var url = Uri.parse(APIEndPoints.updateHoroscope);
  //   print('URL : $url');
  //   print("Body: ${json.encode(registerObject)}");
  //   var response = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/x-www-form-urlencoded',
  //         "token": token
  //       },
  //       body: registerObject
  //   );
  //   print('the response are crossed 6');
  //   print(response.statusCode);
  //   if(response.statusCode == 403){
  //     return '403 Error';
  //   }else if(response.statusCode == 200){
  //     var jsonResponse = json.decode(response.body);
  //     print('the response of the status ' +jsonResponse['Status'] + jsonResponse);
  //     if(jsonResponse['Status'] == 'Success'){
  //       SharedPreferences prefs = await SharedPreferences.getInstance();
  //       await prefs.setString('UserInfo', json.encode(jsonResponse['Data']));
  //       return response.body;
  //     }else{
  //       return jsonResponse['ErrorMessage'];
  //     }
  //   }else{
  //     return 'Something went wrong';
  //   }
  // }

  static Future<APIResponse> updateHoroscope({
    required Map<String, dynamic> addNewHoroscope,
    required String token,
  }) async {
    try {
      var url = Uri.parse(APIEndPoints.updateHoroscope);
      print('URL : $url');
      print("Body: ${json.encode(addNewHoroscope)}");

      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // use 'application/json' for JSON data
          'token': token,
        },
        body: json.encode(addNewHoroscope),
      );

      print('Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        print('Response Body: $jsonResponse');

        if (jsonResponse['Status'] == 'Success') {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('UserInfo', json.encode(jsonResponse['Data']));
          return APIResponse(success: true, data: response.body);
        } else {
          return APIResponse(success: false, errorMessage: jsonResponse['ErrorMessage']);
        }
      } else {
        return APIResponse(success: false, errorMessage: 'HTTP Error ${response.statusCode}');
      }
    } catch (e) {
      return APIResponse(success: false, errorMessage: 'Exception: $e');
    }
  }
  ///get horoscope
  static Future<String?> getHoroscope({required String userId, required String token}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "token": token
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
    };
    var url = Uri.parse(APIEndPoints.getHoroscope+userId);
    var response = await http.get(
      url,
      headers: headers,
    );
    print("Get Vendor Profile URL : $url");
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }


  ///check Duplicate request
  static Future<String?> getDuplicateRequest({required String userId,required String hId, required String rsqDate, required String reqDate, required rqCat, required String token}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "token": token
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
    };
    var url = Uri.parse(APIEndPoints.checkRequest+userId+'&HID='+hId.replaceAll(' ', '')+'&RSQDATE='+rsqDate+'&REQDATE='+reqDate+'&RQCAT='+rqCat);
    print("Get Vendor promise URL : $url");
    var response = await http.get(
      url,
      headers: headers,
    );
    print('the recevied response code ${response.statusCode}');
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  ///Get Daily Charges
  static Future<String?> getDailyCharge({required rqCat, required currency, required String token}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "token": token
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
    };
    var url = Uri.parse(APIEndPoints.getDailyCharge+rqCat+'&Currency='+currency);
    print("Get Daily Charge URL : $url");
    var response = await http.get(
      url,
      headers: headers,
    );
    print('the recevied response code ${response.statusCode}');
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  ///Add Daily Request
  ///private USERID: string;
  static Future<String?> addDailyRequest(
      {required String hid,required String userId, required String latitude, required String longitude,required String startDate,
        required String endDate, String? timestamp, String? completeDateTime,
        required String token}) async {
    Map<String, dynamic> registerObject = {
      "HId": hid,
      "USERID": userId,
      "DST":0,
      "LATITUDE": latitude,
      "LONGITUDE": longitude,
      "RQSDATE": startDate,
      "RQEDDATE": endDate,
      "REPEAT": 'n',
      "TIMESTAMP": timestamp,
      "COMPLETEDATETIME": ''
    };
    var url = Uri.parse(APIEndPoints.addDailyRequest);
    print('passing token $token');
    print('URL : $url');
    print("Body: ${json.encode(registerObject)}");
    var response = await http.post(
      url,
      body: jsonEncode(registerObject),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "token": token
      },
    );
    print('the response are crossed 1');
    print(response.statusCode);
    if(response.statusCode == 403){
      return '403 Server error';
    }else if(response.statusCode == 200){
      return response.body;
    }else{
      return 'Something went wrong';
    }
  }


  ///Update Predictions
  static Future<APIResponse> updatePredictions({
    required Map<String, dynamic> updatePrediction,
    required String token,
  }) async {
    try {
      var url = Uri.parse(APIEndPoints.updatePrediction);
      print('URL : $url');
      print("Body: ${json.encode(updatePrediction)}");
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // use 'application/json' for JSON data
          'token': token,
        },
        body: json.encode(updatePrediction),
      );
      print('Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        print('Response Body: $jsonResponse');
        if (jsonResponse['Status'] == 'Success') {
          return APIResponse(success: true, data: response.body);
        } else {
          return APIResponse(success: false, errorMessage: jsonResponse['ErrorMessage']);
        }
      } else {
        return APIResponse(success: false, errorMessage: 'HTTP Error ${response.statusCode}');
      }
    } catch (e) {
      return APIResponse(success: false, errorMessage: 'Exception: $e');
    }
  }


  static Future<String?> addSpecialRequest(
      {required String hid,required String userId,required String specialReq, required String latitude, required String longitude,required String reqDate,
        String? timestamp, String? completeDateTime,
        required String token}) async {
    Map<String, dynamic> registerObject = {
      "HID": hid,
      "HUSERID": userId,
      "RQSPECIALDETAILS": specialReq,
      "Latitude": latitude,
      "Longitude": longitude,
      "ReqDate": reqDate,
      "TIMESTAMP": timestamp,
      "COMPLETEDATETIME": ''
    };
    var url = Uri.parse(APIEndPoints.addSpecialRequest);
    print('passing token $token');
    print('URL : $url');
    print("Body: ${json.encode(registerObject)}");
    var response = await http.post(
      url,
      body: jsonEncode(registerObject),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "token": token
      },
    );
    print('the response are crossed 1');
    print(response.statusCode);
    if(response.statusCode == 403){
      return '403 Server error';
    }else if(response.statusCode == 200){
      return response.body;
    }else{
      return 'Something went wrong';
    }
  }

  ///get User Messages
  static Future<String?> getUserMessages({required String userId, required String token}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "token": token
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
    };
    var url = Uri.parse(APIEndPoints.getUserMessages+userId);
    var response = await http.get(
      url,
      headers: headers,
    );
    print("Terms and conditions Url is: $url");
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  ///get User All PredictionsList
  static Future<String?> getUserAllPredictions({required String userId,required String hid,required String requestId, required String token}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "token": token
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
    };
    var url = Uri.parse('${APIEndPoints.getUserAllPredictions}$userId&hid=$hid&requestId=$requestId');
    var response = await http.get(
      url,
      headers: headers,
    );
    print("Terms and conditions Url is: $url");
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }


  ///get User Predictions
  static Future<String?> getUserPredictions({required String userId,required String hid, required String token}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "token": token
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
    };
    var url = Uri.parse('${APIEndPoints.getUserPredictions}$userId&hid=$hid');
    var response = await http.get(
      url,
      headers: headers,
    );
    print("Terms and conditions Url is: $url");
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  ///get terms and Conditions
  static Future<String?> termsAndConditions({required String userId, required String token}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "token": token
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
    };
    var url = Uri.parse(APIEndPoints.getTermsAndConditions+userId);
    var response = await http.get(
      url,
      headers: headers,
    );
    print("Terms and conditions Url is: $url");
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }


  ///get invoice List
  static Future<String?> getInvoiceList({required String userId, required String token}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "token": token
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
    };
    var url = Uri.parse(APIEndPoints.getInvoiceList+userId);
    var response = await http.get(
      url,
      headers: headers,
    );
    print("Terms and conditions Url is: $url");
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  ///get user wallet balance
  static Future<String?> getWalletBalance({required String userId,required String statementSEQ, required String token}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "token": token
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
    };
    var url = Uri.parse('${APIEndPoints.getUserWalletBalance}$userId&StatementSEQ=$statementSEQ');
    var response = await http.get(
      url,
      headers: headers,
    );
    print("Terms and conditions Url is: $url");
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  ///delete horoscope
  static Future<String?> deleteHoroscope({required String userId,required String hId, required String token}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "token": token
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
    };
    var url = Uri.parse('${APIEndPoints.deleteHoroscope}$userId&hId=$hId');
    var response = await http.get(
      url,
      headers: headers,
    );
    print("Get Vendor Profile URL : $url");
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }


  ///get Promises
  static Future<String?> getPromise({required String userId,required String hId, required String token}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "token": token
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
    };
    var url = Uri.parse('${APIEndPoints.getPromises}$userId&hId=$hId');
    var response = await http.get(
      url,
      headers: headers,
    );
    print("Get Vendor Profile URL : $url");
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  static Future<String?> getPlanetTransit({required String planet, required String token}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "token": token
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
    };
    var url = Uri.parse('${APIEndPoints.getPlanetTransit}$planet');
    var response = await http.get(
      url,
      headers: headers,
    );
    print("Get Vendor Profile URL : $url");
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  ///view Chart
  static Future<String?> viewHoroscopeChart({required String userId,required String hId, required String token}) async {
    print('the url is');
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "token": token
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
    };
    var url = Uri.parse('${APIEndPoints.viewChart}$userId&Hid=$hId');
    var response = await http.get(
      url,
      headers: headers,
    );
    print("Get Vendor Profile URL : $url");
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  ///Email Chart
  static Future<String?> emailChart(
      {required String userId,required String hId, required String token}) async {
    Map<String, dynamic> registerObject = {
      "HId": hId,
      "UserId": userId,
    };
    var url = Uri.parse(APIEndPoints.emailChart);
    print('URL : $url');
    print("Body: ${json.encode(registerObject)}");
    var response = await http.post(
      url,
      body: jsonEncode(registerObject),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "token": token
      },
    );
    print('the response are crossed 1');
    print(response.statusCode);
    if(response.statusCode == 403){
      return '403 Server error';
    }else if(response.statusCode == 200){
      return response.body;
    }else{
      return 'Something went wrong';
    }
  }



  ///update Vendor Membership
  static Future<Response?> updateMembership(
      {required String id, required bool extended, required String days, required String memberId, required String expiry}) async {
    Map<String, dynamic> registerObject = {
      "Id": id,
      "ExistingMembership": extended,
      "MembershipDays": days,
      "MembershipId": memberId,
      "MembershipExpiry": expiry
    };
    var url = Uri.parse(APIEndPoints.updateMembership);

    print('URL : $url');
    print("Body: ${json.encode(registerObject)}");

    var response = await http.post(
      url,
      body: jsonEncode(registerObject),
      headers: {
        "Content-Type": "application/json",
      },
    );
    var jsonResponse = json.decode(response.body);
    return response;
  }

  ///update Vendor Profile
  static Future<Response?> updateVendorProfile(
      {required String id, required String name, required String abnNumber,String? address,String? category, required String email, required String mobile, required String imageExist, String? imageName, String? imageType, String? base64image}) async {
    Map<String, dynamic> registerObject = {
      "Id":id,
      "FullName":name,
      "ABN_Number":abnNumber,
      "BusinessAddress":address,
      "BusinessCategory":category,
      "Email":email,
      "MobileNumber":mobile,
      "Country":"",
      "University":"",
      "ImageExist":imageExist,
      "ImageName" :imageName,
      "ImageType" :imageType,
      "ImageBusinessProofId":base64image
    };
    var url = Uri.parse(APIEndPoints.updateVendorProfile);

    print('URL : $url');
    print("Body: ${json.encode(registerObject)}");

    var response = await http.post(
      url,
      body: jsonEncode(registerObject),
      headers: {
        "Content-Type": "application/json",
      },
    );
    var jsonResponse = json.decode(response.body);
    return response;
  }

  ///Register Vendor
  static Future<Response?> registerVendor(
      {String? location, required String name,required String role,String? university, required String abn, required String email,required String password, required String mobile, required String website,
      required String imageType, required String imageName,required String memberShipId, required String membershipExpDate, required String base64String}) async {
    Map<String, dynamic> registerObject = {
      "Location": location,
      "FullName": name,
      "Role": role,
      "University": university,
      "ABN_Number": abn,
      "Email": email,
      "Password": password,
      "MobileNumber": mobile,
      "CompanyWebsite": website,
      "ImageType" :imageType,
      "ImageName" :imageName,
      "MembershipId" :memberShipId,
      "MembershipExpiry" :membershipExpDate,
      "ImageBusinessProofId" :base64String
    };

    var url = Uri.parse(APIEndPoints.vendorRegister);

    print('URL : $url');
    print("Body: ${json.encode(registerObject)}");

    var response = await http.post(
      url,
      body: jsonEncode(registerObject),
      headers: {
        "Content-Type": "application/json",
      },
    );
    if(response.statusCode == 403){
      return response;
    }else{
      var jsonResponse = json.decode(response.body);
      return response;
    }
  }

  ///add coupon
  static Future<Response?> addCoupon(
      {required String id, required String name, required String code,required String validity, required String imgName, required String imgType, required String base64}) async {
    Map<String, dynamic> registerObject = {
      "UserId": id,
      "Name": name,
      "Code":code,
      "Validity": validity,
      "ImageName": imgName,
      "ImageType": imgType,
      "Image": base64,
    };

    var url = Uri.parse(APIEndPoints.vendorAddCoupon);

    print('URL : $url');
    print("Body: ${json.encode(registerObject)}");

    var response = await http.post(
      url,
      body: jsonEncode(registerObject),
      headers: {
        "Content-Type": "application/json",
      },
    );
    var jsonResponse = json.decode(response.body);
    return response;
  }


  ///Add Message
  static Future<Response?> addMessage(
      {required String messageId, required String messageUserId, required String userMessage, required String messageStatus, required String messageRead, required String token}) async {
    Map<String, dynamic> registerObject = {
      "MSGCUSTOMERCOM": userMessage,
      "MSGHID": messageId,
      "MSGSTATUS": messageStatus,
      "MSGUNREAD": messageRead,
      "MSGUSERID": messageUserId,
    };
    var url = Uri.parse(APIEndPoints.addMessage);

    print('URL : $url');
    print("Body: ${json.encode(registerObject)}");

    var response = await http.post(
      url,
      body: jsonEncode(registerObject),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "token": token
      },
    );
    var jsonResponse = json.decode(response.body);
    return response;
  }

  ///Update Message
  static Future<Response?> updateMessage(
      {required String messageId, required String messageUserId, required String messageMessageId, required String userMessage, required String messageStatus, required String messageRead, required String token}) async {
    Map<String, dynamic> registerObject = {
      "MSGHID": messageId,
      "MSGUSERID": messageUserId,
      "MSGMESSAGEID":messageMessageId,
      "MSGCUSTOMERCOM": userMessage,
      "MSGSTATUS": messageStatus,
      "MSGUNREAD": messageRead,
    };
    var url = Uri.parse(APIEndPoints.updateMessage);

    print('URL : $url');
    print("Body: ${json.encode(registerObject)}");

    var response = await http.post(
      url,
      body: jsonEncode(registerObject),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "token": token
      },
    );
    var jsonResponse = json.decode(response.body);
    return response;
  }

  ///Delete Message
  static Future<Response?> deleteMessage(String messageId, String hid, String userId, String token) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "token": token
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
    };
    var url = Uri.parse('${APIEndPoints.deleteMessages}$userId&hId=$hid&messageId=$messageId');
    var response = await http.get(
      url,
      headers: headers,
    );
    print("Get Delete Message URL : $url");
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      return response;
    } else {
      return null;
    }
  }

  ///Delete Profile
  static Future<Response?> deleteProfile(String userId, String token) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "token": token
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
    };
    var url = Uri.parse('${APIEndPoints.deleteProfile}$userId');
    var response = await http.get(
      url,
      headers: headers,
    );
    print("Get Delete Message URL : $url");
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      return response;
    } else {
      return null;
    }
  }



  ///add offline Money
  static Future<Response?> addOfflineMoney(
      {required int amount, required String currency, required String email, required String userId, required String token}) async {
    Map<String, dynamic> registerObject = {
      "Amount": amount,
      "Currency": currency,
      "Email":email,
      "UserId": userId
    };
    var url = Uri.parse(APIEndPoints.addOfflineMoney);

    print('URL : $url');
    print("Body: ${json.encode(registerObject)}");

    var response = await http.post(
      url,
      body: jsonEncode(registerObject),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "token": token
      },
    );
    var jsonResponse = json.decode(response.body);
    return response;
  }



  ///add offline Money
  static Future<Response?> payByUpi(
      {required int amount, required String currency, required String email, required String userId, required String token}) async {
    Map<String, dynamic> registerObject = {
      "Amount": amount,
      "Currency": currency,
      "Email":email,
      "UserId": userId
    };
    var url = Uri.parse(APIEndPoints.payByUpi);

    print('URL : $url');
    print("Body: ${json.encode(registerObject)}");

    var response = await http.post(
      url,
      body: jsonEncode(registerObject),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "token": token
      },
    );
    var jsonResponse = json.decode(response.body);
    return response;
  }


  ///add social Media
  static Future<Response?> addSocialMedia(
      {required String id, String? fb, String? instagram}) async {
    Map<String, dynamic> registerObject = {
      "UserId": id,
      "Facebook": fb,
      "Instagram":instagram,
    };

    var url = Uri.parse(APIEndPoints.vendorAddSocialMedia);

    print('URL : $url');
    print("Body: ${json.encode(registerObject)}");

    var response = await http.post(
      url,
      body: jsonEncode(registerObject),
      headers: {
        "Content-Type": "application/json",
      },
    );
    var jsonResponse = json.decode(response.body);
    return response;
  }

  ///show Vendors list
  static Future<Response?> showVendorsList(
      {required String id,required String date}) async {
    Map<String, dynamic> registerObject = {
      "VendorId": id,
      "VisitDate": date,
    };

    var url = Uri.parse(APIEndPoints.showAdsVendorsList);

    print('URL : $url');
    print("Body: ${json.encode(registerObject)}");

    var response = await http.post(
      url,
      body: jsonEncode(registerObject),
      headers: {
        "Content-Type": "application/json",
      },
    );
    var jsonResponse = json.decode(response.body);
    return response;
  }

  ///show Subscribe Vendors list
  static Future<Response?> showSubscribeVendorsList(
      {required String id,required String date}) async {
    Map<String, dynamic> registerObject = {
      "VendorId": id,
      "VisitDate": date,
    };

    var url = Uri.parse(APIEndPoints.showVendorsList);

    print('URL : $url');
    print("Body: ${json.encode(registerObject)}");

    var response = await http.post(
      url,
      body: jsonEncode(registerObject),
      headers: {
        "Content-Type": "application/json",
      },
    );
    var jsonResponse = json.decode(response.body);
    return response;
  }

  ///update social Media
  static Future<Response?> updateSocialMedia(
      {required String id,required String userId, String? fb, String? instagram}) async {
    Map<String, dynamic> registerObject = {
      "Id": id,
      "UserId": userId,
      "Facebook": fb,
      "Instagram":instagram,
    };

    var url = Uri.parse(APIEndPoints.vendorUpdateSocialMedia);

    print('URL : $url');
    print("Body: ${json.encode(registerObject)}");

    var response = await http.post(
      url,
      body: jsonEncode(registerObject),
      headers: {
        "Content-Type": "application/json",
      },
    );
    var jsonResponse = json.decode(response.body);
    return response;
  }


  ///add coupon
  static Future<Response?> addPromotion(
      {required String id, required String name, required String validity, required String imgName, required String imgType, required String base64}) async {
    Map<String, dynamic> registerObject = {
      "UserId": id,
      "Name": name,
      "Validity": validity,
      "ImageName": imgName,
      "ImageType": imgType,
      "Image": base64,
    };

    var url = Uri.parse(APIEndPoints.vendorAddPromotion);

    print('URL : $url');
    print("Body: ${json.encode(registerObject)}");

    var response = await http.post(
      url,
      body: jsonEncode(registerObject),
      headers: {
        "Content-Type": "application/json",
      },
    );
    var jsonResponse = json.decode(response.body);
    return response;
  }


  /// update promotion
  static Future<Response?> updatePromotion(
      {required String userId, required String id, required String name,required String expiryDate, required String validity, required String imgName, required String imgType,required String exist, required String base64}) async {
    Map<String, dynamic> registerObject = {
      "UserId": userId,
      "Id":id,
      "Name": name,
      "ExpiryDate": expiryDate,
      "Validity": validity,
      "ImageName": imgName,
      "ImageType": imgType,
      "ImageExist": exist,
      "Image": base64,
    };

    var url = Uri.parse(APIEndPoints.vendorUpdatePromotion);

    print('URL : $url');
    print("Body: ${json.encode(registerObject)}");

    var response = await http.post(
      url,
      body: jsonEncode(registerObject),
      headers: {
        "Content-Type": "application/json",
      },
    );
    var jsonResponse = json.decode(response.body);
    return response;
  }

  ///add coupon
  static Future<Response?> addShopCount(
      {required String studentId, required String vendorId}) async {
    Map<String, dynamic> registerObject = {
      "StudentId": studentId,
      "VendorId": vendorId,
    };

    var url = Uri.parse(APIEndPoints.viewShopCount);

    print('URL : $url');
    print("Body: ${json.encode(registerObject)}");

    var response = await http.post(
      url,
      body: jsonEncode(registerObject),
      headers: {
        "Content-Type": "application/json",
      },
    );
    var jsonResponse = json.decode(response.body);
    return response;
  }

  ///add promotion count
  static Future<Response?> addPromotionCount(
      {required String promotionId, required String studentId, required String vendorId}) async {
    Map<String, dynamic> registerObject = {
      "PromotionId": promotionId,
      "StudentId": studentId,
      "VendorId": vendorId,
    };

    var url = Uri.parse(APIEndPoints.viewPromotionCount);

    print('URL : $url');
    print("Body: ${json.encode(registerObject)}");

    var response = await http.post(
      url,
      body: jsonEncode(registerObject),
      headers: {
        "Content-Type": "application/json",
      },
    );
    var jsonResponse = json.decode(response.body);
    return response;
  }



  static Future<String?> getVendorProfile(String id) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
    };
    var url = Uri.parse(APIEndPoints.vendorProfile+id);
    var response = await http.get(
      url,
      headers: headers,
    );
    print("Get Vendor Profile URL : $url");
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      return response.body;
    } else {
      return null;
    }
  }

  static Future<String?> getPopularVendors() async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
    };
    var url = Uri.parse(APIEndPoints.popularVendors);
    var response = await http.get(
      url,
      headers: headers,
    );
    print("Get Vendor Profile URL : $url");
    var jsonResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      print("ApiCallings() : orangeMoneyCheckRegisterMerchant() : Error : " + response.body);
      return null;
    }
  }

  static Future<String?> getTrendingVendors() async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
    };
    var url = Uri.parse(APIEndPoints.trendingVendors);
    var response = await http.get(
      url,
      headers: headers,
    );
    print("Get Vendor Profile URL : $url");
    var jsonResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      print("ApiCallings() : orangeMoneyCheckRegisterMerchant() : Error : " + response.body);
      return null;
    }
  }

  static Future<String?> getAdvertisement() async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
    };
    var url = Uri.parse(APIEndPoints.getAdvertisement);
    var response = await http.get(
      url,
      headers: headers,
    );
    print("Get Vendor Advertisement URL : $url");
    var jsonResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      print("ApiCallings() : orangeMoneyCheckRegisterMerchant() : Error : " + response.body);
      return null;
    }
  }

  static Future<String?> getVendorCoupons(String id) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
    };
    var url = Uri.parse(APIEndPoints.vendorCoupons+id);
    var response = await http.get(
      url,
      headers: headers,
    );
    print("Get Vendor Profile URL : $url");
    var jsonResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      print("ApiCallings() : orangeMoneyCheckRegisterMerchant() : Error : " + response.body);
      return null;
    }
  }

  static Future<String?> getVendorSocialMedia(String id) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
    };
    var url = Uri.parse(APIEndPoints.vendorSocialMedia+id);
    var response = await http.get(
      url,
      headers: headers,
    );
    print("Get Vendor Social Media URL : $url");
    var jsonResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      print("ApiCallings() : Social Media Error() : Error : ${response.body}");
      return null;
    }
  }

  static Future<Response?> getVendorByLocation(
      {required String location,required String country,required String search}) async {
    Map<String, dynamic> registerObject = {
      "Location":location,
      "Country":country,
      "SearchText": search
    };
    var url = Uri.parse(APIEndPoints.vendorByLocation);

    print('URL : $url');
    print("Body: ${json.encode(registerObject)}");

    var response = await http.post(
      url,
      body: jsonEncode(registerObject),
      headers: {
        "Content-Type": "application/json",
      },
    );
    var jsonResponse = json.decode(response.body);
    return response;
  }

  static Future<String?> getVendorCounts(String id) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
    };
    var url = Uri.parse(APIEndPoints.vendorCounts+id);
    var response = await http.get(
      url,
      headers: headers,
    );
    print("Get Vendor Profile URL : $url");
    var jsonResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      print("ApiCallings() : orangeMoneyCheckRegisterMerchant() : Error : " + response.body);
      return null;
    }
  }

  static Future<String?> getVendorPromotion(String id) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
    };
    var url = Uri.parse(APIEndPoints.getVendorPromotion+id);
    var response = await http.get(
      url,
      headers: headers,
    );
    print("Get Vendor Profile URL : $url");
    var jsonResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      print("ApiCallings() : orangeMoneyCheckRegisterMerchant() : Error : " + response.body);
      return null;
    }
  }

  static Future<String?> deleteVendorCoupon(String id) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
    };
    var url = Uri.parse(APIEndPoints.deleteVendorCoupon+id);
    var response = await http.get(
      url,
      headers: headers,
    );
    print("Get Vendor Profile URL : $url");
    var jsonResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      print("ApiCallings() : orangeMoneyCheckRegisterMerchant() : Error : " + response.body);
      return null;
    }
  }

  static Future<String?> getVendorMemberships() async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
    };
    var url = Uri.parse(APIEndPoints.getVendorMembership);
    var response = await http.get(
      url,
      headers: headers,
    );
    print("Get Vendor Profile URL : $url");
    var jsonResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      print("ApiCallings() : orangeMoneyCheckRegisterMerchant() : Error : " + response.body);
      return null;
    }
  }
}