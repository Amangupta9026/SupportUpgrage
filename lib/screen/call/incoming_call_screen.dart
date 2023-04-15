import 'dart:async';
import 'dart:developer';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:support/api/api_services.dart';
import 'package:support/screen/call/call.dart';
import 'package:support/sharedpreference/sharedpreference.dart';

import '../../api/api_constant.dart';
import '../../global/utils.dart';
import '../../model/get_call_id_model.dart';

class IncomingCallScreen extends StatefulWidget {
  final String name;
  final String channelId;
  final String? channelToken;
  final String toUserId;
  final int uid;
  const IncomingCallScreen({
    Key? key,
    this.toUserId = "",
    required this.channelId,
    this.channelToken,
    required this.name,
    required this.uid,
  }) : super(key: key);

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  final player = FlutterRingtonePlayer();
  // AudioPlayer();
  Timer? timer;
  int totalSecond = 0;
  bool canPop = false;
  int callIdfromAPI = 0;
  GetCallIdModel? callId;

  Future<void> onCallJoin() async {
    // await for camera and mic permissions before pushing video page
    await AppUtils.handleCameraAndMic(Permission.camera);
    await AppUtils.handleCameraAndMic(Permission.microphone);
    await AppUtils.handleCameraAndMic(Permission.storage);
    await AppUtils.handleCameraAndMic(Permission.bluetooth);
    await AppUtils.handleCameraAndMic(Permission.bluetoothConnect);
    await AppUtils.handleCameraAndMic(Permission.speech);
    await AppUtils.handleCameraAndMic(Permission.audio);
    // push video page with given channel name
    await SharedPreference.getValue(PrefConstants.MERA_USER_ID);

    // ignore: use_build_context_synchronously
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CallPage(
          toUserId: widget.toUserId,
          listenerId: "",
          incoming: true,
          uid: widget.uid,
          channelName: widget.channelId,
          token: widget.channelToken!,
          userName: widget.name,
          callId: callIdfromAPI,
        ),
      ),
    );
  }

  // // Get Call Id
  Future<void> getCallId() async {
    callId = await APIServices.getCallID(
        SharedPreference.getValue(PrefConstants.USER_TYPE) == 'user'
            ? 'user'
            : 'listener');
    if (callId?.status == true) {
      callIdfromAPI = callId?.data?.id ?? 0;
    }
    log(callIdfromAPI.toString(), name: 'callIdfromAPI');
  }

  @override
  void initState() {
    super.initState();
    getCallId();
    log(SharedPreference.getValue(PrefConstants.MERA_USER_ID),
        name: 'merauserID incomingcall');
    FlutterRingtonePlayer.playRingtone(asAlarm: true, looping: true);
    // player.setUrl("asset:assets/sound/ringtone.mp3");
    //  player.play();
    timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => checkCall());
  }

  checkCall() async {
    totalSecond += 1;
    if (totalSecond >= 30) {
      closeCall();
      FlutterRingtonePlayer.stop();
    }
    log(totalSecond.toString());
    var data = await APIServices.getAgoraChannelInfo(widget.channelId);
    if (data.success == true) {
      if (data.data!.broadcasters!.isEmpty) {
        closeCall();
        FlutterRingtonePlayer.stop();
      }
    }
  }

  closeCall() async {
    await APIServices.getBusyOnline(
        'false', SharedPreference.getValue(PrefConstants.MERA_USER_ID));
    if (mounted) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    // player.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (canPop) {
          return true;
        } else {
          Navigator.pop(context);
          FlutterRingtonePlayer.stop();
          return false;
        }
      },
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.deepPurple.shade900, Colors.black])),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
              child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AvatarGlow(
                  endRadius: 100,
                  child: Material(
                    elevation: 8.0,
                    shape: const CircleBorder(),
                    child: CircleAvatar(
                      radius: 60,
                      child: Text(
                        widget.name[0],
                        style: const TextStyle(
                            fontSize: 50.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25.0),
                Text(
                  widget.name,
                  style: const TextStyle(fontSize: 25.0, color: Colors.white),
                ),
                const SizedBox(height: 15.0),
                const Text(
                  "Ringing...",
                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                ),
                const SizedBox(height: 50.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        onCallJoin();
                        FlutterRingtonePlayer.stop();
                      },
                      label: const Text(
                        "Answer",
                        style: TextStyle(color: Colors.white),
                      ),
                      icon: const Icon(Icons.phone, color: Colors.green),
                    ),
                    const SizedBox(width: 25.0),
                    TextButton.icon(
                      onPressed: () async {
                        await APIServices.handleRecording(
                            {"call_id": callIdfromAPI.toString()},
                            APIConstants.STOP_RECORDING);
                        await APIServices.getBusyOnline(
                            'false',
                            SharedPreference.getValue(
                                PrefConstants.MERA_USER_ID));

                        if (mounted) {
                          Navigator.pop(context);
                        }
                        FlutterRingtonePlayer.stop();
                      },
                      label: const Text("Decline",
                          style: TextStyle(color: Colors.white)),
                      icon: const Icon(
                        Icons.call_end,
                        color: Colors.red,
                      ),
                    ),
                  ],
                )
              ],
            ),
          )),
        ),
      ),
    );
  }
}
