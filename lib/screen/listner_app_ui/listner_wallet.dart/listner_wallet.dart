import 'dart:async';

import 'package:flutter/material.dart';
import 'package:support/api/api_services.dart';
import 'package:support/global/color.dart';
import 'package:support/screen/wallet/transaction_screen.dart';

import '../../../api/api_constant.dart';
import '../../../sharedpreference/sharedpreference.dart';
import '../../wallet/withdrawal_page_listner.dart';

class ListnerWalletScreen extends StatefulWidget {
  const ListnerWalletScreen({Key? key}) : super(key: key);

  @override
  State<ListnerWalletScreen> createState() => _ListnerWalletScreenState();
}

class _ListnerWalletScreenState extends State<ListnerWalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String walletAmount = "0.0";
  Timer? _timer;
  bool isFirstCall = true;

   @override
  void dispose() {
  _timer?.cancel();
    super.dispose();
    _timer?.cancel();
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
      });
    });
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back, color: colorWhite)),
          bottom: TabBar(
            padding: const EdgeInsets.only(left: 40, right: 40),
            controller: _tabController,
            tabs: const [
              Tab(
                  icon: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text("Withdrawal", style: TextStyle(color: colorWhite)),
              )),
              Tab(
                  icon: FittedBox(
                fit: BoxFit.fitWidth,
                child:
                    Text("Transactions", style: TextStyle(color: colorWhite)),
              )),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0, top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "₹ $walletAmount /-",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  const Text(
                    "Current Balance",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: const [
              WithdrawPage(),
              TransactionScreen(),
            ],
          ),
        ));
  }
}
