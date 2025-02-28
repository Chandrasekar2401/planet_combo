import 'dart:async';

import 'package:flutter/material.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:get/get.dart';
import 'package:planetcombo/screens/messages/add_message.dart';
import 'package:planetcombo/screens/messages/reply_message.dart';
import 'package:planetcombo/screens/messages/view_history.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:planetcombo/controllers/message_controller.dart';

class MessagesList extends StatefulWidget {
  String horoscopeId;
  MessagesList({super.key, required this.horoscopeId});

  @override
  _MessagesListState createState() => _MessagesListState();
}

class _MessagesListState extends State<MessagesList> {

  final ApplicationBaseController applicationBaseController =
  Get.put(ApplicationBaseController.getInstance(), permanent: true);

  final MessageController messageController =
  Get.put(MessageController.getInstance(), permanent: true);

  @override
  void initState() {
    // TODO: implement initState
    applicationBaseController.getUserMessages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(onPressed: () {
          Navigator.pop(context);
        }, icon: const Icon(Icons.chevron_left_rounded),),
        title: LocalizationController.getInstance().getTranslatedValue("All Messages"),
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)], centerTitle: true,
        actions: [
          IconButton(onPressed: () async{
            CustomDialog.showLoading(context, 'Please wait');
            await applicationBaseController.getUserMessages();
            Timer(const Duration(seconds: 2), (){
              CustomDialog.cancelLoading(context);
            });
          }, icon: const Icon(Icons.refresh))
        ],
      ),
      body: applicationBaseController.messagesHistory.isEmpty ? Center(
        child: SizedBox( width : 280, child: commonText(textAlign: TextAlign.center, color: Colors.grey , text: 'To add message please click on add message button')),
      ) :
      Obx(() => ListView.builder(
        itemCount: applicationBaseController.messagesHistory.length,
        itemBuilder: (BuildContext context, int index) {
          if (widget.horoscopeId == applicationBaseController.messagesHistory[index].msghid!.toString()) {
            return Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Colors.black26,
                        width: 0.5
                    )
                )
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                commonBoldText(text: applicationBaseController.messagesHistory[index].msghcomments!.split('^')[0]),
                const SizedBox(height: 5),
                commonBoldText(text: 'Horoscope Name : ${applicationBaseController.messagesHistory[index].horoname}', color: Colors.black38, fontSize: 14),
                const SizedBox(height: 5),
                commonText(text: applicationBaseController.messagesHistory[index].msgstatus == "1" ?'Waiting for agent to reply' : "Waiting for your reply", color: applicationBaseController.messagesHistory[index].msgstatus == "1" ? Colors.lightBlue : Colors.red, fontSize: 11),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Expanded(
                    //   child: GradientButton(title: LocalizationController.getInstance().getTranslatedValue("Reply"), buttonHeight: 30, textColor: Colors.white, buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)], onPressed: (Offset buttonOffset){
                    //     Navigator.push(
                    //         context, MaterialPageRoute(builder: (context) => ReplyMessages(messageInfo : applicationBaseController.messagesHistory[index])));
                    //   }),
                    // ),
                    Expanded(child:GradientButton(title: LocalizationController.getInstance().getTranslatedValue("Delete"), buttonHeight: 30, textColor: Colors.white, buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)], onPressed: (Offset buttonOffset){
                      yesOrNoDialog(
                        context: context,
                        dialogMessage: 'Do you want to delete this Message ?',
                        cancelText: 'No',
                        okText: 'Yes',
                        cancelAction: (){
                          Navigator.pop(context);
                        },
                        okAction: () async{
                          Navigator.pop(context);
                          var response = await messageController.deleteMessage(context, applicationBaseController.messagesHistory[index].msgmessageid!, applicationBaseController.messagesHistory[index].msghid!, applicationBaseController.messagesHistory[index].msguserid);
                        },
                      );
                    }),
                    ),
                    Expanded(
                      child: GradientButton(title: LocalizationController.getInstance().getTranslatedValue("View History"), buttonHeight: 30, textColor: Colors.white, buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)], onPressed: (Offset buttonOffset){
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) =>  ViewHistory(messageHid : applicationBaseController.messagesHistory[index].msghid, messageMsgId : applicationBaseController.messagesHistory[index].msgmessageid!)));
                      }),
                    ),
                  ],
                ),
              ],
            ),
          );
          } else {
            return const SizedBox();
          }
        },
      )),
      floatingActionButton: GradientFloatingActionButton(
        onPressed: () {
          // Add your message code here
          print('Message');
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddMessages(messageId: widget.horoscopeId)));
        },
        gradient: const LinearGradient(
          colors: [Color(0xFFf2b20a), Color(0xFFf34509)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child:
        Column(
          children: [
            SizedBox(height: 14),
            commonBoldText(text: 'Add', color: Colors.white, fontSize: 12),
            commonText(text: 'Message', color: Colors.white70, fontSize: 9)
          ],
        )
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}


class GradientFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Gradient gradient;

  GradientFloatingActionButton({
    required this.onPressed,
    required this.child,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(25.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.6),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        child: child,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}