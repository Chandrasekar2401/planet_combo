import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:planetcombo/api/api_callings.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:get/get.dart';
import 'package:planetcombo/screens/payments/pending_payments.dart';
import 'package:planetcombo/screens/predictions/predictions.dart';
import 'package:planetcombo/controllers/payment_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:planetcombo/controllers/request_controller.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/controllers/add_horoscope_controller.dart';
import 'package:planetcombo/controllers/horoscope_services.dart';

//screens
import 'package:planetcombo/screens/Requests/daily_prediction.dart';
import 'package:planetcombo/screens/Requests/special_prediction.dart';
import 'package:planetcombo/screens/Requests/planet_transit.dart';
import 'package:planetcombo/screens/services/add_nativePhoto.dart';
import 'package:planetcombo/screens/dashboard.dart';
import 'package:planetcombo/screens/messages/message_list.dart';

import '../payments/pricing.dart';

class HoroscopeServices extends StatefulWidget {
  const HoroscopeServices({super.key});

  @override
  _HoroscopeServicesState createState() => _HoroscopeServicesState();
}

class _HoroscopeServicesState extends State<HoroscopeServices> {
  final double width = 32;
  final double height = 32;

  final LocalizationController localizationController =
  Get.put(LocalizationController.getInstance(), permanent: true);

  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  final ApplicationBaseController applicationBaseController =
  Get.put(ApplicationBaseController.getInstance(), permanent: true);

  final HoroscopeRequestController horoscopeRequestController =
  Get.put(HoroscopeRequestController.getInstance(), permanent: true);

  final AddHoroscopeController addHoroscopeController =
  Get.put(AddHoroscopeController.getInstance(), permanent: true);

  final HoroscopeServiceController horoscopeServiceController =
  Get.put(HoroscopeServiceController.getInstance(), permanent: true);

