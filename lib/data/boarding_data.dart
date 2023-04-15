import 'package:flutter/material.dart';

class OnboardingModel {
  final String title;
  final String subtitle;
  final String image;
  OnboardingModel(
      {required this.image, required this.title, required this.subtitle});
}

class OnboardingData {
  static final List<OnboardingModel> onboardingData = [
    OnboardingModel(
      title: "Take a step forward",
      image: "assets/images/boarding1.jpg",
      subtitle:
          "Gratitude is the most heartwarming\nfeeling. Praise someone in the\neasiest way possible",
    ),
    OnboardingModel(
      title: "Talk anonymously ",
      image: "assets/images/boarding2.jpg",
      subtitle:
          "Browse kudos list. See what your\ncommunity is up to and\nget inspired",
    ),
    OnboardingModel(
      title: "Make a difference",
      image: "assets/images/boarding3.jpg",
      subtitle: "Do your best in your day to day life\nand unlock achievements",
    ),
  ];

  static AnimatedContainer buildDots({
    required int index,
    required int currentPage,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(50),
        ),
        color: Color(0xFF293241),
      ),
      margin: const EdgeInsets.only(right: 5),
      height: 10,
      curve: Curves.easeIn,
      width: currentPage == index ? 20 : 10,
    );
  }
}
