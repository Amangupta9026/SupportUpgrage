import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:support/api/api_services.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:timeago_flutter/timeago_flutter.dart';

import '../../api/api_constant.dart';
import '../../global/color.dart';
import '../../global/utils.dart';
import '../../model/busy_online.dart';
import '../../model/charge_wallet_model.dart';
import '../../model/get_chat_end.dart';
import '../../model/get_chat_end_model.dart';
import '../../model/listner/block_user_model.dart';
import '../../model/listner/nick_name_model.dart';
import '../../model/listner_display_model.dart' as listner;
import '../../model/report_model.dart';
import '../../model/send_chat_id.dart';
import '../../sharedpreference/sharedpreference.dart';
import '../../widget/toast_widget.dart';
import '../listner_app_ui/listner_homescreen.dart';
import '../wallet/wallet_screen.dart';
import 'feedback_screen.dart';
import 'reply_message_widget.dart';

class ChatRoomScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String listenerId;
  final String listenerName;
  final listner.Data? listnerDisplayModel;
  final bool? isTextFieldVisible;
  final int? chatId;
  final bool isfromListnerInbox;

  const ChatRoomScreen(
      {Key? key,
      required this.listenerId,
      required this.listenerName,
      required this.userId,
      required this.userName,
      this.listnerDisplayModel,
      this.isTextFieldVisible,
      this.isfromListnerInbox = false,
      this.chatId})
      : super(key: key);

  @override
  ChatRoomScreenState createState() => ChatRoomScreenState();
}

