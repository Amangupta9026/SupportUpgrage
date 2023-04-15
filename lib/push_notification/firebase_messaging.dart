import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:support/push_notification/push_notification.dart';

import '../screen/call/incoming_call_screen.dart';

class Messaging {
  static void showMessage() {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    // firebaseMessaging.getToken().then((value) => `storeToken(value));
    // // print('fcm token ${fcm_token}');
    // // storeToken(fcm_token);

    firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        final routeFromMessage = message.data['route'];
        log("$routeFromMessage, name: 'msg notifi");
        // Navigator.of(context).pushNamed(routeFromMessage);

        Get.to(
          () => IncomingCallScreen(
            name: message.data['name'],
            channelId: message.data['channel_id'],
            channelToken: message.data['channel_token'],
            uid: int.parse(message.data["user_id"] ?? "0"),
          ),
        );
      }
    });

    /// forground work
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      if (message?.data['channel_id'] != null) {
        PushNotificationService.display(message!);
        log("Current route${Get.currentRoute}");

        log("channel id ${message.data['channel_id']}");
        log("channel token${message.data['channel_token']}");

        Get.to(
          () => IncomingCallScreen(
            toUserId: message.data['to_user_id'],
            name: message.data['name'],
            channelId: message.data['channel_id'],
            channelToken: message.data['channel_token'],
            uid: int.parse(message.data["user_id"] ?? "0"),
          ),
        );
      }
    });

    // When the app is in background but open and user taps
    // on the notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // final routeFromMessage = message.data['route'];
      // log(routeFromMessage);
      // Navigator.of(context).pushNamed(routeFromMessage);
      log('opened');
      log("bg message");
      if (message.data['channel_id'] != null) {
        PushNotificationService.display(message);
        log("Current route${Get.currentRoute}");

        log("channel id ${message.data['channel_id']}");
        log("channel token${message.data['channel_token']}");

        Get.to(
          () => IncomingCallScreen(
            name: message.data['name'],
            channelId: message.data['channel_id'],
            channelToken: message.data['channel_token'],
            uid: int.parse(message.data["user_id"] ?? "0"),
          ),
        );
      }
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("bg message");
  if (message.data['channel_id'] != null) {
    PushNotificationService.display(message);
    // log("Current route${Get.currentRoute}");

    // log("channel id ${message.data['channel_id']}");
    // log("channel token${message.data['channel_token']}");

    Get.to(
      () => IncomingCallScreen(
        name: message.data['name'],
        channelId: message.data['channel_id'],
        channelToken: message.data['channel_token'],
        uid: int.parse(message.data["user_id"] ?? "0"),
      ),
    );
  }
}
