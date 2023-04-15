import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago_flutter/timeago_flutter.dart';

import '../../api/api_services.dart';
import '../../model/listner/listner_chat_request_model.dart';
import '../../model/listner/nick_name_get_model.dart';
import '../chat/chat_screen_2.dart';

class ListnerInboxScreen extends StatefulWidget {
  const ListnerInboxScreen({Key? key}) : super(key: key);

  @override
  ListnerInboxScreenState createState() => ListnerInboxScreenState();
}

class ListnerInboxScreenState extends State<ListnerInboxScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // late QuerySnapshot<Map<String, dynamic>> chats;

  bool _loading = false;
  String id = "";
  String name = "";
  bool isListener = false;
  bool isProgressRunning = false;
  NickNameGETModel getnickNameModel = NickNameGETModel();
  ListnerChatRequest? getListnerRequest = ListnerChatRequest();
  bool isFirstCall = true;
  Timer? _timer;
  bool ispopupVisible = false;

  final audioPlayer = AudioPlayer();

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    id = prefs.getString("userId")!;
    name = prefs.getString("userName")!;
    isListener = prefs.getBool("isListener")!;

    // _firestore
    //     .collection('chatroom')
    //     .where('listener', isEqualTo: id)
    //     .get()
    //     .then((value) {
    setState(() {
      _loading = false;
      // chats = value;
    });
    // APIServices.postBusyNow('false');

    // });
  }

  @override
  void initState() {
    super.initState();
    _loading = true;
    loadData();
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
    _timer?.cancel();
  }

  Future<NickNameGETModel> apigetNickName() async {
    try {
      getnickNameModel = await APIServices.displayNickName();
    } catch (e) {
      log(e.toString());
    } finally {}
    return getnickNameModel;
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('chatroom')
                .where('listener', isEqualTo: id)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                var chats = snapshot.data!.docs;
                return Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: ListView.builder(
                      itemCount: chats.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        String nickname = 'Anonymous';
                        var item = chats[index];

                        return FutureBuilder<NickNameGETModel?>(
                            future: apigetNickName(),
                            builder: (context, snapshot2) {
                              if (snapshot2.data == null) {
                                return const Center(child: SizedBox());
                              }

                              if (snapshot2.data?.status == true &&
                                  snapshot2.data?.data != null) {
                                for (int i = 0;
                                    i < snapshot2.data!.data!.length;
                                    i++) {
                                  if (snapshot2.data!.data?[i].toId ==
                                      item['user']) {
                                    nickname = snapshot2.data!.data?[i].nickname
                                            .toString() ??
                                        'Anonymous';
                                  } else {
                                    log('not match');
                                  }
                                }
                              }
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
                                  key: UniqueKey(),
                                  onTap: () {
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ChatRoomScreen(
                                                  listenerId: id,
                                                  listenerName: name,
                                                  userId: item['user'],
                                                  userName: nickname,
                                                  isTextFieldVisible: false,
                                                  isfromListnerInbox: true,
                                                  // item['user_name'],
                                                )),
                                        (Route<dynamic> route) => false);
                                  },
                                  title: Text(nickname),
                                  subtitle: item["user_count"] > 0
                                      ? const Text(
                                          'You have a new message',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )
                                      : Timeago(
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
                                  leading: const Icon(Icons.account_circle,
                                      size: 42.0),
                                  trailing: Visibility(
                                    visible: item["user_count"] > 0,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.green),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          isListener
                                              ? item["user_count"].toString()
                                              : item["listener_count"]
                                                  .toString(),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            });
                      }),
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return Container();
              }
            });
  }
}
