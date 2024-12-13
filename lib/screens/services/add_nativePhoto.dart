// AddNativePhoto.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/controllers/add_horoscope_controller.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/screens/dashboard.dart';
import 'package:get/get.dart';
import 'package:planetcombo/screens/services/add_primaryInfo.dart';
import 'package:planetcombo/screens/services/horoscope_services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:planetcombo/api/api_endpoints.dart';

class AddNativePhoto extends StatefulWidget {
  const AddNativePhoto({Key? key}) : super(key: key);

  @override
  _AddNativePhotoState createState() => _AddNativePhotoState();
}

class _AddNativePhotoState extends State<AddNativePhoto> {
  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  final LocalizationController localizationController =
  Get.put(LocalizationController.getInstance(), permanent: true);

  final AddHoroscopeController addHoroscopeController =
  Get.put(AddHoroscopeController.getInstance(), permanent: true);

  @override
  void initState() {
    super.initState();
    // Clear previous image data when page loads
    _clearImageData();
  }

  @override
  void dispose() {
    // Clear image data when leaving the page
    _clearImageData();
    super.dispose();
  }

  void _clearImageData() {
    addHoroscopeController.imageFileList?.clear();
    addHoroscopeController.webDisplayImageFileList?.value = [];
    addHoroscopeController.setHoroscopeWebProfileImageBase64?.value = '';
    addHoroscopeController.selectedImageFile?.value = null;
  }


  final ImagePicker _picker = ImagePicker();

  Future<void> _openImagePicker() async {
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
                  _getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              if (!kIsWeb)
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
    try {
      _clearImageData();
      final XFile? pickedImage = await _picker.pickImage(
        source: source,
        imageQuality: 85, // Compress image
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedImage != null) {
        if (kIsWeb) {
          // Handle web image
          final bytes = await pickedImage.readAsBytes();
          final base64Data = base64Encode(bytes);

          addHoroscopeController.setHoroscopeProfileWebImageBase64(base64Data);
          addHoroscopeController.webDisplayImageFileList?.value = [pickedImage];

          // Store original file for upload
          addHoroscopeController.selectedImageFile?.value = pickedImage;
        } else {
          // Handle mobile image
          addHoroscopeController.setImageFileListFromFile(pickedImage);
          addHoroscopeController.selectedImageFile.value = pickedImage;
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      // Show error message to user
    }
  }

  Widget _buildImagePreview() {
    if (addHoroscopeController.imageFileList!.isNotEmpty ||
        addHoroscopeController.setHoroscopeWebProfileImageBase64!.isNotEmpty) {
      return GestureDetector(
        onTap: _openImagePicker,
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: appLoadController.appMidColor,
            borderRadius: BorderRadius.circular(50),
          ),
          child: CircleAvatar(
            radius: 50,
            child: ClipOval(
              child: kIsWeb
                  ? Image.memory(
                base64Decode(addHoroscopeController
                    .setHoroscopeWebProfileImageBase64!.value),
                width: 95,
                height: 95,
                fit: BoxFit.cover,
              )
                  : Image.file(
                File(addHoroscopeController.imageFileList![0].path),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: _openImagePicker,
        child: addHoroscopeController.hNativePhoto.value == ''
            ? Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: appLoadController.appMidColor,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: commonBoldText(
              text: 'Upload Horoscope Profile Picture',
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
              addHoroscopeController.hNativePhoto.value,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        title: LocalizationController.getInstance().getTranslatedValue(
            "Add Horoscope (${appLoadController.loggedUserData.value.username})"),
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Dashboard()),
                    (Route<dynamic> route) => false,
              );
            },
            icon: const Icon(Icons.home_outlined),
          )
        ],
      ),
      body: Obx(
            () => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 3,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildImagePreview(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 20),
                      child: commonText(
                        textAlign: TextAlign.center,
                        color: Colors.black38,
                        fontSize: 14,
                        text: LocalizationController.getInstance()
                            .getTranslatedValue(
                            'Every horoscope needs to be corrected for exact birth time. Hence, we are gathering important data which will help us in rectifying the birth time accurately as much as possible.'),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 300,
              child: GradientButton(
                title: LocalizationController.getInstance()
                    .getTranslatedValue("Next"),
                buttonHeight: 45,
                textColor: Colors.white,
                buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
                onPressed: (Offset buttonOffset) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddPrimary()),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

// AddHoroscopeController extension
extension ImageHandling on AddHoroscopeController {
  Future<void> uploadImage(BuildContext context) async {
    try {
      CustomDialog.showLoading(context, 'Please wait');

      final String filename = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Map<String, String> headers = {
        'TOKEN': appLoadController.loggedUserData.value.token!,
      };

      const String fileKey = 'hNativePhoto';
      final String url = hid.value == '0'
          ? '${APIEndPoints.baseUrl}api/horoscope/addNew?fileKey=$fileKey'
          : '${APIEndPoints.baseUrl}api/horoscope/updateHoroscope?fileKey=$fileKey';

      final Map<String, String> fields = _prepareFormFields();

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(headers);
      request.fields.addAll(fields);

      // Handle file upload based on platform
      if (selectedImageFile.value != null) {
        if (kIsWeb) {
          // Web file handling
          final bytes = await selectedImageFile.value!.readAsBytes();
          final multipartFile = http.MultipartFile.fromBytes(
            'hNativePhoto',
            bytes,
            filename: filename,
            contentType: MediaType('image', 'jpeg'),
          );
          request.files.add(multipartFile);
        } else {
          // Mobile file handling
          final multipartFile = await http.MultipartFile.fromPath(
            'hNativePhoto',
            selectedImageFile.value!.path,
          );
          request.files.add(multipartFile);
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        await _handleSuccessResponse(context);
      } else {
        _handleErrorResponse(context, 'Failed to upload horoscope');
      }
    } catch (e) {
      _handleErrorResponse(context, 'Error uploading horoscope: $e');
    }
  }

  Map<String, String> _prepareFormFields() {
    // Your existing fields map code here
    return {
      'HUSERID': appLoadController.loggedUserData.value.userid!,
      'HID': hid.value == '0' ? '0' : hid.value.trim(),
      // ... rest of your fields
    };
  }

  Future<void> _handleSuccessResponse(BuildContext context) async {
    CustomDialog.cancelLoading(context);
    CustomDialog.okActionAlert(
      context,
      'Horoscope added successfully',
      'OK',
      true,
      14,
          () async {
        await applicationBaseController.getUserHoroscopeList();
        CustomDialog.showLoading(context, 'Please wait');
        await Future.delayed(const Duration(seconds: 2));
        CustomDialog.cancelLoading(context);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HoroscopeServices()),
              (Route<dynamic> route) => false,
        );
      },
    );
  }

  void _handleErrorResponse(BuildContext context, String message) {
    CustomDialog.cancelLoading(context);
    CustomDialog.okActionAlert(
      context,
      message,
      'OK',
      false,
      14,
          () => Navigator.pop(context),
    );
  }
}