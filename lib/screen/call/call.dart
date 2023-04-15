import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import '../../api/api_constant.dart';
import '../../api/api_services.dart';
import '../../global/utils.dart';
import '../../model/charge_wallet_model.dart';
import '../../sharedpreference/sharedpreference.dart';
import '../../widget/toast_widget.dart';
import '../wallet/wallet_screen.dart';

const agoraAppId = '38d72d8d7a90490a80f2fb9e328f2e8a';

class CallPage extends StatefulWidget {
  /// non-modifiable channel name of the page
  final String? channelName;
  final String userName;
  final int uid;
  final String toUserId;
  final bool incoming;

  /// non-modifiable client role of the page
  final String token;

  final String listenerId;
  final int? callId;

  /// Creates a call page with given channel name.
  const CallPage(
      {Key? key,
      this.channelName,
      required this.token,
      required this.uid,
      required this.userName,
      this.incoming = false,
      required this.listenerId,
      this.toUserId = "",
      this.callId})
      : super(key: key);

  @override
  CallPageState createState() => CallPageState();
}

class CallPageState extends State<CallPage> {
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  bool speaker = false;
  late RtcEngine _engine;
  bool isListener = false;
  bool isFirstCall = false;
  String callRecordingId = "";
  final sessionId = getRandomString(16);

  Duration duration = const Duration();
  Timer? timer;
  final player = AudioPlayer();

