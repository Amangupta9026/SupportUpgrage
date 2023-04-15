import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:support/global/color.dart';

import '../../api/api_constant.dart';
import '../../api/api_services.dart';
import '../../model/addmoneyinwallet.dart';
import '../../model/razorpay_orderid.dart';
import '../../sharedpreference/sharedpreference.dart';
import '../../widget/toast_widget.dart';

class RechargeAmountData {
  String amount;
  bool isSelected;
  RechargeAmountData({required this.amount, required this.isSelected});
}

class RechargeScreen extends StatefulWidget {
  const RechargeScreen({Key? key}) : super(key: key);

  @override
  State<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {
  List<RechargeAmountData> rechargeAmountData = [
    // RechargeAmountData(amount: "1", isSelected: false),
    RechargeAmountData(amount: "99", isSelected: false),
    RechargeAmountData(amount: "199", isSelected: false),
    RechargeAmountData(amount: "299", isSelected: false),
    RechargeAmountData(amount: "499", isSelected: true),
    RechargeAmountData(amount: "999", isSelected: false),
    RechargeAmountData(amount: "2499", isSelected: false),
    RechargeAmountData(amount: "4999", isSelected: false),
    RechargeAmountData(amount: "9999", isSelected: false),
  ];
  String amount = "499";
  bool isProgressRunning = false;
  Razorpay? _razorPayGateWay;
  String? orderId, paymentId, signature;
  String? digit6OrderId = "";
  int amounytController = 100;

  @override
  void initState() {
    super.initState();

    _razorPayGateWay = Razorpay();
    _razorPayGateWay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorPayGateWay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorPayGateWay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    AddMoneyIntoWalletModel? addMoneyIntoWalletModel =
        await APIServices.addMoneyintoWallet(
      userId: SharedPreference.getValue(PrefConstants.MERA_USER_ID),
      amount: amount,
      mobileNumber: SharedPreference.getValue(PrefConstants.MOBILE_NUMBER),
      orderId: orderId ?? "",
      paymentId: response.paymentId ?? "",
      signatureId: response.signature ?? "done",
    );
    if (addMoneyIntoWalletModel != null) {
      if (mounted) {
        toastshowDefaultSnackbar(context, 'Your money added successfully');
        // UtilsFlushBar.showDefaultSnackbar(
        //     context, "Your money added successfully");
      }
    }
    log("Response Success $response");
    orderId = response.orderId;
    paymentId = response.paymentId;
    // signature = response.signature;
    log("ORDERID :: ${response.orderId}");
    log("PAYMENT ID :: ${response.paymentId}");
    // log("SIGNATURE :: ${response.signature}");
    // Future.delayed(Duration.zero, () {
    //   _addMoneyIntoWallet();
    // });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    toastshowDefaultSnackbar(context, 'Transaction Failed');
    // UtilsFlushBar.showDefaultSnackbar(context, "Transaction Failed");
    log(response.message.toString());
    log("Error code :: ${response.code}");
    log("Error Message :: ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    log("External wallet name :: ${response.walletName}");
  }

  // Razor Pay

  Future<void> _createNewOrder() async {
    try {
      setState(() {
        isProgressRunning = true;
      });
      RazorPayOrderIdModel myOrderDetails =
          await APIServices.get6digitOrderId(amounytController * 100);
      if (myOrderDetails.status == true) {
        log("${myOrderDetails.data} ", name: "orderId");
        orderId = myOrderDetails.data.toString();
        await openPaymentOption(myOrderDetails.data ?? 0);
      }
    } catch (e) {
      log(e.toString());
      // showErrorDialog(context, e);
    } finally {
      setState(() {
        isProgressRunning = false;
      });
    }
  }

  Future<void> openPaymentOption(int orderId) async {
    var options = {
      'key': 'rzp_live_8nVAaVtEFUQGAF',
      // 'rzp_live_5HtAsZL4CVxxEn',
      // 'rzp_live_iSBhk5iKjYbeDb', // support
      // 'orderId': orderId,
      'amount': (num.parse(amount) * 100),
      'name': 'Support',
      'description': 'Add Amount into wallet',
      'orderId': orderId,
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': '${SharedPreference.getValue(PrefConstants.MOBILE_NUMBER)}',
        'email': 'enter your email',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorPayGateWay?.open(options);
    } catch (e) {
      debugPrint('Error: e');
      log(e.toString());
    }
  }

  @override
  void dispose() {
    super.dispose();
    _razorPayGateWay?.clear();
  }

  // Get Wallet Api Method

  Future<void> getWalletData() async {
    try {
      setState(() {
        isProgressRunning = true;
      });
      String? myWalletResp = await APIServices.getWalletAmount(
          SharedPreference.getValue(PrefConstants.MERA_USER_ID));

      if (myWalletResp != null) {
        SharedPreference.setValue(PrefConstants.WALLET_AMOUNT, myWalletResp);
      }
    } catch (error) {
      log(error.toString());
      // showErrorDialog(context, error);
    } finally {
      setState(() {
        isProgressRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25))),
            onPressed: () async {
              await _createNewOrder();
              // _handlePaymentSuccess(PaymentSuccessResponse("0", "0", "0"));
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "RECHARGE",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          )
        ],
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Wrap(
                children: [
                  for (int i = 0; i < rechargeAmountData.length; i++) ...{
                    InkWell(
                      onTap: () {
                        if (mounted) {
                          setState(() {
                            rechargeAmountData[i].isSelected = true;
                            amount = rechargeAmountData[i].amount;
                            for (int j = 0;
                                j < rechargeAmountData.length;
                                j++) {
                              if (i != j) {
                                rechargeAmountData[j].isSelected = false;
                              }
                            }
                          });
                        }
                      },
                      child: Container(
                        margin:
                            const EdgeInsets.only(left: 10, top: 20, right: 20),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(25)),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              rechargeAmountData[i].isSelected
                                  ? Container(
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: primaryColor),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    )
                                  : const SizedBox(),
                              const SizedBox(
                                width: 8,
                              ),
                              Text("₹ ${rechargeAmountData[i].amount}/-"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  },
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recharge Details",
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Amount:"),
                      Text("₹ $amount.0"),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Talktime",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("$amount.0"),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Amount payable",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "₹ $amount.0",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}
