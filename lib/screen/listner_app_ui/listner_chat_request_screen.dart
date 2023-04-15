import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/api_constant.dart';
import '../../api/api_services.dart';
import '../../global/color.dart';
import '../../model/listner/listner_chat_request_model.dart';
import '../../model/listner/nick_name_get_model.dart';
import '../../model/listner/update_chat_request_model.dart';
import '../../sharedpreference/sharedpreference.dart';
import '../../widget/shimmer_progress_widget.dart';
import '../chat/chat_screen_2.dart';
import 'listner_homescreen.dart';

class ListnerChatRequestScreen extends StatefulWidget {
  final int requestid;
  final String? fromid;
  const ListnerChatRequestScreen(
      {super.key, required this.requestid, this.fromid});

  @override
  State<ListnerChatRequestScreen> createState() =>
      _ListnerChatRequestScreenState();
}

class _ListnerChatRequestScreenState extends State<ListnerChatRequestScreen> {
  ListnerChatRequest? getListnerRequest = ListnerChatRequest();
  final audioPlayer = AudioPlayer();
  Timer? _timer;
  String id = "";
  String? name;
  bool isListener = false;
  bool loading = false;
  bool isProgressRunning = false;
  bool isFirstCall = false;
  NickNameGETModel getnickNameModel = NickNameGETModel();
  String? userName;

  // Listner Chat Request

  Future<ListnerChatRequest?> apigetListnerRequest() async {
    try {
      // setState(() {
      //   isProgressRunning = true;
      // });
      getListnerRequest = await APIServices.listnerChatRequestAPI();

      if (getListnerRequest?.message == 'Data not retrive') {
        audioPlayer.stop();
        _timer?.cancel();
        // SharedPreference.setValue(PrefConstants.LISTNER_CHAT_REQUEST, true);

        if (mounted) {
          _timer?.cancel();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => const ListnerHomeScreen()),
              (Route<dynamic> route) => false);

          return null;
        }
      }
    } catch (e) {
      log(e.toString());
    } finally {
      // if (mounted) {
      //   setState(() {
      //     isProgressRunning = false;
      //   });
      // }
    }

    return null;
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    id = prefs.getString("userId")!;
    name = prefs.getString("userName")!;
    isListener = prefs.getBool("isListener")!;

    setState(() {
      loading = false;
      // chats = value;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    audioPlayer.dispose();
    super.dispose();
    _timer?.cancel();
  }

  void isCallfirst() {
    if (isFirstCall == false) {
      _timer = Timer.periodic(
          const Duration(seconds: 5), (Timer t) => apigetListnerRequest());
      isFirstCall = true;
    }
  }

  @override
  void initState() {
    super.initState();
    isCallfirst();
    apigetNickName();
    // timer = Timer.periodic(
    //     const Duration(seconds: 10), (Timer t) => apigetListnerRequest());

    loading = true;
    loadData();
    //
    audioPlayer.play(
      AssetSource(
        'sound/customsound.mp3',
      ),
    );
    audioPlayer.onPlayerComplete.listen((event) {
      audioPlayer.play(
        AssetSource(
          'sound/customsound.mp3',
        ),
      );
    });
  }

  Future<NickNameGETModel> apigetNickName() async {
    try {
      // setState(() {
      //   isProgressRunning = true;
      // });

      getnickNameModel = await APIServices.displayNickName();
      if (getnickNameModel.status == true) {
        for (int i = 0; i < getnickNameModel.data!.length; i++) {
          if (getnickNameModel.data![i].toId == widget.fromid) {
            userName = getnickNameModel.data![i].nickname!;
          }
          log(userName.toString(), name: "name");
        }
      }

      // if (mounted) {
      //   setState(() {
      //     nickName = nickNameController.text;
      //   });
      // }
    } catch (e) {
      log(e.toString());
    } finally {
      // setState(() {
      //   isProgressRunning = false;
      // });
    }
    return getnickNameModel;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: const SizedBox(),
          title: const Text("Chat Request"),
        ),
        body: isProgressRunning
            ? ShimmerProgressWidget(
                count: 8, isProgressRunning: isProgressRunning)
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 40, 15, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: MediaQuery.of(context).size.width * 0.4,
                      ),
                      const SizedBox(height: 40.0),
                      const Text(
                        "Anonymous sent you chat request",
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 40.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () async {
                              EasyLoading.show(status: 'loading...');
                              UpdateChatRequestModel? updateChatRequest =
                                  await APIServices
                                      .updateChatRequestFromListnerAPI(
                                          widget.requestid, 'approve');

                              if (updateChatRequest?.status == true) {
                                audioPlayer.stop();
                                EasyLoading.dismiss();
                                if (mounted) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) => ChatRoomScreen(
                                                listenerId: id,
                                                listenerName: name ?? '',
                                                userId: updateChatRequest
                                                        ?.data?.fromId
                                                        .toString() ??
                                                    '0',

                                                userName:
                                                    userName ?? 'Anonymous',
                                                // userName: 'Anonymous',
                                              )),
                                      (Route<dynamic> route) => false);
                                }
                              }
                            },
                            child: const Text(
                              'Accept',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 30.0),
                          TextButton(
                              onPressed: () async {
                                EasyLoading.show(status: 'loading...');

                                UpdateChatRequestModel? updateChatRequest =
                                    await APIServices
                                        .updateChatRequestFromListnerAPI(
                                            widget.requestid, 'decline');

                                await APIServices.getBusyOnline(
                                  'false',
                                  SharedPreference.getValue(
                                      PrefConstants.MERA_USER_ID),
                                );

                                if (updateChatRequest?.status == true) {
                                  audioPlayer.stop();
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
                                'Reject',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: colorRed,
                                    fontWeight: FontWeight.bold),
                              )),
                        ],
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
