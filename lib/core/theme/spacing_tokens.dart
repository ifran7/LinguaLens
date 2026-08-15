import 'package:flutter/widgets.dart';

class AppSpacing {
  const AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const hero = 32.0;

  static const screen = EdgeInsets.symmetric(horizontal: lg);
  static const compactCard = EdgeInsets.all(lg);
  static const card = EdgeInsets.all(xxl);
}

class AppRadii {
  const AppRadii._();

  static const chip = 8.0;
  static const field = 12.0;
  static const card = 16.0;
  static const hero = 20.0;
  static const sheet = 24.0;
}
