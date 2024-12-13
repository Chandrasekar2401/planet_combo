import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/controllers/profile_controller.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:get/get.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  final ProfileController profileController =
  Get.put(ProfileController.getInstance(), permanent: true);

  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  String decodeUrlRecursively(String encodedUrl) {
    String decodedUrl = Uri.decodeFull(encodedUrl);

    // Check if the decoded URL is different from the input
    print('the value of decoded value from the url $decodedUrl');
    if (decodedUrl != encodedUrl) {
      // If it's different, recursively decode again
      return decodeUrlRecursively(decodedUrl);
    } else {
      // If it's the same, we've reached the final decoded state
      return decodedUrl;
    }
  }

  String profileCurrency(String currency){
    if(currency.toLowerCase() == 'inr'){
      return 'INR(Indian Rupees)';
    }else if(currency.toLowerCase() == 'aed'){
      return 'AED(UAE Dirhams)';
    }else{
      return 'USD(US Dollar)';
    }
  }

  Widget _buildNetworkImage(String imageUrl) {
    if (kIsWeb) {
      // For web platform
      return ClipOval(
        child: Container(
          width: 100,
          height: 100,
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
            width: 100,
            height: 100,
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
                width: 100,
                height: 100,
                color: Colors.grey[300],
                child: const Icon(Icons.person, size: 62),
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

  @override
  void initState() {
    // TODO: implement initState
    profileController.profileEmail.text = appLoadController.loggedUserData.value.useremail!;
    profileController.profileLanguage.text = appLoadController.loggedUserData.value.userpplang!;
    profileController.profilePaymentCurrency.text = profileCurrency(appLoadController.loggedUserData.value.ucurrency!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SingleChildScrollView(
        child: Obx(() => Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 230,
                  decoration: BoxDecoration(
                      color: Colors.transparent
                  ),
                ),
                Container(
                  height: 180,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/Headletters_background.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(onPressed: () { Navigator.pop(context); },color: Colors.white, iconSize: 28, icon: const Icon(Icons.chevron_left_rounded)),
                            commonBoldText(text: LocalizationController.getInstance().getTranslatedValue("Profile"), fontSize: 20, color: Colors.white),
                            const SizedBox(width: 60, height: 20)
                            //     child: commonSmallColorButton(title: 'Edit', fontSize: 13, textColor: Colors.deepOrange, buttonColor: Colors.white, onPressed: (){
                            //   Navigator.push(
                            //       context, MaterialPageRoute(builder: (context) => const ProfileEdit()));
                            // })
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 125,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _buildNetworkImage(appLoadController.loggedUserData.value.userphoto!)
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            commonBoldText(text: appLoadController.loggedUserData.value.username!, fontSize: 14),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Email'), fontSize: 12, color: Colors.black87, textAlign: TextAlign.start),
                  PrimaryStraightInputText(
                    onValidate: (v) {
                      return null;
                    },
                    fontSize: 12,
                    hintText: LocalizationController.getInstance().getTranslatedValue('Email'),
                    controller: profileController.profileEmail,
                    readOnly: true,
                  ),
                  SizedBox(height: 30),
                  commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Language'), fontSize: 12, color: Colors.black87, textAlign: TextAlign.start),
                  PrimaryStraightInputText(
                    onValidate: (v) {
                      return null;
                    },
                    fontSize: 12,
                    hintText: LocalizationController.getInstance().getTranslatedValue('Language'),
                    controller: profileController.profileLanguage,
                    readOnly: true,
                  ),
                  SizedBox(height: 30),
                  commonBoldText(text: LocalizationController.getInstance().getTranslatedValue('Payment Currency'), fontSize: 12, color: Colors.black87, textAlign: TextAlign.start),
                  PrimaryStraightInputText(
                    onValidate: (v) {
                      return null;
                    },
                    fontSize: 12,
                    hintText: LocalizationController.getInstance().getTranslatedValue('Currency'),
                    controller: profileController.profilePaymentCurrency,
                    readOnly: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            SizedBox(width: 180, child: GradientButton(buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)], title: 'Done', textColor: Colors.white, onPressed: (Offset buttonOffset){
             Navigator.pop(context);
              // yesOrNoDialog(context: context,
              //     cancelAction: (){},
              //     dialogMessage: 'Are you sure you want to delete your profile?', cancelText: 'NO', okText: 'YES', okAction: (){
              //   profileController.deleteProfile(context, appLoadController.loggedUserData.value.userid);
              // });
            }))
          ],
        )),
      ),
    );
  }
}
