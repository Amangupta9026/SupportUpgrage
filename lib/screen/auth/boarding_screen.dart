import 'package:flutter/material.dart';
import 'package:support/screen/auth/login_screen.dart';

import '../../data/boarding_data.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({Key? key}) : super(key: key);

  @override
  OnBoardingState createState() => OnBoardingState();
}

class OnBoardingState extends State<OnBoarding> {
  final pageController = PageController();
  int currentPage = 0;

  final List<OnboardingModel> splashData = OnboardingData.onboardingData;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: pageController,
                itemCount: splashData.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 30.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 15.0),
                        child: Text(
                          splashData[index].title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF424242),
                          ),
                        ),
                      ),
                      // Text(
                      //   splashData[index].subtitle,
                      //   textAlign: TextAlign.center,
                      //   style: TextStyle(
                      //     fontSize: 15,
                      //     color: Colors.grey[400],
                      //     height: 1.5,
                      //   ),
                      // ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 12 / 9,
                          child: Image.asset(
                            splashData[index].image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  );
                },
                onPageChanged: (value) =>
                    mounted ? setState(() => currentPage = value) : null,
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        splashData.length,
                        (int index) => OnboardingData.buildDots(
                            index: index, currentPage: currentPage),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: ElevatedButton(
                        onPressed: () {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeIn,
                          );
                          if (currentPage + 1 == splashData.length) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                            );
                          }
                        },
                        child: Text(
                          currentPage + 1 == splashData.length
                              ? 'Let\'s talk'
                              : 'Next',
                          style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),

                        // color: const Color(0xFF68B684),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
