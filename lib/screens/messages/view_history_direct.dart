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

class ViewHistoryDirect extends StatefulWidget {
  final String horoscopeId;
  final String horoscopeName;

  ViewHistoryDirect({
    super.key,
    required this.horoscopeId,
    required this.horoscopeName
  });

  @override
  _ViewHistoryDirectState createState() => _ViewHistoryDirectState();
}

class _ViewHistoryDirectState extends State<ViewHistoryDirect> with WidgetsBindingObserver {

  final ScrollController _scrollController = ScrollController();

  final ApplicationBaseController applicationBaseController =
  Get.put(ApplicationBaseController.getInstance(), permanent: true);

  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  final MessageController messageController =
  Get.put(MessageController.getInstance(), permanent: true);

  RxList messageComments = [].obs;
  RxBool isLoading = false.obs;
  Timer? _refreshTimer;
  String? currentMessageId;

  void scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> loadMessagesForHoroscope() async {
    try {
      isLoading.value = true;

      // Call the updated API that returns messages for specific horoscope ID
      await applicationBaseController.getUserMessagesForHoroscope(widget.horoscopeId);

      // Find messages for this horoscope
      var horoscopeMessages = applicationBaseController.messagesHistory
          .where((message) => message.msghid.toString() == widget.horoscopeId)
          .toList();

      if (horoscopeMessages.isNotEmpty) {
        // Take the first message (should be only one now based on your new API)
        var messageHistory = horoscopeMessages.first;
        currentMessageId = messageHistory.msgmessageid;

        if (messageHistory.msghcomments != null && messageHistory.msghcomments!.isNotEmpty) {
          List<String> messages = messageHistory.msghcomments!
              .split('!')
              .where((element) => element.trim().isNotEmpty)
              .toList();
          messageComments.value = messages;
          scrollToBottom();
        } else {
          messageComments.value = [];
        }
      } else {
        messageComments.value = [];
        currentMessageId = null;
      }
    } catch (e) {
      print('Error loading messages: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading messages: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (mounted) {
        await loadMessagesForHoroscope();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadMessagesForHoroscope();
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
      loadMessagesForHoroscope();
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
        title: LocalizationController.getInstance().getTranslatedValue("Messages"),
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await loadMessagesForHoroscope();
            },
            icon: const Icon(Icons.refresh),
          ),
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
              text: 'Horoscope: ${widget.horoscopeName}',
            ),
          ),
          Expanded(
            child: Obx(() {
              if (isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (messageComments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      commonText(
                        text: 'No messages yet\nStart a conversation!',
                        textAlign: TextAlign.center,
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
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
              );
            }),
          ),
        ],
      ),
      floatingActionButton: GradientFloatingActionButton(
        onPressed: () {
          if (currentMessageId != null) {
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
                child: ReplyBottomSheetDirect(
                  horoscopeId: widget.horoscopeId,
                  horoscopeName: widget.horoscopeName,
                  messageId: currentMessageId!,
                  onMessageSent: () {
                    loadMessagesForHoroscope(); // Refresh messages after sending
                  },
                ),
              ),
            );
          } else {
            // Create a new message if no message exists
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
                child: CreateMessageBottomSheet(
                  horoscopeId: widget.horoscopeId,
                  horoscopeName: widget.horoscopeName,
                  onMessageCreated: () {
                    loadMessagesForHoroscope(); // Refresh messages after creating
                  },
                ),
              ),
            );
          }
        },
        gradient: const LinearGradient(
          colors: [Color(0xFFf2b20a), Color(0xFFf34509)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Column(
          children: [
            SizedBox(height: 14),
            commonBoldText(text: currentMessageId != null ? 'Reply' : 'Message', color: Colors.white, fontSize: 12),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class ReplyBottomSheetDirect extends StatelessWidget {
  final String horoscopeId;
  final String horoscopeName;
  final String messageId;
  final VoidCallback onMessageSent;
  final TextEditingController userMessage = TextEditingController();
  final MessageController messageController = Get.find<MessageController>();
  final AppLoadController appLoadController = Get.find<AppLoadController>();

  ReplyBottomSheetDirect({
    super.key,
    required this.horoscopeId,
    required this.horoscopeName,
    required this.messageId,
    required this.onMessageSent,
  });

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
                commonBoldText(text: 'Horoscope: $horoscopeName'),
                const SizedBox(height: 20),
                commonBoldText(text: 'Message'),
                const SizedBox(height: 20),
                Expanded(
                  child: PrimaryInputText(
                    hintText: 'Type your message...',
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
                          if (userMessage.text.trim().isNotEmpty) {
                            // Use your existing updateMessage method
                            await messageController.updateMessage(
                              context,
                              horoscopeId,
                              appLoadController.loggedUserData.value.useremail!,
                              messageId,
                              userMessage.text.trim(),
                              "1", // message status
                              "y", // unread
                            );
                            // Refresh will happen through the callback in updateMessage
                            onMessageSent(); // Also call our callback to refresh
                          } else {
                            showFailedToast("Please add your message");
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

class CreateMessageBottomSheet extends StatelessWidget {
  final String horoscopeId;
  final String horoscopeName;
  final VoidCallback onMessageCreated;
  final TextEditingController userMessage = TextEditingController();
  final MessageController messageController = Get.find<MessageController>();
  final AppLoadController appLoadController = Get.find<AppLoadController>();

  CreateMessageBottomSheet({
    super.key,
    required this.horoscopeId,
    required this.horoscopeName,
    required this.onMessageCreated,
  });

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
                    .getTranslatedValue("New Message"),
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
                commonBoldText(text: 'Horoscope: $horoscopeName'),
                const SizedBox(height: 20),
                commonBoldText(text: 'Message'),
                const SizedBox(height: 20),
                Expanded(
                  child: PrimaryInputText(
                    hintText: 'Type your message...',
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
                          if (userMessage.text.trim().isNotEmpty) {
                            // Use your existing addMessage method
                            await messageController.addMessage(
                              context,
                              horoscopeId,
                              appLoadController.loggedUserData.value.useremail!,
                              userMessage.text.trim(),
                              "1", // message status
                              "y", // unread
                            );
                            // Refresh will happen through the callback in addMessage
                            onMessageCreated(); // Also call our callback to refresh
                          } else {
                            showFailedToast("Please add your message");
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