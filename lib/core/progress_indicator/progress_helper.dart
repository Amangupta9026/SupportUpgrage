import 'package:flutter/material.dart';

import '../../global/color.dart';

class ProgressWidget extends StatelessWidget {
  final String? progressText;

  const ProgressWidget({this.progressText, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation(primaryColor),
        ),
      ),
    );
  }
}
