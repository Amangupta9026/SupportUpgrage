import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:support/global/color.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../global/all_images.dart';
import '../../resusable_widget/appbar.dart';
import 'mobile_otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GlobalKey<FormState> formKey = GlobalKey();
  FocusNode mobileNumberFocusNode = FocusNode();
  final TextEditingController mobileNumberController = TextEditingController();
  String mobileNumber = "";
  int? resendTokens;

  sendFirebaseOTP() async {
    try {
      EasyLoading.show(status: 'loading...');
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: mobileNumber,
        timeout: const Duration(seconds: 120),
        verificationCompleted: (PhoneAuthCredential credential) async {},
        verificationFailed: (FirebaseAuthException e) {},
        codeSent: (String verificationId, int? resendToken) async {
          resendTokens = resendToken;
          // Update the UI - wait for the user to enter the SMS code
          EasyLoading.dismiss();

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => OTPScreen(
                        mobileNumber: mobileNumber,
                        verificationId: verificationId,
                        resendToken: resendTokens,
                      )));

          // String smsCode = '227149';

          // // Create a PhoneAuthCredential with the code
          // PhoneAuthCredential credential = PhoneAuthProvider.credential(
          //     verificationId: verificationId, smsCode: smsCode);

          // // Sign the user in (or link) with the credential
          // await FirebaseAuth.instance.signInWithCredential(credential);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          EasyLoading.dismiss();
        },
      );
    } catch (e) {
      EasyLoading.dismiss();
      log("$e");
    }
  }

  @override
  void dispose() {
    mobileNumberController.dispose();
    mobileNumberFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 4.0, 15.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const CustomBackButton(),
                      const Spacer(),
                      Image.asset(
                        appLogoTransparent,
                        // height: 80,
                        width: MediaQuery.of(context).size.width * 0.35,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(
                        width: 35,
                      ),
                      const Spacer(),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0, top: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Enter your \nmobile number',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: colorBlack,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        const Text(
                          'we will send you confirmation code',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: colorGrey,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(6, 30.0, 6, 35),
                          child: Material(
                            surfaceTintColor: Colors.white,
                            shadowColor: primaryColor,
                            elevation: 1,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IntlPhoneField(
                                controller: mobileNumberController,
                                autofocus: true,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: colorBlack,
                                ),
                                focusNode: mobileNumberFocusNode,
                                dropdownIconPosition: IconPosition.trailing,
                                disableLengthCheck: true,
                                initialCountryCode: "IN",
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  focusColor: Colors.white,
                                  hoverColor: Colors.white,
                                  suffixIcon: InkWell(
                                    onTap: () {
                                      mobileNumberController.text = "";
                                      mobileNumberFocusNode.unfocus();
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: colorRed,
                                    ),
                                  ),
                                  border: InputBorder.none,
                                ),
                                onChanged: (phone) {
                                  mobileNumber = phone.completeNumber;
                                },
                                onCountryChanged: (country) {},
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.65,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                ),
                                onPressed: () {
                                  if (mobileNumberController.text.length ==
                                      10) {
                                    sendFirebaseOTP();

                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) => OTPScreen(
                                    //               mobileNumber:
                                    //                   mobileNumberController
                                    //                       .text,
                                    //               verificationId: "111111",
                                    //               resendToken: null,
                                    //             )));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text("Enter a valid number")));
                                  }
                                },
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 14.0, bottom: 14),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.verified_user,
                                          size: 24,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "Proceed Securly",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Center(
                          child: InkWell(
                            onTap: () {
                              launchUrl(Uri.parse(
                                  "https://support2heal.com/manage/privacy_policy"));
                            },
                            child: RichText(
                              textScaleFactor: 1,
                              text: const TextSpan(
                                text: 'By clicking, I accept the ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorBlack,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'T&C',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: colorBlue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: ' and ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorBlack,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: colorBlue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
