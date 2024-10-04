import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/controllers/profile_controller.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/screens/profile/edit_profile.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    profileController.profileEmail.text = appLoadController.loggedUserData.value.useremail!;
    profileController.profileLanguage.text = appLoadController.loggedUserData.value.userpplang!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Obx(() => Column(
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
                          SizedBox(width: 60, height: 20, child: commonSmallColorButton(title: 'Edit', fontSize: 13, textColor: Colors.deepOrange, buttonColor: Colors.white, onPressed: (){
                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) => const ProfileEdit()));
                          }))
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
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black26,
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 80,
                      child: ClipOval(
                        child: appLoadController.loggedUserData.value.userphoto != null
                            ? Image.network(
                          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRNlBkEd3_jxQ6mh26UJsKrV0y1TTvITYK4aA&usqp=CAU",
                          fit: BoxFit.cover,
                          width: 160,
                          height: 160,
                        )
                            : CircularProgressIndicator(),
                      ),
                    )
                  ),
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
              ],
            ),
          ),
          SizedBox(height: 20),
          SizedBox(width: 180, child: GradientButton(buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)], title: 'Delete Profile', textColor: Colors.white, onPressed: (Offset buttonOffset){
            yesOrNoDialog(context: context, dialogMessage: 'Are you sure you want to delete your profile?', cancelText: 'NO', okText: 'YES', okAction: (){
              profileController.deleteProfile(context, appLoadController.loggedUserData.value.userid);
            });
          }))
        ],
      )),
    );
  }
}
