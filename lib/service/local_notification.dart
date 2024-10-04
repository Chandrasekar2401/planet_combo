import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService{
  static Future initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize = const AndroidInitializationSettings('mipmap/ic_launcher');
    // var iOSInitialize = const IOSInitializationSettings();
    var initializationsSettings = InitializationSettings(android: androidInitialize);
    await flutterLocalNotificationsPlugin.initialize(initializationsSettings );
  }

  static Future showBigTextNotification({var id =0,required String title, required String body,
    var payload, required FlutterLocalNotificationsPlugin fln
  } ) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'you_can_name_it_whatever1',
      'channel_name',
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
      importance: Importance.max,
      priority: Priority.high,
        ticker: 'ticker',
        additionalFlags: Int32List.fromList(<int>[4]) // this flag is required when targeting S+ (version 31 and above)
    );

    var not= NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, not);
  }

}