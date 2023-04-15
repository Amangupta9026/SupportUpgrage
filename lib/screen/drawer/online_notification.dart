import 'dart:developer';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:support/api/api_constant.dart';

import '../../api/api_services.dart';
import '../../global/color.dart';
import '../../model/chat_notification.dart';
import '../../model/read_notifications.dart';
import '../../widget/shimmer_progress_widget.dart';

class OnlineListnerNotification extends StatefulWidget {
  const OnlineListnerNotification({Key? key}) : super(key: key);

  @override
  State<OnlineListnerNotification> createState() =>
      _OnlineListnerNotificationState();
}

class _OnlineListnerNotificationState extends State<OnlineListnerNotification> {
  bool isProgressRunning = false;
  ChatNotificationModel? chatNotificationModel;
  ReadNotificationModel? readNotificationModel;

  Future<void> apiNotifyListnerList() async {
    try {
      setState(() {
        isProgressRunning = true;
      });
      chatNotificationModel = await APIServices.getNotification();
    } catch (e) {
      log(e.toString());
    } finally {
      setState(() {
        isProgressRunning = false;
      });
    }
  }

  Future<void> apiGetReadNotification() async {
    try {
      setState(() {
        isProgressRunning = true;
      });
      readNotificationModel = await APIServices.readNotificationApi();
    } catch (e) {
      log(e.toString());
    } finally {
      setState(() {
        isProgressRunning = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    apiNotifyListnerList();
    apiGetReadNotification();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: InkWell(
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back)),
          title: const Text(
            'Notification',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
        body: isProgressRunning
            ? ShimmerProgressWidget(
                count: 8, isProgressRunning: isProgressRunning)
            : SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (chatNotificationModel?.allNotifications != null &&
                          chatNotificationModel!
                              .allNotifications!.isNotEmpty) ...{
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15.0, 15, 15, 8),
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: chatNotificationModel
                                      ?.allNotifications?.length ??
                                  0,
                              scrollDirection: Axis.vertical,
                              physics: const ScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Card(
                                        elevation: 3,
                                        color: colorWhite,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: colorWhite,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                12.0, 12, 12, 12),
                                            child: Column(
                                              children: [
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: 40,
                                                            height: 40,
                                                            decoration:
                                                                BoxDecoration(
                                                                    border: Border.all(
                                                                        width:
                                                                            3,
                                                                        color:
                                                                            primaryColor),
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    image:
                                                                        DecorationImage(
                                                                      image: chatNotificationModel?.allNotifications?[index].dataImage !=
                                                                              null
                                                                          ? ExtendedNetworkImageProvider(
                                                                              "${APIConstants.BASE_URL}${chatNotificationModel?.allNotifications?[index].dataImage}",
                                                                              cache: true,
                                                                            )
                                                                          : const AssetImage('assets/logo.png')
                                                                              as ImageProvider,
                                                                    )),
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Text(
                                                            chatNotificationModel
                                                                    ?.allNotifications?[
                                                                        index]
                                                                    .dataName ??
                                                                "",
                                                            style: const TextStyle(
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16),
                                                          ),
                                                        ],
                                                      ),
                                                      Text(
                                                        chatNotificationModel
                                                                ?.allNotifications?[
                                                                    index]
                                                                .dataMsg ??
                                                            "",
                                                        style: const TextStyle(
                                                            color: Colors.green,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16),
                                                      )
                                                    ]),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                );
                              }),
                        ),
                      } else ...{
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(height: 80),
                            Center(
                              child: Text(
                                'No Notification yet',
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(fontSize: 18, color: colorBlack),
                              ),
                            )
                          ],
                        )
                      }
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
