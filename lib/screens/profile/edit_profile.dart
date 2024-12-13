import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/controllers/add_horoscope_controller.dart';
import 'package:planetcombo/models/social_login.dart';
import 'package:planetcombo/screens/social_login.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:planetcombo/controllers/request_controller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:planetcombo/screens/web/webLogin.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({Key? key}) : super(key: key);

  @override
  _ProfileEditState createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  final LocalizationController localizationController =
  Get.put(LocalizationController.getInstance(), permanent: true);

  final AddHoroscopeController addHoroscopeController =
  Get.put(AddHoroscopeController.getInstance(), permanent: true);

  final HoroscopeRequestController horoscopeRequestController =
  Get.put(HoroscopeRequestController.getInstance(), permanent: true);

  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  final ApplicationBaseController applicationBaseController =
  Get.put(ApplicationBaseController.getInstance(), permanent: true);

  TextEditingController username = TextEditingController();
  TextEditingController userEmail = TextEditingController();
  TextEditingController userCountry = TextEditingController();
  TextEditingController userCurrency = TextEditingController();

  bool isSwitched = false;
  bool isChecked = false;
  bool isPaymentInfoChecked = false;

  Future<Map<String, dynamic>>? _locationFuture;

  String currentValue(String value) {
    if (value == 'ta') {
      return 'தமிழ்';
    } else if (value == 'en') {
      return 'English';
    } else if (value == 'hi') {
      return 'हिंदी';
    }
    return '';
  }

  void getUserCurrency(String country) {
    if (country == "India" || country == "INDIA") {
      userCurrency.text = "INR";
      appLoadController.loggedUserData.value.ucurrency = "INR";
      applicationBaseController.getTermsAndConditions();
    } else if (country == "United Arab Emirates" || country == "UAE" || country == "Uae") {
      userCurrency.text = "AED";
      appLoadController.loggedUserData.value.ucurrency = "AED";
      applicationBaseController.getTermsAndConditions();
    } else {
      userCurrency.text = "USD";
      appLoadController.loggedUserData.value.ucurrency = "USD";
      applicationBaseController.getTermsAndConditions();
    }
  }