  final PaymentController paymentController =
  Get.put(PaymentController.getInstance(), permanent: true);

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    applicationBaseController.paymentForHoroscope.value = false;
    applicationBaseController.getUserHoroscopeList();
    // Start the periodic refresh
    _startAutoRefresh();
  }

  String formatIndianRupees(double amount) {
    double roundedAmount = (amount * 100).round() / 100;
    NumberFormat indianRupeesFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    String formattedAmount = indianRupeesFormat
        .format(roundedAmount)
        .replaceAll('₹', '')
        .trim();
    return formattedAmount;
  }

  void _startAutoRefresh() {
    // Cancel any existing timer
    _refreshTimer?.cancel();
    // Create new timer that fires every 10 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 90), (timer) {
      if (mounted) {
        applicationBaseController.getUserHoroscopeList();
      }
    });
  }

  @override
  void dispose() {
    // Ensure _isLoading is false when the widget is disposed
    horoscopeServiceController.isLoading.value = false;
    _refreshTimer?.cancel();
    super.dispose();
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

        if (result == true) { // Explicit check for true
          print('Navigating to Predictions');
          await Navigator.push( // Added await here
            context,
            MaterialPageRoute(
              builder: (context) => const Predictions(),
            ),
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

  void deleteHoroscope(String userId, String hid) async{
    CustomDialog.showLoading(context, 'Please wait');
    var result = await APICallings.deleteHoroscope(userId: userId, hId: hid.trim(), token: appLoadController.loggedUserData!.value.token!);
    CustomDialog.cancelLoading(context);
    var jsondata = jsonDecode(result!);
    print('The recevied result is $jsondata');
    applicationBaseController.updateHoroscopeUiList();
  }

  void navigateToPaymentScreen() {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PendingPaymentsPage())
    );
  }

  void viewHoroscope(String userId, String hid, bool paid) async{
    CustomDialog.showLoading(context, 'Please wait');
    var result = await APICallings.viewHoroscopeChart(userId: userId, hId: hid.trim(), token: appLoadController.loggedUserData!.value.token!);
    print('the value of result is $result');
    CustomDialog.cancelLoading(context);
    if(result == null){
      CustomDialog.showAlert(context, 'Error 404 : Please try later', false, 14);
    }else{
      var jsondata = jsonDecode(result);
      if(jsondata['status'] == 'Success'){
        if(jsondata['data'] == 'undefined' || jsondata['data'] == null || jsondata['data'] == ""){
          if(paid == false){
            yesOrNoDialog(context: context, dialogMessage: 'Horoscope is not ready yet, due to pending payment', cancelText: 'Close', okText: 'Pay Screen', okAction: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  const PendingPaymentsPage()));
            }, cancelAction: (){
              Navigator.pop(context);
            });
          }else{
            CustomDialog.showAlert(context, 'The horoscope is being prepared and its not ready yet', null,14);
          }
        }else{
          String htmlLink = jsondata['data'];
          if (!await launchUrl(Uri.parse(htmlLink))){
            throw Exception('Could not launch $htmlLink');
          }
        }
      }
    }
  }

  void emailHoroscope(String userId, String hid) async {
    CustomDialog.showLoading(context, 'Please wait');

    try {
      var result = await APICallings.emailChart(
          userId: userId,
          hId: hid.trim(),
          token: appLoadController.loggedUserData!.value.token!
      );

      print('The value of result is $result');

      CustomDialog.cancelLoading(context);

      if (result.startsWith('2')) { // Successful response
        var jsonData = json.decode(result);
        if (jsonData['status'] == 'Success') {
          CustomDialog.showAlert(context, jsonData['message'], true, 14);
        } else {
          CustomDialog.showAlert(context, jsonData['errorMessage'] ?? 'Unknown error occurred', false, 14);
        }
      } else {
        // Handle various error scenarios
        switch (result) {
          case '403 Forbidden: Server denied access':
            CustomDialog.showAlert(context, 'Access denied. Please check your credentials.', false, 14);
            break;
          case '404 Not Found: The requested resource could not be found':
            CustomDialog.showAlert(context, 'The requested horoscope could not be found.', false, 14);
            break;
          case '500 Internal Server Error: Something went wrong on the server':
            CustomDialog.showAlert(context, 'Server error. Please try again later.', false, 14);
            break;
          case 'Request timed out after 10 seconds':
            CustomDialog.showAlert(context, 'The request timed out. Please check your internet connection and try again.', false, 14);
            break;
          default:
            if (result.startsWith('Network error:')) {
              CustomDialog.showAlert(context, 'Network error. Please check your internet connection.', false, 14);
            } else if (result == 'Invalid response format from the server') {
              CustomDialog.showAlert(context, 'Received an invalid response from the server. Please try again.', false, 14);
            } else {
              CustomDialog.showAlert(context, 'An unexpected error occurred: $result', false, 14);
            }
        }
      }
    } catch (e) {
      CustomDialog.cancelLoading(context);
      CustomDialog.showAlert(context, 'An unexpected error occurred: $e', false, 14);
    }
  }

  void viewTwoPageKundli(String link) async {
    if(link == null || link.isEmpty) {
      CustomDialog.showAlert(context, 'Horoscope is not ready yet, Our Team reviewing your details', null,14);
    } else {
      // Remove _Chart.html and add .pdf
      String modifiedLink = link.replaceAll('_Chart.html', '.pdf');
      await launchUrl(Uri.parse(modifiedLink));
    }
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> _openImagePicker(BuildContext context, String hid) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: commonBoldText(
                    text: kIsWeb ? 'Choose from Computer' : 'Choose from Gallery'),
                onTap: () {
                  _getImage(context, ImageSource.gallery, hid);
                  Navigator.of(context).pop();
                },
              ),
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: commonBoldText(text: 'Take a Photo'),
                  onTap: () {
                    _getImage(context, ImageSource.camera, hid);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(BuildContext context, ImageSource source, String hid) async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: source,
        imageQuality: 85, // Compress image
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedImage != null) {
        if (kIsWeb) {
          // Handle web image
          // Store original file for upload
          addHoroscopeController.updateHoroscopeImage?.value = pickedImage;
          print('you entered web logic $pickedImage');
          addHoroscopeController.updateHoroscopeImageOnly(hid);
        } else {
          // Handle mobile image
          // addHoroscopeController.setImageFileListFromFile(pickedImage);
          // addHoroscopeController.selectedImageFile.value = pickedImage;
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      // Show error message to user
    }
  }

  String convertDateFormat(String inputDate) {
    // Parse the input date string
    DateTime parsedDate = DateTime.parse(inputDate);

    // Format the date into dd/MM/yyyy format
    String formattedDate = DateFormat('MMMM dd, yyyy').format(parsedDate);

    return formattedDate;
  }


