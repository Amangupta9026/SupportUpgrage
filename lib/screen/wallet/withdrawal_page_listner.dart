import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:support/global/color.dart';
import 'package:support/screen/listner_app_ui/listner_homescreen.dart';

import '../../api/api_constant.dart';
import '../../api/api_services.dart';
import '../../core/progress_indicator/progress_container_view.dart';
import '../../model/withdrawal_model.dart';
import '../../sharedpreference/sharedpreference.dart';
import '../../widget/toast_widget.dart';

class WithdrawPage extends StatefulWidget {
  final String? bankNumber;
  final String? bankName;

  const WithdrawPage({Key? key, this.bankNumber, this.bankName})
      : super(key: key);

  @override
  WithdrawPageState createState() => WithdrawPageState();
}

class WithdrawPageState extends State<WithdrawPage> {
  final TextEditingController _amountController = TextEditingController();
  bool upiID = true, bank = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isProgressRunning = false;

  TextEditingController upiIDController = TextEditingController();
  String upiId = '';

  TextEditingController bankAccountController = TextEditingController();
  TextEditingController ifsccodeController = TextEditingController();
  TextEditingController bankNameController = TextEditingController();

  String walletAmount = "0.0";

  // WithDrawalModel commonResponseModel;

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
  }

  // Future<void> _apiWithdrawalAmount(BuildContext context) async {
  //   try {
  //     setState(() {
  //       isProgressRunning = true;
  //     });
  //     double withdrawalAmount = double.parse(_amountController.text);
  //     commonResponseModel = await APIServices.getwithDraw(
  //       paytm ? "paytm" : "bank_account",
  //       withdrawalAmount,
  //       paytmController.text,
  //     );
  //     if (commonResponseModel.status) {
  //       UtilsFlushBar.showDefaultSnackbar(context, commonResponseModel.message);

  //       setState(() {
  //         paytm = true;
  //         bank = false;
  //       });
  //       _amountController.text = "";
  //       Navigator.pop(context, true);
  //     } else {
  //       showCommonMessageDialog(context, commonResponseModel.message);
  //     }
  //   } catch (e) {
  //     showErrorDialog(context, "Server not reachable, Please Contact Admin");
  //   } finally {
  //     setState(() {
  //       isProgressRunning = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colorWhite,
      body: ProgressContainerView(
        isProgressRunning: isProgressRunning,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [_otherDetailsCard()],
            ),
          ),
        ),
      ),
      bottomNavigationBar: InkWell(
        onTap: () async {
          if (_amountController.text.isEmpty) {
            toastshowDefaultSnackbar(context, 'Please enter amount');
            return;
          }
          if (bank == true) {
            if (bankAccountController.text.isEmpty &&
                ifsccodeController.text.isEmpty &&
                bankNameController.text.isEmpty) {
              toastshowDefaultSnackbar(context, 'Please fill data');
              return;
            }
          }
          if (upiID == true && upiIDController.text.isEmpty) {
            toastshowDefaultSnackbar(context, 'Please fill upi id');
            return;
          }

          // double withdrawalAmount = double.parse(_amountController.text);

          EasyLoading.show(status: 'loading...');
          log('upiIDController.text: ${upiIDController.text}');

          WithdrawalModel? withdrawPage = await APIServices.withdrawalWalletApi(
              upiIDController.text,
              _amountController.text,
              bankAccountController.text,
              ifsccodeController.text,
              bankNameController.text);

          EasyLoading.dismiss();
          if (mounted) {
            toastshowDefaultSnackbar(context, withdrawPage?.message);
          }

          log('withdrawPage: ${withdrawPage?.toJson()}', name: 'withdrawPage');

          if (withdrawPage?.status == true &&
                  withdrawPage?.message ==
                      'Minimum withdrawal amount is 1000' ||
              withdrawPage?.message == 'Minimum withdrawal amount is 200') {
            EasyLoading.dismiss();

            if (!mounted) return;
            toastshowDefaultSnackbar(context, withdrawPage?.message);
          } else if (withdrawPage?.status == true &&
              withdrawPage?.message == 'withdrawal request send') {
            EasyLoading.dismiss();
            if (!mounted) return;
            showWithdrawalDialog(context, withdrawPage?.message ?? '');
          }
        },
        child: Card(
          elevation: 0.0,
          child: Container(
            height: 50.0,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: primaryColor,
            ),
            child: const Center(
              child: Text(
                'WITHDRAWAL',
                style: TextStyle(
                  color: colorBlack,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _otherDetailsCard() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'Your Current Amount',
                style: TextStyle(
                  color: colorBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "₹ ${SharedPreference.getValue(PrefConstants.WALLET_AMOUNT) ?? 10}",
                  style: const TextStyle(
                    color: colorBlack,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          TextFormField(
            controller: _amountController,
            maxLength: 10,
            keyboardType: const TextInputType.numberWithOptions(
                signed: true, decimal: true),
            decoration: const InputDecoration(
              filled: true,
              counterText: "",
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colorBlack, width: 1.2),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colorBlack, width: 1.2),
              ),
              disabledBorder: InputBorder.none,
              hintText: "₹ 0.0",
              hintStyle: TextStyle(
                  color: colorGrey,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600),
              fillColor: colorWhite,
            ),
          ),
          const SizedBox(height: 8.0),
          const Text(
            "Min Withdrawal ₹200",
            style: TextStyle(
              color: colorBlack,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8.0),
          Container(
            width: double.infinity,
            color: const Color(0xfff5f5f5),
            child: Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        upiID = true;
                      });
                    },
                    child: Checkbox(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: upiID,
                      activeColor: colorBlack,
                      onChanged: (bool? value) {
                        setState(() {
                          upiID = value!;
                          bank = false;
                          bankAccountController.clear();
                          bankNameController.clear();
                          ifsccodeController.clear();

                          //  bank = false;
                        });
                      },
                    ),
                  ),
                  const Text(
                    "UPI ID",
                    style: TextStyle(
                      color: colorBlack,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 30.0),
                  InkWell(
                    onTap: () {
                      setState(() {
                        bank = true;
                      });
                    },
                    child: Checkbox(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: bank,
                      activeColor: colorBlack,
                      onChanged: (bool? value) {
                        setState(() {
                          bank = value!;
                          upiID = false;
                          upiIDController.clear();
                        });
                      },
                    ),
                  ),
                  const Text(
                    "Bank",
                    style: TextStyle(
                      color: colorBlack,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14.0),

          // Paytm Click Visibility

          Visibility(
              visible: upiID == true,
              child: Container(
                width: double.infinity,
                color: const Color(0xfff5f5f5),
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 5),
                  child: Row(
                    children: [
                      const Text(
                        "UPI ID: ",
                        style: TextStyle(
                          color: colorBlack,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (upiIDController.text.isNotEmpty &&
                          upiIDController.text.contains('@'))
                        Text(
                          upiId,
                          style: const TextStyle(
                            color: colorBlack,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else
                        const Text(""),

                      // Visibility(
                      //   visible:
                      //   child: child)

                      const SizedBox(width: 14.0),
                      InkWell(
                        onTap: () {
                          showPaytmAlertDialog(context);
                        },
                        child: const Icon(
                          Icons.edit,
                          color: colorBlack,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              )),

          // Bank Click Visibility

          Visibility(
            visible: bank == true,
            child: Container(
              width: double.infinity,
              color: const Color(0xfff5f5f5),
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 10, bottom: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Text(
                            "Account no.:",
                            style: TextStyle(
                              color: colorBlack,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: bankAccountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                hintText: 'Please enter Account no.',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                )),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Text(
                            "IFSC Code",
                            style: TextStyle(
                              color: colorBlack,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: ifsccodeController,
                            decoration: const InputDecoration(
                                hintText: 'Please enter IFSC Code',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                )),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Text(
                            "Bank Name:",
                            style: TextStyle(
                              color: colorBlack,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: bankNameController,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                                hintText: 'Please enter bank name',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                )),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 14.0),
          Container(
            decoration: const BoxDecoration(
              color: colorWhite,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 8, top: 5.0, bottom: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: primaryColor,
                    width: double.infinity,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8, top: 8.0, bottom: 8),
                      child: Text(
                        "NOTE: ",
                        style: TextStyle(
                          letterSpacing: 0.2,
                          fontWeight: FontWeight.w800,
                          fontSize: 14.0,
                          color: colorWhite,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    width: double.infinity,
                    color: const Color(0xfff5f5f5),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 5.0, bottom: 5),
                      child: Text(
                        "[1]. UPI min : 200 and Maximum : 5000",
                        style: TextStyle(
                            letterSpacing: 0.2,
                            fontWeight: FontWeight.w400,
                            fontSize: 14.0,
                            color: colorBlack),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    "[2]. Bank min : 1000 and Maximum : 25,000",
                    style: TextStyle(
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.w400,
                        fontSize: 14.0,
                        color: colorBlack),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    width: double.infinity,
                    color: const Color(0xfff5f5f5),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 5.0, bottom: 5),
                      child: Text(
                        "[3]. Please check UPI ID for submitting UPI withdrawal",
                        style: TextStyle(
                            letterSpacing: 0.2,
                            fontWeight: FontWeight.w400,
                            fontSize: 14.0,
                            color: colorBlack),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    "[4]. Please check Bank Account number for submitting Bank withdrawal",
                    style: TextStyle(
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.w400,
                        fontSize: 14.0,
                        color: colorBlack),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    width: double.infinity,
                    color: const Color(0xfff5f5f5),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 5.0, bottom: 5),
                      child: Text(
                        "[5]. After Submission of withdrawal, you will get a withdrawal amount in your account within 24 hours",
                        style: TextStyle(
                            letterSpacing: 0.2,
                            fontWeight: FontWeight.w400,
                            fontSize: 14.0,
                            color: colorBlack),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getBankDetailsCard() {
    //  String bankAccountNumber = widget.bankAccountDocuments.bankAccountNumber;
    //  String secure = bankAccountNumber.replaceAll(RegExp(r'.(?=.{4})'), '*');

    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: const [
            // widget.bankAccountDocuments.ifscCode ? "dd" :
            // if (widget.bankAccountDocuments.ifscCode != null &&
            //     widget.bankAccountDocuments.ifscCode.contains('SBI'))
            //   Image.asset(
            //     IconImgConstants.SBI_LOGO,
            //     height: 40.0,
            //     width: 40.0,
            //   )

            // else if (widget.bankAccountDocuments.ifscCode != null &&
            //     widget.bankAccountDocuments.ifscCode.contains('ORBC'))
            //   Image.asset(
            //     IconImgConstants.ORIENTAL_LOGO,
            //     height: 40.0,
            //     width: 40.0,
            //   )
            // else if (widget.bankAccountDocuments.ifscCode != null &&
            //     widget.bankAccountDocuments.ifscCode.contains('PUNB'))
            //   Image.asset(
            //     IconImgConstants.PNB_LOGO,
            //     height: 40.0,
            //     width: 40.0,
            //   )
            // else if (widget.bankAccountDocuments.ifscCode != null &&
            //     widget.bankAccountDocuments.ifscCode.contains('HDFC'))
            //   Image.asset(
            //     IconImgConstants.HDFC_LOGO,
            //     height: 40.0,
            //     width: 40.0,
            //   )
            // else if (widget.bankAccountDocuments.ifscCode != null &&
            //     widget.bankAccountDocuments.ifscCode.contains('ICIC'))
            //   Image.asset(
            //     IconImgConstants.ICICI_LOGO,
            //     height: 40.0,
            //     width: 40.0,
            //   )
            // else if (widget.bankAccountDocuments.ifscCode != null &&
            //     widget.bankAccountDocuments.ifscCode.contains('UTI'))
            //   Image.asset(
            //     IconImgConstants.AXIS_LOGO,
            //     height: 40.0,
            //     width: 40.0,
            //   )
            // else
            //   Image.asset(
            //     IconImgConstants.IC_BANK_IMAGE,
            //     height: 40.0,
            //     width: 40.0,
            //   ),
            SizedBox(width: 20.0),
          ],
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context, String message) {
    //  set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        // Navigator.pushReplacement(context,
        //     MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      // title: Text("My title"),
      content: Text(message),
      actions: [
        okButton,
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

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  showPaytmAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text(
        "Cancel",
        style: TextStyle(
          color: colorBlack,
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget okButton = TextButton(
        child: const Text(
          "OK",
          style: TextStyle(
            color: colorBlack,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        onPressed: () {
          if (upiIDController.text.isEmpty) {
            Navigator.pop(context);
            Fluttertoast.showToast(
                msg: "Please enter your UPI ID",
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1);
          } else if (upiIDController.text.isNotEmpty &&
              upiIDController.text.contains('@')) {
            Navigator.pop(context);
          } else {
            Fluttertoast.showToast(
                msg: "Please enter valid UPI ID",
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1);
            // Navigator.pushReplacement(
            //     context,
            //     MaterialPageRoute(
            //         builder: (BuildContext context) =>
            //             WithdrawalSuccessScreen(
            //               amount: _amountController.text,
            //               paymentType: "Paytm",
            //               paytmNumber: paytmController.text,
            //             )));
          }
          {}
        });

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.only(left: 10.0),
      titlePadding: const EdgeInsets.all(0.0),
      // insetPadding: EdgeInsets.all(0.0),
      title: const Padding(
        padding: EdgeInsets.only(left: 15.0, top: 15),
        child: Text(
          "Enter UPI ID",
          style: TextStyle(
            color: colorBlack,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      content: SizedBox(
        width: double.infinity,
        child: TextField(
          controller: upiIDController,
          decoration: const InputDecoration(
            // border: OutlineInputBorder(),
            hintText: 'Enter your UPI ID',
            hintStyle: TextStyle(
              color: colorGrey,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          onChanged: (text) {
            setState(() {
              upiId = text;
            });
          },
        ),
      ),
      actions: [
        cancelButton,
        okButton,
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

  // Withdrawal alert

  showWithdrawalDialog(BuildContext context, String message) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const ListnerHomeScreen()),
            (Route<dynamic> route) => false);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      title: const Text("Successfully"),
      content: Text(message),
      actions: [
        okButton,
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
}
