import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/models/messages_list.dart';
import 'package:planetcombo/screens/dashboard.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:get/get.dart';
import 'package:planetcombo/controllers/message_controller.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';

class ViewHistory extends StatefulWidget {
  final int messageHid;
  final String messageMsgId;
  ViewHistory({super.key, required this.messageHid, required this.messageMsgId});

  @override
  _ViewHistoryState createState() => _ViewHistoryState();
}

class _ViewHistoryState extends State<ViewHistory> with WidgetsBindingObserver {

  final ScrollController _scrollController = ScrollController();

  final ApplicationBaseController applicationBaseController =
  Get.put(ApplicationBaseController.getInstance(), permanent: true);

  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  final MessageController messageController =
  Get.put(MessageController.getInstance(), permanent: true);
  late MessageHistory selectedMessageHistory;
  RxList messageComments = [].obs;
  Timer? _refreshTimer;

  void scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }


  void loadMessageHistory() {
    selectedMessageHistory = applicationBaseController.messagesHistory.firstWhere(
          (message) => (message.msghid == widget.messageHid &&
          message.msgmessageid == widget.messageMsgId),
      orElse: () => throw Exception('Message not found'),
    );
    if (selectedMessageHistory.msghcomments != null) {
      List<String> messages = selectedMessageHistory.msghcomments!
          .split('!')
          .where((element) => element.isNotEmpty)
          .toList();
      messageComments.value = messages;
      // Scroll to bottom after loading messages
      WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
    }
  }


  void startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      print('Refreshing messages...');
      await applicationBaseController.getUserMessages();
      loadMessageHistory();
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadMessageHistory();
    startPeriodicRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadMessageHistory();
      startPeriodicRefresh();
    } else if (state == AppLifecycleState.paused) {
      _refreshTimer?.cancel();
    }
  }

  String formatDateTime(String rawTime) {
    try {
      DateFormat inputFormat = DateFormat('dd MMMM yyyy HH:mm:ss.SSS');
      DateTime parsedTime = inputFormat.parse(rawTime);
      return DateFormat('dd MMMM yyyy, hh:mm:ss a').format(parsedTime);
    } catch (e) {
      return rawTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        title: LocalizationController.getInstance().getTranslatedValue("History"),
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Dashboard()),
                    (Route<dynamic> route) => false,
              );
            },
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: commonBoldText(
              text: 'Horoscope Name : ${selectedMessageHistory.horoname}',
            ),
          ),
          Expanded(
            child: Obx(
                  () => ListView.builder(
                    controller: _scrollController,
                itemCount: messageComments.length,
                padding: const EdgeInsets.symmetric(vertical: 10),
                    itemBuilder: (BuildContext context, int index) {
                      List<String> parts = messageComments[index].split('^');
                      String message = parts.first.trim();
                      String rawTime = parts.length > 1 ? parts[1].trim() : 'N/A';
                      String formattedDateTime = formatDateTime(rawTime);
                      String email = parts.length > 2 ? parts[2].trim() : 'N/A';

                      bool isUserMessage = email == appLoadController.loggedUserData.value.useremail;

                      return Padding(
                        padding: EdgeInsets.only(
                          left: isUserMessage ? 40 : 8,
                          right: isUserMessage ? 8 : 40,
                          top: 4,
                          bottom: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.8,
                                minWidth: MediaQuery.of(context).size.width * 0.55,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isUserMessage
                                      ? const Color(0xFFf2b20a).withOpacity(0.2)
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: Radius.circular(isUserMessage ? 16 : 4),
                                    bottomRight: Radius.circular(isUserMessage ? 4 : 16),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: commonText(
                                        text: message,
                                        fontSize: 15,
                                        color: isUserMessage ? Colors.black87 : Colors.black87,
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        commonText(
                                          text: formattedDateTime,
                                          color: Colors.black54,
                                          fontSize: 11,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: GradientFloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ReplyBottomSheet(messageHistory: selectedMessageHistory),
            ),
          );
        },
        gradient: const LinearGradient(
          colors: [Color(0xFFf2b20a), Color(0xFFf34509)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Column(
          children: [
            SizedBox(height: 19),
            commonBoldText(text: 'Reply', color: Colors.white, fontSize: 12),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class ReplyBottomSheet extends StatelessWidget {
  final MessageHistory messageHistory;
  final TextEditingController userMessage = TextEditingController();
  final MessageController messageController = Get.find<MessageController>();

  ReplyBottomSheet({super.key, required this.messageHistory});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              commonBoldText(
                text: LocalizationController.getInstance()
                    .getTranslatedValue("Reply Message"),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                commonBoldText(text: 'Horoscope Name : ${messageHistory.horoname}'),
                const SizedBox(height: 20),
                commonBoldText(text: 'Message'),
                const SizedBox(height: 20),
                Expanded(
                  child: PrimaryInputText(
                    hintText: 'Type Your message',
                    maxLines: 6,
                    controller: userMessage,
                    autoFocus: true,
                    onValidate: (v) => null,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GradientButton(
                        title: "Send",
                        buttonHeight: 45,
                        textColor: Colors.white,
                        buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
                        onPressed: (offset) async {
                          if (userMessage.text.isNotEmpty) {
                            bool success = await messageController.updateMessage(
                              context,
                              messageHistory.msghid.toString(),
                              messageHistory.msguserid,
                              messageHistory.msgmessageid,
                              userMessage.text,
                              messageHistory.msgstatus,
                              messageHistory.msgunread,
                            );
                            if (success && context.mounted) {
                              Navigator.pop(context);
                            }
                          } else {
                            showFailedToast("Please add reply message");
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
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
            offset: const Offset(0, 3),
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