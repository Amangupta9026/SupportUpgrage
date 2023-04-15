import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:support/global/color.dart';

class ShimmerProgressWidget extends StatelessWidget {
  final int? count;
  final bool? isProgressRunning;

  const ShimmerProgressWidget({this.count, this.isProgressRunning, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      enabled: isProgressRunning!,
      child: ListView.builder(
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: colorWhite,
              ),
            ),
            child: Column(
              children: [
                // Center(
                //   child: Container(
                //     width: 100.0,
                //     height: 8.0,
                //     color: Colors.white,
                //   ),
                // ),
                const SizedBox(height: 12.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 100.0,
                          height: 8.0,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 6.0),
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(60.0),
                              child: Container(
                                width: 50.0,
                                height: 50.0,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6.0),
                            Container(
                              width: 40.0,
                              height: 8.0,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 100.0),
                    Column(
                      children: [
                        Container(
                          width: 100.0,
                          height: 8.0,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 6.0),
                        Row(
                          children: [
                            Container(
                              width: 40.0,
                              height: 8.0,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6.0),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(60.0),
                              child: Container(
                                width: 50.0,
                                height: 50.0,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        itemCount: 8,
      ),
    );
  }
}

// class MyWidget extends StatelessWidget {
//   const MyWidget({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
    
//   }
// }
