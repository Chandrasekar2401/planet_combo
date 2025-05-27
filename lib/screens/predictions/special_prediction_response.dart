import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/controllers/predictions_controller.dart';
import 'package:intl/intl.dart';

class ApiMessage {
  final int id;
  final int messageType;
  final String message;
  final DateTime creationDate;
  final int predictionId;
  final List<String> splitMessages; // To handle multiple questions in one message
  final String? extractedDate; // For first user message only

  ApiMessage({
    required this.id,
    required this.messageType,
    required this.message,
    required this.creationDate,
    required this.predictionId,
    this.splitMessages = const [],
    this.extractedDate,
  });

  factory ApiMessage.fromJson(Map<String, dynamic> json, {bool isFirstUserMessage = false}) {
    String message = json['message'];
    List<String> splitMessages = [];
    String? extractedDate;

    // Only process first user message (from client) specially
    if (isFirstUserMessage && json['messageType'] == 2) {
      // Extract date if it exists in the format "| May 02, 2025 | 12:12:28 PM"
      final dateRegex = RegExp(r'\|\s+([^|]+)\s+\|\s+(\d+:\d+:\d+\s+[AP]M)');
      final match = dateRegex.firstMatch(message);

      if (match != null) {
        extractedDate = '${match.group(1)} ${match.group(2)}';
        // Remove the date part from the message
        message = message.replaceAll(dateRegex, '').trim();
      }

      // Split questions if numbered like "1. ... 2. ..."
      // Use a more robust regex that better handles various formats
      // This will properly capture the complete text of each numbered question
      final questionRegex = RegExp(r'(\d+\.\s*[^0-9.].*?)(?=\s+\d+\.|$)', dotAll: true);
      final matches = questionRegex.allMatches(message);

      if (matches.isNotEmpty) {
        splitMessages = matches.map((m) => m.group(1)!.trim()).toList();
        // If we didn't capture all the original text, use the original message
        String combinedText = splitMessages.join(' ');
        if (combinedText.trim().length < message.trim().length / 2) {
          // If we lost too much content, don't split
          splitMessages = [message];
        }
      }
    }

    return ApiMessage(
      id: json['id'],
      messageType: json['messageType'],
      message: message,
      creationDate: DateTime.parse(json['creationDate']),
      predictionId: json['predictionId'],
      splitMessages: splitMessages.isEmpty ? [message] : splitMessages,
      extractedDate: extractedDate,
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

        // Find the first user message for special processing
        int? firstUserMessageIndex;
        for (int i = 0; i < jsonList.length; i++) {
          if (jsonList[i]['messageType'] == 2) {
            firstUserMessageIndex = i;
            break;
          }
        }

        final List<ApiMessage> newMessages = jsonList.asMap().entries.map((entry) {
          final index = entry.key;
          final json = entry.value;
          return ApiMessage.fromJson(
              json,
              isFirstUserMessage: index == firstUserMessageIndex
          );
        }).toList();

        messages.assignAll(newMessages);
        messages.sort((a, b) => a.creationDate.compareTo(b.creationDate)); // Sort messages by date, oldest first
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
  final TextEditingController _messageController = TextEditingController();

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
    _messageController.dispose();
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
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Obx(() {
                // Organize messages by date
                final Map<String, List<ApiMessage>> messagesByDate = {};

                // Process existing messages
                for (final message in controller.messages) {
                  // Format the date as key using intl package
                  String dateKey;
                  DateTime dateToUse = message.creationDate;

                  // For first user message, use the extracted date if available
                  if (message.extractedDate != null) {
                    try {
                      // Try to parse the extracted date string
                      final extractedDateTime = DateFormat('MMMM dd, yyyy hh:mm:ss a').parse(message.extractedDate!);
                      dateToUse = extractedDateTime;
                    } catch (e) {
                      print('Error parsing extracted date: $e');
                      // Fall back to creationDate if parsing fails
                    }
                  }

                  dateKey = DateFormat('MMMM dd, yyyy').format(dateToUse);

                  // Create list if it doesn't exist
                  if (!messagesByDate.containsKey(dateKey)) {
                    messagesByDate[dateKey] = [];
                  }

                  // Add the message to the appropriate date group
                  messagesByDate[dateKey]!.add(message);
                }

                // Add initial messages if needed
                if (controller.initialAnswer.isNotEmpty && controller.messages.isEmpty) {
                  final answerMsg = ApiMessage(
                    id: -2,
                    messageType: 1,
                    message: controller.initialAnswer.value,
                    creationDate: DateTime.now(),
                    predictionId: controller.predictionId.value,
                  );

                  final today = DateFormat('MMMM dd, yyyy').format(DateTime.now());
                  if (!messagesByDate.containsKey(today)) {
                    messagesByDate[today] = [];
                  }
                  messagesByDate[today]!.add(answerMsg);
                }

                if (controller.initialQuestion.isNotEmpty && controller.messages.isEmpty) {
                  final questionMsg = ApiMessage(
                    id: -1,
                    messageType: 2,
                    message: controller.initialQuestion.value,
                    creationDate: DateTime.now(),
                    predictionId: controller.predictionId.value,
                  );

                  final today = DateFormat('MMMM dd, yyyy').format(DateTime.now());
                  if (!messagesByDate.containsKey(today)) {
                    messagesByDate[today] = [];
                  }
                  messagesByDate[today]!.add(questionMsg);
                }

                // Sort date keys in reverse chronological order (newest first)
                final sortedDates = messagesByDate.keys.toList()..sort((a, b) {
                  return DateFormat('MMMM dd, yyyy').parse(b).compareTo(
                      DateFormat('MMMM dd, yyyy').parse(a)
                  );
                });

                return ListView.builder(
                  reverse: false, // Changed to show oldest dates at top, newest at bottom
                  itemCount: sortedDates.length,
                  itemBuilder: (context, dateIndex) {
                    // Use reverse index to display newest dates at the bottom
                    final reversedIndex = sortedDates.length - 1 - dateIndex;
                    final dateKey = sortedDates[reversedIndex];
                    final messagesForDate = messagesByDate[dateKey]!;

                    // Sort messages within each date by time (oldest first)
                    messagesForDate.sort((a, b) => a.creationDate.compareTo(b.creationDate));

                    // Calculate total items: 1 date header + number of messages (accounting for split messages)
                    int totalItems = 1;
                    for (final msg in messagesForDate) {
                      totalItems += msg.splitMessages.length;
                    }

                    return Column(
                      children: [
                        // Date header
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              dateKey,
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        // Messages for this date
                        ...messagesForDate.expand((message) {
                          // For the first user message with multiple questions, display each question separately
                          if (message.splitMessages.length > 1) {
                            return message.splitMessages.map((splitMsg) =>
                                _buildMessageBubble(
                                    ApiMessage(
                                      id: message.id,
                                      messageType: message.messageType,
                                      message: splitMsg,
                                      creationDate: message.creationDate,
                                      predictionId: message.predictionId,
                                      extractedDate: message.extractedDate,
                                    )
                                )
                            );
                          } else {
                            return [_buildMessageBubble(message)];
                          }
                        }).toList(),
                      ],
                    );
                  },
                );
              }),
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
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFf2b20a).withOpacity(0.15) : const Color(0xFF8A6BB1).withOpacity(0.25),
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.extractedDate != null
                      ? DateFormat('hh:mm a').format(DateFormat('MMMM dd, yyyy hh:mm:ss a').parse(message.extractedDate!))
                      : '${message.creationDate.hour}:${message.creationDate.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
                // Add message status indicator (optional)
                if (isUser) SizedBox(width: 4),
                if (isUser) Icon(Icons.done_all, size: 12, color: Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
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
          Container(
            width: 48,
            height: 48,
            child: Stack(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green,
                  radius: 24,
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
                // Add hover delete icon for web (not visible on mobile)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.delete_outline,
                        size: 12,
                        color: Colors.red[400],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}