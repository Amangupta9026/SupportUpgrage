import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:support/global/color.dart';

import '../../api/api_constant.dart';
import '../../sharedpreference/sharedpreference.dart';
import '../drawer/drawer.dart';
import '../in_app_update/in_app_update.dart';
import '../wallet/wallet_screen.dart';
import 'helper_screen.dart';
import 'inbox_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isInboxVisible = true;
  final GlobalKey<ScaffoldState> _scaffoldStateKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    UpdateChecker.checkForUpdate();
    log(SharedPreference.getValue(PrefConstants.MOBILE_NUMBER),
        name: 'Mobile Number');
    log(SharedPreference.getValue(PrefConstants.MERA_USER_ID), name: 'User Id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldStateKey,
        drawer: const DrawerScreen(),
        appBar: AppBar(
          leading: InkWell(
            onTap: () {
              _scaffoldStateKey.currentState?.openDrawer();
            },
            child: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WalletScreen()));
                },
                child: const Icon(
                  Icons.wallet,
                  size: 26,
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
                      InboxScreen(),
                      HelperScreen(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
