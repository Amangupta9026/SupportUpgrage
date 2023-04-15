import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support/api/api_services.dart';
import 'package:support/global/color.dart';

import '../../api/api_constant.dart';
import '../../model/listner/listner_availability_model.dart';
import '../../model/listner/listner_chat_request_model.dart';
import '../../model/listner/togglebutton_on_off_model.dart';
import '../../sharedpreference/sharedpreference.dart';
import '../drawer/drawer.dart';
import '../home/helper_screen.dart';
import '../in_app_update/in_app_update.dart';
import '../wallet/wallet_screen.dart';
import 'listner_chat_request_screen.dart';
import 'listner_inbox.dart';
import 'listner_wallet.dart/listner_wallet.dart';

class ListnerHomeScreen extends StatefulWidget {
  const ListnerHomeScreen({Key? key}) : super(key: key);

  @override
  State<ListnerHomeScreen> createState() => _ListnerHomeScreenState();
}

class _ListnerHomeScreenState extends State<ListnerHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isInboxVisible = true;
  final GlobalKey<ScaffoldState> _scaffoldStateKey = GlobalKey<ScaffoldState>();
  bool status = false;
  bool isListener = false, isProgressRunning = false;
  ListnerAvaiabilityModel? listnerAvaiabilityModel;

  ListnerChatRequest? getListnerRequest = ListnerChatRequest();

  Timer? _timer;
  bool isFirstCall = true;
  bool loading = true;

  // Listner Chat Request

  Future<ListnerChatRequest?> apigetListnerRequest() async {
    try {
      getListnerRequest = await APIServices.listnerChatRequestAPI();

      if (getListnerRequest?.requestedCount != null &&
          (getListnerRequest?.requestedCount)! > 0) {
        _timer?.cancel();
        if (mounted) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => ListnerChatRequestScreen(
                        requestid: getListnerRequest?.requests?[0].id ?? 0,
                        fromid: getListnerRequest?.requests?[0].fromId ?? '0',
                      )));
        }
      }
    } catch (e) {
      log(e.toString());
    }

    return null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
    _timer?.cancel();
  }

  void firstCall() {
    loading = true;
    _timer = Timer.periodic(
        const Duration(seconds: 5), (Timer t) => apigetListnerRequest());
  }

  @override
  void initState() {
    super.initState();
    firstCall();

    status = SharedPreference.getValue(PrefConstants.ONLINE) ?? false;
    if (status) {
      APIServices.makeUserNotBusy();
    }
    _tabController = TabController(length: 2, vsync: this);
    checkListener();
    UpdateChecker.checkForUpdate();
    log(SharedPreference.getValue(PrefConstants.MOBILE_NUMBER),
        name: 'Mobile Number');
    log(SharedPreference.getValue(PrefConstants.MERA_USER_ID), name: 'User Id');
  }

  checkListener() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isListener = prefs.getBool("isListener")!;
    setState(() {});
  }

  List<String> listnerAvailablility = ['Chat', 'Call', 'Chat & Call'];
  String? dropdownValue = 'Chat & Call';

  // Listner Availability API

  Future<void> apiListnerAvailability(String selectAvailability) async {
    try {
      setState(() {
        isProgressRunning = true;
      });
      listnerAvaiabilityModel =
          await APIServices.listnerAvaiabilityModel(selectAvailability);
    } catch (e) {
      log(e.toString());
    } finally {
      setState(() {
        isProgressRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: colorWhite,
        key: _scaffoldStateKey,
        drawer: const DrawerScreen(),
        appBar: AppBar(
          foregroundColor: colorWhite,
          iconTheme: const IconThemeData(color: colorWhite),
          leading: IconButton(
            icon: const Icon(Icons.menu, color: colorWhite),
            onPressed: () {
              _scaffoldStateKey.currentState!.openDrawer();
            },
          ),
          centerTitle: false,
          title: Row(
            children: [
              CupertinoSwitch(
                  trackColor: Colors.grey,
                  // activeText: '',
                  // inactiveText: '',
                  // inactiveColor: colorGrey,
                  // width: 45.0,
                  // height: 20.0,
                  // toggleSize: 20.0,
                  value: status,
                  // borderRadius: 20.0,
                  // padding: 0,
                  // showOnOff: true,
                  onChanged: (val) async {
                    // val = true;
                    EasyLoading.show(status: 'loading...');
                    ToggleButtonONOFFModel? toggleButtonONOFFModel =
                        await APIServices.toggleButtonONOFFModel(
                      SharedPreference.getValue(PrefConstants.MERA_USER_ID),
                    );
                    if (toggleButtonONOFFModel?.status == true) {
                      EasyLoading.dismiss();
                      if (toggleButtonONOFFModel?.data?.onlineStatus == '1') {
                        EasyLoading.showSuccess('Online');
                        // await APIServices.getBusyOnline(
                        //   'false',
                        //   SharedPreference.getValue(PrefConstants.MERA_USER_ID),
                        // );
                      } else if (toggleButtonONOFFModel?.data?.onlineStatus ==
                          '0') {
                        EasyLoading.showSuccess('Offline');
                      }
                    }
                    setState(() {
                      status = val;
                    });
                    SharedPreference.setValue(PrefConstants.ONLINE, val);
                    log('clock');
                    EasyLoading.dismiss();
                  }),
              const SizedBox(width: 20),
              Expanded(
                child: DropdownButtonFormField<String>(
                  iconEnabledColor: colorWhite,
                  isDense: true,
                  icon: const SizedBox(),
                  // isExpanded: false,
                  selectedItemBuilder: (context) {
                    return listnerAvailablility.map((String value) {
                      return Row(
                        children: [
                          Text(
                            SharedPreference.getValue(
                                    PrefConstants.LISTNER_AVAILABILITY) ??
                                value,
                            style: const TextStyle(
                                color: colorWhite,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: colorWhite,
                          )
                        ],
                      );
                    }).toList();
                  },
                  decoration: const InputDecoration(
                      labelStyle: TextStyle(color: colorWhite)),
                  style: const TextStyle(color: colorWhite),
                  value: dropdownValue,
                  items: listnerAvailablility.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(
                            color: colorBlack,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (SharedPreference.getValue(
                            PrefConstants.LISTNER_AVAILABILITY) ==
                        value) {
                      return;
                    }
                    apiListnerAvailability(value!);
                    log(value, name: 'selection');
                    SharedPreference.setValue(
                        PrefConstants.LISTNER_AVAILABILITY, value);
                    setState(() {
                      dropdownValue = value;
                    });
                  },
                ),
              )
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: InkWell(
                onTap: () {
                  isListener
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ListnerWalletScreen()))
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const WalletScreen()));
                },
                child: Row(
                  children: const [
                    // Text(
                    //   'Rs 250',
                    // ),
                    // SizedBox(
                    //   width: 10,
                    // ),
                    Icon(
                      Icons.wallet,
                      size: 26,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 14,
            )
          ],
        ),
        body: SafeArea(
          child: SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 40.0, right: 40),
                  child: TabBar(
                    indicatorWeight: 1,
                    indicator: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Colors.black, width: 4))),
                    unselectedLabelColor: Colors.black,
                    labelColor: Colors.black,
                    indicatorColor: colorBlue,
                    tabs: [
                      Tab(
                        child: Column(
                          children: const [
                            SizedBox(
                              height: 12,
                            ),
                            Text("Inbox"),
                          ],
                        ),
                      ),
                      Tab(
                        child: Column(
                          children: const [
                            SizedBox(
                              height: 12,
                            ),
                            Text("All"),
                          ],
                        ),
                      )
                    ],
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      ListnerInboxScreen(),
                      HelperScreen(),
                      // ListnerInboxScreen(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
