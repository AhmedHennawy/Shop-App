import 'package:flutter/material.dart';

class CustompageTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    if (route.isFirst) {
      return child;
    }
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
