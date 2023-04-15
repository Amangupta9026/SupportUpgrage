// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support/api/api_services.dart';
import 'package:support/global/color.dart';
import 'package:support/screen/home/home_screen.dart';
import 'package:support/screen/home/listner_image.dart';
import 'package:support/screen/wallet/wallet_screen.dart';

import '../../api/api_constant.dart';
import '../../global/utils.dart';
import '../../model/bell_icon_notify_model.dart';
import '../../model/busy_online.dart';
import '../../model/feedback_model.dart';
import '../../model/listner_display_model.dart' as listner;
import '../../model/listner_display_model.dart';
import '../../model/report_model.dart';
import '../../model/user_chat_send_request.dart';
import '../../resusable_widget/appbar.dart';
import '../../sharedpreference/sharedpreference.dart';
import '../../widget/toast_widget.dart';
import '../call/call.dart';
import 'chat_request_screen.dart';

class HelperDetailScreen extends StatefulWidget {
  final listner.Data? listnerDisplayModel;
  final RatingReviews? ratingModel;
  const HelperDetailScreen(
      {Key? key, this.listnerDisplayModel, this.ratingModel})
      : super(key: key);

  @override
  State<HelperDetailScreen> createState() => _HelperDetailScreenState();
}

class _HelperDetailScreenState extends State<HelperDetailScreen> {
  num? percent5, percent4, percent3, percent2, percent1;
  final feedbackController = TextEditingController();
  double ratingStore = 5;
  String walletAmount = "0.0";
  bool isListener = false;
  BusyOnlineModel? busyOnlineModel;
  bool isProgressRunning = false;
  bool isFirstCall = true;
  String name = '';

  Widget? image;
  double? width = 150;
  double? height = 150;
  var response;

