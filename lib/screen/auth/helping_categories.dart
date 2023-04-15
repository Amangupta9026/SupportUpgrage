// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support/global/color.dart';
import 'package:support/screen/home/home_screen.dart';

import '../../api/api_constant.dart';
import '../../api/api_services.dart';
import '../../model/register_model.dart';

import '../../sharedpreference/sharedpreference.dart';
import '../listner_app_ui/listner_homescreen.dart';

// bool isListener = false;

class TopicCategories {
  String topicName;
  String topicDescription;
  bool isSelected;
  TopicCategories(
      {required this.topicName,
      required this.topicDescription,
      required this.isSelected});
}

class HelperCategories extends StatefulWidget {
  final String? mobileNumber;
  const HelperCategories({Key? key, this.mobileNumber}) : super(key: key);

  @override
  State<HelperCategories> createState() => _HelperCategoriesState();
}

class _HelperCategoriesState extends State<HelperCategories> {
  FirebaseMessaging? firebaseMessaging;
  String? selectedTopic;
  String? selectHelping;
  List<TopicCategories> topicCategories = [
    TopicCategories(
      topicName: "Anger issues",
      topicDescription:
          "Unable to control your anger, feeling restless and helpless",
      isSelected: false,
    ),
    TopicCategories(
      topicName: "Addiction and gambling",
      topicDescription:
          "Not able to quit, facing dullness and sleep issues, not able to focus anywhere",
      isSelected: false,
    ),
    TopicCategories(
      topicName: "Breakup",
      topicDescription:
          "Unable to deal the separation, feeling stuck, blaming yourself",
      isSelected: false,
    ),
    TopicCategories(
      topicName: "Educational and financial Stress",
      topicDescription:
          "failure in competitive exams, poor concentration in studies, lack of management in finances",
      isSelected: false,
    ),
    TopicCategories(
      topicName: "Health and grief",
      topicDescription:
          "Feeling anxious over health issues, loss opportunities, loss of near and dear ones",
      isSelected: false,
    ),
    TopicCategories(
      topicName: "Loneliness",
      topicDescription:
          "missing a loved one, need someone to talk to, not able to open up with the feelings",
      isSelected: false,
    ),
    TopicCategories(
      topicName: "Marriage and relationships",
      topicDescription:
          "Feeling cheated, regular arguments and fights, facing criticism, unable to take the decision over a dominant partner",
      isSelected: false,
    ),
    TopicCategories(
      topicName: "Parents and family issues",
      topicDescription:
          "Conflicts in life decisions, not able to maintain a healthy relations, poor adjustments",
      isSelected: false,
    ),
    TopicCategories(
      topicName: "Spirituality",
      topicDescription:
          "Feeling abandoned, questioning beliefs or sudden doubts, finding purpose or meaning in life",
      isSelected: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: const Size.fromWidth(120),
              ),
              onPressed: () async {
                EasyLoading.show(status: 'loading...');
                String? token = await FirebaseMessaging.instance.getToken();

                RegistrationModel registerModel = await APIServices.registerAPI(
                  widget.mobileNumber.toString(),
                  selectedTopic.toString(),
                  token.toString(),
                );

                if (registerModel.status == true) {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString("userId", registerModel.data!.id.toString());
                  prefs.setString("userName", registerModel.data!.name!);

                  SharedPreference.setValue(PrefConstants.MOBILE_NUMBER,
                      registerModel.data?.mobileNo.toString());
                  SharedPreference.setValue(PrefConstants.MERA_USER_ID,
                      registerModel.data?.id.toString());
                  SharedPreference.setValue(PrefConstants.USER_TYPE,
                      registerModel.data?.userType.toString());

                  SharedPreference.setValue(PrefConstants.LISTENER_NAME,
                      registerModel.data?.name.toString());

                  SharedPreference.setValue(PrefConstants.LISTENER_IMAGE,
                      registerModel.data?.image.toString());
                  SharedPreference.setValue(PrefConstants.ONLINE,
                      registerModel.data?.onlineStatus == 1 ? true : false);

                  EasyLoading.dismiss();

                  if (registerModel.data?.userType == 'user') {
                    // if (!isListener) {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setBool("isListener", false);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  } else {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setBool("isListener", true);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ListnerHomeScreen(),
                      ),
                    );
                   
                  }
                } else {
                  //  EasyLoading.dismiss();
                  //  UtilsFlushBar.showDefaultSnackbar(
                  //     context, "Something went wrong, please try again");
                  log("Register API failed");
                }
              },
              child: const Text("Submit"),
            ),
            const SizedBox(
              height: 20,
            )
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16, 16, 100),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "What is bothering you lately?",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Please select one of the topic from below",
                    style: TextStyle(color: Colors.black),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  for (int i = 0; i < topicCategories.length; i++) ...{
                    InkWell(
                      highlightColor: backgroundColor,
                      onTap: () {
                        if (mounted) {
                          setState(() {
                            topicCategories[i].isSelected =
                                !topicCategories[i].isSelected;
                            selectedTopic = topicCategories[i].topicName;
                          });
                        }
                        for (int j = 0; j < topicCategories.length; j++) {
                          if (i != j) {
                            topicCategories[j].isSelected = false;
                          }
                        }
                      },
                      child: Column(
                        children: [
                          Card(
                            color: topicCategories[i].isSelected
                                ? primaryColor
                                : Colors.white,
                            elevation: topicCategories[i].isSelected ? 10 : 2,
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(11.0, 14, 11, 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    topicCategories[i].topicName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: topicCategories[i].isSelected
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    topicCategories[i].topicDescription,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: topicCategories[i].isSelected
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  }
                ],
              ),
            ),
          ),
        ));
  }
}
