import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppWidgets {
  Future multiTextAlignYesOrNoDialog({
    required BuildContext context,
    String? iconUrl, // Add iconUrl parameter
    String? subText1Key,
    String? subText1Value,
    String? subText1Value1,
    String? subText2Key,
    String? subText2Value,
    String? subText2Value2,
    String? subText3Key,
    String? subText3Value,
    String? subText3Value3,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          subText1Value!,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          subText1Value1!,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          subText2Value!,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          subText2Value2!,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          subText3Value!,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          subText3Value3!,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
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
}