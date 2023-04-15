import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../global/color.dart';

class CustomBackButton extends StatefulWidget {
  const CustomBackButton({Key? key}) : super(key: key);

  @override
  State<CustomBackButton> createState() => _CustomBackButtonState();
}

class _CustomBackButtonState extends State<CustomBackButton> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadowColor: primaryColor,
        child: Container(
          decoration: BoxDecoration(
            color: colorWhite,
            borderRadius: BorderRadius.circular(10),
          ),
          height: 38,
          width: 38,
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Center(
              child: Padding(
                padding: EdgeInsets.only(left: 6.0),
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 16,
                  color: colorBlack,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Share Button

class CustomShareButton extends StatefulWidget {
  const CustomShareButton({Key? key}) : super(key: key);

  @override
  State<CustomShareButton> createState() => _CustomShareButtonState();
}

class _CustomShareButtonState extends State<CustomShareButton> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadowColor: primaryColor,
        child: Container(
          decoration: BoxDecoration(
            color: colorWhite,
            borderRadius: BorderRadius.circular(10),
          ),
          height: 38,
          width: 38,
          child: InkWell(
            onTap: () {
              Share.share(
                  'https://play.google.com/store/apps/details?id=com.example.support&hl=en_IN&gl=US',
                  subject: 'Look what I made!');
            },
            child: const Center(
              child: Icon(
                Icons.share,
                size: 16,
                color: colorBlack,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
