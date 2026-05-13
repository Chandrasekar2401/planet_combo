import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/models/messages_list.dart';
import 'package:planetcombo/screens/dashboard.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/controllers/message_controller.dart';
import 'package:get/get.dart';


class ReplyMessages extends StatefulWidget {
  final MessageHistory messageInfo;
  const ReplyMessages({super.key, required this.messageInfo});

  @override
  _ReplyMessagesState createState() => _ReplyMessagesState();
}

class _ReplyMessagesState extends State<ReplyMessages> {

  final MessageController messageController =
  Get.put(MessageController.getInstance(), permanent: true);

  // Use late + initState so the controller is created exactly once
  // per State instance. (As a field-initializer it was also created
  // once, but late + initState keeps lifecycle visible alongside dispose.)
  late final TextEditingController userMessage;
  late final FocusNode _messageFocus;

  @override
  void initState() {
    super.initState();
    userMessage = TextEditingController();
    _messageFocus = FocusNode();
  }

  @override
  void dispose() {
    userMessage.dispose();
    _messageFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(onPressed: () {
          Navigator.pop(context);
        }, icon: const Icon(Icons.chevron_left_rounded),),
        title: LocalizationController.getInstance().getTranslatedValue("Reply Message"),
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)], centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              commonBoldText(text: 'Horoscope Name : ${widget.messageInfo.horoname}'),
              const SizedBox(height: 20),
              commonBoldText(text: 'Message'),
              const SizedBox(height: 20),
              // Use TextField directly (not PrimaryInputText) so we can
              // pin textInputAction to newline. With maxLines > 1 the
              // Android keyboard "tick" / done action was being treated
              // as a submit that, combined with autofocus and the
              // initialValue:null path in TextFormField, wiped the text.
              TextField(
                controller: userMessage,
                focusNode: _messageFocus,
                maxLines: 6,
                minLines: 6,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: GoogleFonts.lexend(color: Colors.black),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(16),
                  labelText: LocalizationController.getInstance()
                      .getTranslatedValue('Type Your message'),
                  labelStyle: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black54),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: GradientButton(
                        title: LocalizationController.getInstance().getTranslatedValue("Cancel"),buttonHeight: 45, textColor: Colors.white, buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)], onPressed: (Offset buttonOffset){
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => Dashboard()),
                            (Route<dynamic> route) => false,
                      );
                    }),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: GradientButton(
                        title: LocalizationController.getInstance().getTranslatedValue("Send"),buttonHeight: 45, textColor: Colors.white, buttonColors: [Color(0xFFf2b20a), Color(0xFFf34509)], onPressed: (Offset buttonOffset){
                      // Close the keyboard first so the IME flushes any
                      // pending composition into the controller before
                      // we read its text.
                      _messageFocus.unfocus();
                      final text = userMessage.text.trim();
                      if(text.isNotEmpty){
                        messageController.updateMessage(context, widget.messageInfo.msghid.toString(), widget.messageInfo.msguserid, widget.messageInfo.msgmessageid, text, widget.messageInfo.msgstatus, widget.messageInfo.msgunread);
                      }else{
                        showFailedToast("Please add reply message");
                      }
                    }),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
