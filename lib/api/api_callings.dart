import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:planetcombo/api/api_endpoints.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:planetcombo/api/api_encryption.dart';

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
  static Future<String> socialLogin({
    required String email,
    required String medium,
    required String password,
    required String tokenId
  }) async {
    try {
      // Test encryption before using
      if (!EncryptionService.testEncryption()) {
        print('Warning: Encryption system is not working properly!');
      }

      Map<String, dynamic> registerObject = {
        "Email": email,
        "Medium": medium,
        "PASSWORD": password,
        "TokenId": tokenId
      };

      final isEncrypted = await EncryptionService.isEncryptionEnabled();
      var url = Uri.parse(APIEndPoints.socialLogin);

      // Prepare request body and headers
      var requestBody;
      Map<String, String> headers = {
        "Content-Type": "application/json",
        "X-Encrypted": isEncrypted.toString(),
      };

      if (isEncrypted) {
        requestBody = {"data": EncryptionService.encryptRequest(registerObject)};
        headers["Content-Type"] = "application/json; charset=utf-8";
      } else {
        requestBody = registerObject;
      }

      print('Sending encrypted request...');
      var response = await http.post(
        url,
        body: json.encode(requestBody),
        headers: headers,
      );

      // Handle response...
      if (response.statusCode == 200) {
        var responseBody = response.body;
        if (isEncrypted) {
          responseBody = EncryptionService.decryptResponse(responseBody);
        }

        var jsonResponse = json.decode(responseBody);
        print('Response from social login: $jsonResponse');

        if (jsonResponse['status'] == 'Success') {
          if (jsonResponse['message'] == 'No Data found') {
            return 'No Data found';
          } else {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('UserInfo', json.encode(jsonResponse['data']));
            return 'true';
          }
        }
        return 'false';
      }
      return 'false';
    } catch (error) {
      print('Error in social login: $error');
      return 'false';
    }
  }

  ///Add and Update Horoscope
  static Future addNewHoroscope(
      {required Map<String, dynamic> addNewHoroscope,  required String token}) async {
    Map<String, dynamic> registerObject = addNewHoroscope;
    var url = Uri.parse(APIEndPoints.addNewHoroscope);
    try{
      var response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            "token": token
          },
          body: registerObject
      );
      print(response.statusCode);
      if(response.statusCode == 403){
        return '403 Error';
      }else if(response.statusCode == 200){
        var jsonResponse = json.decode(response.body);
        print(jsonResponse);
        if(jsonResponse['data'] == null){
          return null;
        }else{
          return response.body;
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

  static Future<APIResponse> updateHoroscope({
    required Map<String, dynamic> updateHoroscope,
    required String token,
  }) async {
    try {
      Map<String, dynamic> updateObject = updateHoroscope;
      var url = Uri.parse(APIEndPoints.updateHoroscope);
      print('URL : $url');
      print("Body: ${json.encode(updateHoroscope)}");
      var response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            "token": token
          },
          body: updateObject
      );
      print('Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        print('Response Body: $jsonResponse');
        if (jsonResponse['status'] == 'Success') {
          return APIResponse(success: true, data: response.body);
        } else {
          return APIResponse(success: false, errorMessage: jsonResponse['errorMessage']);
        }
      } else {
        return APIResponse(success: false, errorMessage: 'HTTP Error ${response.statusCode}');
      }
    } catch (e) {
      return APIResponse(success: false, errorMessage: 'Exception: $e');
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
        if(jsonResponse['status'] == 'Success'){
          return response.body;
        }else{
          return jsonResponse['errorMessage'];
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


  ///Update Profile
  static Future updateHoroscopeImage(
      {required Map<String, dynamic> updateProfile,required String userId,required String hid,  required String token}) async {
    Map<String, dynamic> registerObject = updateProfile;
    var url = Uri.parse('${APIEndPoints.updateHoroscopeImage}/$userId/$hid');
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
        if(jsonResponse['status'] == 'Success'){
          return response.body;
        }else{
          return jsonResponse['errorMessage'];
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
        if(jsonResponse['status'] == 'Success'){
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('UserInfo', json.encode(jsonResponse['data']));
          return response.body;
        }else{
          if(jsonResponse['message'] != null){
            return jsonResponse['message'];
          }else{
            return jsonResponse['errorMessage'];
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

  static Future<String?> getHoroscope({required String userId, required String token}) async {
    try {
      Map<String, String> headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "token": token
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
        // Try to parse error message from response body
        try {
          var errorBody = json.decode(response.body);
          throw 'Error ${response.statusCode}: ${errorBody['message'] ?? 'Unknown error occurred'}';
        } catch (e) {
          throw 'Error ${response.statusCode}: ${_getStatusCodeMessage(response.statusCode)}';
        }
      }
    } catch (e) {
      throw e.toString();
    }
  }


  static Future<String?> getPendingPayments({required String userId, required String token}) async {
    try {
      Map<String, String> headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "token": token
      };
      var url = Uri.parse(APIEndPoints.getPendingPayments+userId);
      var response = await http.get(
        url,
        headers: headers,
      );
      print("Get Vendor Profile URL : $url");

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Try to parse error message from response body
        try {
          var errorBody = json.decode(response.body);
          throw 'Error ${response.statusCode}: ${errorBody['message'] ?? 'Unknown error occurred'}';
        } catch (e) {
          throw 'Error ${response.statusCode}: ${_getStatusCodeMessage(response.statusCode)}';
        }
      }
    } catch (e) {
      throw e.toString();
    }
  }
  ///check Duplicate request

// Helper method to get standard HTTP status messages
  static String _getStatusCodeMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad Request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 500:
        return 'Internal Server Error';
      case 502:
        return 'Bad Gateway';
      case 503:
        return 'Service Unavailable';
      default:
        return 'Unknown Error';
    }
  }


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
    Map<String, dynamic> addingObject = {
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
    print("Body: ${json.encode(addingObject)}");
    var response = await http.post(
      url,
      body: jsonEncode(addingObject),
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
    var url = Uri.parse('${APIEndPoints.getUserAllPredictions}$userId/$hid/$requestId');
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
    var response = await http.post(
      url,
      headers: headers,
    );
    print("Invoice List api link: ${response.statusCode}");
    if (response.statusCode == 200) {
      return response.body;
    } else {
      ApplicationBaseController().invoiceListApiError.value == 'Error ${response.statusCode}: Please try after sometime';
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

  static Future<String> emailChart({
    required String userId,
    required String hId,
    required String token,
  }) async {
    Map<String, dynamic> registerObject = {
      "HId": hId,
      "UserId": userId,
    };
    var url = Uri.parse(APIEndPoints.emailChart);
    print('URL : $url');
    print("Body: ${json.encode(registerObject)}");

    try {
      var response = await http.post(
        url,
        body: jsonEncode(registerObject),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "token": token
        },
      ).timeout(const Duration(seconds: 10));
      print('Response status code: ${response.statusCode}');
      switch (response.statusCode) {
        case 200:
          return response.body;
        case 403:
          return '403 Forbidden: Server denied access';
        case 404:
          return '404 Not Found: The requested resource could not be found';
        case 500:
          return '500 Internal Server Error: Something went wrong on the server';
        default:
          return 'Unexpected status code: ${response.statusCode}';
      }
    } on TimeoutException {
      return 'Request timed out after 10 seconds';
    } on http.ClientException catch (e) {
      return 'Network error: ${e.message}';
    } on FormatException {
      return 'Invalid response format from the server';
    } catch (e) {
      return 'Unexpected error occurred: $e';
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



  ///Add Message
  static Future<Response?> updatePredictionFlag(
      {required String userId, required int hid, required String reqId, required int flagId, required String flag, required String token}) async {
    Map<String, dynamic> registerObject = {
      "flag": flag,
    };
    var url = Uri.parse('${APIEndPoints.updateFlag}$userId/$hid/$reqId/$flagId?flag=$flag');
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


  ///
  static Future<Response?> getSpecialPredictions(String userId,int hid, String requestId, String token) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "token": token
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
    };
    var url = Uri.parse('${APIEndPoints.specialPredictions}$userId/$hid/$requestId');
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

  ///get daily prediction dates
  static Future<Response?> getDailyPredictionDates(String userId,int hid, String requestId, String token) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "token": token
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
    };
    var url = Uri.parse('${APIEndPoints.getDailyPredictionDates}$userId/$hid/$requestId');
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


  ///get daily prediction date details
  static Future<Response?> getDailyPredictionDateDetails(String userId,int hid, String requestId,String date, String token) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "token": token
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
    };
    var url = Uri.parse('${APIEndPoints.getDailyPredictionDateDetails}$userId/$hid/$requestId/$date');
    var response = await http.get(
      url,
      headers: headers,
    );
    print("Get Delete Message URL : $url");
    print(response.statusCode);
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      return response;
    } else {
      return null;
    }
  }




  ///get Special Prediction Messages
  static Future<Response?> getSpecialPredictionMessages(int predictionId,String token) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "token": token
      // "Authorization": "Bearer ${currentUserData.value.result!.accessToken}"
    };
    var url = Uri.parse('${APIEndPoints.specialPredictionMessages}$predictionId');
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

  ///add
  static Future<int> replySpecialPrediction(
      {required int predictionId, required String message, required String token}) async {
    Map<String, dynamic> registerObject = {
      "messageType": 2,
      "message": message,
      "predictionId": predictionId
    };
    var url = Uri.parse(APIEndPoints.replyPredictionMessage);

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
    return response.statusCode;
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



  ///add paypal payment
  static Future<Response?> payByPaypal(
      {required double amount, required int reqId, required String userId, required String token}) async {
    Map<String, dynamic> registerObject = {
      "requestId": reqId,
      "userId": userId,
      "amount":amount,
    };
    var url = Uri.parse(APIEndPoints.payByPaypal);

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


  ///add paypal payment
  static Future<Response?> payByUpi(
      {required double amount, required int reqId, required String userId, required String token}) async {
    Map<String, dynamic> registerObject = {
      "requestId": reqId,
      "userId": userId,
      "amount":amount,
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


  ///add paypal payment
  static Future<Response?> payByStripe(
      {required double amount, required int reqId, required String userId, required String token}) async {
    Map<String, dynamic> registerObject = {
      "requestId": reqId,
      "userId": userId,
      "amount":amount,
    };
    var url = Uri.parse(APIEndPoints.payByStripe);

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