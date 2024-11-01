import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/controllers/predictions_controller.dart';

class ApiMessage {
  final int id;
  final int messageType;
  final String message;
  final DateTime creationDate;
  final int predictionId;

  ApiMessage({
    required this.id,
    required this.messageType,
    required this.message,
    required this.creationDate,
    required this.predictionId,
  });

  factory ApiMessage.fromJson(Map<String, dynamic> json) {
    return ApiMessage(
      id: json['id'],
      messageType: json['messageType'],
      message: json['message'],
      creationDate: DateTime.parse(json['creationDate']),
      predictionId: json['predictionId'],
    );
  }
}

class SpecialPredictionController extends GetxController {
  final messages = <ApiMessage>[].obs;
  final RxInt predictionId = 0.obs;
  final RxString initialQuestion = ''.obs;
  final RxString initialAnswer = ''.obs;

  SpecialPredictionController();

  void updatePredictionId(int newId, String question, String answer) {
    predictionId.value = newId;
    initialQuestion.value = question;
    initialAnswer.value = answer;
    getMessages();
  }

  Future<void> getMessages() async {
    try {
      final jsonString = await PredictionsController.getInstance().getSpecialRequestMessages(predictionId.value);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        final List<ApiMessage> newMessages = jsonList.map((json) => ApiMessage.fromJson(json)).toList();
        messages.assignAll(newMessages);
        messages.sort((a, b) => b.creationDate.compareTo(a.creationDate)); // Sort messages by date, newest first
      } else {
        print('No messages received');
      }
    } catch (e) {
      print('Error fetching messages: $e');
      // Handle error (e.g., show a snackbar)
    }
  }

  Future<void> sendMessage(String text) async {
    try {
      final success = await PredictionsController.getInstance().addSpecialRequestReply(predictionId.value, text);
      if (success == 200) {
        await getMessages(); // Refresh messages after successful send
      } else {
        print('Failed to send message');
        // Handle failure (e.g., show a snackbar)
      }
    } catch (e) {
      print('Error sending message: $e');
      // Handle error (e.g., show a snackbar)
    }
  }
}

class SpecialPredictionResponse extends StatefulWidget {
  final int predictionId;
  final String initialQuestion;
  final String initialAnswer;

  SpecialPredictionResponse({
    Key? key,
    required this.predictionId,
    required this.initialQuestion,
    required this.initialAnswer
  }) : super(key: key);

  @override
  _SpecialPredictionResponseState createState() => _SpecialPredictionResponseState();
}

class _SpecialPredictionResponseState extends State<SpecialPredictionResponse> with WidgetsBindingObserver, RouteAware {
  late final SpecialPredictionController controller;
  Timer? _refreshTimer;
  late RouteObserver<PageRoute> _routeObserver;

  @override
  void initState() {
    super.initState();
    controller = Get.put(SpecialPredictionController(), tag: 'special_prediction_controller');
    WidgetsBinding.instance.addObserver(this);
    _routeObserver = RouteObserver<PageRoute>();
    _updateControllerAndFetchMessages();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    _stopRefreshTimer();
    WidgetsBinding.instance.removeObserver(this);
    _routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    // Called when the route is pushed onto the navigator
    _startRefreshTimer();
  }

  @override
  void didPopNext() {
    // Called when returning to this route
    _startRefreshTimer();
  }

  @override
  void didPushNext() {
    // Called when a new route is pushed on top of this route
    _stopRefreshTimer();
  }

  @override
  void didPop() {
    // Called when this route is popped off the navigator
    _stopRefreshTimer();
  }

  void _updateControllerAndFetchMessages() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.updatePredictionId(widget.predictionId, widget.initialQuestion, widget.initialAnswer);
    });
  }

  void _startRefreshTimer() {
    _stopRefreshTimer(); // Ensure any existing timer is stopped
    _refreshTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (mounted) {
        controller.getMessages();
      } else {
        _stopRefreshTimer();
      }
    });
  }

  void _stopRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startRefreshTimer();
    } else if (state == AppLifecycleState.paused) {
      _stopRefreshTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _stopRefreshTimer();
        return true;
      },
      child: Scaffold(
        appBar: GradientAppBar(
          leading: IconButton(
            onPressed: () {
              _stopRefreshTimer();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          title: LocalizationController.getInstance()
              .getTranslatedValue("Life Guidance Questions"),
          colors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () async {
                await controller.getMessages();
              },
              icon: const Icon(Icons.refresh),
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Obx(() => ListView(
                reverse: true,
                children: [
                  ...controller.messages.map((message) => _buildMessageBubble(message)),
                  if (controller.initialAnswer.isNotEmpty && controller.messages.isEmpty)
                    _buildMessageBubble(ApiMessage(
                      id: -2,
                      messageType: 1,
                      message: controller.initialAnswer.value,
                      creationDate: DateTime.now(),
                      predictionId: controller.predictionId.value,
                    )),
                  if (controller.initialQuestion.isNotEmpty && controller.messages.isEmpty)
                    _buildMessageBubble(ApiMessage(
                      id: -1,
                      messageType: 2,
                      message: controller.initialQuestion.value,
                      creationDate: DateTime.now(),
                      predictionId: controller.predictionId.value,
                    )),
                ],
              )),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ApiMessage message) {
    final isUser = message.messageType == 2;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.green[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(color: Colors.black87),
            ),
            SizedBox(height: 4),
            Text(
              '${message.creationDate.hour}:${message.creationDate.minute.toString().padLeft(2, '0')}',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    final TextEditingController _messageController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type your Query...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          SizedBox(
            width: 48,
            height: 48,
            child: CircleAvatar(
              backgroundColor: Colors.green,
              child: IconButton(
                icon: const Icon(Icons.send, size: 24, color: Colors.white),
                onPressed: () {
                  if (_messageController.text.trim().isNotEmpty) {
                    controller.sendMessage(_messageController.text.trim());
                    _messageController.clear();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}