import 'package:flutter/material.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/screens/dashboard.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:planetcombo/controllers/message_controller.dart';
import 'package:planetcombo/models/horoscope_list.dart';
import 'package:get/get.dart';

class AddMessages extends StatefulWidget {
  final String messageId;
  AddMessages({super.key, required this.messageId});

  @override
  _AddMessagesState createState() => _AddMessagesState();
}

class _AddMessagesState extends State<AddMessages> {
  final ApplicationBaseController applicationBaseController =
  Get.put(ApplicationBaseController.getInstance(), permanent: true);

  final MessageController messageController =
  Get.put(MessageController.getInstance(), permanent: true);

  HoroscopesList? selectedHoroscope;

  TextEditingController userMessage = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set the default selected horoscope based on messageId
    selectedHoroscope = applicationBaseController.horoscopeList.firstWhere(
          (horoscope) => horoscope.hid == widget.messageId,
      orElse: () => applicationBaseController.horoscopeList.first,
    );
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
        title: LocalizationController.getInstance().getTranslatedValue("Add Message"),
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
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              commonText(fontSize: 12, text: 'Please do not use this option for asking predictions. This option is used by us to communicate any issues in chart generation.', color: Colors.grey),
              SizedBox(height: 5),
              commonBoldText(text: 'Horoscope'),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Selected horoscope',
                    border: InputBorder.none,
                  ),
                  child: Text(
                    selectedHoroscope?.hname ?? 'No horoscope selected',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 20),
              commonBoldText(text: 'Message'),
              SizedBox(height: 20),
              PrimaryInputText(
                  hintText: 'Type Your message',
                  maxLines: 6,
                  controller: userMessage,
                  autoFocus: true,
                  onValidate: (v) {
                    return null;
                  }
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: 150,
                    child: GradientButton(
                        title: LocalizationController.getInstance().getTranslatedValue("Cancel"),
                        buttonHeight: 45,
                        textColor: Colors.white,
                        buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
                        onPressed: (Offset buttonOffset) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => Dashboard()),
                                (Route<dynamic> route) => false,
                          );
                        }
                    ),
                  ),
                  SizedBox(width: 20),
                  SizedBox(
                    width: 150,
                    child: GradientButton(
                        title: LocalizationController.getInstance().getTranslatedValue("Send"),
                        buttonHeight: 45,
                        textColor: Colors.white,
                        buttonColors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
                        onPressed: (Offset buttonOffset) async {
                          if (selectedHoroscope == null) {
                            showFailedToast('No horoscope selected');
                          } else if (userMessage.text.isEmpty) {
                            showFailedToast('Please Add your message');
                          } else {
                            var response = await messageController.addMessage(
                                context,
                                selectedHoroscope!.hid,
                                selectedHoroscope!.huserid,
                                userMessage.text,
                                '1',
                                "Y"
                            );
                          }
                        }
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}