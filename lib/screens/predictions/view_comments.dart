import 'package:flutter/material.dart';

import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/screens/dashboard.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:get/get.dart';

class Comment {
  final String commentText;
  final String date;
  final String time;
  final String email;

  Comment({
    required this.commentText,
    required this.date,
    required this.time,
    required this.email,
  });
}

class ViewComments extends StatefulWidget {
  String comments;
  ViewComments({super.key, required this.comments});

  @override
  State<ViewComments> createState() => _ViewCommentsState();
}

class _ViewCommentsState extends State<ViewComments> {

  ScrollController _scrollController = ScrollController();

  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  List<Comment> historyCommentToDisplay = [];

  List<Comment> processComments() {
    try {
      List<String> s = widget.comments.split("!");
      print(s);
      for (String item in s) {
        if (item.isNotEmpty) {// Replace with actual name translation logic
          try {
            List<String> parts = item.split("^");
            print(parts);
            var commentText = parts[0].trim();
            // var dateTime = DateTime.parse(parts[1].trim());
            var email = parts[2].trim();

            // var date = DateFormat('dd/MM/yyyy').format(dateTime);
            // var time = DateFormat('hh:mm:ss a').format(dateTime);

            var comment = Comment(
              commentText: commentText,
              date: '14/07/2024',
              time: '12:00',
              email: email,
            );
            if(comment.commentText != ''){
              historyCommentToDisplay.add(comment);
            }
            print(historyCommentToDisplay.length);
          } catch (e) {
            print(e);
          }
        }
      }
      return historyCommentToDisplay;
    } catch (e) {
      // Handle the exception if necessary
      return [];
    }
  }

  String currentUserEmail = "";

 @override
  void initState() {
    // TODO: implement initState
   currentUserEmail = appLoadController.loggedUserData.value.useremail!;
   processComments();
   // Scroll to bottom after the frame is built
   WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    super.initState();
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: GradientAppBar(
          leading: IconButton(onPressed: () { Navigator.pop(context); }, icon: Icon(Icons.chevron_left_rounded),),
          title: LocalizationController.getInstance().getTranslatedValue("Comments"),
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
        body: historyCommentToDisplay.isEmpty ? Container(
          child: Center(
            child: commonBoldText(text: 'No Comments available'),
          ),
        ) :
        ListView.builder(
            controller: _scrollController,
        itemCount: historyCommentToDisplay.length,
    itemBuilder: (context, index) {
    Comment comment = historyCommentToDisplay[index];
    bool isCurrentUser = comment.email == currentUserEmail;
    return Container(
          alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
          crossAxisAlignment:
          isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
                    Container(
                    padding: const EdgeInsets.all(10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                    color: isCurrentUser ? Colors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                    Column(
                    crossAxisAlignment:
                    isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                    Text(
                    comment.commentText,
                    style: TextStyle(
                    color: isCurrentUser ? Colors.white : Colors.black,
                      ),),
                      SizedBox(height: 5),
                      // Text(
                      // '${comment.date} ${comment.time}',
                      // style: TextStyle(
                      // color: isCurrentUser ? Colors.white60 : Colors.black54,
                      // fontSize: 12,
                      // ),),
                      // const SizedBox(height: 5),
                      Text(
                      comment.email,
                      style: TextStyle(
                      color: isCurrentUser ? Colors.white60 : Colors.black54,
                      fontSize: 12,
                      ),),],),),],),);
                    }));
}


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
