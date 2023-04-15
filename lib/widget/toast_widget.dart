import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:support/global/color.dart';

void toastshowDefaultSnackbar(BuildContext context, content) {
  Fluttertoast.showToast(
      msg: content,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: colorBlack,
      textColor: Colors.white,
      fontSize: 14.0);
}
