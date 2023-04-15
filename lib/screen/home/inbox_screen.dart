import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago_flutter/timeago_flutter.dart';

import '../../api/api_constant.dart';
import '../../api/api_services.dart';
import '../../model/support_chat_model.dart';
import '../../sharedpreference/sharedpreference.dart';
import '../chat/home_screen_inbox.dart';
import '../support_chat/support_chat.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({Key? key}) : super(key: key);

  @override
  InboxScreenState createState() => InboxScreenState();
}

class InboxScreenState extends State<InboxScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // late QuerySnapshot<Map<String, dynamic>> chats;

  bool _loading = false;
  String id = "";
  String name = "";
  bool isListener = false;

  String walletAmount = "0.0";
  bool isProgressingRunning = false;
  bool isProgressRunning = false;
  SupportChatModel? supportChatModel;
  int chatCount = 0;

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    id = prefs.getString("userId")!;
    name = prefs.getString("userName")!;
    isListener = prefs.getBool("isListener")!;

    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loading = true;
    loadData();
    apiSupportChat();
  }

  // Support Chat
  Future<void> apiSupportChat() async {
    try {
      setState(() {
        isProgressRunning = true;
      });

      supportChatModel = await APIServices.getSupportChatAPI('730');
      // SharedPreference.getValue(PrefConstants.MERA_USER_ID));
      if (supportChatModel!.allMessages!.isNotEmpty &&
          supportChatModel?.allMessages?[0].id != null) {
        for (int i = 0; i < supportChatModel!.allMessages!.length; i++) {
          if (supportChatModel?.allMessages?[i].id != null) {
            await apiMessageRead(supportChatModel?.allMessages?[i].id);
          }
          setState(() {
            chatCount = supportChatModel!.allMessages!.length;
          });
        }
      }
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

  // Message Read
  Future<void> apiMessageRead(int? messageId) async {
    try {
      setState(() {
        isProgressRunning = true;
      });

      await APIServices.getSupportMessageReadAPI(messageId ?? 1);
    } catch (e) {
      log(e.toString());
    } finally {
      setState(() {
        isProgressRunning = false;
      });
    }
  }

  Future<void> apiWallet() async {
    try {
      setState(() {
        isProgressingRunning = true;
      });
      String amount = await APIServices.getWalletAmount(
              SharedPreference.getValue(PrefConstants.MERA_USER_ID)) ??
          "0.0";
      setState(() {
        walletAmount = amount;
        SharedPreference.setValue(PrefConstants.WALLET_AMOUNT, walletAmount);
      });
    } catch (e) {
      log(e.toString());
    } finally {
      setState(() {
        isProgressingRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: 25),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.shade300,
                          spreadRadius: 5,
                          blurRadius: 5)
                    ],
                    color: Colors.white),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SupportChat()),
                    );
                  },
                  title: const Text('Support'),
                  subtitle: supportChatModel?.unreadMessages != 0
                      ? const Text(
                          'You have a new message',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : const SizedBox(),
                  leading: Image.asset(
                    "assets/logo.png",
                    // width: 100,
                    height: 80,
                  ),
                  trailing: Visibility(
                    visible:
                        supportChatModel?.unreadMessages != 0 ? false : true,
                    child: Container(
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade500,
                          blurRadius: 10.0,
                        ),
                      ], shape: BoxShape.circle, color: Colors.green),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          supportChatModel?.unreadMessages.toString() ?? "0",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chatroom')
                    .where('user', isEqualTo: id)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    var chats = snapshot.data!.docs;
                    return Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: ListView.builder(
                          // restorationId: 'inbox_list',
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: chats.length,
                          itemBuilder: (context, index) {
                            var item = chats[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey.shade300,
                                        spreadRadius: 5,
                                        blurRadius: 5)
                                  ],
                                  color: Colors.white),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomeScreenInbox(
                                                listenerId: item['listener'],
                                                listenerName:
                                                    item['listener_name'],
                                                userId: id,
                                                userName: name,
                                              )));
                                  // }
                                },
                                title: Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: Text(item['listener_name']),
                                ),
                                subtitle: item["listener_count"] > 0
                                    ? const Padding(
                                        padding: EdgeInsets.only(left: 15.0),
                                        child: Text(
                                          'You have a new message',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      )
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(left: 15.0),
                                        child: Timeago(
                                          date: item["last_time"] == null
                                              ? DateTime.now()
                                              : item["last_time"].toDate(),
                                          builder: (BuildContext context,
                                              String value) {
                                            return Text(
                                              value,
                                              style: const TextStyle(
                                                fontSize: 12.0,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                leading: item["listener_photo"] == null ||
                                        item["listener_photo"] == ""
                                    ? const Icon(Icons.account_circle, size: 40)
                                    : CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            "${APIConstants.BASE_URL}${item["listener_photo"]}"),
                                      ),
                                trailing: Visibility(
                                  visible: item["listener_count"] > 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.shade500,
                                            blurRadius: 10.0,
                                          ),
                                        ],
                                        shape: BoxShape.circle,
                                        color: Colors.green),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        isListener
                                            ? item["user_count"].toString()
                                            : item["listener_count"].toString(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                    );
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Container();
                  }
                },
              )
            ]),
          );
  }
}
