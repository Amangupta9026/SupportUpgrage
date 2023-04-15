import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About us'),
      ),
      body: const SafeArea(
          child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text(
            "Support - Let's talk is a start up created to provide support to individuals who are going through their tough  and emotional journey, not able to cope up with the adversity. Our listeners are trained to provide non-judgemental support and will respect your confidentiality. We believe that everyone deserves to have someone to talk to, and we hope that our service can provide some comfort and relief to those who need it. If you are feeling lost or alone, don't hesitate to reach out to us. We are here to help. Let's talk"),
      )),
    );
  }
}
