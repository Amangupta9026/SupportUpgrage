import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../api/api_constant.dart';
import '../../api/api_services.dart';
import '../../global/color.dart';
import '../../model/feedback_model.dart';
import '../../sharedpreference/sharedpreference.dart';
import '../../widget/toast_widget.dart';
import '../home/home_screen.dart';

class FeedbackScreen extends StatefulWidget {
  final String listenerId;
  const FeedbackScreen({super.key, required this.listenerId});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final feedbackController = TextEditingController();
  double ratingStore = 5;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    feedbackController.dispose();
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Enter your feedback",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            const SizedBox(height: 100),
            RatingBar.builder(
              initialRating: 5,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 30,
              itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: primaryColor,
                size: 30,
              ),
              onRatingUpdate: (rating) {
                ratingStore = rating;
              },
            ),
            const SizedBox(height: 25),
            TextField(
              controller: feedbackController,
              decoration: const InputDecoration(
                hintText: 'Enter your feedback',
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    child: const Text("Skip"),
                    onPressed: () async {
                      if (!mounted) return;
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const HomeScreen()),
                          (Route<dynamic> route) => false);
                    }),
                // set up the button
                TextButton(
                  child: const Text("OK"),
                  onPressed: () async {
                    EasyLoading.show(status: 'loading...');
                    FeedBackModel? feedBackModel =
                        await APIServices.feedbackAPI(
                            SharedPreference.getValue(
                                PrefConstants.MERA_USER_ID),
                            widget.listenerId.toString(),
                            ratingStore.toString(),
                            feedbackController.text);

                    if (feedBackModel?.status == true) {
                      // await stopWatchTimer.dispose();
                      EasyLoading.dismiss();
                      if (!mounted) return;
                      toastshowDefaultSnackbar(
                          context, 'Thank you for your feedback');

                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const HomeScreen()),
                          (Route<dynamic> route) => false);
                    } else {
                      EasyLoading.dismiss();
                      if (!mounted) return;
                      toastshowDefaultSnackbar(context, 'Something went wrong');
                    }
                  },
                ),
              ],
            )
          ],
        ),
      )),
    );
  }
}
