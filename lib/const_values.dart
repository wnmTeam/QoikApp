import 'dart:core';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

class ConstValues {
  static Color FIRST_COLOR = Colors.white;
  static Color SECOND_COLOR = Color(0xffef5924);
  static Color THIRD_COLOR = Colors.teal[500];
  static Color FOURTH_COLOR = Color(0xff0670ba);
  static Color mainColor = Color(0xFFF05924);
  static Color altColor = Color(0xFF0571BC);
  static Color titleColor = Colors.cyan;
  static Color subTitleColor = Colors.black87;
  static Color textColor = Colors.black;
  static double fontSize_1 = 15;
  static double fontSize_2 = 22;
  static double fontSize_3 = 25;
  static double fontSize_4 = 28;
  static double fontSize_5 = 28;

  static User user;
}

final dashBoardButtonStyle = BoxDecoration(
  border: new Border.all(width: 3.0, color: ConstValues.SECOND_COLOR),
  color: Colors.white,
  borderRadius: BorderRadius.circular(10),
  boxShadow: [
    BoxShadow(
      color: Colors.grey.withOpacity(0.5),
      spreadRadius: 3,
      blurRadius: 5,
      offset: Offset(0, 3), // changes position of shadow
    ),
  ],
);

// final appNameStyle = GoogleFonts.oswald(
//   textStyle: TextStyle(
//       color: ConstValues.FOURTH_COLOR,
//       fontSize: 20,
//       fontWeight: FontWeight.w700),
// );
// final buttonTextStyle = GoogleFonts.openSans(
//     textStyle: TextStyle(
//         color: ConstValues.FOURTH_COLOR,
//         fontSize: 16,
//         fontWeight: FontWeight.w600));
// final buttonSubTitle = GoogleFonts.openSans(
//     textStyle: TextStyle(
//         color: ConstValues.FOURTH_COLOR,
//         fontSize: 14,
//         fontWeight: FontWeight.w600));
// final articleTitle = GoogleFonts.almendraDisplay(
//   textStyle: TextStyle(
//       color: ConstValues.FOURTH_COLOR,
//       fontSize: 18,
//       fontWeight: FontWeight.w600),
// );
// final articleSubTitle = GoogleFonts.rubik(
//   textStyle: TextStyle(
//       color: ConstValues.FOURTH_COLOR,
//       fontSize: 16,
//       fontWeight: FontWeight.w400),
// );
//
// final subTitleStyle = GoogleFonts.vollkorn(
//     textStyle: TextStyle(
//         color: Color(0xffa29aac), fontSize: 14, fontWeight: FontWeight.w600));
//
// final mainTitleStyle = GoogleFonts.playfairDisplay(
//     textStyle: TextStyle(
//         color: Colors.lightBlue, fontSize: 20, fontWeight: FontWeight.bold));

final kTitleStyle = TextStyle(
  color: Color(0xFF3594DD),
  fontFamily: 'CM Sans Serif',
  fontSize: 26.0,
  height: 1.5,
);
