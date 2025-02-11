import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/models/messages_list.dart';
import 'package:planetcombo/screens/dashboard.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:get/get.dart';

class ViewHistory extends StatefulWidget {
  MessageHistory messageHistory;
  ViewHistory({Key? key, required this.messageHistory}) : super(key: key);

  @override
  _ViewHistoryState createState() => _ViewHistoryState();
}

class _ViewHistoryState extends State<ViewHistory> {
  RxList messageComments = [].obs;

  @override
  void initState() {
    super.initState();
    List<String> messages = widget.messageHistory.msghcomments!
        .split('!')
        .where((element) => element.isNotEmpty)
        .toList();
    messageComments.value = messages;
  }

  String formatDateTime(String rawTime) {
    try {
      // Assuming the time string is like '02 February 2025 16:15:50.795'
      DateFormat inputFormat = DateFormat('dd MMMM yyyy HH:mm:ss.SSS');
      DateTime parsedTime = inputFormat.parse(rawTime);
      return DateFormat('dd MMMM yyyy, hh:mm:ss a').format(parsedTime);
    } catch (e) {
      return rawTime; // Return raw time if parsing fails
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
        title: LocalizationController.getInstance()
            .getTranslatedValue("History"),
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Dashboard()),
                    (Route<dynamic> route) => false,
              );
            },
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: Obx(() => ListView.builder(
        itemCount: messageComments.length,
        itemBuilder: (BuildContext context, int index) {
          List<String> parts = messageComments[index].split('^');
          String message = parts.first.trim();
          String rawTime = parts.length > 1 ? parts[1].trim() : 'N/A';
          String formattedDateTime = formatDateTime(rawTime);
          String email = parts.length > 2 ? parts[2].trim() : 'N/A';

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 6,
                  spreadRadius: 2,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                commonText(
                  text: message,
                  fontSize: 16,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    commonText(
                      text: 'By: $email',
                      color: Colors.black45,
                      fontSize: 13,
                    ),
                    commonText(
                      text: formattedDateTime,
                      color: Colors.blueGrey,
                      fontSize: 13,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      )),
    );
  }
}