  final StopWatchTimer stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
    onChangeRawMinute: (value) => () {
      log('cut thr price');
    },
  );

  void ringingTime() {
    timer = Timer.periodic(const Duration(seconds: 30), (Timer t) {
      if (duration.inSeconds <= 0) {
        _onCallEnd(context);
      }
    });
  }

  void startTimer() {
    // !isListener ? stopWatchTimer.minuteTime.listen(amountKaatLo) : null;
    // amountKaatLo(5);
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
    stopWatchTimer.onExecute.add(StopWatchExecute.start);
    !isListener ? stopWatchTimer.minuteTime.listen(amountKaatLo) : null;
    // timer =
    // Timer.periodic(const Duration(seconds: 60), (_) => amountKaatLo(5));
  }

  void addTime() {
    if (mounted) {
      setState(() {
        final seconds = duration.inSeconds + 1;
        if (seconds < 0) {
          timer?.cancel();
        } else {
          duration = Duration(seconds: seconds);
        }
      });
    }
  }

  Widget buildTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      buildTimeCard(time: hours, header: 'HOURS'),
      const SizedBox(
        width: 8,
      ),
      buildTimeCard(time: minutes, header: 'MINUTES'),
      const SizedBox(
        width: 8,
      ),
      buildTimeCard(time: seconds, header: 'SECONDS'),
    ]);
  }

  Widget buildTimeCard({required String time, required String header}) => Text(
        time,
        style: const TextStyle(
            fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
      );

  void amountKaatLo(value) async {
    log('trying to cut amount');
    if (!isFirstCall) {
      isFirstCall = true;
      return;
    }
    String amount = SharedPreference.getValue(PrefConstants.WALLET_AMOUNT);
    if (double.tryParse(amount)! <= 5.0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        EasyLoading.showInfo('Balance is Low, recharge your wallet');
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const WalletScreen()));
      });
      return;
    }

    log("value $value");

    int addminute = 1;
    log(addminute.toString());
    // EasyLoading.show(status: 'loading...');
    ChargeWalletModel chargeWalletModel =
        await APIServices.chargeWalletDeductionApi(
            SharedPreference.getValue(PrefConstants.MERA_USER_ID),
            widget.listenerId,
            addminute.toString(),
            'Call',
            sessionId);
    // ignore: unrelated_type_equality_checks
    if (chargeWalletModel.status == true) {
      SharedPreference.setValue(PrefConstants.WALLET_AMOUNT,
          chargeWalletModel.remaningWallet!.walletAmount.toString());
      if (double.tryParse(
              chargeWalletModel.remaningWallet!.walletAmount.toString())! <=
          5.0) {
        // await stopWatchTimer.dispose();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          EasyLoading.showInfo('Balance is Low, recharge your wallet');
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const WalletScreen()));
          // _engine.muteLocalAudioStream(true);
          // _engine.muteAllRemoteAudioStreams(true);
          // showAddMoney(context);
        });
      } else {
        // await stopWatchTimer.dispose();
        log('click');
      }

      // showFeedBackDialog(context);
    } else {
      // EasyLoading.dismiss();
      if (!mounted) return;
      toastshowDefaultSnackbar(context, 'Something went wrong');
    }
  }

  @override
  void dispose() {
    // clear users
    _users.clear();
    _dispose();
    timer?.cancel();
    // stopWatchTimer.dispose();
    super.dispose();
  }

  Future<void> _dispose() async {
    // destroy sdk
    if (widget.callId != null) {
      log({"call_id": widget.callId}.toString());
      EasyLoading.show(
          status: 'Please wait, updating your wallet balance',
          maskType: EasyLoadingMaskType.clear);
      await APIServices.handleRecording(
          {"call_id": widget.callId.toString()}, APIConstants.STOP_RECORDING);
      await APIServices.getBusyOnline('false', widget.listenerId);
      EasyLoading.dismiss();
    }
    await _engine.leaveChannel();
    await _engine.destroy();

    player.dispose();
  }

  @override
  void initState() {
    super.initState();
    log(widget.callId.toString(), name: 'callIdFRomCALL');
    // initialize agora sdk
    initialize();
    log(widget.listenerId, name: 'listenerId');
  }

  Future<void> initialize() async {
    if (agoraAppId.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await _engine.joinChannel(
        widget.token, widget.channelName!, null, widget.uid);
    ringingTime();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isListener = prefs.getBool("isListener") ?? false;
    player.setUrl("asset:assets/sound/ringing.mp3");
    player.play();
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(agoraAppId);
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(ClientRole.Broadcaster);
    await _engine.setEnableSpeakerphone(false);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    log('start handler');
    _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    }, joinChannelSuccess: (channel, uid, elapsed) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
      });
    }, leaveChannel: (stats) {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    }, userJoined: (uid, elapsed) {
      player.stop();
      startTimer();
      setState(() {
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
      });
      if (widget.incoming) {
        log("incoming call recording");
        startrecording();
      }
    }, userOffline: (uid, elapsed) {
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
        _onCallEnd(context);
      });
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    }));
  }

  startrecording() async {
    Map<String, String> formData = {
      "from_id": widget.toUserId,
      "to_id": SharedPreference.getValue(PrefConstants.MERA_USER_ID),
      "channel_name": widget.channelName ?? "",
      "user_id": widget.uid.toString(),
      "token": widget.token,
    };
    log(jsonEncode(formData));
    var response = await APIServices.handleRecording(
        formData, APIConstants.START_RECORDING);
    if (response["call_id"] != null) {
      callRecordingId = response["call_id"].toString();
    }
  }

  /// Toolbar layout
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
          ),
          RawMaterialButton(
            onPressed: () => onToggleSpeaker(context),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              speaker ? Icons.volume_up : Icons.volume_down,
              color: Colors.blueAccent,
              size: 20.0,
            ),
          )
        ],
      ),
    );
  }

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return const Text(
                    "null"); // return type can't be null, a widget was required
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _infoStrings[index],
                          style: const TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onCallEnd(BuildContext context) async {
    await APIServices.handleRecording(
        {"call_id": widget.callId.toString()}, APIConstants.STOP_RECORDING);
    await APIServices.getBusyOnline('false', widget.listenerId);
    log(widget.callId.toString(), name: "callId");
    log(widget.listenerId, name: "listenerId");

    try {
      await stopWatchTimer.dispose();
    } catch (e) {
      log(e.toString());
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void onToggleSpeaker(BuildContext context) {
    setState(() {
      speaker = !speaker;
    });
    _engine.setEnableSpeakerphone(speaker);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: duration.inSeconds <= 0 ? const Text('Ringing...') : buildTime(),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.3,
                    child: Icon(
                      Icons.person,
                      size: MediaQuery.of(context).size.width * 0.2,
                    ),
                  ),
                  const SizedBox(height: 50.0),
                  Text(
                    widget.userName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30.0),
                  ),
                ],
              ),
            ),
            // _viewRows(),
            if (kDebugMode) _panel(),
            _toolbar(),
          ],
        ),
      ),
    );
  }
}
