import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:support/global/color.dart';
import 'package:support/screen/home/home_screen.dart';

import '../../api/api_services.dart';
import '../../model/get_chat_request_from_user.dart';
import '../../model/listner/update_chat_request_model.dart';
import '../../model/send_chat_id.dart';
import '../../model/user_chat_send_request.dart';
import '../../model/listner_display_model.dart' as listner;
import '../chat/chat_screen_2.dart';

class ChatRequestPending extends StatefulWidget {
  final UserChatSendRequest? userChatSendRequest;
  final String userId;
  final String userName;
  final String listenerId;
  final String listenerName;
  final listner.Data? listnerDisplayModel;
  const ChatRequestPending(
      {super.key,
      this.userChatSendRequest,
      required this.userId,
      required this.userName,
      required this.listenerId,
      required this.listenerName,
      this.listnerDisplayModel});

  @override
  State<ChatRequestPending> createState() => _ChatRequestPendingState();
}

class _ChatRequestPendingState extends State<ChatRequestPending>
    with TickerProviderStateMixin {
  AnimationController? controller;
  int levelClock = 120;
  GetChatRequestByUserModel? getChatRequestByUserModel;
  Timer? timer;
  SendChatIDModel? chatIdModel;

  UpdateChatRequestModel? updateChatRequestModel = UpdateChatRequestModel();
    String? docID;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    checkStatus() async {
    var data = await _firestore.collection('chatroom').doc(docID).get();
  }

  @override
  void initState() {
    super.initState();

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

    }). then((value) => chatId());


    

    controller = AnimationController(
        vsync: this,
        duration: Duration(
            seconds:
                levelClock) // gameData.levelClock is a user entered number elsewhere in the applciation
        );

    controller?.forward();
    timer = Timer.periodic(
        const Duration(seconds: 5), (Timer t) => getChatRequestByUser());

    controller?.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        EasyLoading.show(indicator: const CircularProgressIndicator());
        updateChatRequestModel =
            await APIServices.updateChatRequestFromListnerAPI(
                widget.userChatSendRequest?.data?.id ?? 0, 'cancelled');

        if (updateChatRequestModel?.status == true) {
          
          EasyLoading.dismiss();
          if (mounted) {
            // Navigator.pop(context);
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false);

            Fluttertoast.showToast(
                msg:
                    '${widget.listnerDisplayModel?.name} is Unavailable at the moment');
          }
          await APIServices.getBusyOnline('false', widget.listenerId);
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    timer?.cancel();
    super.dispose();
  }

  // Get Chat Id
  Future<SendChatIDModel?> chatId() async {
    try {
      chatIdModel = await APIServices.sendChatIDAPI(
          widget.userId, widget.listenerId, 
          // 'message'
          docID ?? '0',
          );
    } catch (e) {
      log(e.toString());
    }
    return chatIdModel;
  }



  Future<GetChatRequestByUserModel?> getChatRequestByUser() async {
    try {
      getChatRequestByUserModel = await APIServices.getChatRequestAPI(
        widget.userChatSendRequest?.data?.id.toString() ?? '0',
      );
      if (getChatRequestByUserModel?.data?[0].status == 'approve') {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => ChatRoomScreen(
                        listnerDisplayModel: widget.listnerDisplayModel,
                        listenerId: widget.listnerDisplayModel!.id.toString(),
                        listenerName: widget.listnerDisplayModel!.name!,
                        userId: widget.userId,
                        userName: widget.userName,
                        chatId: chatIdModel?.data?.id,
                      )),
              (Route<dynamic> route) => false);
        }
      } else if (getChatRequestByUserModel?.data?[0].status == 'decline') {
        if (mounted) {
          

          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (Route<dynamic> route) => false);

          Fluttertoast.showToast(
              msg:
                  '${widget.listnerDisplayModel?.name} Listner Decline the Request');
        }
        await APIServices.getBusyOnline('false', widget.listenerId);
      }
    } catch (e) {
      log(e.toString());
    } finally {}
    return getChatRequestByUserModel;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Decline the request
        showcancelChat(context);

        return true;
      },
      child: Scaffold(
        backgroundColor: colorWhite,
        appBar: AppBar(
          leading: InkWell(
              onTap: () {
                // Decline the request
                showcancelChat(context);
              },
              child: const Icon(Icons.arrow_back)),
          title: const Text(
            'Please Wait',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 20, 15, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Column(
                    children: const [
                      Text(
                        'Connecting.... ',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'You can Chat only after Listener Approve',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Countdown(
                  animation: StepTween(
                    begin: levelClock, // THIS IS A USER ENTERED NUMBER
                    end: 0,
                  ).animate(controller!),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Camcel the request

  showcancelChat(BuildContext context) {
    // set up the buttons
    Widget cancelRequestButton = TextButton(
      child: const Text("Yes"),
      onPressed: () async {
        EasyLoading.show(status: 'Please wait...');
        await APIServices.getBusyOnline('false', widget.listenerId);

        updateChatRequestModel =
            await APIServices.updateChatRequestFromListnerAPI(
                widget.userChatSendRequest?.data?.id ?? 0, 'cancelled');

        if (updateChatRequestModel?.status == true) {
          EasyLoading.dismiss();

          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false);
          }
        }
      },
    );
    Widget continueButton = TextButton(
      child: const Text("No"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Are you Sure?"),
      content: const Text("You want to end this session?"),
      actions: [
        cancelRequestButton,
        continueButton,
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
}

// ignore: must_be_immutable
class Countdown extends AnimatedWidget {
  Countdown({Key? key, this.animation})
      : super(key: key, listenable: animation!);
  Animation<int>? animation;

  @override
  build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation!.value);

    String timerText =
        '${clockTimer.inMinutes.remainder(60).toString()}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    return Text(
      timerText,
      style: const TextStyle(
        fontSize: 50,
        color: primaryColor,
      ),
    );
  }
}
