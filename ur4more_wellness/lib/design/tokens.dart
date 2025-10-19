import 'package:flutter/material.dart';

/// Spacing scale (dp)
class AppSpace {
  static const x1 = 4.0;
  static const x2 = 8.0;
  static const x3 = 12.0;
  static const x4 = 16.0;
  static const x5 = 20.0;
  static const x6 = 24.0;
  static const x8 = 32.0;
  static const x10 = 40.0;
  static const x12 = 48.0;
}

/// Radii
class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
}

/// Elevations
class AppElev {
  static const none = 0.0;
  static const low = 1.0;
  static const md  = 2.0;
  static const hi  = 4.0;
}

/// Content width caps (for cards/containers)
class AppMaxW {
  static const phone = 430.0; // overall app max width
  static const card  = 360.0; // typical card/container max width
}

/// Shared paddings
class Pad {
  static const page = EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x2);
  static const card = EdgeInsets.all(AppSpace.x5);
}

/// Typography helpers
class AppText {
  static const button = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  static const title  = TextStyle(fontSize: 20, fontWeight: FontWeight.w700);
  static const body   = TextStyle(fontSize: 14, height: 1.35);
  static const mutED  = TextStyle(color: Colors.black54);
}






