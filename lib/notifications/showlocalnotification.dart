import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Showlocalnotification {
  //initialization
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  void shownotification(String title, String body) async {
    var android = AndroidNotificationDetails('channel id', 'channel Name',
        priority: Priority.high, importance: Importance.max);
    var platform = NotificationDetails(android: android);
    await flutterLocalNotificationsPlugin.show(0, title, body, platform,
        payload: "Bienvenue dans le TIE");
  }
}
