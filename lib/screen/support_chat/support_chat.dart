import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/api_services.dart';
import '../../model/support_chat_model.dart';

class SupportChat extends StatefulWidget {
  const SupportChat({super.key});

  @override
  State<SupportChat> createState() => _SupportChatState();
}

class _SupportChatState extends State<SupportChat> {
  bool isProgressRunning = false;
  SupportChatModel? supportChatModel;
  late final Uri url;

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
        }
      }
    } catch (e) {
      log(e.toString());
    } finally {
      setState(() {
        isProgressRunning = false;
      });
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

  @override
  void initState() {
    super.initState();
    apiSupportChat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back)),
        title: const Text('Support'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 20, 15, 30),
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: supportChatModel?.allMessages?.length ?? 0,
                scrollDirection: Axis.vertical,
                physics: const ScrollPhysics(),
                itemBuilder: (context, index) {
                  supportChatModel?.allMessages?[index].link != null &&
                      supportChatModel!.allMessages![index].link!.isNotEmpty;
                  final Uri url = Uri.parse(
                      supportChatModel?.allMessages?[index].link ?? '');

                  Future<void> launchUrlInApp() async {
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  }

                  return Column(
                    children: [
                      Container(
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
                          title: Text(
                              supportChatModel?.allMessages?[index].title ??
                                  ''),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  supportChatModel
                                          ?.allMessages?[index].message ??
                                      '',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (supportChatModel
                                            ?.allMessages?[index].link !=
                                        null &&
                                    supportChatModel!.allMessages![index].link!
                                        .isNotEmpty) ...{
                                  const SizedBox(height: 6),
                                  InkWell(
                                    onTap: () {
                                      launchUrlInApp();
                                    },
                                    child: Text(
                                      supportChatModel
                                              ?.allMessages?[index].link ??
                                          '',
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                }
                              ],
                            ),
                          ),
                          leading: CachedNetworkImage(
                            imageUrl:
                                supportChatModel?.allMessages?[index].image ??
                                    '',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Image.asset(
                              "assets/logo.png",
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                            placeholder: (context, url) => Image.asset(
                              "assets/logo.png",
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }
}
