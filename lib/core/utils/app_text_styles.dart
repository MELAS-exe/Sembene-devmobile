import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tera/core/utils/app_colors.dart';

abstract class AppTextStyles {
  // Eyebrow / overline: 10.5sp, weight 600, tracking 0.12em, uppercase
  static TextStyle eyebrow({Color color = AppColors.inkSoft}) =>
      GoogleFonts.inter(
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 10.5 * 0.12,
        color: color,
      );

  // Serif heading — Instrument Serif regular
  static TextStyle serifHeading({
    double fontSize = 40,
    Color color = AppColors.ink,
  }) =>
      GoogleFonts.instrumentSerif(
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.01 * fontSize,
        height: 1,
        color: color,
      );

  // Serif italic accent
  static TextStyle serifItalic({
    double fontSize = 40,
    Color color = AppColors.greenDeep,
  }) =>
      GoogleFonts.instrumentSerif(
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        letterSpacing: -0.01 * fontSize,
        height: 1,
        color: color,
      );

  // Tabular numbers (prices)
  static TextStyle tabularNum({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.ink,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        fontFeatures: const [
          FontFeature.tabularFigures(),
          FontFeature.liningFigures(),
        ],
      );

  static TextStyle body({
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.ink,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: -0.005 * fontSize,
      );

  static TextStyle label({
    double fontSize = 12.5,
    FontWeight fontWeight = FontWeight.w500,
    Color color = AppColors.inkSoft,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: 0.01 * fontSize,
      );
}
