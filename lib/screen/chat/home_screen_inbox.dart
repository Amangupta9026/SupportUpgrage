import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:support/api/api_services.dart';
import 'package:timeago_flutter/timeago_flutter.dart';

import '../../api/api_constant.dart';
import '../../global/color.dart';
import '../../model/busy_online.dart';
import '../../model/listner/nick_name_get_model.dart';
import '../../model/listner/nick_name_model.dart';
import '../../model/listner_display_model.dart' as listner;
import '../../sharedpreference/sharedpreference.dart';

class HomeScreenInbox extends StatefulWidget {
  final String userId;
  final String userName;
  final String listenerId;
  final String listenerName;
  final listner.Data? listnerDisplayModel;

  const HomeScreenInbox(
      {Key? key,
      required this.listenerId,
      required this.listenerName,
      required this.userId,
      required this.userName,
      this.listnerDisplayModel})
      : super(key: key);

  @override
  HomeScreenInboxState createState() => HomeScreenInboxState();
}

class HomeScreenInboxState extends State<HomeScreenInbox>
    with WidgetsBindingObserver {
  late ScrollController _scrollController;
  final nickNameController = TextEditingController();
  String? docID;
  final TextEditingController _chatController = TextEditingController();
  BusyOnlineModel? busyOnlineModel;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isListener = false;
  DateTime lastTime = DateTime.now().subtract(const Duration(seconds: 60));

  final isHours = true;
  NickNameModel? nickNameModel;
  String? nickName;
  final feedbackController = TextEditingController();
  double ratingStore = 5;
  int? sendvalue;

  checkListener() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isListener = prefs.getBool("isListener")!;
    setState(() {});
  }

  // NickName for Listner Profile

  bool isProgressRunning = false;
  bool isFirstCall = false;

  final DateTime now = DateTime.now();
  final formattedDate = DateFormat('yyyy-MM-dd - kk:mm');
  String walletAmount = "0.0";
  NickNameGETModel? getnickNameModel;

  @override
  void initState() {
    super.initState();
    checkListener();

    // loadProviderData();
    _firestore
        .collection('chatroom')
        .where('user', isEqualTo: widget.userId)
        .where('listener', isEqualTo: widget.listenerId)
        .get()
        .then((value) {
      setState(() {
        docID = value.docs.isNotEmpty ? value.docs.first.id : null;
      });
      checkStatus();
    });

    Future.delayed(Duration.zero, () async {
      String amount = await APIServices.getWalletAmount(
              SharedPreference.getValue(PrefConstants.MERA_USER_ID)) ??
          "0.0";
      setState(() {
        walletAmount = amount;
        SharedPreference.setValue(PrefConstants.WALLET_AMOUNT, walletAmount);
      });
    });

    // : const SizedBox();

    _scrollController = ScrollController();
  }

  @override
  void dispose() async {
    super.dispose();
    _scrollController.dispose();

    feedbackController.dispose();
    _chatController.dispose();
  }

  checkStatus() async {
    var data = await _firestore.collection('chatroom').doc(docID).get();
    if (SharedPreference.getValue(PrefConstants.USER_TYPE) == 'user') {
      // if (data["session"] != null) {
      _firestore.collection('chatroom').doc(docID).update({
        "last_time": FieldValue.serverTimestamp(),
      });
      setState(() {
        lastTime = data["last_time"].toDate();
      });
      // }
    }
  }

  void scrollToBottom() {
    final bottomOffset = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      bottomOffset,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
  }

  Future<void> onSendMessage() async {
    if (_chatController.text != '') {
      Map<String, dynamic> messages = {
        // "isImage": false,
        "sendby": isListener ? widget.listenerName : widget.userName,
        "message": _chatController.text,
        "time": FieldValue.serverTimestamp(),
      };
      if (docID == null) {
        var data = await _firestore.collection('chatroom').add({
          'user': widget.userId,
          'user_name': widget.userName,
          'listener': widget.listenerId,
          'listener_name': widget.listenerName,
          "last_time": FieldValue.serverTimestamp(),
          "listener_count": isListener ? 1 : 0,
          "user_count": isListener ? 0 : 1
        });
        setState(() {
          docID = data.id;
        });
        _firestore
            .collection('chatroom')
            .doc(docID)
            .collection('chats')
            .add(messages);
        // sendNotification(
        //     _chatController.text.trim(), widget.listenerId, widget.userName);
        _chatController.clear();
      } else {
        var data = await _firestore.collection('chatroom').doc(docID).get();
        _firestore
            .collection('chatroom')
            .doc(docID)
            .collection('chats')
            .add(messages);
        _firestore.collection('chatroom').doc(docID).update({
          "last_time": FieldValue.serverTimestamp(),
          "listener_count": isListener ? data["listener_count"] + 1 : 0,
          "user_count": isListener ? 0 : data["user_count"] + 1
        });
        // sendNotification(
        //     _chatController.text.trim(), widget.listenerId, widget.userName);
        _chatController.clear();
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter some message')));
    }
  }

  final StopWatchTimer stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
    onChangeRawMinute: (value) => () {
      log('cut thr price');
    },
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream:
              _firestore.collection('users').doc(widget.listenerId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              return Column(
                children: [
                  Text(isListener
                      ? nickName != null
                          ? nickName.toString()
                          : widget.userName
                      : widget.listenerName),
                ],
                // widget.userName
              );
            } else {
              return Container();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage("assets/images/chat_bg.jpg"))),
          // height: size.height / 1.25,
          width: size.width,
          child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chatroom')
                  .doc(docID)
                  .collection('chats')
                  .orderBy('time', descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  _firestore
                      .collection('chatroom')
                      .doc(docID)
                      .get()
                      .then((value) {
                    _firestore.collection('chatroom').doc(docID).update({
                      "last_time": FieldValue.serverTimestamp(),
                      "listener_count":
                          isListener ? value["listener_count"] : 0,
                      "user_count": isListener ? 0 : value["user_count"]
                    });
                  });

                  return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      itemCount: snapshot.data?.docs.length ?? 0,
                      itemBuilder: (context, index) {
                        if (snapshot.data!.docs[index]['time'] != null &&
                            lastTime.isAfter(
                                DateTime.fromMicrosecondsSinceEpoch((snapshot
                                        .data!.docs[index]['time'] as Timestamp)
                                    .microsecondsSinceEpoch))) {
                          // final displayTime =
                          //     StopWatchTimer.getDisplayTime(
                          //   sendvalue!.toInt(),
                          //   hours: isHours,
                          //   milliSecond: false,
                          // );

                          return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 15.0),
                                  child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    decoration: BoxDecoration(
                                        color: Colors.lightGreen.shade700,
                                        borderRadius:
                                            BorderRadius.circular(25)),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check_circle,
                                            color: Colors.lightGreen),
                                        const SizedBox(width: 5.0),
                                        Text(
                                          //  DateFormat format() ),
                                          "Chat - ${formattedDate.format(DateTime.fromMicrosecondsSinceEpoch((snapshot.data!.docs[index]['time'] as Timestamp).microsecondsSinceEpoch))}",
                                          style: const TextStyle(
                                              color: colorWhite),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ]);
                        }
                        return Container(
                          width: size.width,
                          alignment: isListener
                              ? snapshot.data!.docs[index]['sendby'] ==
                                      widget.listenerName
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft
                              : snapshot.data!.docs[index]['sendby'] ==
                                      widget.userName
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 8,
                                ),
                                margin: const EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: isListener
                                      ? snapshot.data!.docs[index]['sendby'] ==
                                              widget.listenerName
                                          ? Colors.blue
                                          : Colors.green
                                      : snapshot.data!.docs[index]['sendby'] ==
                                              widget.userName
                                          ? Colors.blue
                                          : Colors.green,
                                ),
                                child: Column(
                                  crossAxisAlignment: isListener
                                      ? snapshot.data!.docs[index]['sendby'] ==
                                              widget.listenerName
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start
                                      : snapshot.data!.docs[index]['sendby'] ==
                                              widget.userName
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                  children: [
                                    snapshot.data!.docs[index]['time'] != null
                                        ? isListener
                                            ? Text(
                                                snapshot.data!.docs[index]
                                                    ['message'],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16.0,
                                                ),
                                              )
                                            : Text(
                                                lastTime.isBefore(snapshot.data!
                                                        .docs[index]['time']
                                                        .toDate())
                                                    ? snapshot.data!.docs[index]
                                                        ['message']
                                                    : "",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16.0,
                                                ),
                                              )
                                        : const SizedBox.shrink(),
                                    const SizedBox(height: 4),
                                    Timeago(
                                      date: snapshot.data!.docs[index]
                                                  ['time'] ==
                                              null
                                          ? DateTime.now()
                                          : snapshot.data!.docs[index]['time']
                                              .toDate(),
                                      builder:
                                          (BuildContext context, String value) {
                                        return Text(
                                          value,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.0,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                        // Text(
                        //     snapshot.data!.docs[index]['message']);
                      });
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return Container();
                }
              }),
        ),
      ),
    );
  }
}
