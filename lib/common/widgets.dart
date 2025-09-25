import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// String appMode = 'Light';
String appMode = 'Dark';

void showSuccessToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.green,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

Widget fullIconColorButton(
    {required String title,
      required Color textColor,
      required Color buttonColor,
      Color? iconColor,
      required BuildContext context,
      required VoidCallback onPressed,
      String? iconUrl}) {
  return SizedBox(
    height: 45,
    width: MediaQuery.of(context).size.width * 1,
    child: ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(buttonColor),
        padding:
        MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
        elevation: MaterialStateProperty.all(0),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SvgPicture.asset(iconUrl, color: iconColor,),
          Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),

    ),
  );
}

Widget fullIconCurveColorButton(
    {required String title,
      required Color textColor,
      required Color buttonColor,
      Color? iconColor,
      required BuildContext context,
      required VoidCallback onPressed,
      String? iconUrl,
      IconData? materialIcon,
      double? materialIconSize
    }) {
  return SizedBox(
    height: 45,
    width: MediaQuery.of(context).size.width * 1,
    child: ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(buttonColor),
        padding:
        MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
        elevation: MaterialStateProperty.all(4),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(21),
          ),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconUrl != null ? SvgPicture.asset(iconUrl, color: iconColor,):
          Icon(materialIcon, size: materialIconSize ?? 16),
          Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),

    ),
  );
}

class GradientButton extends StatelessWidget {
  final String title;
  final Color textColor;
  final Function(Offset) onPressed;
  final IconData? materialIcon;
  final List<Color> buttonColors;
  final Color? iconColor;
  final double? materialIconSize;
  final double? buttonHeight;
  final bool isDisabled; // New parameter for disabled state

  GradientButton({
    super.key,
    this.buttonHeight,
    required this.buttonColors,
    this.iconColor,
    this.materialIconSize,
    required this.title,
    required this.textColor,
    required this.onPressed,
    this.materialIcon,
    this.isDisabled = false, // Default to enabled
  });

  final GlobalKey _buttonPositionKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // Generate disabled colors (grayed out) if button is disabled
    List<Color> actualButtonColors = isDisabled
        ? [Colors.grey.shade400, Colors.grey.shade500]
        : buttonColors;

    Color actualTextColor = isDisabled
        ? Colors.grey.shade200
        : textColor;

    Color actualIconColor = isDisabled
        ? Colors.grey.shade200
        : (iconColor ?? Colors.white);

