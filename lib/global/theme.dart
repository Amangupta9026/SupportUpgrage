import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:support/global/color.dart';

// Set Theme for app.

ThemeData themeData = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.poppins().fontFamily,
    colorSchemeSeed: primaryColor,
    appBarTheme: const AppBarTheme(
        surfaceTintColor: primaryColor,
        backgroundColor: primaryColor,
        titleTextStyle: TextStyle(),
        toolbarTextStyle: TextStyle(),
        iconTheme: IconThemeData(color: Colors.white)),
    scaffoldBackgroundColor: backgroundColor,
    floatingActionButtonTheme:
        const FloatingActionButtonThemeData(foregroundColor: Colors.white),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: primaryColor,
      surfaceTintColor: primaryColor,
    )));
