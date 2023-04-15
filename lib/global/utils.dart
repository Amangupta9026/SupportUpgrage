import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUtils {
  static launchURL(String url) async => await canLaunchUrl(Uri.parse(url))
      ? await launchUrl(Uri.parse(url))
      : throw 'Could not launch $url';

  static Future<void> handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    debugPrint(status.toString());
  }
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}

extension PhoneNumber on String {
  bool isPhoneNumber() {
    return RegExp(r'^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$')
        .hasMatch(this);
  }
}

// extension AbuseMessage on String {
//   bool isAbuseMessage() {
//     return RegExp(
//             'sex|madharchod|madhar|chod|Madhar|Chod|behenchod|bhosdike|madhar chod|Sex|Madharchod|hole|HOLE|Hole|MADHARCHOD|SEX|BEHENCHOD|Behenchod|Behen chod|BEHEN CHOD|behen chod|BHOSDIKE|ass|Ass|ASS|cock|Cock|COCK|MOTHERFUCKER|Mother Fucker|MotherFucker|motherfucker|SisterFucking|sisterfucking|FUCK|fuck|fucking|Asshole|ASSHOLE|asshole|fuckyou|fuck you|Fuck you|FUCK YOU |id|ID|FACEBOOK|facebook|INSTA|insta|instagran|INSTAGRAM')
//         .hasMatch(this);
//   }
// }

// extension KeyPaDSpecialWord on String {
//   bool isKeyPaDSpecialWord() {
//     return RegExp(r'^(\+\d#@!{1,2}\s)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$')
//         .hasMatch(this);
//   }
// }

extension SocialSite on String {
  bool isSocialSite() {
    return RegExp('@.com|@|.com|WWW|'.toLowerCase()).hasMatch(this);
  }
}

// extension SocialSite on String {
//   bool isSocialSite() {
//     return RegExp('@.com|@|.com|.COM|www|WWW|Www').hasMatch(this);
//   }
// }

bool checkEmpty(mixedVar) {
  //print('checkEmpty in 1');
  if (mixedVar is List || mixedVar is Map) {
    if (mixedVar.isEmpty) {
      return true;
    }
  } else {
    //print('checkEmpty in 2');
    var undef;
    var undefined;
    int i;
    var emptyValues = [
      undef,
      null,
      'null',
      'Null',
      'NULL',
      false,
      0,
      '',
      '0',
      '0.00',
      '0.0',
      'empty',
      undefined,
      'undefined'
    ];
    var len = emptyValues.length;
    if (mixedVar is String) {
      mixedVar = mixedVar.trim();
    }

    for (i = 0; i < len; i++) {
      if (mixedVar == emptyValues[i]) {
        return true;
      }
    }
  }
  return false;
}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
final Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