class ChatRoomScreenState extends State<ChatRoomScreen>
    with WidgetsBindingObserver {
  late ScrollController _scrollController;
  final nickNameController = TextEditingController();
  String? docID;
  final TextEditingController _chatController = TextEditingController();
  BusyOnlineModel? busyOnlineModel;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isListener = SharedPreference.getValue("isListener");
  DateTime lastTime = DateTime.now().subtract(const Duration(seconds: 60));
  final sessionId = getRandomString(16);

  final isHours = true;
  NickNameModel? nickNameModel;
  String? nickName;

  int? sendvalue;
  String? replyMessage, replyName, replyTime;
  String chatDocId = '';
  String attherate = '@';
  String hash = '#';
  String dotCom = '.com';

  // Future<void> secureScreen() async {
  //   await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  // }

  // NickName for Listner Profile

  bool isProgressRunning = false;
  bool isFirstCall = false;

  final DateTime now = DateTime.now();
  final formattedDate = DateFormat('yyyy-MM-dd - kk:mm');
  String walletAmount = "0.0";

  int? getchatId;
  SendChatIDModel? chatIdModel;
  APIGetChatEndModel? getChatEndModel = APIGetChatEndModel();
  Timer? _timer;
  int? chatIdAssignToListener;

  void amountKaatLo(value) async {
    if (!isFirstCall) {
      isFirstCall = true;
      return;
    }
    String amount = SharedPreference.getValue(PrefConstants.WALLET_AMOUNT);
    if (double.tryParse(amount)! <= 5.0) {
      // await stopWatchTimer.dispose();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        EasyLoading.showInfo('Balance is Low, recharge your wallet');
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const WalletScreen()));
      });
      return;
    }
    int addminute = 1;

    ChargeWalletModel chargeWalletModel =
        await APIServices.chargeWalletDeductionApi(
            SharedPreference.getValue(PrefConstants.MERA_USER_ID),
            widget.listenerId,
            addminute.toString(),
            'Chat',
            sessionId);
    // ignore: unrelated_type_equality_checks
    if (chargeWalletModel.status == true) {
      SharedPreference.setValue(PrefConstants.WALLET_AMOUNT,
          chargeWalletModel.remaningWallet!.walletAmount.toString());
      if (double.tryParse(
              chargeWalletModel.remaningWallet!.walletAmount.toString())! <=
          5.0) {
        // await stopWatchTimer.dispose();
        EasyLoading.showInfo('Balance is Low, recharge your wallet');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const WalletScreen()));
        });
      } else {
        // await stopWatchTimer.dispose();
      }

      // showFeedBackDialog(context);
    } else {
      // EasyLoading.dismiss();
      if (!mounted) return;
      toastshowDefaultSnackbar(context, 'Something went wrong');
    }
  }

  // Online Busy Display API

  Future<void> apiOnlineBusy() async {
    try {
      setState(() {
        isProgressRunning = true;
      });
      busyOnlineModel = await APIServices.getBusyOnline(
        'true',
        SharedPreference.getValue(PrefConstants.MERA_USER_ID),
      );
    } catch (e) {
      log(e.toString());
    } finally {
      setState(() {
        isProgressRunning = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // log('resumed');
      _firestore
          .collection('chatroom')
          .doc(docID)
          .collection('chats')
          .where('user_type', isEqualTo: isListener ? 'user' : 'listener')
          .get()
          .then((value) {
        // ignore: avoid_function_literals_in_foreach_calls
        value.docs.forEach((element) {
          element.reference.update({'is_seen': true});
        });
      });
      // set status online
      if (!isListener) {
        _firestore
            .collection('chatroom')
            .doc(docID)
            .update({'is_user_online': true});
      } else {
        _firestore
            .collection('chatroom')
            .doc(docID)
            .update({'is_listner_online': true});
      }
    } else if (state == AppLifecycleState.inactive) {
      // log('inactive');
      if (!isListener) {
        _firestore
            .collection('chatroom')
            .doc(docID)
            .update({'is_user_online': false});
      } else {
        _firestore
            .collection('chatroom')
            .doc(docID)
            .update({'is_listner_online': false});
      }
    } else if (state == AppLifecycleState.paused) {
      // log('paused');
      if (!isListener) {
        _firestore
            .collection('chatroom')
            .doc(docID)
            .update({'is_user_online': false});
      } else {
        _firestore
            .collection('chatroom')
            .doc(docID)
            .update({'is_listner_online': false});
      }
    } else if (state == AppLifecycleState.detached) {
      log('detached');
      _firestore
          .collection('chatroom')
          .doc(docID)
          .update({'is_user_online': false});
      _firestore
          .collection('chatroom')
          .doc(docID)
          .update({'is_listner_online': false});
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  void initState() {
    log(widget.userName, name: 'userName');
    // secureScreen();  // not taking screenshot
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.isfromListnerInbox == false ? apiOnlineBusy() : const SizedBox();
    // apiOnlineBusy();

    _timer = Timer.periodic(
        const Duration(seconds: 5),
        (Timer t) => WidgetsBinding.instance.addPostFrameCallback((_) {
              apigetChatEndAPI();
            }));

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

      // is Seen
      if (docID != null) {
        _firestore
            .collection('chatroom')
            .doc(docID)
            .collection('chats')
            .where('user_type', isEqualTo: isListener ? 'user' : 'listener')
            .get()
            .then((value) {
          // ignore: avoid_function_literals_in_foreach_calls
          value.docs.forEach((element) {
            element.reference.update({'is_seen': true});
          });
        });
        // set status online
        if (isListener) {
          _firestore.collection('chatroom').doc(docID).update({
            'is_listner_online': true,
            'is_user_typing': false,
            'is_listner_typing': false
          });
        } else {
          _firestore.collection('chatroom').doc(docID).update({
            'is_user_online': true,
            'is_user_typing': false,
            'is_listner_typing': false
          });
        }
      }

      checkStatus();

      //Uncomwent

      stopWatchTimer.onExecute.add(StopWatchExecute.start);
      !isListener ? stopWatchTimer.minuteTime.listen(amountKaatLo) : null;
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

    _scrollController = ScrollController();
  }

  void getchatIdRoomId() {
    SharedPreference.getValue(PrefConstants.USER_TYPE) == 'user'
        ? chatId()
        : const SizedBox();
  }

  Future<SendChatIDModel?> chatId() async {
    try {
      if (SharedPreference.getValue(PrefConstants.USER_TYPE) == 'user') {
        chatIdModel = await APIServices.sendChatIDAPI(
          widget.userId,
          widget.listenerId,
          docID ?? '0',
        );
      }
    } catch (e) {
      log(e.toString());
    }
    return chatIdModel;
  }

  // GetChat Listner Side API

  Future<GetChatEndModel?> apigetChatEndAPI() async {
    try {
      if (SharedPreference.getValue(PrefConstants.USER_TYPE) == 'user') {
        getChatEndModel = await APIServices.getChatIdListnerSideAPI(
            SharedPreference.getValue(PrefConstants.MERA_USER_ID), 'user');
        if (getChatEndModel?.data != null) {
          if (getChatEndModel?.data?.status == 'end') {
            await stopWatchTimer.dispose();
            // _timer?.cancel();
            await APIServices.getBusyOnline(
              'false',
              SharedPreference.getValue(PrefConstants.MERA_USER_ID),
            );

            if (mounted) {
              _timer?.cancel();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) =>
                      FeedbackScreen(listenerId: widget.listenerId)));
              Fluttertoast.showToast(msg: 'Chat End');
            }
          }
        }
      } else {
        getChatEndModel = await APIServices.getChatIdListnerSideAPI(
            SharedPreference.getValue(PrefConstants.MERA_USER_ID), 'listener');
        if (getChatEndModel?.data != null) {
          // _timer?.cancel();
          chatIdAssignToListener = getChatEndModel?.data?.id;

          if (getChatEndModel?.data?.status == 'end') {
            await stopWatchTimer.dispose();
            // _timer?.cancel();
            await APIServices.getBusyOnline(
              'false',
              SharedPreference.getValue(PrefConstants.MERA_USER_ID),
            );

            if (mounted) {
              _timer?.cancel();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const ListnerHomeScreen()));
              Fluttertoast.showToast(msg: 'Chat End');
            }
          }
        }
      }
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  @override
  void dispose() async {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _scrollController.dispose();
    await stopWatchTimer.dispose();
    _chatController.dispose();
    nickNameController.dispose();
    super.dispose();
  }

  checkStatus() async {
    var data = await _firestore.collection('chatroom').doc(docID).get();
  }

  void scrollToBottom() {
    final bottomOffset = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      bottomOffset,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
  }

  //Change typing status
  void changeTypingStatus(bool isTyping) async {
    if (docID == null) {
      return;
    }

    if (isListener) {
      _firestore
          .collection('chatroom')
          .doc(docID)
          .update({"is_listner_typing": isTyping});
    } else {
      _firestore
          .collection('chatroom')
          .doc(docID)
          .update({"is_user_typing": isTyping});
    }
  }

  Future<void> onSendMessage(String id) async {
    if (_chatController.text.trim().isNotEmpty) {
      final chatRoomDetails =
          await _firestore.collection('chatroom').doc(docID).get();
      Map<String, dynamic> messages = {
        // "isImage": false,
        "sendby": isListener ? widget.listenerName : widget.userName,
        "message": _chatController.text,
        "time": FieldValue.serverTimestamp(),
        "is_seen": isListener && chatRoomDetails["is_user_online"]
            ? true
            : !isListener && chatRoomDetails["is_listner_online"]
                ? true
                : false,
        "user_type": isListener ? "listener" : "user",
        "replyId": replyMessage != null ? id : ""
      };
      if (docID == null) {
        var data = await _firestore.collection('chatroom').add({
          'user': widget.userId,
          'user_name': widget.userName,
          'listener': widget.listenerId,
          'listener_name': widget.listenerName,
          "last_time": FieldValue.serverTimestamp(),
          "listener_count": isListener ? 1 : 0,
          "user_count": isListener ? 0 : 1,
          "listener_photo": widget.listnerDisplayModel?.image ?? "",
          "is_user_typing": false,
          "is_listner_typing": false,
          "is_user_online": !isListener,
          "is_listner_online": isListener,
        });
        setState(() {
          docID = data.id;
        });
        APIServices.sendChatIDAPI(
          widget.userId,
          widget.listenerId,
          data.id,
        );

        _firestore
            .collection('chatroom')
            .doc(docID)
            .collection('chats')
            .add(messages);

        // sendNotification(
        //     _chatController.text.trim(), widget.listenerId, widget.userName);
        _chatController.clear();
        cancelReply();
      } else {
        var data = await _firestore.collection('chatroom').doc(docID).get();

        await _firestore
            .collection('chatroom')
            .doc(docID)
            .collection('chats')
            .add(messages);
        await _firestore.collection('chatroom').doc(docID).update({
          "last_time": FieldValue.serverTimestamp(),
          "listener_count": isListener ? data["listener_count"] + 1 : 0,
          "user_count": isListener ? 0 : data["user_count"] + 1,
          if (!isListener)
            if (data["listener_photo"] != widget.listnerDisplayModel?.image)
              "listener_photo": widget.listnerDisplayModel?.image ?? "",
        });

        // sendNotification(
        //     _chatController.text.trim(), widget.listenerId, widget.userName);
      }
      await _firestore
          .collection('chatroom')
          .doc(docID)
          .get()
          .then((value) async {
        if (value["is_user_online"]) {
          log(
            "Send Message is user online is ${value["is_user_online"].toString()}",
          );
          await _firestore
              .collection('chatroom')
              .doc(docID)
              .collection('chats')
              .where('user_type', isEqualTo: isListener ? 'user' : 'listener')
              .where("is_seen", isEqualTo: false)
              .get()
              .then((value) {
            log(
              "Send Message something is updating",
            );
            // ignore: avoid_function_literals_in_foreach_calls
            value.docs.forEach((element) async {
              log(
                "Send Message something is updating 2",
              );
              await _firestore
                  .collection('chatroom')
                  .doc(docID)
                  .collection('chats')
                  .doc(element.id)
                  .update({"is_seen": true});
            });
          });
        }
        if (value["is_listner_online"]) {
          await _firestore
              .collection('chatroom')
              .doc(docID)
              .collection('chats')
              .where('user_type', isEqualTo: isListener ? 'user' : 'listener')
              .where("is_seen", isEqualTo: false)
              .get()
              .then((value) {
            // ignore: avoid_function_literals_in_foreach_calls
            value.docs.forEach((element) async {
              await _firestore
                  .collection('chatroom')
                  .doc(docID)
                  .collection('chats')
                  .doc(element.id)
                  .update({"is_seen": true});
            });
          });
        }
      });
      _chatController.clear();
      cancelReply();
      // If user is listner then update seen property of message for listner is true only if user is online
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter some message')));
    }
  }

  onChatPushNotify() async {
    if (widget.listnerDisplayModel?.deviceToken != null) {
      EasyLoading.show(
          status: "Connecting with our secure server",
          maskType: EasyLoadingMaskType.clear);
      // var data = await APIServices.getAgoraTokens();
      EasyLoading.dismiss();
      APIServices.sendChatNotification(
        deviceToken: widget.listnerDisplayModel!.deviceToken!,
        senderName: isListener ? widget.userName : widget.listenerName,
        // cId: 'support1', cTn: 'support1', uid: widget.listenerId
      );
    }
    // else {
    // EasyLoading.showError("User not available");
    // }
  }

  final StopWatchTimer stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
    onChangeRawMinute: (value) => () {},
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (widget.isfromListnerInbox == true) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ListnerHomeScreen()),
          );
          // Navigator.of(context).pushAndRemoveUntil(
          //     MaterialPageRoute(builder: (context) => const ListnerHomeScreen()),
          //     (Route<dynamic> route) => false);

          return true;
        } else {
          await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: const Text('Are you sure?'),
                content: const Text('You want to close this session?'),
                actions: [
                  if (isListener) ...{
                    ElevatedButton(
                        onPressed: () async {
                          _firestore
                              .collection('chatroom')
                              .doc(docID)
                              .update({'is_listner_online': false});

                          changeTypingStatus(false);
                          // int getidincrease = getchatId! + 1;

                          EasyLoading.show(status: 'loading...');

                          await stopWatchTimer.dispose();
                          await APIServices.getBusyOnline(
                            'false',
                            SharedPreference.getValue(
                                PrefConstants.MERA_USER_ID),
                          );
                          // _timer?.cancel();

                          GetChatEndModel? getChatEndModel =
                              await APIServices.chatEndAPI(
                                  chatIdAssignToListener ?? 0);

                          if (getChatEndModel?.status == true) {
                            // _timer?.cancel();
                            EasyLoading.dismiss();

                            if (mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ListnerHomeScreen()),
                                  (Route<dynamic> route) => false);
                            }
                          }
                        },
                        child: const Text(
                          'Yes',
                        )),
                    ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'No, Continue',
                        )),
                  } else ...{
                    ElevatedButton(
                        onPressed: () async {
                          _firestore
                              .collection('chatroom')
                              .doc(docID)
                              .update({'is_user_online': false});
                          changeTypingStatus(false);

                          EasyLoading.show(status: 'loading...');

                          await stopWatchTimer.dispose();
                          await APIServices.getBusyOnline(
                            'false',
                            SharedPreference.getValue(
                                PrefConstants.MERA_USER_ID),
                          );
                          // _timer?.cancel();

                          GetChatEndModel? getChatEndModel =
                              await APIServices.chatEndAPI(widget.chatId ?? 0);

                          if (getChatEndModel?.status == true) {
                            // _timer?.cancel();
                            // Navigator.pop(context);
                            EasyLoading.dismiss();
                            if (mounted) {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => FeedbackScreen(
                                          listenerId: widget.listenerId)));
                            }
                          }
                        },
                        child: const Text(
                          'Yes',
                        )),
                    ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'No, Continue',
                        )),
                  }
                ],
              );
            },
          );
        }

        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const SizedBox(),
          leadingWidth: 15,
          title: Column(
            children: [
              Text(isListener
                  ? nickName != null
                      ? nickName.toString()
                      : widget.userName
                  : widget.listenerName),
              const SizedBox(height: 3),
              StreamBuilder(
                  // isTyping
                  stream: FirebaseFirestore.instance
                      .collection('chatroom')
                      .doc(docID)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var data = snapshot.data as DocumentSnapshot;
                      if (data.exists) {
                        if (isListener) {
                          if (data['is_user_typing']) {
                            return const Text("typing....");
                          }
                        } else {
                          if (data['is_listner_typing']) {
                            return const Text("typing....");
                          }
                        }
                      }
                    }
                    return const SizedBox();
                  }),
            ],
          ),
          actions: [
            Visibility(
              visible: !isListener,
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: StreamBuilder<int>(
                  stream: stopWatchTimer.rawTime,
                  initialData: stopWatchTimer.rawTime.value,
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const SizedBox();
                    }
                    final value = snap.data!;
                    sendvalue = snap.data!;
                    final displayTime = StopWatchTimer.getDisplayTime(
                      value,
                      hours: isHours,
                      milliSecond: false,
                    );
                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        displayTime,
                        style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Helvetica',
                            fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      showReportDialog(context);
                    },
                    child: Visibility(
                        visible: isListener,
                        child: const Center(
                            child: Text(
                          'Report and Block',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ))),
                  ),
                  const SizedBox(width: 15),
                  InkWell(
                    onTap: () {
                      showAlertDialog(context);
                    },
                    child: Visibility(
                        visible: isListener,
                        child: const Center(
                            child: Text(
                          'Add Nick Name',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ))),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
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
                            _firestore
                                .collection('chatroom')
                                .doc(docID)
                                .update({
                              "last_time": FieldValue.serverTimestamp(),
                              "listener_count":
                                  isListener ? value["listener_count"] : 0,
                              "user_count": isListener ? 0 : value["user_count"]
                            });
                          });

                          return ListView.builder(
                              controller: _scrollController,
                              reverse: true,
                              shrinkWrap: true,
                              itemCount: snapshot.data?.docs.length ?? 0,
                              itemBuilder: (context, index) {
                                if (snapshot.data!.docs[index]['time'] !=
                                        null &&
                                    lastTime.isAfter(
                                        DateTime.fromMicrosecondsSinceEpoch(
                                            (snapshot.data!.docs[index]['time']
                                                    as Timestamp)
                                                .microsecondsSinceEpoch))) {
                                  final displayTime =
                                      StopWatchTimer.getDisplayTime(
                                          sendvalue?.toInt() ?? 0,
                                          hours: false,
                                          second: false,
                                          minute: true,
                                          milliSecond: false,
                                          secondRightBreak: '..');
                                  int minutess = int.parse(displayTime);
                                  int addminute = minutess + 1;
                                  log(addminute.toString());

                                  // final displayTime =
                                  //     StopWatchTimer.getDisplayTime(
                                  //   sendvalue!.toInt(),
                                  //   hours: isHours,
                                  //   milliSecond: false,
                                  // );

                                  return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 15.0),
                                          child: Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 5, 10, 5),
                                            decoration: BoxDecoration(
                                                color:
                                                    Colors.lightGreen.shade700,
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
                                return SwipeTo(
                                  key: ValueKey(snapshot.data!.docs[index].id),
                                  onLeftSwipe: () {
                                    // Each message reply bu sendwr name

                                    setState(() {
                                      replyMessage =
                                          snapshot.data!.docs[index]['message'];
                                      chatDocId = snapshot.data!.docs[index].id;
                                      replyName =
                                          snapshot.data!.docs[index]['sendby'];
                                      // replyTime = snapshot
                                      //     .data!.docs[index]['time']
                                      //     .toString();
                                    });
                                  },
                                  child: Container(
                                    key:
                                        ValueKey(snapshot.data!.docs[index].id),
                                    width: size.width,
                                    alignment: isListener
                                        ? snapshot.data!.docs[index]
                                                    ['sendby'] ==
                                                widget.listenerName
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft
                                        : snapshot.data!.docs[index]
                                                    ['sendby'] ==
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
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: isListener
                                                  ? snapshot.data!.docs[index]
                                                              ['sendby'] ==
                                                          widget.listenerName
                                                      ? Colors.blue
                                                      : Colors.green
                                                  : snapshot.data!.docs[index]
                                                              ['sendby'] ==
                                                          widget.userName
                                                      ? const Color(0xff23408e)
                                                      : Colors.grey
                                                          .withOpacity(0.8)),
                                          child: Column(
                                            crossAxisAlignment: isListener
                                                ? snapshot.data!.docs[index]
                                                            ['sendby'] ==
                                                        widget.listenerName
                                                    ? CrossAxisAlignment.end
                                                    : CrossAxisAlignment.start
                                                : snapshot.data!.docs[index]
                                                            ['sendby'] ==
                                                        widget.userName
                                                    ? CrossAxisAlignment.end
                                                    : CrossAxisAlignment.start,
                                            children: [
                                              snapshot.data!.docs[index]
                                                          ['replyId'] !=
                                                      ''
                                                  ? StreamBuilder(
                                                      stream: FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'chatroom')
                                                          .doc(docID)
                                                          .collection('chats')
                                                          .doc(snapshot.data!
                                                                  .docs[index]
                                                              ['replyId'])
                                                          .snapshots(),
                                                      // .snapshots(),
                                                      builder: (context,
                                                          AsyncSnapshot<
                                                                  DocumentSnapshot>
                                                              snapshot2) {
                                                        if (snapshot.hasData) {
                                                          final senderReplyName = snapshot
                                                                          .data!
                                                                          .docs[index]
                                                                      [
                                                                      'sendby'] ==
                                                                  widget
                                                                      .listenerName
                                                              ? widget
                                                                  .listenerName
                                                              : 'Anonymous';
                                                          return ReplyMessageWidget(
                                                              message: snapshot2
                                                                          .data?[
                                                                      'message'] ??
                                                                  '',
                                                              senderName:
                                                                  senderReplyName,
                                                              textColor: true,
                                                              chatDocId: snapshot
                                                                          .data!
                                                                          .docs[
                                                                      index]
                                                                  ['replyId']);
                                                        }
                                                        return const SizedBox
                                                            .shrink();
                                                      })
                                                  : const SizedBox.shrink(),
                                              const SizedBox(height: 10),
                                              snapshot.data!.docs[index]
                                                          ['time'] !=
                                                      null
                                                  ? isListener
                                                      ? Text(
                                                          snapshot.data!
                                                                  .docs[index]
                                                              ['message'],
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16.0,
                                                          ),
                                                        )
                                                      : Text(
                                                          lastTime.isBefore(
                                                                  snapshot
                                                                      .data!
                                                                      .docs[
                                                                          index]
                                                                          [
                                                                          'time']
                                                                      .toDate())
                                                              ? snapshot.data!
                                                                          .docs[
                                                                      index]
                                                                  ['message']
                                                              : "",
                                                          style:
                                                              const TextStyle(
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
                                                    : snapshot.data!
                                                        .docs[index]['time']
                                                        .toDate(),
                                                builder: (BuildContext context,
                                                    String value) {
                                                  return Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        value,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10.0,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      StreamBuilder(
                                                          stream:
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'chatroom')
                                                                  .doc(docID)
                                                                  .collection(
                                                                      'chats')
                                                                  .doc(snapshot
                                                                      .data!
                                                                      .docs[
                                                                          index]
                                                                      .id)
                                                                  .snapshots(),
                                                          builder: (context,
                                                              AsyncSnapshot<
                                                                      DocumentSnapshot>
                                                                  snapshot2) {
                                                            // Is seen double check
                                                            if (snapshot2
                                                                    .hasData &&
                                                                snapshot2
                                                                        .data !=
                                                                    null) {
                                                              if (snapshot2
                                                                      .data![
                                                                  'is_seen']) {
                                                                return const Icon(
                                                                  Icons
                                                                      .done_all,
                                                                  color: Colors
                                                                      .lightGreenAccent,
                                                                  size: 15,
                                                                );
                                                              } else {
                                                                return const Icon(
                                                                  Icons.done,
                                                                  color: Colors
                                                                      .red,
                                                                  size: 15,
                                                                );
                                                              }
                                                            }
                                                            return const SizedBox
                                                                .shrink();
                                                          })
                                                    ],
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
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
              if (widget.isTextFieldVisible == false) ...{
                const SizedBox(
                  height: 10,
                ),
              } else ...{
                buildReply(),
                Container(
                  height: size.height / 10.0,
                  width: size.width,
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: size.height / 12,
                    width: size.width / 1.1,
                    child: Row(
                      children: [
                        SizedBox(
                          height: size.height / 12,
                          width: size.width / 1.32,
                          child: TextField(
                            autofocus: true,
                            controller: _chatController,
                            decoration: const InputDecoration(
                              hintText: 'Type here',
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                changeTypingStatus(true);
                                // log(value, name: 'onChanged');
                              } else {
                                changeTypingStatus(false);
                                // log(value, name: 'else onChanged');
                              }
                            },
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                            onTap: () {
                              // if (_chatController.text.toLowerCase() ==
                              //     'welcome') {
                              //   _chatController.text = 'Welcome';
                              //   onSendMessage(chatDocId);
                              //   onChatPushNotify();
                              // } else

                              if (_chatController.text.isPhoneNumber() ||
                                      _chatController.text.isValidEmail() ||
                                      _chatController.text.toLowerCase() ==
                                          dotCom ||
                                      _chatController.text == hash ||
                                      _chatController.text == attherate
                                  // _chatController.text.isAbuseMessage() ||
                                  // _chatController.text.isSocialSite()
                                  ) {
                                _chatController.text = 'Xxxxxx';
                                onSendMessage(chatDocId);
                                onChatPushNotify();
                              } else {
                                onSendMessage(chatDocId);
                                onChatPushNotify();
                              }
                              changeTypingStatus(false);
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Icon(Icons.send),
                            )),
                      ],
                    ),
                  ),
                ),
              }
            ],
          ),
        ),
      ),
    );
  }

  // Show Alert Box for Add nick name

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
        child: const Text("OK"),
        onPressed: () async {
          if (nickNameController.text.isNotEmpty) {
            nickNameModel = await APIServices.getNickName(
                SharedPreference.getValue(PrefConstants.MERA_USER_ID),
                widget.userId,
                nickNameController.text);

            if (nickNameModel?.status == true) {
              Fluttertoast.showToast(msg: 'Nickname Added Successfully');
              setState(() {
                nickName = nickNameController.text;
              });
              if (!mounted) return;
              Navigator.pop(context);
            } else {
              Fluttertoast.showToast(msg: 'Please Enter Nick Name');
            }
          }
        });

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      title: Column(
        children: [
          // widget.userId
          const Text("Please enter nick name"),
          TextField(
            controller: nickNameController,
            decoration: const InputDecoration(
              hintText: 'Enter Nick Name',
            ),
          ),
        ],
      ),
      // content:
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // Show FeedBack Alert Dialog

  // Show Alert Dialog for Report

  showReportDialog(BuildContext context) {
    // set up the button
    Widget reportButton = TextButton(
      child: const Text(
        "REPORT",
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: primaryColor),
      ),
      onPressed: () async {
        EasyLoading.show(status: 'loading...');
        ReportModel? reportModel = await APIServices.reportAPI(
            SharedPreference.getValue(PrefConstants.MERA_USER_ID),
            widget.userId.toString(),
            '""');

        if (reportModel?.status == true) {
          EasyLoading.showSuccess(reportModel?.message.toString() ?? '');
          EasyLoading.dismiss();

          if (!mounted) return;
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      const ListnerHomeScreen()));
        } else {
          EasyLoading.dismiss();
          if (!mounted) return;
          toastshowDefaultSnackbar(context, 'Something went wrong');
        }
      },
    );

    Widget blockButton = TextButton(
      child: const Text(
        "BLOCK",
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: primaryColor),
      ),
      onPressed: () async {
        EasyLoading.show(status: 'loading...');
        BlockUserModel? blockModel = await APIServices.blockAPI(
          widget.userId.toString(),
        );

        if (blockModel?.status == true) {
          EasyLoading.showSuccess(blockModel?.message.toString() ?? '');
          EasyLoading.dismiss();

          if (!mounted) return;
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      const ListnerHomeScreen()));
        } else {
          EasyLoading.dismiss();
          if (!mounted) return;
          toastshowDefaultSnackbar(context, 'Something went wrong');
        }
      },
    );
    Widget cancelButton = TextButton(
      child: const Text(
        "CANCEL",
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: primaryColor),
      ),
      onPressed: () async {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      buttonPadding: const EdgeInsets.symmetric(vertical: 0),
      title: Text(
        "Report ${widget.userName}",
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorBlack,
        ),
      ),
      content: Text(
        'The last session with ${widget.userName} was not good. Do you want to report this user?',
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
      actions: [
        reportButton,
        blockButton,
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // If Replying
  Widget buildReply() => replyMessage == null
      ? const SizedBox.shrink()
      : Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(24),
            ),
          ),
          child: ReplyMessageWidget(
            senderName: replyName,
            message: replyMessage,
            onCancelReply: cancelReply,
            isReplyDesign: true,
          ),
        );

  void cancelReply() {
    setState(() {
      replyMessage = null;
    });
  }
}
