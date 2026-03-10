import 'package:dio_request_inspector/src/page/resources/app_color.dart';
import 'package:flutter/material.dart';

abstract class AppTheme {
  static ThemeData get theme => ThemeData(
        colorScheme: ColorScheme.light(
          primary: AppColor.primary,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColor.primary,
          surfaceTintColor: Colors.transparent,
          elevation: 3,
          iconTheme: IconThemeData(color: AppColor.primary),
          titleTextStyle: TextStyle(
            color: AppColor.primary,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        tabBarTheme: TabBarThemeData(
          labelColor: AppColor.primary,
          unselectedLabelColor: AppColor.primary,
          indicatorColor: AppColor.primary,
          dividerColor: Colors.transparent,
          labelStyle: TextStyle(
            color: AppColor.primary,
            // fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: TextStyle(
            color: Colors.black45,
            // fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.grey.withValues(alpha: 0.15);
            }
            if (states.contains(WidgetState.hovered)) {
              return Colors.grey.withValues(alpha: 0.08);
            }
            return null;
          }),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
        ),
      );
}
