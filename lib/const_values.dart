import 'dart:core';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

class ConstValues {

  static Color secondColor = Color(0xffff4463);
  static Color titleColor = Colors.cyan;
  static Color subTitleColor = Colors.black87;
  static Color textColor = Colors.black;
  static double fontSize_1 = 15;
  static double fontSize_2 = 22;
  static double fontSize_3 = 25;
  static double fontSize_4 = 28;
  static double fontSize_5 = 28;



  static MaterialColor firstColor = MaterialColor(0xFFE51A4B, {
    50: Color.fromRGBO(229, 26, 75, .1),
    100: Color.fromRGBO(229, 26, 75, .2),
    200: Color.fromRGBO(229, 26, 75, .3),
    300: Color.fromRGBO(229, 26, 75, .4),
    400: Color.fromRGBO(229, 26, 75, .5),
    500: Color.fromRGBO(229, 26, 75, .6),
    600: Color.fromRGBO(229, 26, 75, .7),
    700: Color.fromRGBO(229, 26, 75, .8),
    800: Color.fromRGBO(229, 26, 75, .9),
    900: Color.fromRGBO(229, 26, 75, 1),
  });

}

final dashBoardButtonStyle = BoxDecoration(
  border: new Border.all(width: 3.0, color: ConstValues.firstColor),
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