    return ElevatedButton(
      key: _buttonPositionKey,
      onPressed: isDisabled
          ? null // Set to null when disabled to prevent standard elevation animation
          : () {
        RenderBox? renderBox = _buttonPositionKey.currentContext!.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          Offset offset = renderBox.localToGlobal(Offset.zero);
          onPressed(offset);
        }
      },
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.all(8),
        ),
        backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
        overlayColor: WidgetStateProperty.all<Color>(Colors.black12),
        elevation: WidgetStateProperty.all<double>(0),
        textStyle: WidgetStateProperty.all<TextStyle>(
          const TextStyle(fontSize: 12),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        minimumSize: WidgetStateProperty.all<Size>(const Size(0, 48)),
      ),
      child: Ink(
        height: buttonHeight ?? 40,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDisabled
                  ? Colors.grey.withOpacity(0.3) // Lighter shadow for disabled buttons
                  : Colors.grey.withOpacity(0.5),
              spreadRadius: isDisabled ? 1 : 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          gradient: LinearGradient(
            colors: actualButtonColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (materialIcon != null)
              Row(
                children: [
                  const SizedBox(width: 5),
                  Icon(
                    materialIcon,
                    color: actualIconColor,
                    size: materialIconSize ?? 16,
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 12, 0),
              child: commonBoldText(text: title, color: actualTextColor, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class ServicesButton extends StatelessWidget {
  final String title;
  final Color textColor;
  final Function(Offset) onPressed;
  final IconData? materialIcon;
  final List<Color> buttonColors;
  final Color? iconColor;
  final double? materialIconSize;
  final double? buttonHeight;
  final bool isDisabled;

  ServicesButton({
    super.key,
    this.buttonHeight,
    required this.buttonColors,
    this.iconColor,
    this.materialIconSize,
    required this.title,
    required this.textColor,
    required this.onPressed,
    this.materialIcon,
    this.isDisabled = false,
  });

  final GlobalKey _buttonPositionKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: buttonHeight ?? 40,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        // Enhanced shadow system
        boxShadow: isDisabled
            ? [
          // Flat, inset-like shadow for disabled
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ]
            : [
          // Primary shadow - colored and prominent
          BoxShadow(
            color: buttonColors.first.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          // Secondary shadow - subtle depth
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        gradient: isDisabled
            ? null
            : LinearGradient(
          colors: buttonColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        // Flat disabled background
        color: isDisabled ? Colors.grey.shade300 : null,
        borderRadius: BorderRadius.circular(24.0),
        // Subtle border for disabled state
        border: isDisabled
            ? Border.all(
          color: Colors.grey.shade400,
          width: 0.5,
        )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          key: _buttonPositionKey,
          onTap: isDisabled
              ? null
              : () {
            RenderBox? renderBox = _buttonPositionKey.currentContext!
                .findRenderObject() as RenderBox?;
            if (renderBox != null) {
              Offset offset = renderBox.localToGlobal(Offset.zero);
              onPressed(offset);
            }
          },
          borderRadius: BorderRadius.circular(24),
          // Enhanced ripple effect for enabled buttons
          splashColor: isDisabled
              ? Colors.transparent
              : Colors.white.withOpacity(0.3),
          highlightColor: isDisabled
              ? Colors.transparent
              : Colors.white.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (materialIcon != null) ...[
                  Icon(
                    materialIcon,
                    color: isDisabled
                        ? Colors.grey.shade500
                        : (iconColor ?? Colors.white),
                    size: materialIconSize ?? 16,
                  ),
                  const SizedBox(width: 6),
                ],
                commonBoldText(
                  text: title,
                  color: isDisabled
                      ? Colors.black54
                      : textColor,
                  fontSize: 11,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Alternative version with even more pronounced 3D effect
class ServicesButton3D extends StatelessWidget {
  final String title;
  final Color textColor;
  final Function(Offset) onPressed;
  final IconData? materialIcon;
  final List<Color> buttonColors;
  final Color? iconColor;
  final double? materialIconSize;
  final double? buttonHeight;
  final bool isDisabled;

  ServicesButton3D({
    super.key,
    this.buttonHeight,
    required this.buttonColors,
    this.iconColor,
    this.materialIconSize,
    required this.title,
    required this.textColor,
    required this.onPressed,
    this.materialIcon,
    this.isDisabled = false,
  });

  final GlobalKey _buttonPositionKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: isDisabled ? null : (_) {}, // For press animation
      onTapUp: isDisabled ? null : (_) {},
      onTapCancel: isDisabled ? null : () {},
      onTap: isDisabled
          ? null
          : () {
        RenderBox? renderBox = _buttonPositionKey.currentContext!
            .findRenderObject() as RenderBox?;
        if (renderBox != null) {
          Offset offset = renderBox.localToGlobal(Offset.zero);
          onPressed(offset);
        }
      },
      child: AnimatedContainer(
        key: _buttonPositionKey,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 3),
        height: buttonHeight ?? 40,
        decoration: BoxDecoration(
          // Multi-layered shadow for 3D effect
          boxShadow: isDisabled
              ? [
            // Minimal inset-like shadow
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 0,
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ]
              : [
            // Large soft shadow for depth
            BoxShadow(
              color: buttonColors.first.withOpacity(0.25),
              spreadRadius: 2,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            // Sharp shadow for definition
            BoxShadow(
              color: buttonColors.last.withOpacity(0.4),
              spreadRadius: 0,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
            // Highlight shadow (top)
            BoxShadow(
              color: Colors.white.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 2,
              offset: const Offset(0, -1),
            ),
          ],
          gradient: isDisabled
              ? null
              : LinearGradient(
            colors: [
              // Add slight highlights for 3D effect
              Color.lerp(buttonColors.first, Colors.white, 0.1)!,
              buttonColors.first,
              buttonColors.last,
              Color.lerp(buttonColors.last, Colors.black, 0.1)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
          color: isDisabled ? Colors.grey.shade300 : null,
          borderRadius: BorderRadius.circular(24.0),
          border: isDisabled
              ? Border.all(color: Colors.grey.shade400, width: 0.5)
              : Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (materialIcon != null) ...[
                Icon(
                  materialIcon,
                  color: isDisabled
                      ? Colors.grey.shade500
                      : (iconColor ?? Colors.white),
                  size: materialIconSize ?? 16,
                ),
                const SizedBox(width: 6),
              ],
              commonBoldText(
                text: title,
                color: isDisabled
                    ? Colors.grey.shade500
                    : textColor,
                fontSize: 11,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Horoscope page example matching your screenshot
class HoroscopeServicesExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text("Horoscope Services - Pu...", style: TextStyle(color: Colors.white)),
        leading: Icon(Icons.arrow_back, color: Colors.white),
        actions: [
          Container(
            margin: EdgeInsets.all(8),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.add, size: 16),
              label: Text("Add Horoscope", style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // First user - has active predictions
          _buildUserCard(
            name: "Kuruvamma",
            joinDate: "OCB: Apr 16, 2026",
            horoscope: "Gemini/Ga 1-14",
            status: "Horoscope is in progress",
            isPaid: true,
            buttonsEnabled: [false, true, false], // Only predictions enabled
          ),

          SizedBox(height: 16),

          // Second user - has active horoscope
          _buildUserCard(
            name: "Chellama",
            joinDate: "OCB: April 02, 2026",
            horoscope: "Leo/Ma 1-14",
            status: "Horoscope is in progress",
            isPaid: true,
            buttonsEnabled: [false, false, true], // Only horoscope enabled
          ),

          SizedBox(height: 16),

          // Third user - all services available
          _buildUserCard(
            name: "Susritha",
            joinDate: "OCB: April 02, 2026",
            horoscope: "Gemini/Ga 2-6",
            status: "Horoscope is in progress",
            isPaid: true,
            buttonsEnabled: [true, true, true], // All buttons enabled
          ),

          SizedBox(height: 16),

          // Fourth user - predictions active
          _buildUserCard(
            name: "Mahi bai",
            joinDate: "OCB: April 12, 1999",
            horoscope: "Cancer/Ka 4",
            status: "Horoscope is in progress",
            isPaid: true,
            buttonsEnabled: [false, true, false], // Only predictions enabled
          ),

          SizedBox(height: 16),

          // Fifth user - no active services
          _buildUserCard(
            name: "Kalyani",
            joinDate: "OCB: April 04, 1999",
            horoscope: "Taurus/Ka 1-4",
            status: "Horoscope is in progress",
            isPaid: true,
            buttonsEnabled: [true, true, true], // All available
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard({
    required String name,
    required String joinDate,
    required String horoscope,
    required String status,
    required bool isPaid,
    required List<bool> buttonsEnabled, // [Plans, Predictions, Horoscope]
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.orange,
                child: Text(
                  name[0].toUpperCase(),
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      joinDate,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    Text(
                      horoscope,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    Text(
                      status,
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ],
                ),
              ),
              Text(
                isPaid ? "Paid" : "Unpaid",
                style: TextStyle(
                  fontSize: 12,
                  color: isPaid ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ServicesButton(
                  title: "Plans",
                  textColor: Colors.white,
                  buttonColors: [Colors.grey.shade600, Colors.grey.shade700],
                  onPressed: (offset) => print("Plans pressed"),
                  isDisabled: !buttonsEnabled[0],
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ServicesButton(
                  title: "Predictions",
                  textColor: Colors.white,
                  buttonColors: [Colors.orange, Colors.deepOrange],
                  onPressed: (offset) => print("Predictions pressed"),
                  isDisabled: !buttonsEnabled[1],
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ServicesButton(
                  title: "Horoscope",
                  textColor: Colors.white,
                  buttonColors: [Colors.grey.shade600, Colors.grey.shade700],
                  onPressed: (offset) => print("Horoscope pressed"),
                  isDisabled: !buttonsEnabled[2],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget fullIconGradientCurveColorButton(
    {required String title,
      required Color textColor,
      required List<Color> buttonColors,
      Color? iconColor,
      double? buttonHeight,
      required BuildContext context,
      required VoidCallback onPressed,
      String? iconUrl,
      IconData? materialIcon,
      double? materialIconSize,
      void Function(TapUpDetails)? tapUp,
    }) {
  return Container(
    height: buttonHeight ?? 45,
    width: double.infinity,
    decoration:  BoxDecoration(
      borderRadius: BorderRadius.circular(21),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 2,
          blurRadius: 3,
          offset: const Offset(0, 3),
        ),
      ],
      gradient: LinearGradient(
        colors: buttonColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: GestureDetector(
      onTap: onPressed,
      onTapUp: tapUp,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconUrl != null ? SvgPicture.asset(iconUrl, color: iconColor,):
          materialIcon == null ? const SizedBox(width: 0):Icon(materialIcon, size: materialIconSize ?? 16, color: Colors.white,),
          Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),

    ),
  );
}

void showFailedToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.red,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

class CustomDialog{
  static void showLoading(BuildContext context, String title) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.scale,
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
  static void cancelLoading(BuildContext context) {
    AwesomeDialog(context: context).dismiss();
  }

  static void cancelNoContextLoading() {
    Get.back();
  }

  static void showAlert(
      BuildContext context, String dialogMessage, bool? success, double? fontSize) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                success != null ? Icon(
                  success ? Icons.check_circle : Icons.error_outline,
                  color: success ? Colors.green : Colors.red,
                  size: 40,
                ):Container(),
                const SizedBox(height: 15),
                Text(
                  dialogMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(
                      fontSize: fontSize ?? 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                )
              ],
            ),
            actions: [
              Container(
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey)),
                child: TextButton(
                  child: Text(
                      'OK',
                      style: GoogleFonts.lexend(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black)),
                  onPressed: () {
                    Navigator.pop(context);//Close Dialog Box
                  },
                ),
              ),
            ],
          );
        });
  }

  static void okActionAlert(
      BuildContext context, String dialogMessage,String? okText, bool success, double? fontSize, VoidCallback okAction) {
    showDialog(
        context: context,
        builder: (context) {
          return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: (){},
              child: AlertDialog(
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      success ? Icons.check_circle : Icons.clear,
                      color: success ? Colors.green : Colors.red,
                      size: 40,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      dialogMessage,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(
                          fontSize: fontSize ?? 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    )
                  ],
                ),
                actions: [
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey)),
                    child: TextButton(
                      onPressed: okAction ,
                      child: Text(
                          okText?? 'OK',
                          style: GoogleFonts.lexend(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black)),
                    ),
                  ),
                ],
              )
          );
        });
  }
}

class WebLoadingDialog extends StatelessWidget {
  final String title;

  const WebLoadingDialog({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 300),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showWebLoadingDialog(BuildContext context, String title) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WebLoadingDialog(title: title);
    },
  );
}

void dismissWebLoadingDialog(BuildContext context) {
  Navigator.of(context).pop();
}

Widget commonBoldText({required String text,TextAlign? textAlign, int? maxLines, TextOverflow? textOverflow, Color? color, double? fontSize}){
  return Text(text,
      textAlign: textAlign,
      overflow: textOverflow,
      maxLines: maxLines,
      style: GoogleFonts.lexend(
        fontSize: fontSize ?? 16,
        fontWeight: FontWeight.w500,
        color: color ?? (appMode == 'Dark' ? Colors.black : Colors.white),
      )
  );
}

Widget gradientContainer({required double height, required BuildContext context, required Widget child}){
  return Container(
    height: height,
    width: MediaQuery.of(context).size.width * 1,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF543eb3),
          Color(0xFFa468ca),
        ],
      ),
    ),
    child: child,
  );
}

Widget commonText({required String text,TextAlign? textAlign,TextDecoration? textDecoration, int? maxLines, TextOverflow? textOverflow, Color? color, double? fontSize}){
  return Text(text,
      textAlign: textAlign,
      overflow: textOverflow,
      maxLines: maxLines,
      style: GoogleFonts.lexend(
        decoration:textDecoration,
        fontSize: fontSize ?? 16,
        fontWeight: FontWeight.w400,
        color: color ?? (appMode == 'Dark' ? Colors.black : Colors.white),
      )
  );
}

class PrimaryInputText extends StatelessWidget {
  final String hintText;
  final String? Function(String? value) onValidate;
  final String? Function(String? value)? onChange;
  final TextEditingController? controller;
  final bool isEnabled;
  final int maxLines;
  final int? maxLength;
  final Widget? suffixImage;
  final TextInputType textInputType;
  final FocusNode? focusNode;
  final bool? readOnly;
  final bool? obscureText;
  final String? value;
  final bool? autoFocus;
  const PrimaryInputText({super.key,this.obscureText,this.value, required this.hintText,this.readOnly, this.controller, required this.onValidate,this.isEnabled = true, this.textInputType = TextInputType.text, this.maxLines=1,this.maxLength, this.onChange, this.suffixImage, this.focusNode, this.autoFocus});


  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      readOnly: readOnly ?? false,
      style: GoogleFonts.lexend(color: Colors.black),
      controller: controller,
      autofocus: autoFocus ?? false,
      focusNode: focusNode,
      obscureText: obscureText ?? false,
      validator: onValidate,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: isEnabled,
      onChanged: onChange,
      keyboardType: textInputType,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(16),
        counterText: "",
        labelText: hintText,
        suffixIcon: suffixImage,
        labelStyle: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: (appMode == 'Dark' ? Colors.black54 : Colors.white60)
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: (appMode == 'Dark' ? Colors.black54 : Colors.white60),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class PrimaryIconInputText extends StatelessWidget {
  final String hintText;
  final String? Function(String? value) onValidate;
  final String? Function(String? value)? onChange;
  final TextEditingController? controller;
  final bool isEnabled;
  final int maxLines;
  final int? maxLength;
  final Widget? suffixImage;
  final TextInputType textInputType;
  final FocusNode? focusNode;
  final bool? readOnly;
  final bool? obscureText;
  final String? value;
  const PrimaryIconInputText({Key? key,this.obscureText,this.value, required this.hintText,this.readOnly, this.controller, required this.onValidate,this.isEnabled = true, this.textInputType = TextInputType.text, this.maxLines=1,this.maxLength, this.onChange, this.suffixImage, this.focusNode}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      readOnly: readOnly ?? false,
      style: GoogleFonts.lexend(color: Colors.black),
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText ?? false,
      validator: onValidate,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: isEnabled,
      onChanged: onChange,
      keyboardType: textInputType,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(16),
        counterText: "",
        labelText: hintText,
        suffixIcon: suffixImage,
        labelStyle: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: (appMode == 'Dark' ? Colors.black54 : Colors.white60)
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: (appMode == 'Dark' ? Colors.black54 : Colors.white60),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class PrimaryStraightInputText extends StatelessWidget {
  final String hintText;
  final String? Function(String? value) onValidate;
  final String? Function(String? value)? onChange;
  final TextEditingController? controller;
  final bool isEnabled;
  final int maxLines;
  final int? maxLength;
  final Widget? suffixImage;
  final TextInputType textInputType;
  final FocusNode? focusNode;
  final bool? readOnly;
  final bool? obscureText;
  final String? value;
  final double? fontSize;
  final double? height;
  final bool allowOnlyLetters; // New parameter

  const PrimaryStraightInputText({
    Key? key,
    this.obscureText,
    this.fontSize,
    this.value,
    this.height,
    required this.hintText,
    this.readOnly,
    this.controller,
    required this.onValidate,
    this.isEnabled = true,
    this.textInputType = TextInputType.text,
    this.maxLines = 1,
    this.maxLength,
    this.onChange,
    this.suffixImage,
    this.focusNode,
    this.allowOnlyLetters = false, // Default value is false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 30,
      child: TextFormField(
        initialValue: value,
        readOnly: readOnly ?? false,
        style: GoogleFonts.lexend(color: Colors.black, fontSize: fontSize ?? 14),
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText ?? false,
        validator: onValidate,
        maxLines: maxLines,
        maxLength: maxLength,
        enabled: isEnabled,
        keyboardType: textInputType,
        // Add input formatters conditionally
        inputFormatters: allowOnlyLetters
            ? [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
        ]
            : null,
        // Modified onChanged to handle letter-only restriction
        onChanged: (value) {
          if (onChange != null) {
            if (allowOnlyLetters) {
              // Remove any non-alphabetic characters that might have been pasted
              final cleanedValue = value.replaceAll(RegExp(r'[^a-zA-Z\s]'), '');
              if (cleanedValue != value && controller != null) {
                controller!.text = cleanedValue;
                controller!.selection = TextSelection.fromPosition(
                  TextPosition(offset: cleanedValue.length),
                );
                onChange!(cleanedValue);
              } else {
                onChange!(value);
              }
            } else {
              onChange!(value);
            }
          }
        },
        decoration: InputDecoration(
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.deepOrange)
          ),
          enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange)
          ),
          hintText: hintText,
          contentPadding: kIsWeb ? const EdgeInsets.only(bottom: 12) : null,
          hintStyle: GoogleFonts.lexend(
              fontSize: fontSize ?? 14,
              fontWeight: FontWeight.w400,
              color: (appMode == 'Dark' ? Colors.black54 : Colors.white60)
          ),
          // Add error text if letters-only mode is on and invalid characters are detected
          errorText: allowOnlyLetters && controller?.text.contains(RegExp(r'[^a-zA-Z\s]')) == true
              ? 'Only letters are allowed'
              : null,
        ),
      ),
    );
  }
}

class PrimaryStraightIconInputText extends StatelessWidget {
  final String hintText;
  final String? Function(String? value) onValidate;
  final String? Function(String? value)? onChange;
  final TextEditingController? controller;
  final bool isEnabled;
  final int maxLines;
  final int? maxLength;
  final Widget? suffixImage;
  final TextInputType textInputType;
  final FocusNode? focusNode;
  final bool? readOnly;
  final bool? obscureText;
  final String? value;
  const PrimaryStraightIconInputText({Key? key,this.obscureText,this.value, required this.hintText,this.readOnly, this.controller, required this.onValidate,this.isEnabled = true, this.textInputType = TextInputType.text, this.maxLines=1,this.maxLength, this.onChange, this.suffixImage, this.focusNode}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      readOnly: readOnly ?? false,
      style: GoogleFonts.lexend(color: Colors.black),
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText ?? false,
      validator: onValidate,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: isEnabled,
      onChanged: onChange,
      keyboardType: textInputType,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(16),
        counterText: "",
        labelText: hintText,
        suffixIcon: suffixImage,
        labelStyle: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: (appMode == 'Dark' ? Colors.black54 : Colors.white60)
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: (appMode == 'Dark' ? Colors.black54 : Colors.white60),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class ReusableDropdown<T> extends StatelessWidget {
  final List<T> options;
  final T? currentValue;
  final ValueChanged<T?> onChanged;

  const ReusableDropdown({
    Key? key,
    required this.options,
    required this.currentValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      width: double.infinity,
      child: DropdownButton<T>(
        value: currentValue,
        onChanged: onChanged,
        iconEnabledColor: Colors.deepOrange,
        isExpanded: true,
        underline: Container(
          height: 1,
          color: Colors.orange,
        ),
        items: options
            .map((T value) => DropdownMenuItem<T>(
          value: value,
          child: Text(
            value.toString(),
            style: GoogleFonts.lexend(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ))
            .toList(),
      ),
    );
  }
}

class ReusableJsonDropdown extends StatelessWidget {
  final List<Map<String, dynamic>> options;
  final String currentValue;
  final String valueKey;  // Key to use for the dropdown value
  final String displayKey;  // Key to use for the display text
  final Function(String?) onChanged;

  ReusableJsonDropdown({
    required this.options,
    required this.currentValue,
    required this.valueKey,
    required this.displayKey,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      width: double.infinity,
      child: DropdownButton<String>(
        value: currentValue,
        onChanged: onChanged,
        iconEnabledColor: Colors.deepOrange,
        isExpanded: true,
        underline: Container(
          height: 1,
          color: Colors.orange,
        ),
        items: options.map<DropdownMenuItem<String>>((Map<String, dynamic> json) {
          return DropdownMenuItem<String>(
            value: json[valueKey].toString(),
            child: Text(
              json[displayKey].toString(),
              style: GoogleFonts.lexend(fontSize: 14, color: Colors.black54),
            ),
          );
        }).toList(),
      ),
    );
  }
}


class ReusableBorderDropdown extends StatelessWidget {
  final List<String> options;
  final String currentValue;
  final Function(String?) onChanged;

  ReusableBorderDropdown({required this.options, required this.currentValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(12)
      ),
      height: 45,
      width: double.infinity,
      child: DropdownButton<String>(
        value: currentValue,
        onChanged: onChanged,
        iconEnabledColor: Colors.black,
        isExpanded: true,
        underline: Container(
          height: 0,
          color: Colors.transparent,
        ),
        items: options
            .map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(value,
              style: GoogleFonts.lexend(
                  fontSize: 16,
                  color: Colors.black54
              )
          ),
        ))
            .toList(),
      ),
    );
  }
}

class ReusablePopupButton extends StatelessWidget {
  final List<String> options;
  final Function(String)? onOptionSelected;

  const ReusablePopupButton({super.key,
    required this.options,
    this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: PopupMenuButton<String>(
        itemBuilder: (BuildContext context) {
          return options.map((String option) {
            return PopupMenuItem<String>(
              value: option,
              child: commonBoldText(text: option),
            );
          }).toList();
        },
        onSelected: (String selectedOption) {
          onOptionSelected?.call(selectedOption);
        },
      ),
    );
  }
}

Widget underLineTextButton({required VoidCallback onPressed,TextAlign? textAlign, required String text, Color? color, double? size}){
  return GestureDetector(
    onTap: onPressed,
    child: Text(text,
        textAlign: textAlign,
        style: GoogleFonts.lexend(
          decoration: TextDecoration.underline,
          fontSize: size ?? 14,
          fontWeight: FontWeight.bold,
          color: color ?? Colors.black,
        )),
  );
}

///This is the widget for creating buttons
Widget commonSmallColorButton(
    {required String title,
      required Color textColor,
      double? fontSize,
      required Color buttonColor,
      required VoidCallback onPressed}) {
  return ElevatedButton(
    style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(buttonColor),
        padding:
        MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 0, horizontal: 2)),
        elevation: MaterialStateProperty.all(2),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(
          // side: const BorderSide(color: Color(0xff979797)),
            borderRadius: BorderRadius.circular(16)))),
    onPressed: onPressed,
    child: Padding(
      padding: const EdgeInsets.all(0),
      child: Text(
        title,
        style: GoogleFonts.lexend(
          fontSize: fontSize ?? 15,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    ),
  );
}


///This is the widget for creating buttons
Widget commonColorButton(
    {required String title,
      required Color textColor,
      double? fontSize,
      double? textPadding,
      required Color buttonColor,
      required VoidCallback onPressed}) {
  return ElevatedButton(
    style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(buttonColor),
        padding:
        WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 8, horizontal: 8)),
        elevation: WidgetStateProperty.all(0),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
          // side: const BorderSide(color: Color(0xff979797)),
            borderRadius: BorderRadius.circular(4)))),
    onPressed: onPressed,
    child: Padding(
      padding: EdgeInsets.all(textPadding ?? 4.0),
      child: Text(
        title,
        style: GoogleFonts.lexend(
          fontSize: fontSize ?? 15,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    ),
  );
}

Widget fullLeftIconColorButton(
    {required String title,
      required Color textColor,
      required Color buttonColor,
      Color? iconColor,
      double? iconLeftSize,
      required BuildContext context,
      required VoidCallback onPressed,
      required String iconUrl}) {
  return SizedBox(
    height: 45,
    width: MediaQuery.of(context).size.width * 1,
    child: ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(buttonColor),
        padding:
        WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
        elevation: WidgetStateProperty.all(4),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(21),
          ),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(width: iconLeftSize ?? 40, child: SvgPicture.asset(iconUrl, color: iconColor)),
          Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          SizedBox(
            width: 40,
            child: Opacity(opacity: 0,
            child: SvgPicture.asset(iconUrl, color: iconColor)),
          ),
        ],
      ),
    ),
  );
}