  imagedata(width, height) {
    return CachedNetworkImage(
      imageUrl: "${APIConstants.BASE_URL}${widget.listnerDisplayModel?.image}",
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorWidget: (context, url, error) => Image.asset(
        "assets/logo.png",
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
      placeholder: (context, url) => Image.asset(
        "assets/logo.png",
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      String amount = await APIServices.getWalletAmount(
              SharedPreference.getValue(PrefConstants.MERA_USER_ID)) ??
          "0.0";
      setState(() {
        walletAmount = amount;
        SharedPreference.setValue(PrefConstants.WALLET_AMOUNT, walletAmount);
      });
    });
    checkListener();
    // apiOnlineBusy();
    image = CachedNetworkImage(
      imageUrl: "${APIConstants.BASE_URL}${widget.listnerDisplayModel?.image}",
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorWidget: (context, url, error) => Image.asset(
        "assets/logo.png",
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
      placeholder: (context, url) => Image.asset(
        "assets/logo.png",
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }

  checkListener() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isListener = prefs.getBool("isListener")!;
    setState(() {});
  }

  onCallPlaced() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String id = prefs.getString("userId")!;
    String name = prefs.getString("userName")!;
    EasyLoading.show(
        status: "Connecting with our secure server",
        maskType: EasyLoadingMaskType.clear);
    var data = await APIServices.getAgoraTokens();

    Map<String, String> formData = {
      "from_id": SharedPreference.getValue(PrefConstants.MERA_USER_ID),
      "to_id": widget.listnerDisplayModel!.id.toString(),
      "channel_name": data["room_id"],
      "user_id": data["agora_uid_one"],
      "token": data["token_one"],
    };

    response = await APIServices.handleRecording(
        formData, APIConstants.START_RECORDING);
    log("response: $response", name: "handleRecording");

    if (response["busy_status"] == true) {
      // alert popup box
      await APIServices.bellIconNotify(
          SharedPreference.getValue(PrefConstants.MERA_USER_ID),
          widget.listnerDisplayModel?.id.toString() ?? '0');
      EasyLoading.dismiss();

      log("User is busy");
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "${widget.listnerDisplayModel?.name} is busy",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()),
                          (Route<dynamic> route) => false);
                    },
                    child: const Text("Ok"))
              ],
            );
          });
    } else if (widget.listnerDisplayModel?.deviceToken != null) {
      APIServices.sendNotification(
          deviceToken: widget.listnerDisplayModel!.deviceToken!,
          senderName: isListener ? widget.listnerDisplayModel!.name! : name,
          cId: data["room_id"],
          cTn: data["token_two"],
          uid: data["agora_uid_two"]);

      EasyLoading.dismiss();

      onCallJoin(
          channelId: data["room_id"],
          channelToken: data["token_one"],
          uid: int.parse(data["agora_uid_one"]),
          data: response["call_id"]);
    } else {
      EasyLoading.showError("User not available");
    }
  }

  Future<void> onCallJoin({channelId, channelToken, uid, int? data}) async {
    // await for camera and mic permissions before pushing video page
    await AppUtils.handleCameraAndMic(Permission.camera);
    await AppUtils.handleCameraAndMic(Permission.microphone);
    await AppUtils.handleCameraAndMic(Permission.storage);
    await AppUtils.handleCameraAndMic(Permission.bluetooth);
    await AppUtils.handleCameraAndMic(Permission.bluetoothConnect);
    await AppUtils.handleCameraAndMic(Permission.speech);
    await AppUtils.handleCameraAndMic(Permission.audio);

    // push video page with given channel name
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallPage(
          listenerId: widget.listnerDisplayModel!.id.toString(),
          userName: widget.listnerDisplayModel?.name ?? "Seeker",
          uid: uid,
          channelName: channelId,
          token: channelToken,
          callId: data,
        ),
      ),
    );

    showFeedBackDialog(context);
  }

  @override
  void dispose() {
    // timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBackgroundLightBlue,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (SharedPreference.getValue(PrefConstants.USER_TYPE) == 'user') ...{
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.listnerDisplayModel?.onlineStatus == 1 &&
                    widget.listnerDisplayModel?.busyStatus == 0) ...{
                  if (widget.listnerDisplayModel?.availableOn == 'call' ||
                      widget.listnerDisplayModel?.availableOn == 'Call' ||
                      widget.listnerDisplayModel?.availableOn == 'call,chat' ||
                      widget.listnerDisplayModel?.availableOn == 'Chat & Cal' ||
                      widget.listnerDisplayModel?.availableOn == 'chat & cal')
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size.fromWidth(125),
                          backgroundColor: colorBlack.withOpacity(0.85),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      onPressed: () async {
                        if (double.tryParse(SharedPreference.getValue(
                                PrefConstants.WALLET_AMOUNT))! <=
                            5.0) {
                          showLowBalancetDialog(context);
                        } else {
                          onCallPlaced();
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "CALL NOW",
                          style: TextStyle(
                            fontSize: 12,
                            color: colorWhite,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (widget.listnerDisplayModel?.availableOn == 'Chat' ||
                      widget.listnerDisplayModel?.availableOn == 'chat' ||
                      widget.listnerDisplayModel?.availableOn == 'call,chat' ||
                      widget.listnerDisplayModel?.availableOn == 'Chat & Cal' ||
                      widget.listnerDisplayModel?.availableOn == 'chat & cal')
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size.fromWidth(125),
                          backgroundColor: colorBlack.withOpacity(0.85),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      onPressed: () async {
                        if (double.tryParse(SharedPreference.getValue(
                                PrefConstants.WALLET_AMOUNT))! <=
                            5.0) {
                          showLowBalancetDialog(context);
                        } else {
                          showChatRequestDialog(
                              context,
                              SharedPreference.getValue(
                                  PrefConstants.MERA_USER_ID),
                              widget.listnerDisplayModel!.id.toString(),
                              widget.listnerDisplayModel!.id.toString(),
                              widget.listnerDisplayModel!.name.toString(),
                              widget.listnerDisplayModel!);
                        }
                      },
                      child: const Text(
                        "CHAT NOW",
                        style: TextStyle(
                          fontSize: 12,
                          color: colorWhite,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                } else ...{
                  InkWell(
                    onTap: () async {
                      EasyLoading.show(status: 'loading...');

                      BellIconNotifyModel? bellIconNotify =
                          await APIServices.bellIconNotify(
                              SharedPreference.getValue(
                                  PrefConstants.MERA_USER_ID),
                              widget.listnerDisplayModel!.id.toString());

                      if (bellIconNotify?.status == true) {
                        EasyLoading.showSuccess(bellIconNotify?.message ?? '');
                        EasyLoading.dismiss();
                      }
                    },
                    child: const CircleAvatar(
                        backgroundColor: colorBlack,
                        radius: 30,
                        child: Icon(Icons.notifications,
                            size: 30, color: Colors.white)),
                  ),
                },
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          }
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 20, 15, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CustomBackButton(),
                        if (SharedPreference.getValue(
                                PrefConstants.USER_TYPE) ==
                            'user') ...{
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  showReportDialog(context);
                                },
                                child: const Text(
                                  'Report',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const CustomShareButton(),
                            ],
                          ),
                        },
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: InkWell(
                            onTap: () {
                              width = MediaQuery.of(context).size.width;
                              height = MediaQuery.of(context).size.height;

                              var image = imagedata(width, height);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ListnerImage(
                                            image: image,
                                          )));
                            },
                            child: image,
                          )),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Text(
                        widget.listnerDisplayModel?.name ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          color: colorBlack,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    if (widget.listnerDisplayModel?.busyStatus == 1) ...{
                      const Center(
                          child: Text('Busy',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14,
                                  letterSpacing: 0.3,
                                  color: colorRed,
                                  fontWeight: FontWeight.bold)))
                    } else if (widget.listnerDisplayModel?.onlineStatus ==
                        1) ...{
                      const Center(
                          child: Text('Online',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                  letterSpacing: 0.3,
                                  fontWeight: FontWeight.bold)))
                    } else ...{
                      const Center(
                          child: Text('Offline',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14,
                                  letterSpacing: 0.3,
                                  color: colorRed,
                                  fontWeight: FontWeight.bold)))
                    },
                  ],
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(45),
                      topLeft: Radius.circular(45),
                    ),
                    color: colorWhite),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 30, 15, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: colorLightBlue,
                            borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ABOUT ME',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: colorBlack,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              Text(
                                widget.listnerDisplayModel?.about ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: colorBlack,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                                color: colorLightBlue,
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  widget.listnerDisplayModel?.sex == 'F'
                                      ? const Icon(
                                          Icons.female,
                                          size: 35,
                                        )
                                      : const Icon(
                                          Icons.male,
                                          size: 35,
                                        ),
                                  const Text(
                                    'Gender/Age',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: colorBlack,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    '${widget.listnerDisplayModel?.sex} ${widget.listnerDisplayModel?.age} Years',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: colorBlack,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  const Text(
                                    '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorBlack,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                                color: colorLightBlue,
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.interests,
                                    size: 35,
                                  ),
                                  const Text(
                                    'Interest',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: colorBlack,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    widget.listnerDisplayModel?.interest ?? '',
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: colorBlack,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  const Text(
                                    '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorBlack,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                                color: colorLightBlue,
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.language,
                                    size: 30,
                                  ),
                                  const Text(
                                    'Language',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: colorBlack,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  SizedBox(
                                    height: 43,
                                    child: Text(
                                      widget.listnerDisplayModel?.language ??
                                          '',
                                      maxLines: 2,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: colorBlack,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: colorLightBlue,
                            borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 5, 20, 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.listnerDisplayModel!.ratingReviews!
                                        .averageRating
                                        .toString(),
                                    style: const TextStyle(
                                      fontSize: 40,
                                      color: Color(0xff0157ca),
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  RatingBar.builder(
                                    ignoreGestures: true,
                                    initialRating: double.tryParse(widget
                                                .listnerDisplayModel!
                                                .ratingReviews!
                                                .averageRating
                                                ?.toString() ??
                                            '0.0') ??
                                        0.0,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemSize: 30,
                                    itemPadding: const EdgeInsets.symmetric(
                                        horizontal: 1.0),
                                    itemBuilder: (context, _) => const Icon(
                                      Icons.star,
                                      color: primaryColor,
                                      size: 30,
                                    ),
                                    onRatingUpdate: (rating) {
                                      log(rating.toString());
                                    },
                                  ),
                                ],
                              ),

                              // Progress Indicator for Showing Rating

                              Column(
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      const Text(
                                        '5',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: colorBlack,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      const Text(
                                        '☆',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: colorBlack,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      LinearPercentIndicator(
                                        barRadius: const Radius.circular(25),
                                        width: 100.0,
                                        lineHeight: 8.0,
                                        percent: widget
                                                .listnerDisplayModel!
                                                .ratingReviews!
                                                .rating5percent! /
                                            100.toDouble(),
                                        progressColor: Colors.green,
                                      ),
                                      Text(
                                        widget.listnerDisplayModel!
                                            .ratingReviews!.rating5
                                            .toString(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: colorBlack,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ],
                                  ),

                                  Row(
                                    children: [
                                      const Text(
                                        '4',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: colorBlack,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      const Text(
                                        '☆',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: colorBlack,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      LinearPercentIndicator(
                                        barRadius: const Radius.circular(25),
                                        width: 100.0,
                                        lineHeight: 8.0,
                                        percent: widget
                                                .listnerDisplayModel!
                                                .ratingReviews!
                                                .rating4percent! /
                                            100.toDouble(),
                                        progressColor: Colors.green,
                                      ),
                                      Text(
                                        widget.listnerDisplayModel!
                                            .ratingReviews!.rating4
                                            .toString(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: colorBlack,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // 3rd place
                                  Row(
                                    children: [
                                      const Text(
                                        '3',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: colorBlack,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      const Text(
                                        '☆',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: colorBlack,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      LinearPercentIndicator(
                                        barRadius: const Radius.circular(25),
                                        width: 100.0,
                                        lineHeight: 8.0,
                                        percent: widget
                                                .listnerDisplayModel!
                                                .ratingReviews!
                                                .rating3percent! /
                                            100.toDouble(),
                                        progressColor: Colors.green,
                                      ),
                                      Text(
                                        widget.listnerDisplayModel!
                                            .ratingReviews!.rating3
                                            .toString(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: colorBlack,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // 2 place
                                  Row(
                                    children: [
                                      const Text(
                                        '2',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: colorBlack,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      const Text(
                                        '☆',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: colorBlack,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      LinearPercentIndicator(
                                        barRadius: const Radius.circular(25),
                                        width: 100.0,
                                        lineHeight: 8.0,
                                        percent: widget
                                                .listnerDisplayModel!
                                                .ratingReviews!
                                                .rating2percent! /
                                            100.toDouble(),
                                        progressColor: Colors.green,
                                      ),
                                      Text(
                                        widget.listnerDisplayModel!
                                            .ratingReviews!.rating2
                                            .toString(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: colorBlack,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // 1 place
                                  Row(
                                    children: [
                                      const Text(
                                        '1',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: colorBlack,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      const Text(
                                        '☆',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: colorBlack,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      LinearPercentIndicator(
                                        barRadius: const Radius.circular(25),
                                        width: 100.0,
                                        lineHeight: 8.0,
                                        percent: widget
                                                .listnerDisplayModel!
                                                .ratingReviews!
                                                .rating1percent! /
                                            100.toDouble(),
                                        progressColor: Colors.green,
                                      ),
                                      Text(
                                        widget.listnerDisplayModel!
                                            .ratingReviews!.rating1
                                            .toString(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: colorBlack,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                                color: colorLightBlue,
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(12.0, 20, 12, 20),
                              child: Column(
                                children: [
                                  const Text(
                                    'Available on',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: colorBlack,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          const Icon(
                                            Icons.phone,
                                            size: 20,
                                          ),
                                          const SizedBox(
                                            height: 3,
                                          ),
                                          InkWell(
                                            onTap: () {},
                                            child: const Text(
                                              'Call',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: colorBlack,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: const [
                                          Icon(
                                            Icons.chat,
                                            size: 20,
                                          ),
                                          SizedBox(
                                            height: 3,
                                          ),
                                          Text(
                                            'Chat',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: colorBlack,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          //
                          // Charges Price
                          //

                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                                color: colorLightBlue,
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(12.0, 20, 12, 20),
                              child: Column(
                                children: [
                                  const Text(
                                    'Charges',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: colorBlack,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '₹',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: colorBlack,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        widget.listnerDisplayModel?.charge
                                                ?.substring(0, 1) ??
                                            '5',
                                        style: const TextStyle(
                                          fontSize: 30,
                                          color: colorBlack,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      const Text(
                                        'per minute',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: colorBlack,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          //
                          //
                          // Review

                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                                color: colorLightBlue,
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(12.0, 20, 12, 20),
                              child: Column(
                                children: [
                                  const Text(
                                    'Review',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: colorBlack,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    widget.listnerDisplayModel!.ratingReviews!
                                            .allReviews?.length
                                            .toString() ??
                                        '0',
                                    style: const TextStyle(
                                      fontSize: 30,
                                      color: colorBlack,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: colorBlack,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 10, 12, 10),
                  child: Center(
                    child: Text(
                      '${widget.listnerDisplayModel!.ratingReviews!.allReviews?.length ?? '0'}'
                      ' Reviews',
                      style: const TextStyle(
                        fontSize: 20,
                        color: colorWhite,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: colorWhite,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 15, 15, 110),
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.listnerDisplayModel?.ratingReviews
                              ?.allReviews?.length ??
                          0,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            RatingBar.builder(
                              ignoreGestures: true,
                              initialRating: double.tryParse(widget
                                      .listnerDisplayModel!
                                      .ratingReviews!
                                      .allReviews![index]
                                      .rating
                                      .toString()) ??
                                  0.0,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 30,
                              itemPadding:
                                  const EdgeInsets.symmetric(horizontal: 1.0),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: colorBlack,
                                size: 30,
                              ),
                              onRatingUpdate: (rating) {
                                log(rating.toString());
                              },
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.listnerDisplayModel!.ratingReviews!
                                            .allReviews?[index].review ??
                                        '',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: colorBlack,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    widget.listnerDisplayModel!.ratingReviews!
                                            .allReviews?[index].createdAt
                                            .toString() ??
                                        '0',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: colorBlack,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Divider(),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        );
                      }),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

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
            widget.listnerDisplayModel!.id.toString(),
            '""');

        if (reportModel?.status == true) {
          EasyLoading.showSuccess(reportModel?.message.toString() ?? '');
          EasyLoading.dismiss();

          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const HomeScreen()));
        } else {
          EasyLoading.dismiss();
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
        "Report ${widget.listnerDisplayModel?.name}",
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorBlack,
        ),
      ),
      content: Text(
        'The last session with ${widget.listnerDisplayModel?.name} was not good. Do you want to report this listner?',
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
      actions: [
        reportButton,
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  //show dialog

  showLowBalancetDialog(BuildContext context) {
    // set up the button
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    Widget addButton = TextButton(
      child: const Text("Add into Money"),
      onPressed: () async {
        if (!mounted) return;
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const WalletScreen()));
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      title: const Text("Balance is Low"),
      content: Text(
          "You should have at least Rs 5/- to chat with ${widget.listnerDisplayModel!.name ?? ''}"),
      actions: [
        addButton,
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showFeedBackDialog(BuildContext context) {
    Widget skipButton = TextButton(
        child: const Text("Skip"),
        onPressed: () async {
          if (!mounted) return;
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const HomeScreen()));
        });
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () async {
        EasyLoading.show(status: 'loading...');
        FeedBackModel? feedBackModel = await APIServices.feedbackAPI(
            SharedPreference.getValue(PrefConstants.MERA_USER_ID),
            widget.listnerDisplayModel!.id.toString(),
            ratingStore.toString(),
            feedbackController.text);

        if (feedBackModel?.status == true) {
          EasyLoading.dismiss();
          if (!mounted) return;
          toastshowDefaultSnackbar(context, 'Thank you for your feedback');

          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const HomeScreen()));
        } else {
          EasyLoading.dismiss();
          if (!mounted) return;
          toastshowDefaultSnackbar(context, 'Something went wrong');
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      title: Column(
        children: [
          const Text("Enter your feedback"),
          const SizedBox(height: 10),
          RatingBar.builder(
            initialRating: 5,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 30,
            itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: primaryColor,
              size: 30,
            ),
            onRatingUpdate: (rating) {
              ratingStore = rating;
              log(ratingStore.toString());
            },
          ),
        ],
      ),
      content: TextField(
        controller: feedbackController,
        decoration: const InputDecoration(
          hintText: 'Enter your feedback',
        ),
      ),
      actions: [skipButton, okButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

// Chat now Request

showChatRequestDialog(
  BuildContext context,
  String fromId,
  String toId,
  String listnerId,
  String listnerName,
  listner.Data listnerDisplayModel,
) {
  Widget sendRequestButton = TextButton(
      child: const Text("Send Request"),
      onPressed: () async {
        EasyLoading.show(status: 'loading...');

        UserChatSendRequest? userChatSendRequest =
            await APIServices.userChatSendRequestAPI(fromId, toId);

        if (userChatSendRequest?.status == true) {
          EasyLoading.dismiss();
          if (userChatSendRequest?.busyStatus == true) {
            Navigator.pop(context);
            await APIServices.bellIconNotify(
                SharedPreference.getValue(PrefConstants.MERA_USER_ID),
                listnerDisplayModel.id.toString());
            // alert popup box
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      "${listnerDisplayModel.name} is busy",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () async {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => const HomeScreen()),
                                (Route<dynamic> route) => false);
                          },
                          child: const Text("Ok"))
                    ],
                  );
                });
          } else {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String id = prefs.getString("userId")!;
            String name = prefs.getString("userName")!;

            APIServices.sendChatNotification(
                deviceToken: listnerDisplayModel.deviceToken!,
                senderName: 'Annonymous');

            EasyLoading.dismiss();

            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => ChatRequestPending(
                          userChatSendRequest: userChatSendRequest,
                          listenerId: listnerId,
                          listenerName: listnerName,
                          userId: id,
                          userName: name,
                          listnerDisplayModel: listnerDisplayModel,
                        )),
                (Route<dynamic> route) => false);
          }
        }
      });
  // set up the button
  Widget cancelButton = TextButton(
    child: const Text("Cancel"),
    onPressed: () async {
      Navigator.pop(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    backgroundColor: Colors.white,
    title: Column(
      children: const [
        Text("You can Chat only after Listener Approve.",
            style: TextStyle(fontSize: 16)),
        SizedBox(height: 10),
      ],
    ),
    actions: [sendRequestButton, cancelButton],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