// Create a global key for loading dialog
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  Future<void> _showPermissionRetryDialog() async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text(LocalizationController.getInstance().getTranslatedValue('Location Not Enabled')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(LocalizationController.getInstance().getTranslatedValue(
                    'Please make sure to allow location access in your browser when prompted.'
                )),
                const SizedBox(height: 15),
                if (kIsWeb) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocalizationController.getInstance().getTranslatedValue('Browser Instructions:'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('• ' + LocalizationController.getInstance().getTranslatedValue(
                            'Look for the location icon in the address bar'
                        )),
                        Text('• ' + LocalizationController.getInstance().getTranslatedValue(
                            'Click it and select "Allow"'
                        )),
                        Text('• ' + LocalizationController.getInstance().getTranslatedValue(
                            'Then try again'
                        )),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text(LocalizationController.getInstance().getTranslatedValue('Cancel')),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: Text(LocalizationController.getInstance().getTranslatedValue('Try Again')),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  if (mounted) {
                    setState(() {
                      _locationFuture = _getCurrentLocationAndCountry();
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _showSettingsDialog() async {
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(LocalizationController.getInstance().getTranslatedValue('Location Access Required')),
          content: Text(LocalizationController.getInstance().getTranslatedValue(
              'Location access is permanently denied. Please enable it in your device settings to continue.'
          )),
          actions: <Widget>[
            TextButton(
              child: Text(LocalizationController.getInstance().getTranslatedValue('Cancel')),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(LocalizationController.getInstance().getTranslatedValue('Open Settings')),
              onPressed: () async {
                await Geolocator.openLocationSettings();
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<bool> _checkLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        return await _showLocationDialog();
      } else if (permission == LocationPermission.deniedForever) {
        if (kIsWeb) {
          // For web, show the improved location dialog
          return await _showLocationDialog();
        } else {
          // For mobile, show settings dialog
          return await _showSettingsDialog();
        }
      }

      return true;
    } catch (e) {
      if (kIsWeb) {
        return await _showLocationDialog();
      }
      return false;
    }
  }

  Future<bool> _showLocationDialog() async {
    OverlayEntry? loadingOverlay;
    bool permissionGranted = false;

    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(LocalizationController.getInstance().getTranslatedValue('Enable Location')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(LocalizationController.getInstance().getTranslatedValue(
                  'To set your country and currency, please follow these steps:'
              )),
              const SizedBox(height: 15),
              Text('1. ' + LocalizationController.getInstance().getTranslatedValue(
                  'Click Enable below'
              )),
              Text('2. ' + LocalizationController.getInstance().getTranslatedValue(
                  'When your browser shows the location popup, click Allow'
              )),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(LocalizationController.getInstance().getTranslatedValue('Cancel')),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text(LocalizationController.getInstance().getTranslatedValue('Enable')),
              onPressed: () async {
                final currentContext = context;

                // Show loading overlay
                loadingOverlay = OverlayEntry(
                  builder: (context) => Material(
                    color: Colors.black54,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 20),
                            Text(
                              LocalizationController.getInstance().getTranslatedValue(
                                  'Waiting for browser permission...'
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );

                Navigator.of(currentContext).pop(true);

                if (mounted) {
                  Overlay.of(currentContext).insert(loadingOverlay!);
                }

                try {
                  // Request permission and wait for the result
                  final permission = await Geolocator.requestPermission();

                  // Check if permission was actually granted
                  if (permission == LocationPermission.always ||
                      permission == LocationPermission.whileInUse) {
                    // Try to get the position to verify permission
                    try {
                      await Geolocator.getCurrentPosition(
                          timeLimit: const Duration(seconds: 5)
                      );
                      permissionGranted = true;
                    } catch (e) {
                      permissionGranted = false;
                    }
                  }

                  // Remove loading overlay
                  loadingOverlay?.remove();
                  loadingOverlay = null;

                  if (!permissionGranted && mounted) {
                    _showPermissionRetryDialog();
                  }
                } catch (e) {
                  loadingOverlay?.remove();
                  loadingOverlay = null;
                  if (mounted) {
                    _showPermissionRetryDialog();
                  }
                }
              },
            ),
          ],
        );
      },
    );

    // Clean up overlay if it still exists
    loadingOverlay?.remove();

    return permissionGranted;
  }

  Future<Map<String, dynamic>> _getCurrentLocationAndCountry() async {
    try {
      bool permissionGranted = await _checkLocationPermission();
      if (!permissionGranted) {
        throw Exception('Location permission not granted');
      }

      Position position = await Geolocator.getCurrentPosition(
          timeLimit: const Duration(seconds: 10)
      );
      String country = 'Unknown';

      if (kIsWeb) {
        final url = Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=3'
        );

        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          country = data['address']['country'] ?? 'Unknown';
          appLoadController.loggedUserData.value.ucountry = country;
        }
      } else {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude
        );
        country = placemarks.first.country ?? 'Unknown';
        appLoadController.loggedUserData.value.ucountry = country;
      }

      return {
        'position': position,
        'country': country,
      };
    } catch (e) {
      if (!mounted) return {'position': null, 'country': 'Unknown'};

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(LocalizationController.getInstance().getTranslatedValue('Location Error')),
            content: Text(LocalizationController.getInstance().getTranslatedValue(
                'Unable to get your location. Please ensure you have allowed location access in your browser.'
            )),
            actions: <Widget>[
              TextButton(
                child: Text(LocalizationController.getInstance().getTranslatedValue('Try Again')),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _locationFuture = _getCurrentLocationAndCountry();
                  });
                },
              ),
            ],
          );
        },
      );

      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    addHoroscopeController.editProfileImageFileList?.clear();
    username.text = appLoadController.loggedUserData.value.username!;
    userEmail.text = appLoadController.loggedUserData.value.useremail!;
    isSwitched = appLoadController.loggedUserData.value.touchid == 'T';

    if (appLoadController.addNewUser.value == "YES") {
      userCountry.text = "";
      userCurrency.text = "";

      // Initialize location fetching
      Future.microtask(() {
        if (mounted) {
          setState(() {
            _locationFuture = _getCurrentLocationAndCountry();
          });
        }
      });
    } else {
      userCountry.text = appLoadController.loggedUserData.value.ucountry!;
      userCurrency.text = appLoadController.loggedUserData.value.ucurrency!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(
          onPressed: () async {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove('UserInfo');
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const SocialLogin()),
              );
            }
          },
          icon: Icon(Icons.chevron_left_rounded),
        ),
        title: LocalizationController.getInstance().getTranslatedValue("Update Profile"),
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
        centerTitle: true,
      ),
      body: appLoadController.addNewUser.value == "YES"
          ? FutureBuilder<Map<String, dynamic>>(
        future: _locationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Please wait, fetching location...'),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text('No location data available'),
            );
          } else {
            Position? position = snapshot.data!['position'];
            String country = snapshot.data!['country'];
            userCountry.text = country;
            getUserCurrency(country);
            return _buildProfileContent(position);
          }
        },
      )
          : _buildProfileContent(null),
    );
  }

  Widget _buildProfileContent(Position? position) {
    return SingleChildScrollView(
      child: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          _buildProfileImage(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputField(
                  label: 'User Name',
                  controller: username,
                  hintText: 'Name or Nickname',
                  isAlert: addHoroscopeController.horoscopeNameAlert.value,
                  onValidate: (v) {
                    addHoroscopeController.horoscopeNameAlert.value = v == null || v.isEmpty;
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                _buildInputField(
                  label: 'Email',
                  controller: userEmail,
                  hintText: 'Email',
                  readOnly: true,
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: 'Country',
                  controller: userCountry,
                  hintText: 'Country',
                  readOnly: true,
                ),
                const SizedBox(height: 10),
                _buildInputField(
                  label: 'Billing Currency',
                  controller: userCurrency,
                  hintText: 'Currency',
                  readOnly: true,
                ),
                const SizedBox(height: 20),
                _buildDropdown(
                  label: 'Language',
                  options: [
                    LocalizationController.getInstance().getTranslatedValue('English'),
                    // LocalizationController.getInstance().getTranslatedValue('தமிழ்'),
                    // LocalizationController.getInstance().getTranslatedValue('हिंदी'),
                  ],
                  currentValue: currentValue(localizationController.currentLanguage.value),
                  onChanged: (value) {
                    if (value == 'தமிழ்') {
                      localizationController.currentLanguage.value = 'ta';
                    } else if (value == 'English') {
                      localizationController.currentLanguage.value = 'en';
                    } else if (value == 'हिंदी') {
                      localizationController.currentLanguage.value = 'hi';
                    }
                    localizationController.getLanguage();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          if (!kIsWeb) _buildFingerTouchSecurity(),
          if (appLoadController.addNewUser.value == 'YES') _buildPaymentInfo(),
          if (appLoadController.addNewUser.value == 'YES') _buildTermsAndConditions(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(child: _buildCancelButton()),
                SizedBox(width: 20),
                Expanded(child: _buildSaveButton()),
              ],
            ),
          ),
          if (position != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Coordinates: ${position.latitude}, ${position.longitude}'),
            ),
        ],
      )),
    );
  }

  Widget _buildNetworkImage(String imageUrl) {
    if (kIsWeb) {
      // For web platform
      return ClipOval(
        child: Container(
          width: 95,
          height: 95,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: NetworkImage(
                imageUrl,
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
            imageUrl,
            width: 95,
            height: 95,
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
                width: 95,
                height: 95,
                color: Colors.grey[300],
                child: const Icon(Icons.person, size: 40),
              );
            },
          ),
        ),
      );
    } else {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: 95,
          height: 95,
          fit: BoxFit.cover,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => Container(
            width: 95,
            height: 95,
            color: Colors.grey[300],
            child: const Icon(Icons.person, size: 40),
          ),
        ),
      );
    }
  }

  Widget _buildProfileImage() {
    return _buildNetworkImage(appLoadController.loggedUserData.value.userphoto!);
  }

  Widget _buildInputField({required String label, required TextEditingController controller, required String hintText,
    bool readOnly = false, bool isAlert = false, Function(String?)? onValidate,}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        commonBoldText(
          text: LocalizationController.getInstance().getTranslatedValue(label),
          fontSize: 12,
          color: isAlert ? Colors.red : Colors.black87,
          textAlign: TextAlign.start,
        ),
        PrimaryStraightInputText(
          readOnly: readOnly,
          onValidate: (v){},
          hintText: LocalizationController.getInstance().getTranslatedValue(hintText),
          controller: controller,
        ),
      ],
    );
  }

  Widget _buildDropdown({required String label, required List<String> options, required String currentValue, required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        commonBoldText(
          text: LocalizationController.getInstance().getTranslatedValue(label),
          fontSize: 12,
          color: Colors.black87,
          textAlign: TextAlign.start,
        ),
        ReusableDropdown(
          options: options,
          currentValue: currentValue,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildFingerTouchSecurity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Finger Touch Security')),
          Switch(
            value: isSwitched,
            activeColor: Colors.deepOrange,
            onChanged: (value) {
              setState(() {
                isSwitched = value;
              });
              appLoadController.loggedUserData.value.touchid = value ? 'T' : 'F';
            },
          )
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Row(
      children: [
        Checkbox(
          value: isPaymentInfoChecked,
          onChanged: (bool? value) {
            setState(() {
              isPaymentInfoChecked = value ?? false;
            });
          },
          checkColor: Colors.white,
          activeColor: Colors.orange,
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if(userCurrency.text == 'INR')const Text(
                    'Payments accepted only via UPI in India',
                    textAlign: TextAlign.left,
                  ),
                  if(userCurrency.text != 'INR')const Text(
                    'Payments accepted via Paypal using International Credit/Debit Cards',
                    textAlign: TextAlign.left,
                  ),
                ],
              )
            ),
          )
        ),
      ],
    );
  }

  Widget _buildTermsAndConditions() {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          onChanged: (bool? value) {
            setState(() {
              isChecked = value ?? false;
            });
          },
          checkColor: Colors.white,
          activeColor: Colors.orange,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                isChecked = !isChecked;
              });
            },
            child: Align(
              alignment: Alignment.centerLeft,
              child: IntrinsicWidth(
                child: TextButton(
                  onPressed: () {
                    launchUrl(Uri.parse(applicationBaseController.termsAndConditionsLink.value));
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'I read and agreed to the terms & conditions',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            )
          ),
        ),
      ],
    );
  }

  Widget _buildCancelButton() {
    return GradientButton(
      title: LocalizationController.getInstance().getTranslatedValue("Cancel"),
      buttonHeight: 45,
      textColor: Colors.white,
      buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
      onPressed: (Offset buttonOffset) async {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.remove('UserInfo');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SocialLogin()),
          );
        }
      },
    );
  }

  Widget _buildSaveButton() {
    return GradientButton(
      title: LocalizationController.getInstance().getTranslatedValue("Save"),
      buttonHeight: 45,
      textColor: Colors.white,
      buttonColors: ((appLoadController.addNewUser.value == "YES" && isChecked && isPaymentInfoChecked) || appLoadController.addNewUser.value == "NO") ? const [Color(0xFFf2b20a), Color(0xFFf34509)] : const [Color(0x19f2b20a), Color(0x19f34509)],
      onPressed: (Offset buttonOffset) async {
        if (appLoadController.addNewUser.value == 'YES') {
          if(appLoadController.loggedUserData.value.ucountry == 'Unknown'){
            CustomDialog.showAlert(context, 'You are trying to save profile without location enable, please allow the location and try again', false, 14);
          }else if (isChecked && isPaymentInfoChecked) {
            var response = await addHoroscopeController.addNewProfileWithoutImage(context);
            var string2json = json.decode(response);
            if ((string2json['status'] == 'Success' && string2json['data'] == null)) {
              CustomDialog.showAlert(context, string2json['message'] + ' Please contact admin for more info', false, 14);
            } else {
              appLoadController.addNewUser.value = 'NO';
              CustomDialog.okActionAlert(context, 'Your Profile has been successfully saved , Please login to continue', 'Ok', true, 14, (){
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => const WebLogin()));
              });
            }
          } else {
            showFailedToast('Please read and agree the Terms and conditions & agree the payments');
          }
        } else {
          var response = await addHoroscopeController.updateProfile(context, username.text);
          print('the response received after the profile Update $response');
          if (response != null) {
            var responseData = json.decode(response);
            SharedPreferences pref = await SharedPreferences.getInstance();
            await pref.setString('UserInfo', json.encode(responseData['data']));
            final prefs = await SharedPreferences.getInstance();
            String? jsonString = prefs.getString('UserInfo');
            var jsonBody = json.decode(jsonString!);
            appLoadController.loggedUserData.value = SocialLoginData.fromJson(jsonBody);
            if (responseData['status'] == 'Success') {
              CustomDialog.showAlert(context, responseData['message'], true, 14);
            } else {
              CustomDialog.showAlert(context, responseData['message'], false, 14);
            }
          }
        }
      },
    );
  }
}