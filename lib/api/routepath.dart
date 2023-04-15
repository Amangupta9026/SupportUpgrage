import 'package:flutter/material.dart';

import '../screen/auth/boarding_screen.dart';

Route generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case RoutePath.initRoutePath:
      return MaterialPageRoute(builder: (context) => const OnBoarding());

    default:
      return MaterialPageRoute(builder: (context) => const OnBoarding());
   
  }
}

class RoutePath {
  static const String initRoutePath = "/";
}
