import 'package:flutter/material.dart';
import 'package:sixam_mart_store/util/app_constants.dart';

ThemeData light = ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: const Color(0xFF7ED321),
  secondaryHeaderColor: const Color(0xFF3D8A0F),
  disabledColor: const Color(0xFF9CA3AF),
  brightness: Brightness.light,
  hintColor: const Color(0xFF9CA3AF),
  cardColor: const Color(0xFFFFFFFF),
  scaffoldBackgroundColor: const Color(0xFFF5F7F8),
  shadowColor: Colors.black.withValues(alpha: 0.04),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: const Color(0xFF7ED321))),
  colorScheme: const ColorScheme.light(primary: Color(0xFF7ED321), secondary: Color(0xFF3D8A0F)).copyWith(error: const Color(0xFFDC2626)),
  popupMenuTheme: const PopupMenuThemeData(color: Color(0xFFFFFFFF), surfaceTintColor: Color(0xFFFFFFFF)),
  dialogTheme: const DialogThemeData(surfaceTintColor: Color(0xFFFFFFFF)),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(500))),
    backgroundColor: Color(0xFF7ED321),
    foregroundColor: Colors.white,
  ),
  bottomAppBarTheme: const BottomAppBarThemeData(
    surfaceTintColor: Color(0xFFFFFFFF), height: 64,
    padding: EdgeInsets.symmetric(vertical: 8),
  ),
  dividerTheme: const DividerThemeData(thickness: 0.5, color: Color(0xFFE5E7EB)),
  tabBarTheme: const TabBarThemeData(dividerColor: Colors.transparent),
);
