import 'package:flutter/material.dart';

abstract final class AppRadii {
  static const r12 = 12.0;
  static const r20 = 20.0;
  static const r28 = 28.0;
  static const full = 999.0;

  static const radius12 = BorderRadius.all(Radius.circular(r12));
  static const radius20 = BorderRadius.all(Radius.circular(r20));
  static const radius28 = BorderRadius.all(Radius.circular(r28));
  static const radiusFull = BorderRadius.all(Radius.circular(full));
}
