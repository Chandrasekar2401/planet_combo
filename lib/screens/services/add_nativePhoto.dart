import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/controllers/add_horoscope_controller.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/screens/dashboard.dart';
import 'package:get/get.dart';
import 'package:planetcombo/screens/services/add_primaryInfo.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  void _openImagePicker() {
    print('theis is the images you clciked');
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: kIsWeb ? Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: commonBoldText(text: 'Choose from Computer'),
                onTap: () {
                  _getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ) : Wrap(
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
    if(pickedImage != null){
      if (kIsWeb) {
        // Web-specific handling
        final bytes = await pickedImage.readAsBytes();
        final base64Data = base64Encode(bytes);
        print('the web converted ${base64Data}');
        addHoroscopeController.setHoroscopeProfileWebImageBase64(base64Data);
      }else{
        addHoroscopeController.setImageFileListFromFile(pickedImage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(onPressed: () { Navigator.pop(context); }, icon: const Icon(Icons.chevron_left_rounded),),
        title: LocalizationController.getInstance().getTranslatedValue("Add Horoscope (${appLoadController.loggedUserData.value.username})"),
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)], centerTitle: true,
        actions: [
          IconButton(onPressed: (){
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Dashboard()),
                  (Route<dynamic> route) => false,
            );
          }, icon: const Icon(Icons.home_outlined))
        ],),
      body: Obx(() => Column(
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
                    addHoroscopeController.imageFileList!.isNotEmpty || addHoroscopeController.setHoroscopeWebProfileImageBase64!.isNotEmpty ?
                    GestureDetector(
                      onTap: _openImagePicker,
                      child: Container(
                          height:100,
                          width: 100,
                          decoration: BoxDecoration(
                              color: appLoadController.appMidColor,
                              borderRadius: BorderRadius.circular(50)
                          ),
                          child:
                          CircleAvatar(
                            radius: 50,
                            child: ClipOval(
                              child: kIsWeb ?  Image.memory(
                                base64Decode(addHoroscopeController.setHoroscopeWebProfileImageBase64!.value),
                                width: 95,
                                height: 95,
                                fit: BoxFit.cover,
                              ): Image.file(File(addHoroscopeController.imageFileList![0].path),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                      ),
                    ):
                    GestureDetector(
                      onTap: _openImagePicker,
                      child: addHoroscopeController.hNativePhoto.value == '' ?
                      Container(
                        height:100,
                        width: 100,
                        decoration: BoxDecoration(
                            color: appLoadController.appMidColor,
                            borderRadius: BorderRadius.circular(50)
                        ),
                        child:
                        Center(child: commonBoldText(text: 'Press here to take your photo',textAlign: TextAlign.center, color: Colors.white, fontSize: 10)),
                      ) :
                      CircleAvatar(
                        radius: 50,
                        child: ClipOval(
                          child: Image.network(addHoroscopeController.hNativePhoto.value,
                              width: 100, height: 100,
                          fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      child: commonText(textAlign: TextAlign.center,color: Colors.black38, fontSize: 14, text: LocalizationController.getInstance().getTranslatedValue('Every horoscope needs to be corrected for exact birth time. Hence, we are gathering important data which will help us in rectifying the birth time accurately as much as possible.')),
                    )
                  ],
                )
            ),
          ),
          const SizedBox(height: 10),
            SizedBox(
              width: 300,
              child: GradientButton(
                  title: LocalizationController.getInstance().getTranslatedValue("Next"),buttonHeight: 45, textColor: Colors.white, buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)], onPressed: (Offset buttonOffset){
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const AddPrimary()));
              }),
          )
        ],
      )),
    );
  }
}
