// ignore_for_file: non_constant_identifier_names

import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support/api/api_services.dart';
import 'package:support/global/color.dart';
import 'package:support/model/delete_model.dart';
import 'package:support/screen/auth/boarding_screen.dart';
import 'package:support/screen/drawer/about_us_screen.dart';
import 'package:support/screen/drawer/online_notification.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/api_constant.dart';
import '../../model/chat_notification.dart';
import '../../sharedpreference/sharedpreference.dart';
import '../auth/login_screen.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({Key? key}) : super(key: key);

  @override
  DrawerScreenState createState() => DrawerScreenState();
}

class DrawerScreenState extends State<DrawerScreen> {
  bool isProgressRunning = false;
  ChatNotificationModel? chatNotificationModel;

  final Uri _listnerurl = Uri.parse(
      'https://docs.google.com/forms/d/e/1FAIpQLSeQ68KEWTZ3CSo1uz0_xpIqI6xCbNAhg6BNeDNsu-BIeT-zmw/viewform');

  Future<void> _launchUrl() async {
    if (!await launchUrl(_listnerurl)) {
      throw 'Could not launch $_listnerurl';
    }
  }

  Future<void> apiNotifyListnerList() async {
    try {
      setState(() {
        isProgressRunning = true;
      });
      chatNotificationModel = await APIServices.getNotification();
    } catch (e) {
      log(e.toString());
    } finally {
      if (mounted) {
      setState(() {
        isProgressRunning = false;
      });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    apiNotifyListnerList();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: colorWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: colorRed,
          ),
          Expanded(
            child: Container(
              color: colorWhite,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 13, right: 13, bottom: 10, top: 30),
                        child: Row(
                          children: [
                            Column(children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: colorBlack),
                                  shape: BoxShape.circle,
                                ),
                                child: SharedPreference.getValue(
                                            PrefConstants.USER_TYPE) ==
                                        'user'
                                    ? const Icon(
                                        Icons.person,
                                        size: 50,
                                      )
                                    : CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            APIConstants.BASE_URL +
                                                SharedPreference.getValue(
                                                    PrefConstants
                                                        .LISTENER_IMAGE)),
                                      ),
                              ),
                            ]),
                            const SizedBox(
                              width: 13,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  SharedPreference.getValue(
                                              PrefConstants.USER_TYPE) ==
                                          'user'
                                      ? 'Anonymous'
                                      : SharedPreference.getValue(
                                          PrefConstants.LISTENER_NAME),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      ?.copyWith(
                                        color: colorBlack,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  SharedPreference.getValue(
                                          PrefConstants.MOBILE_NUMBER) ??
                                      '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2
                                      ?.copyWith(
                                        color: colorBlack,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        thickness: 0.5,
                        color: colorGrey,
                      ),
                      Visibility(
                        visible: SharedPreference.getValue(
                                PrefConstants.USER_TYPE) ==
                            'user',
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 6,
                            ),
                            customRow(
                              "Profile",
                              const Icon(Icons.person, color: colorBlack),
                              () {
                                showAlertDialog(context);
                              },
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: SharedPreference.getValue(
                                PrefConstants.USER_TYPE) ==
                            'user',
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 15,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 13, right: 13),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const OnlineListnerNotification(),
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: colorGrey,
                                        ),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(6),
                                        child: Icon(Icons.notification_add,
                                            color: colorBlack),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          "Chat Notification",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: colorBlack,
                                          ),
                                        ),

                                        const SizedBox(width: 8),
                                        // isProgressRunning
                                        //     ?
                                        if (
                                        // isProgressRunning
                                        //   &&
                                        chatNotificationModel != null &&
                                            chatNotificationModel!
                                                    .unreadNotifications! >
                                                0)
                                          Visibility(
                                            visible:
                                                // isProgressRunning &&
                                                chatNotificationModel != null &&
                                                    chatNotificationModel!
                                                            .unreadNotifications! >
                                                        0,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.green),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: Text(
                                                  '${chatNotificationModel?.unreadNotifications ?? ''}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        // : const SizedBox(),
                                        // if (chatNotificationModel != null &&
                                        //     chatNotificationModel
                                        //             ?.unreadNotifications ==
                                        //         0 &&
                                        //     isProgressRunning) ...{
                                        //   // const SizedBox()
                                        //   const CircularProgressIndicator(),
                                        // } else
                                        //   // if (chatNotificationModel !=
                                        //   //         null &&
                                        //   //     chatNotificationModel!
                                        //   //             .unreadNotifications! >
                                        //   //         0 &&
                                        //   //     isProgressRunning)
                                        //   ...{
                                        //   Container(
                                        //     decoration: const BoxDecoration(
                                        //         shape: BoxShape.circle,
                                        //         color: Colors.green),
                                        //     child: Padding(
                                        //       padding:
                                        //           const EdgeInsets.all(5.0),
                                        //       child: Text(
                                        //         '${chatNotificationModel?.unreadNotifications ?? ''}',
                                        //         style: const TextStyle(
                                        //           fontSize: 12,
                                        //           color: Colors.white,
                                        //         ),
                                        //       ),
                                        //     ),
                                        //   ),
                                        //   // } else ...{
                                        //   //   const Text('dddddd'),
                                        // }
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: SharedPreference.getValue(
                                PrefConstants.USER_TYPE) ==
                            'user',
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 15,
                            ),
                            customRow(
                              "Be a Listner",
                              const Icon(Icons.interpreter_mode,
                                  color: colorBlack),
                              // FontAwesomeIcons.moon,

                              _launchUrl,
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => const ListnerHomeScreen(),
                              //   ),
                              // );
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      customRow(
                        "Need Help ?",
                        const Icon(Icons.contact_support, color: colorBlack),
                        () {
                          launchUrl(Uri.parse('mailto:help@support2heal.com'));
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => const MenuProfile(),
                          //   ),
                          // );
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      customRow(
                        "Logout",
                        const Icon(Icons.logout, color: colorBlack),
                        () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.clear();
                          await FirebaseAuth.instance.signOut();
                          if (mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                                (Route<dynamic> route) => false);
                          }
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      customRow(
                        "Delete Account",
                        const Icon(Icons.delete, color: colorBlack),
                        () async {
                          EasyLoading.show(status: 'loading...');
                          DeleteModel? data =
                              await APIServices.getDeleteAccount(
                            SharedPreference.getValue(
                                    PrefConstants.MERA_USER_ID.toString()) ??
                                '',
                          );
                          if (data?.status == true) {
                            log(
                                SharedPreference.getValue(
                                        PrefConstants.MERA_USER_ID) ??
                                    '',
                                name: 'Delete Account Success');

                            EasyLoading.dismiss();
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.clear();
                            await FirebaseAuth.instance.signOut();
                            if (mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => const OnBoarding()),
                                  (Route<dynamic> route) => false);
                            }
                          }
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      customRow(
                        "About us",
                        const Icon(Icons.info, color: colorBlack),
                        () async {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => const AboutUsScreen()),
                          );
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      customRow(
                        "Privacy policy",
                        const Icon(Icons.privacy_tip, color: colorBlack),
                        () async {
                          launchUrl(Uri.parse(
                              "https://support2heal.com/manage/privacy_policy"));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget customRow(String txt, Icon icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 13, right: 13),
      child: InkWell(
        onTap: () {
          onTap();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorGrey,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: icon,
              ),
            ),

            //   Icon(icon, color: Theme.of(context).textTheme.headline6.color),
            const SizedBox(
              width: 15,
            ),
            Text(
              txt,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: colorBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the button

    Widget okButton = TextButton(
      child: Container(
          color: primaryColor,
          child: const Padding(
            padding: EdgeInsets.fromLTRB(25.0, 5, 25, 5),
            child: Text(
              "OK",
              style: TextStyle(
                color: colorWhite,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          )),
      onPressed: () {
        Navigator.pop(context);
        Scaffold.of(context).openEndDrawer();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
            backgroundColor: Colors.white,
      titlePadding: const EdgeInsets.all(0),
      contentPadding: const EdgeInsets.all(0),
      insetPadding: const EdgeInsets.all(0),
      actionsPadding: const EdgeInsets.all(0),
      buttonPadding: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: double.infinity,
              color: Colors.grey.shade200,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: const [
                    Text("You are Anonymous"),
                  ],
                ),
              )),
        ],
      ),
      content: const Padding(
        padding: EdgeInsets.fromLTRB(14.0, 18, 14, 20),
        child: Text("Dear user,\nYour profile is anonymous to everyone."),
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog

    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
