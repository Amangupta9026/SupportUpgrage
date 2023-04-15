import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support/screen/home/home_screen.dart';
import 'package:support/sharedpreference/sharedpreference.dart';

import 'firebase_options.dart';
import 'global/color.dart';
import 'global/theme.dart';
import 'global/utils.dart';
import 'push_notification/firebase_messaging.dart';
import 'screen/auth/boarding_screen.dart';
import 'screen/call/incoming_call_screen.dart';
import 'screen/listner_app_ui/listner_homescreen.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  log(message.data.toString(), name: 'main.dart');
  log(message.notification!.title.toString(), name: 'main.dart notifi');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SharedPreference.init();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await AppUtils.handleCameraAndMic(Permission.microphone);
  await AppUtils.handleCameraAndMic(Permission.bluetooth);
  await AppUtils.handleCameraAndMic(Permission.notification);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? home = const OnBoarding();

  @override
  void initState() {
    super.initState();
    Messaging.showMessage();

    checkLogin();

    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        log("FirebaseMessaging.instance.getInitialMessage");
        // if (message != null) {
        //   log("New Notification");
        //   // if (message.data['_id'] != null) {
        //   //   Navigator.of(context).push(
        //   //     MaterialPageRoute(
        //   //       builder: (context) => DemoScreen(
        //   //         id: message.data['_id'],
        //   //       ),
        //   //     ),
        //   //   );
        //   // }
        // }
        if (message?.data['channel_id'] != null) {
          log("Current route${Get.currentRoute}");

          log("channel id ${message?.data['channel_id']}");
          log("channel token${message?.data['channel_token']}");

          Get.to(
            () => IncomingCallScreen(
              name: message?.data['name'],
              channelId: message?.data['channel_id'],
              channelToken: message?.data['channel_token'],
              uid: int.parse(message?.data["user_id"] ?? "0"),
            ),
          );
        }
      },
    );

    // 2. This method only call when App in forground it mean app must be opened
    FirebaseMessaging.onMessage.listen(
      (message) {
        log("FirebaseMessaging.onMessage.listen");
        if (message.notification != null &&
            message.data['channel_id'] != null) {
          log(message.notification!.title.toString());
          log(message.notification!.body.toString());
          log("message.data11 ${message.data}");
          // LocalNotificationService.display(message);

          Get.to(
            () => IncomingCallScreen(
              name: message.data['name'],
              channelId: message.data['channel_id'],
              channelToken: message.data['channel_token'],
              uid: int.parse(message.data["user_id"] ?? "0"),
            ),
          );
        }
      },
    );

    // 3. This method only call when App in background and not terminated(not closed)
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        log("FirebaseMessaging.onMessageOpenedApp.listen");
        if (message.notification != null &&
            message.data['channel_id'] != null) {
          log(message.notification?.title.toString() ?? '');
          log(message.notification?.body.toString() ?? '');
          log("message.data22 ${message.data['_id']}");

          Get.to(
            () => IncomingCallScreen(
              name: message.data['name'],
              channelId: message.data['channel_id'],
              channelToken: message.data['channel_token'],
              uid: int.parse(message.data["user_id"] ?? "0"),
            ),
          );
        }
      },
    );
  }

  void checkLogin() async {
    if (FirebaseAuth.instance.currentUser != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? isListener = prefs.getBool("isListener");
      if (!isListener!) {
        home = const HomeScreen();
      } else {
        home = const ListnerHomeScreen();
      }
    } else {
      home = const OnBoarding();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return
        // Scaffold(
        //   body: home,
        // );
        GetMaterialApp(
      color: primaryColor,
      debugShowCheckedModeBanner: false,
      title: 'Support',
      theme: themeData,
      home: home,
      builder: EasyLoading.init(),
    );
  }
}
