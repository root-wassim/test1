import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color bg = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF12121A);
  static const Color card = Color(0xFF1A1A28);
  static const Color accent = Color(0xFFFF6B6B);
  static const Color gold = Color(0xFFFFD700);

  static ThemeData get dark => ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bg,
        primaryColor: primary,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: secondary,
          surface: surface,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: bg,
          elevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