class CustomDropdownButton extends StatefulWidget {
  final String placeholder;
  final Color textColor;
  final Color buttonColor;
  final Color? iconColor;
  final Color placeholderColor;
  final double? iconLeftSize;
  final List<DropdownItem> items;
  final Function(DropdownItem?) onChanged;

  const CustomDropdownButton({
    super.key,
    required this.placeholder,
    required this.textColor,
    this.buttonColor = const Color(0xFFFFEB3B),
    this.iconColor,
    this.placeholderColor = Colors.black87,
    this.iconLeftSize,
    required this.items,
    required this.onChanged,
  });

  @override
  _CustomDropdownButtonState createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomDropdownButton> {
  DropdownItem? selectedItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: widget.buttonColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<DropdownItem>(
            isExpanded: true,
            value: selectedItem,
            icon: const Padding(
              padding:  EdgeInsets.only(right: 12),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.black87,
              ),
            ),
            elevation: 0,
            style: GoogleFonts.lexend(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: widget.textColor,
            ),
            onChanged: (DropdownItem? newValue) {
              setState(() {
                selectedItem = newValue;
              });
              widget.onChanged(newValue);
            },
            hint: Align(
              alignment: Alignment.center,
              child: Text(
                widget.placeholder,
                style: GoogleFonts.lexend(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: widget.placeholderColor,
                ),
              ),
            ),
            selectedItemBuilder: (BuildContext context) {
              return widget.items.map<Widget>((DropdownItem item) {
                return Container(
                  padding: const EdgeInsets.only(left: 16),
                  child: Stack(
                    children: [
                      // Left-aligned icon
                      if (selectedItem != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: widget.iconLeftSize ?? 20,
                            child: Image.asset(
                              selectedItem!.iconUrl,
                              color: widget.iconColor,
                            ),
                          ),
                        ),
                      // Centered text
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          selectedItem?.title ?? '',
                          style: GoogleFonts.lexend(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList();
            },
            items: widget.items.map<DropdownMenuItem<DropdownItem>>((DropdownItem item) {
              return DropdownMenuItem<DropdownItem>(
                value: item,
                child: Row(
                  children: [
                    SizedBox(
                      width: widget.iconLeftSize ?? 20,
                      child: Image.asset(
                        item.iconUrl,
                        color: widget.iconColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(item.title),
                  ],
                ),
              );
            }).toList(),
            dropdownColor: widget.buttonColor,
          ),
        ),
      ),
    );
  }
}

class DropdownItem {
  final String title;
  final String iconUrl;

  DropdownItem({required this.title, required this.iconUrl});
}

Widget reusablePopUp({required BuildContext context}){
  return GestureDetector(
    onTapUp: (TapUpDetails details) async {
      final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
      final RelativeRect position = RelativeRect.fromRect(
        Rect.fromPoints(
          details.globalPosition,
          details.globalPosition,
        ),
        Offset.zero & overlay.size,
      );

      // Show the popup menu
      final selectedValue = await showMenu(
        context: context,
        position: position,
        items: [
          PopupMenuItem(
            child: Text('Menu 1'),
            value: 1,
          ),
          PopupMenuItem(
            child: Text('Menu 2'),
            value: 2,
          ),
          PopupMenuItem(
            child: Text('Menu 3'),
            value: 3,
          ),
        ],
      );

      // Handle the selected menu option
      if (selectedValue != null) {
        switch (selectedValue) {
          case 1:
          // Handle Menu 1 option
            break;
          case 2:
          // Handle Menu 2 option
            break;
          case 3:
          // Handle Menu 3 option
            break;
        }
      }
    },
  );
}

class CommonSearchBar extends StatelessWidget {
  final String hintText;
  final String? Function(String? value)? onChange;
  final TextEditingController? searchController;
  final FocusNode? focusNode;
  const CommonSearchBar({Key? key, this.focusNode, required this.hintText, this.onChange, this.searchController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChange,
      focusNode: focusNode,
      showCursor: true,
      controller: searchController,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xffD6D6D6),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(
          Icons.search,
          size: 25,
          color: Color(0xff858585),
        ),
        hintText: hintText,
        hintStyle: GoogleFonts.lexend(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xffADADAD),
        ),
      ),
    );
  }
}

