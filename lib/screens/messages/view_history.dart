import 'package:flutter/material.dart';
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
    // TODO: implement initState
    print(widget.messageHistory.msghcomments);
    List<String> messages = widget.messageHistory.msghcomments!.split('!').where((element) => element.isNotEmpty).toList();
    messageComments.value = messages;
    print(messageComments);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(onPressed: () {
          Navigator.pop(context);
        }, icon: const Icon(Icons.chevron_left_rounded),),
        title: LocalizationController.getInstance().getTranslatedValue("History"),
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
      body: Obx(() => ListView.builder(
        itemCount: messageComments.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                commonText(text: '${messageComments[index].split('^').last}', fontSize: 14),
                SizedBox(height: 10),
                commonText(text: '${messageComments[index].split('^')[1]} : ${messageComments[index].split('^').first}', color: Colors.black54, fontSize: 13),
              ],
            ),
          );
        },
      )),
    );
  }
}
