import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class CommonCallings{

  static void showLoginDialog(BuildContext context, String title) {
    AwesomeDialog(
      context: context,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 20, top: 10),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12,),
            Text(
              title,
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: true,
    ).show();
  }

  static void cancelLoadingDialog(BuildContext context) {
    AwesomeDialog(context: context).dismiss();
  }
}