Future yesOrNoDialog({required BuildContext context, required String dialogMessage, required String cancelText, required String okText, required VoidCallback okAction, required VoidCallback cancelAction}) {
  return  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info,
                color: Colors.red,
                size: 40,
              ),
              const SizedBox(height: 15),
              Text(
                dialogMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              )
            ],
          ),
          actionsPadding: EdgeInsets.only(bottom: 8, right: 8),
          actions: [
            Container(
              height: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey)),
              child: TextButton(
                onPressed: cancelAction,
                child: Text(cancelText,
                    style: GoogleFonts.lexend(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black)),
              ),
            ),
            Container(
              height: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red)),
              child: TextButton(
                onPressed: okAction,
                child: Text(okText,
                    style: GoogleFonts.lexend(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.red)),
              ),
            ),
          ],
        );
      });
}

Future multiTextYesOrNoDialog({
  required BuildContext context,
  String? iconUrl, // Add iconUrl parameter
  String? subText1Key,
  String? subText1Value,
  String? subText2Key,
  String? subText2Value,
  String? subText3Key,
  String? subText3Value,
  required String dialogMessage,
  required String cancelText,
  required String okText,
  required VoidCallback okAction,
  required VoidCallback cancelAction,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Conditional icon rendering
            iconUrl != null
                ? Image.asset(
              iconUrl,
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            )
                : const Icon(
              Icons.info,
              color: Colors.red,
              size: 40,
            ),
            const SizedBox(height: 10),
            Text(
              dialogMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            if (subText1Key != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      subText1Key,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    subText1Value!,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
            ],
            if (subText2Key != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      subText2Key,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    subText2Value!,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
            ],
            if (subText3Key != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      subText3Key,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    subText3Value!,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
            ],
          ],
        ),
        actionsPadding: const EdgeInsets.only(bottom: 8, right: 8),
        actions: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
            child: TextButton(
              onPressed: cancelAction,
              child: Text(
                cancelText,
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red),
            ),
            child: TextButton(
              onPressed: okAction,
              child: Text(
                okText,
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Color> colors;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  Color? fontColor;

  GradientAppBar({required this.title,this.fontColor, required this.colors , this.leading, this.actions, required this.centerTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: AppBar(
        centerTitle: centerTitle,
        leading: leading,
        actions: actions,
        title: commonBoldText(text: title, color: fontColor ?? Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}


class PopupDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final void Function(String) onSubmit;

  const PopupDialog({
    Key? key,
    required this.title,
    required this.hintText,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _PopupDialogState createState() => _PopupDialogState();
}

class _PopupDialogState extends State<PopupDialog> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: commonBoldText(text: widget.title),
      content: TextField(
        style: GoogleFonts.lexend(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.red),
        controller: _textEditingController,
        decoration: InputDecoration(
            hintText: widget.hintText),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: commonBoldText(text: 'Cancel'),
        ),
        TextButton(
          onPressed: () {
            String text = _textEditingController.text.trim();
            if (text.isNotEmpty) {
              widget.onSubmit(text);
              Navigator.of(context).pop(); // Close the dialog
            }
          },
          child: commonBoldText(text: 'Submit'),
        ),
      ],
    );
  }
}