// helper function for _HoroscopeServicesState class
  Widget _buildOfferItem(String text, bool included) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            included ? Icons.check_circle : Icons.cancel,
            color: included ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: commonText(
              text: text,
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Builder(builder: (BuildContext buttonContext){
      return PopScope(
        canPop: true,
        child: Scaffold(
            appBar: GradientAppBar(
              leading: IconButton(onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Dashboard()),
                      (Route<dynamic> route) => false,
                );
              }, icon: const Icon(Icons.chevron_left_rounded),),
              title: LocalizationController.getInstance().getTranslatedValue("Horoscope Services - ${appLoadController.loggedUserData.value.username}"),
              colors: const [Color(0xFFf2b20a), Color(0xFFf34509)], centerTitle: true,
              actions: [
                Row(
                  children: [
                    const Icon(Icons.payment_outlined, color: Colors.white, size: 16),
                    // commonBoldText(text: 'Currency(', color: Colors.white, fontSize: 12),
                    commonBoldText(text: ' - ${appLoadController.loggedUserData.value.ucurrency!}', color: Colors.white, fontSize: 12),
                    const SizedBox(width: 10)
                  ],
                )
              ],
            ),
            body:
            Obx(() {
              if (applicationBaseController.horoscopeListPageLoad.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (applicationBaseController.horoscopeListError.value
                  .isNotEmpty) {
                return
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 70,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Text(
                            applicationBaseController.horoscopeListError
                                .value,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => applicationBaseController
                              .getUserHoroscopeList(),
                          icon: const Icon(
                              Icons.refresh, color: Colors.white),
                          label: const Text(
                            'Retry',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFf34509),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
              }
              return
                Column(
                  children: [
                    Container(
                      height: 65,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
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
                              width: localizationController.currentLanguage
                                  .value == 'ta' ? 215 : 165,
                              child: GradientButton(
                                  title: LocalizationController.getInstance()
                                      .getTranslatedValue("Add Horoscope"),
                                  textColor: Colors.white,
                                  buttonColors: const [
                                    Color(0xFFf2b20a),
                                    Color(0xFFf34509)
                                  ],
                                  onPressed: (Offset buttonOffset) {
                                    addHoroscopeController.refreshAlerts();
                                    Navigator.push(
                                        context, MaterialPageRoute(
                                        builder: (
                                            context) => const AddNativePhoto()));
                                  },
                                  materialIcon: Icons.add,
                                  materialIconSize: 21)),
                          const SizedBox(width: 15)
                        ],
                      ),
                    ),
                    applicationBaseController.horoscopeList.isEmpty
                        ? Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Introductory offer card
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8A3FFC), Color(0xFFAA6BFF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8A3FFC).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  commonBoldText(
                                    text: "Introductory Offer",
                                    color: Colors.white,
                                    fontSize: 22,
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: commonBoldText(
                                      text: "Limited Time Only!",
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      commonBoldText(
                                        text: "${appLoadController.loggedUserData.value.ucurrency} ",
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                      commonBoldText(
                                        text: "999",
                                        color: Colors.white,
                                        fontSize: 32,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  commonText(
                                    text: "Complete Horoscope Package",
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 16,
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        _buildOfferItem("Personalized Birth Chart", true),
                                        _buildOfferItem("90-Day Predictions", true),
                                        _buildOfferItem("Life Guidance Questions", true),
                                        _buildOfferItem("Planetary Transit Readings", true),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Add New Horoscope button
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: GradientButton(
                              title: "Add New Horoscope",
                              buttonHeight: 50,
                              textColor: Colors.white,
                              buttonColors: const [Color(0xFF8A3FFC), Color(0xFFAA6BFF)],
                              onPressed: (Offset buttonOffset) {
                                addHoroscopeController.refreshAlerts();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const AddNativePhoto())
                                );
                              },
                              materialIcon: Icons.add,
                              materialIconSize: 24,
                            ),
                          ),
                          const Spacer(),
                          // View Pricing button at bottom
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => const PricingPage()));
                              },
                              child: commonText(
                                text: "Checkout our pricing plans",
                                color: const Color(0xFF8A3FFC),
                                fontSize: 14,
                                textDecoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                        : Expanded(
                      child: ListView.builder(
                        itemCount: applicationBaseController.horoscopeList
                            .length,
                        itemBuilder: (BuildContext context, int index) {
                          final bool isPaid = applicationBaseController
                              .horoscopeList[index].isPaid == "true";
                          final bool isHoroscopeGenerated = applicationBaseController
                              .horoscopeList[index].hstatus == "5";
                          return // Replace your existing card structure with this
                            Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey,
                                    width: 0.2,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(7, 7, 7, 7),
                                child: Stack(
                                  children: [
                                    // Main content
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            // Profile image
                                            GestureDetector(
                                              onTap: () {
                                                _openImagePicker(context,
                                                    applicationBaseController.horoscopeList[index].hid!);
                                              },
                                              child: ClipOval(
                                                child: Container(
                                                  width: 55,
                                                  height: 55,
                                                  // Image code remains the same
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                        applicationBaseController.horoscopeList[index].hnativephoto!,
                                                        headers: {
                                                          'Access-Control-Allow-Origin': '*',
                                                          'Access-Control-Allow-Methods': 'GET',
                                                        },
                                                      ),
                                                      fit: BoxFit.cover,
                                                      onError: (error, stackTrace) {
                                                        print('Error loading image: $error');
                                                      },
                                                    ),
                                                  ),
                                                  child: Image.network(
                                                    applicationBaseController.horoscopeList[index].hnativephoto!,
                                                    width: 55,
                                                    height: 55,
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (context, child, loadingProgress) {
                                                      if (loadingProgress == null) return child;
                                                      return Center(
                                                        child: CircularProgressIndicator(
                                                          value: loadingProgress.expectedTotalBytes != null
                                                              ? loadingProgress.cumulativeBytesLoaded /
                                                              loadingProgress.expectedTotalBytes!
                                                              : null,
                                                        ),
                                                      );
                                                    },
                                                    errorBuilder: (context, error, stackTrace) {
                                                      print('Web image error: $error');
                                                      return Container(
                                                        width: 55,
                                                        height: 55,
                                                        color: Colors.grey[300],
                                                        child: const Icon(Icons.person, size: 25, color: Colors.black54),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // Horoscope details
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    // Horoscope name
                                                    Flexible(
                                                      child: LayoutBuilder(
                                                        builder: (context, constraints) {
                                                          // Check if screen width is mobile size
                                                          bool isMobileSize = MediaQuery.of(context).size.width < 600; // You can adjust this breakpoint
                                                          return commonBoldText(
                                                            textOverflow: TextOverflow.ellipsis,
                                                            text: applicationBaseController.horoscopeList[index].hname!,
                                                            fontSize: 14,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    if(!isPaid) SizedBox(width: 4),
                                                    // Edit icon button
                                                    if(!isPaid) Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        borderRadius: BorderRadius.circular(16),
                                                        onTap: () {
                                                          // Handle edit action
                                                          if (applicationBaseController.horoscopeList[index].hstatus == "1") {
                                                            addHoroscopeController.editHoroscope(
                                                                applicationBaseController.horoscopeList[index]);
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(builder: (context) => const AddNativePhoto()),
                                                            );
                                                          } else {
                                                            CustomDialog.showAlert(context,
                                                                "You can't edit this horoscope because it has already been generated",
                                                                false, 12);
                                                          }
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(2.0),
                                                          child: Container(
                                                            padding: const EdgeInsets.all(2),
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              border: Border.all(color: Colors.grey[300]!),
                                                            ),
                                                            child: Icon(
                                                              Icons.edit_outlined,
                                                              size: 12,
                                                              color: Colors.grey[600],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    // Delete icon button
                                                    if(!isPaid) Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        borderRadius: BorderRadius.circular(16),
                                                        onTap: () {
                                                          // Handle delete action
                                                          yesOrNoDialog(
                                                            context: context,
                                                            cancelAction: () {
                                                              Navigator.pop(context);
                                                            },
                                                            dialogMessage: 'Are you sure you want to delete this horoscope?',
                                                            cancelText: 'No',
                                                            okText: 'Yes',
                                                            okAction: () {
                                                              Navigator.pop(context);
                                                              deleteHoroscope(
                                                                applicationBaseController.horoscopeList[index].huserid!,
                                                                applicationBaseController.horoscopeList[index].hid!.trim(),
                                                              );
                                                            },
                                                          );
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(2.0),
                                                          child: Container(
                                                            padding: const EdgeInsets.all(2),
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              border: Border.all(color: Colors.grey[300]!),
                                                            ),
                                                            child: const SizedBox(
                                                              width: 14,
                                                              height: 14,
                                                              child: Center(
                                                                child: Icon(
                                                                  Icons.delete_outline,
                                                                  size: 12,
                                                                  color: Colors.red,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                commonText(
                                                    text: 'DOB: ${convertDateFormat(
                                                        applicationBaseController.horoscopeList[index].hdobnative!.substring(
                                                            0,
                                                            applicationBaseController.horoscopeList[index].hdobnative!.indexOf("T")
                                                        )
                                                    )}',
                                                    color: Colors.black38,
                                                    fontSize: 11
                                                ),
                                                commonText(
                                                    text: 'Horoscope ID: ${applicationBaseController.horoscopeList[index].hid}',
                                                    color: Colors.black38,
                                                    fontSize: 11
                                                ),
                                                if(isPaid && applicationBaseController.horoscopeList[index].hstatus != '5')commonBoldText(
                                                    text: 'Horoscope is in progress',
                                                    color: Colors.green[600],
                                                    fontSize: 11
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        // Action buttons
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                              child: GradientButton(
                                                  title: LocalizationController
                                                      .getInstance()
                                                      .getTranslatedValue("Plans"),
                                                  buttonHeight: 30,
                                                  textColor: Colors.white,
                                                  isDisabled: (!isPaid && applicationBaseController.horoscopeList[index].hstatus != '5') || (isPaid && applicationBaseController.horoscopeList[index].hstatus != '5'),
                                                  buttonColors: const [
                                                    Color(0xFFf2b20a),
                                                    Color(0xFFf34509)
                                                  ],
                                                  onPressed: (
                                                      Offset buttonOffset) async {
                                                    if (!isPaid) {
                                                      navigateToPaymentScreen();
                                                      return;
                                                    }
                                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                                    await prefs.setString('paymentHid',
                                                        applicationBaseController
                                                            .horoscopeList[index]
                                                            .hid!
                                                    );
                                                    if (applicationBaseController
                                                        .horoscopeList[index]
                                                        .hstatus == '5') {
                                                      if (horoscopeRequestController
                                                          .deviceCurrentLocationFound
                                                          .value == true) {
                                                        final RenderBox overlay = Overlay
                                                            .of(context)!.context
                                                            .findRenderObject() as RenderBox;
                                                        final RelativeRect position = RelativeRect
                                                            .fromRect(
                                                          Rect.fromPoints(
                                                            buttonOffset,
                                                            buttonOffset +
                                                                buttonOffset, // buttonSize is the size of the button
                                                          ),
                                                          Offset.zero & overlay
                                                              .size, // Overlay size
                                                        );
                                                        final selectedValue = await showMenu(
                                                          context: context,
                                                          position: position,
                                                          items: [
                                                            PopupMenuItem(
                                                              value: 1,
                                                              child: commonText(
                                                                  text: LocalizationController
                                                                      .getInstance()
                                                                      .getTranslatedValue(
                                                                      "Daily Predictions - 90 days"),
                                                                  fontSize: 14),
                                                            ),
                                                            PopupMenuItem(
                                                              value: 3,
                                                              child: commonText(
                                                                  text: LocalizationController
                                                                      .getInstance()
                                                                      .getTranslatedValue(
                                                                      "Life Guidance Questions"),
                                                                  fontSize: 14),
                                                            )
                                                          ],
                                                        );

                                                        if (selectedValue != null) {
                                                          switch (selectedValue) {
                                                            case 1:
                                                              horoscopeRequestController
                                                                  .selectedRequest
                                                                  .value = 1;
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (
                                                                        context) =>
                                                                        DailyPredictions(
                                                                            horoscope: applicationBaseController
                                                                                .horoscopeList[index])),
                                                              );
                                                              break;
                                                            case 3:
                                                              horoscopeRequestController
                                                                  .selectedRequest
                                                                  .value = 3;
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (
                                                                        context) =>
                                                                        SpecialPredictions(
                                                                            horoscope: applicationBaseController
                                                                                .horoscopeList[index])),
                                                              );
                                                              break;
                                                          }
                                                        }
                                                      } else {
                                                        CustomDialog.showLoading(
                                                            context, 'Please wait');
                                                        var request = await horoscopeRequestController
                                                            .getCurrentLocation(
                                                            context);
                                                        print(
                                                            'the received value of request $request');
                                                        if (request == true) {
                                                          print(
                                                              'the true value is occured');
                                                          final RenderBox overlay = Overlay
                                                              .of(context)!.context
                                                              .findRenderObject() as RenderBox;
                                                          final RelativeRect position = RelativeRect
                                                              .fromRect(
                                                            Rect.fromPoints(
                                                              buttonOffset,
                                                              buttonOffset +
                                                                  buttonOffset, // buttonSize is the size of the button
                                                            ),
                                                            Offset.zero & overlay
                                                                .size, // Overlay size
                                                          );
                                                          final selectedValue = await showMenu(
                                                            context: context,
                                                            position: position,
                                                            items: [
                                                              PopupMenuItem(
                                                                value: 1,
                                                                child: commonText(
                                                                    text: LocalizationController
                                                                        .getInstance()
                                                                        .getTranslatedValue(
                                                                        "Daily Predictions - 90 days"),
                                                                    fontSize: 14),
                                                              ),
                                                              PopupMenuItem(
                                                                value: 3,
                                                                child: commonText(
                                                                    text: LocalizationController
                                                                        .getInstance()
                                                                        .getTranslatedValue(
                                                                        "Life Guidance Questions"),
                                                                    fontSize: 14),
                                                              ),
                                                            ],
                                                          );
                                                          if (selectedValue !=
                                                              null) {
                                                            switch (selectedValue) {
                                                              case 1:
                                                                horoscopeRequestController
                                                                    .selectedRequest
                                                                    .value = 2;
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (
                                                                          context) =>
                                                                          DailyPredictions(
                                                                              horoscope: applicationBaseController
                                                                                  .horoscopeList[index])),
                                                                );
                                                                break;
                                                              case 3:
                                                                horoscopeRequestController
                                                                    .selectedRequest
                                                                    .value = 3;
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (
                                                                          context) =>
                                                                          SpecialPredictions(
                                                                              horoscope: applicationBaseController
                                                                                  .horoscopeList[index])),
                                                                );
                                                                break;
                                                            }
                                                          }
                                                        }
                                                      }
                                                    } else {
                                                      CustomDialog.showAlert(
                                                          context,
                                                          LocalizationController
                                                              .getInstance()
                                                              .getTranslatedValue(
                                                              "Horoscope is under preparation"),
                                                          null, 14);
                                                    }
                                                  }),
                                            ),
                                            Expanded(
                                              child: GradientButton(
                                                  title: LocalizationController
                                                      .getInstance()
                                                      .getTranslatedValue(
                                                      "Predictions"),
                                                  buttonHeight: 30,
                                                  textColor: Colors.white,
                                                  isDisabled: (!isPaid && applicationBaseController.horoscopeList[index].hstatus != '5') || (isPaid && applicationBaseController.horoscopeList[index].hstatus != '5'),
                                                  buttonColors: const [
                                                    Color(0xFFf2b20a),
                                                    Color(0xFFf34509)
                                                  ],
                                                  onPressed: (
                                                      Offset buttonOffset) async {
                                                    if (!isPaid) {
                                                      navigateToPaymentScreen();
                                                      return;
                                                    }
                                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                                    await prefs.setString('paymentHid',
                                                        applicationBaseController
                                                            .horoscopeList[index]
                                                            .hid!
                                                    );
                                                    if (applicationBaseController
                                                        .horoscopeList[index]
                                                        .hstatus == '5') {
                                                      _getUserPredictions(
                                                          applicationBaseController
                                                              .horoscopeList[index]
                                                              .hid!.trim());
                                                    } else {
                                                      CustomDialog.showAlert(
                                                          context,
                                                          LocalizationController
                                                              .getInstance()
                                                              .getTranslatedValue(
                                                              "Prediction is yet to be generated"),
                                                          null, 14);
                                                    }
                                                  }),
                                            ),
                                            Expanded(
                                              child: GradientButton(
                                                  title: isPaid
                                                      ? LocalizationController.getInstance().getTranslatedValue("Horoscope")
                                                      : LocalizationController.getInstance().getTranslatedValue("Make Payment"),
                                                  buttonHeight: 30,
                                                  textColor: Colors.white,
                                                  isDisabled: (isPaid && applicationBaseController.horoscopeList[index].hstatus != '5'),
                                                  buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
                                                  onPressed: (
                                                      Offset buttonOffset) async {
                                                    if (!isPaid) {
                                                      // Navigate to payment screen
                                                      if (appLoadController.loggedUserData!.value.ucurrency!
                                                          .toLowerCase()
                                                          .compareTo('INR'.toLowerCase()) ==
                                                          0) {
                                                        paymentController.payByUpi(
                                                            applicationBaseController
                                                                .horoscopeList[index]
                                                                .huserid!,
                                                            applicationBaseController
                                                                .horoscopeList[index]
                                                                .requestId!,
                                                            applicationBaseController
                                                                .horoscopeList[index]
                                                                .amount!,
                                                            appLoadController.loggedUserData.value.token!,
                                                            'horoscope',
                                                            context);
                                                      }else if (appLoadController.loggedUserData!.value.ucurrency!
                                                          .toLowerCase()
                                                          .compareTo('AED'.toLowerCase()) ==
                                                          0) {
                                                        paymentController.payByStripe(
                                                            applicationBaseController
                                                                .horoscopeList[index]
                                                                .huserid!,
                                                            applicationBaseController
                                                                .horoscopeList[index]
                                                                .requestId!,
                                                            applicationBaseController
                                                                .horoscopeList[index]
                                                                .amount!,
                                                            'horoscope',
                                                            appLoadController.loggedUserData.value.token!,
                                                            context);
                                                      } else {
                                                        paymentController.payByStripe(
                                                            applicationBaseController
                                                                .horoscopeList[index]
                                                                .huserid!,
                                                            applicationBaseController
                                                                .horoscopeList[index]
                                                                .requestId!,
                                                            applicationBaseController
                                                                .horoscopeList[index]
                                                                .amount!,
                                                            'horoscope',
                                                            appLoadController.loggedUserData.value.token!,
                                                            context);
                                                      }
                                                      return;
                                                    }
                                                    final RenderBox overlay = Overlay
                                                        .of(context).context
                                                        .findRenderObject() as RenderBox;
                                                    final RelativeRect position = RelativeRect
                                                        .fromRect(
                                                      Rect.fromPoints(
                                                        buttonOffset,
                                                        buttonOffset +
                                                            buttonOffset, // buttonSize is the size of the button
                                                      ),
                                                      Offset.zero & overlay
                                                          .size, // Overlay size
                                                    );
                                                    final selectedValue = await showMenu(
                                                      context: context,
                                                      position: position,
                                                      items: [
                                                        PopupMenuItem(
                                                          value: 1,
                                                          child: commonText(
                                                              text: LocalizationController
                                                                  .getInstance()
                                                                  .getTranslatedValue(
                                                                  'Show Horoscope'),
                                                              fontSize: 14),
                                                        ),
                                                        if(!isPaid)PopupMenuItem(
                                                          value: 2,
                                                          child: commonText(
                                                              text: LocalizationController
                                                                  .getInstance()
                                                                  .getTranslatedValue(
                                                                  'Edit Horoscope'),
                                                              fontSize: 14),
                                                        ),
                                                        PopupMenuItem(
                                                          value: 3,
                                                          child: commonText(
                                                              text: LocalizationController
                                                                  .getInstance()
                                                                  .getTranslatedValue(
                                                                  'Two Page Horoscope'),
                                                              fontSize: 14),
                                                        ),
                                                        if(!isPaid)PopupMenuItem(
                                                          value: 4,
                                                          child: commonText(
                                                              text: LocalizationController
                                                                  .getInstance()
                                                                  .getTranslatedValue(
                                                                  'Delete Horoscope'),
                                                              fontSize: 14),
                                                        ),
                                                        if(isPaid)PopupMenuItem(
                                                          value: 5,
                                                          child: commonText(
                                                              text: LocalizationController
                                                                  .getInstance()
                                                                  .getTranslatedValue(
                                                                  'Messages'),
                                                              fontSize: 14),
                                                        ),
                                                      ],
                                                    );

                                                    if (selectedValue != null) {
                                                      switch (selectedValue) {
                                                        case 1:
                                                          viewHoroscope(
                                                              applicationBaseController
                                                                  .horoscopeList[index]
                                                                  .huserid!,
                                                              applicationBaseController
                                                                  .horoscopeList[index]
                                                                  .hid!.trim(),
                                                              isPaid
                                                          );
                                                          break;
                                                        case 2:
                                                          if (applicationBaseController
                                                              .horoscopeList[index]
                                                              .hstatus == "1") {
                                                            addHoroscopeController
                                                                .editHoroscope(
                                                                applicationBaseController
                                                                    .horoscopeList[index]);
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (
                                                                      context) => const AddNativePhoto()),
                                                            );
                                                          } else {
                                                            CustomDialog.showAlert(
                                                                context,
                                                                "You cant edit this horoscope because horoscope already generated",
                                                                false, 12);
                                                          }
                                                          break;
                                                        case 3:
                                                          print(
                                                              'the value of hpdf ${applicationBaseController
                                                                  .horoscopeList[index]
                                                                  .hpdf!}');
                                                          viewTwoPageKundli(
                                                              applicationBaseController
                                                                  .horoscopeList[index]
                                                                  .hpdf!);
                                                          break;
                                                        case 4:
                                                          print(
                                                              'selected value is 4');
                                                          yesOrNoDialog(
                                                            context: context,
                                                            cancelAction: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            dialogMessage: 'Are you sure you want to delete?',
                                                            cancelText: 'No',
                                                            okText: 'Yes',
                                                            okAction: () {
                                                              Navigator.pop(
                                                                  context);
                                                              deleteHoroscope(
                                                                applicationBaseController
                                                                    .horoscopeList[index]
                                                                    .huserid!,
                                                                applicationBaseController
                                                                    .horoscopeList[index]
                                                                    .hid!.trim(),
                                                              );
                                                            },
                                                          );
                                                          break;
                                                        case 5:
                                                          SharedPreferences prefs = await SharedPreferences.getInstance();
                                                          await prefs.setString('paymentHid',
                                                              applicationBaseController
                                                                  .horoscopeList[index]
                                                                  .hid!
                                                          );
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (
                                                                    context) =>
                                                                    MessagesList(
                                                                        horoscopeId: applicationBaseController
                                                                            .horoscopeList[index]
                                                                            .hid!)),
                                                          );
                                                          break;
                                                      }
                                                    }
                                                  }),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                      ],
                                    ),

                                    // Payment Status Badge - Positioned at the top right
                                    Positioned(
                                      top: 15,
                                      right: 15,
                                      child: !isPaid
                                          ? Column(
                                            children: [
                                              Center(
                                                child: commonBoldText(
                                              text: 'Payment Pending',
                                              color: Colors.red[800],
                                              fontSize: 10,
                                              textAlign: TextAlign.center)),
                                              Center(
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.baseline, // Align text baselines
                                                    textBaseline: TextBaseline.alphabetic, // Required for baseline alignment
                                                    children: [
                                                      commonBoldText(
                                                          text: '${appLoadController.loggedUserData.value.ucurrency}',
                                                          color: Colors.grey,
                                                          fontSize: 12,
                                                          textAlign: TextAlign.center),
                                                      commonBoldText(
                                                          text: ' ${formatIndianRupees(applicationBaseController.horoscopeList[index].amount!)}',
                                                          color: Colors.grey,
                                                          fontSize: 24,
                                                          textAlign: TextAlign.start),
                                                    ],
                                                  ))
                                            ],
                                          )
                                          : Center(
                                        child: commonBoldText(
                                          text: 'Paid',
                                          color: Colors.green[800],
                                          fontSize: 12,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                        },
                      ),
                    )
                  ],
                );
            })
        ),
      );
    });
  }
}