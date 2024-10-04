import 'package:flutter/material.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/models/messages_list.dart';
import 'package:planetcombo/screens/dashboard.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/controllers/message_controller.dart';
import 'package:get/get.dart';


class ReplyMessages extends StatefulWidget {
  final MessageHistory messageInfo;
  const ReplyMessages({Key? key, required this.messageInfo}) : super(key: key);

  @override
  _ReplyMessagesState createState() => _ReplyMessagesState();
}

class _ReplyMessagesState extends State<ReplyMessages> {

  final MessageController messageController =
  Get.put(MessageController.getInstance(), permanent: true);

  TextEditingController userMessage = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(onPressed: () {
          Navigator.pop(context);
        }, icon: const Icon(Icons.chevron_left_rounded),),
        title: LocalizationController.getInstance().getTranslatedValue("Reply Message"),
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)], centerTitle: true,
        actions: [
          IconButton(onPressed: (){
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Dashboard()),
                  (Route<dynamic> route) => false,
            );
          }, icon: const Icon(Icons.home_outlined))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              commonBoldText(text: 'Horoscope Name : ${widget.messageInfo.horoname}'),
              SizedBox(height: 20),
              commonBoldText(text: 'Message'),
              SizedBox(height: 20),
              PrimaryInputText(hintText: 'Type Your message',maxLines: 6,controller: userMessage, onValidate: (v){
                return null;
              }),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: GradientButton(
                        title: LocalizationController.getInstance().getTranslatedValue("Cancel"),buttonHeight: 45, textColor: Colors.white, buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)], onPressed: (Offset buttonOffset){
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const Dashboard()),
                            (Route<dynamic> route) => false,
                      );
                    }),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: GradientButton(
                        title: LocalizationController.getInstance().getTranslatedValue("Send"),buttonHeight: 45, textColor: Colors.white, buttonColors: [Color(0xFFf2b20a), Color(0xFFf34509)], onPressed: (Offset buttonOffset){
                      if(userMessage.text.isNotEmpty){
                        messageController.updateMessage(context, widget.messageInfo.msghid, widget.messageInfo.msguserid, widget.messageInfo.msgmessageid, userMessage.text, widget.messageInfo.msgstatus, widget.messageInfo.msgunread);
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
