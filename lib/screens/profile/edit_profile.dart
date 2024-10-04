import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/controllers/add_horoscope_controller.dart';
import 'package:planetcombo/models/social_login.dart';
import 'package:planetcombo/screens/dashboard.dart';
import 'package:planetcombo/screens/social_login.dart';
import 'package:planetcombo/screens/policy.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:planetcombo/controllers/request_controller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

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

  Future<Map<String, dynamic>> _getCurrentLocationAndCountry() async {
    print('i reached get location place');
    Position position;
    String country = 'Unknown';

    try {
      position = await Geolocator.getCurrentPosition();
      print('Position: $position');

      if (kIsWeb) {
        // Web implementation
        final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=3');
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          country = data['address']['country'] ?? 'Unknown';
          appLoadController.loggedUserData.value.ucountry = country;
        } else {
          print('Failed to get country name for web');
        }
      } else {
        // Mobile implementation
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        country = placemarks.first.country ?? 'Unknown';
        appLoadController.loggedUserData.value.ucountry = country;
      }

      print('Country: $country');

      return {
        'position': position,
        'country': country,
      };
    } catch (e) {
      print('Error getting location or country: $e');
      return {
        'position': null,
        'country': 'Unknown',
      };
    }
  }

  void getUserCurrency(String country) {
    if (country == "India" || country == "INDIA") {
      userCurrency.text = "INR";
      appLoadController.loggedUserData.value.ucurrency = "INR";
    } else if (country == "United Arab Emirates" || country == "UAE" || country == "Uae") {
      userCurrency.text = "AED";
      appLoadController.loggedUserData.value.ucurrency = "AED";
    } else {
      userCurrency.text = "USD";
      appLoadController.loggedUserData.value.ucurrency = "USD";
    }
  }

  void _openImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: kIsWeb
              ? ListTile(
            leading: const Icon(Icons.photo_library),
            title: commonBoldText(text: 'Choose from Computer'),
            onTap: () {
              _getImage(ImageSource.gallery);
              Navigator.of(context).pop();
            },
          )
              : Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: commonBoldText(text: 'Choose from Gallery'),
                onTap: () {
                  _getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: commonBoldText(text: 'Take a Photo'),
                onTap: () {
                  _getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);
    if (pickedImage != null) {
      if (kIsWeb) {
        final bytes = await pickedImage.readAsBytes();
        final base64Data = base64Encode(bytes);
        addHoroscopeController.setEditProfileImageBase64(base64Data);
      } else {
        addHoroscopeController.setEditProfileImageFileListFromFile(pickedImage);
      }
    }
  }

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

  @override
  void initState() {
    super.initState();
    addHoroscopeController.editProfileImageFileList?.clear();
    username.text = appLoadController.loggedUserData.value.username!;
    userEmail.text = appLoadController.loggedUserData.value.useremail!;
    isSwitched = appLoadController.loggedUserData.value.touchid == 'T';

    if (appLoadController.addNewUser.value == "YES") {
      _locationFuture = _getCurrentLocationAndCountry();
      userCountry.text = "";
      userCurrency.text = "";
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
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: commonText(
              textAlign: TextAlign.center,
              color: Colors.black38,
              fontSize: 14,
              text: LocalizationController.getInstance().getTranslatedValue('upload profile picture'),
            ),
          ),
          const SizedBox(height: 20),
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
                    LocalizationController.getInstance().getTranslatedValue('தமிழ்'),
                    LocalizationController.getInstance().getTranslatedValue('हिंदी'),
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
          // Display fetched location (optional)
          if (position != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Coordinates: ${position.latitude}, ${position.longitude}'),
            ),
        ],
      )),
    );
  }

  Widget _buildProfileImage() {
    if (addHoroscopeController.editProfileImageFileList!.isNotEmpty ||
        addHoroscopeController.editProfileImageBase64!.isNotEmpty) {
      return GestureDetector(
        onTap: appLoadController.addNewUser.value == 'YES' ? () {} : _openImagePicker,
        child: Container(
          height: 90,
          width: 90,
          decoration: BoxDecoration(
            color: appLoadController.appMidColor,
            borderRadius: BorderRadius.circular(50),
          ),
          child: CircleAvatar(
            radius: 50,
            child: ClipOval(
              child: kIsWeb
                  ? Image.memory(
                base64Decode(addHoroscopeController.editProfileImageBase64!.value),
                width: 95,
                height: 95,
                fit: BoxFit.cover,
              )
                  : Image.file(
                File(addHoroscopeController.editProfileImageFileList![0].path),
                width: 95,
                height: 95,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: _openImagePicker,
        child: (appLoadController.loggedUserData.value.userphoto == '' ||
            appLoadController.loggedUserData.value.userphoto == null)
            ? Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: appLoadController.appMidColor,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: commonBoldText(
              text: 'Press here to take your photo',
              textAlign: TextAlign.center,
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        )
            : CircleAvatar(
          radius: 50,
          child: ClipOval(
            child: Image.network(
              appLoadController.loggedUserData.value.userphoto!,
              width: 95,
              height: 95,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    bool readOnly = false,
    bool isAlert = false,
    Function(String?)? onValidate,
  }) {
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

  Widget _buildDropdown({
    required String label,
    required List<String> options,
    required String currentValue,
    required Function(String?) onChanged,
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
                  if(userCurrency.text == 'INR')Text(
                    'Payments accepted via GooglePay through UPI in India',
                    textAlign: TextAlign.left,
                  ),
                  if(userCurrency.text != 'INR')Text(
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
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const TermsConditions()),
                    );
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
          if (isChecked && isPaymentInfoChecked) {
            var response = await addHoroscopeController.addNewProfileWithoutImage(context);
            var string2json = json.decode(response);
            if ((string2json['Status'] == 'Success' && string2json['Data'] == null)) {
              CustomDialog.showAlert(context, string2json['Message'] + ' Please contact admin for more info', false, 14);
            } else {
              final prefs = await SharedPreferences.getInstance();
              String? jsonString = prefs.getString('UserInfo');
              var jsonBody = json.decode(jsonString!);
              appLoadController.loggedUserData.value = SocialLoginData.fromJson(jsonBody);
              applicationBaseController.initializeApplication();
              appLoadController.addNewUser.value = 'NO';
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => const Dashboard()));
            }
          } else {
            showFailedToast('Please read and agree the Terms and conditions & agree the payments');
          }
        } else {
          var response = await addHoroscopeController.updateProfile(context, username.text);
          if (response != null) {
            var responseData = json.decode(response);
            SharedPreferences pref = await SharedPreferences.getInstance();
            await pref.setString('UserInfo', json.encode(responseData['Data']));
            final prefs = await SharedPreferences.getInstance();
            String? jsonString = prefs.getString('UserInfo');
            var jsonBody = json.decode(jsonString!);
            appLoadController.loggedUserData.value = SocialLoginData.fromJson(jsonBody);
            if (responseData['Status'] == 'Success') {
              CustomDialog.showAlert(context, responseData['Message'], true, 14);
            } else {
              CustomDialog.showAlert(context, responseData['Message'], false, 14);
            }
          }
        }
      },
    );
  }
}