import 'package:flutter/material.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:get/get.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/test/admin_dashboard.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);
  TextEditingController userIdController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  var formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Container(
              height: MediaQuery.of(context).size.height * 1,
              width: MediaQuery.of(context).size.width * 1,
              decoration: const BoxDecoration(
                  color: Colors.white
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 70, child: Image.asset('assets/images/logo.png')),
                    const SizedBox(height: 20),
                    commonBoldText(text: 'LOGIN', fontSize: 21),
                    const SizedBox(height: 7),
                    commonText(text: 'Please Sign in as ADMIN', color: Colors.grey, fontSize: 14),
                    commonText(text: 'or User1 or User2', color: Colors.grey,  fontSize: 14),
                    const SizedBox(height: 30),
                    PrimaryInputText(hintText: 'User Name',
                        suffixImage: const Icon(Icons.person, size: 21),
                        controller: userIdController,
                        onValidate: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Please enter Username';
                          }
                          return null;
                        }),
                    const SizedBox(height: 15),
                    PrimaryInputText(hintText: 'Password',
                        suffixImage: const Icon(Icons.key_off_rounded, size: 21),
                        controller: passwordController,
                        onValidate: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Please enter password';
                          }
                          return null;
                        }),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        underLineTextButton(onPressed: (){

                        }, text: '', color: Colors.blueAccent, size: 12)
                      ],
                    ),
                    const SizedBox(height: 15),
                    fullIconColorButton(title: 'Login', textColor: Colors.white, buttonColor: appLoadController.appPrimaryColor, context: context, onPressed: (){
                      // Navigator.pushReplacement(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => const Dashboard()),
                      // );
                      if (formKey.currentState!.validate()) {
                            if(userIdController.text == 'admin' && passwordController.text == '12345'){
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const AdminDashboard()),
                              );
                            }
                      }
                    }, iconUrl: 'assets/svg/google.svg'),
                    const SizedBox(height: 30),
                    commonBoldText(text: 'Version 1.0.0', fontSize: 14)
                  ],
                ),
              ),
            ),
          ),
        )
    );
  }
}
