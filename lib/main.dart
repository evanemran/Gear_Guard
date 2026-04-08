import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gearguard/app/core/theme/app_colors.dart';
import 'package:gearguard/app/routes/app_pages.dart';
import 'package:gearguard/app/routes/app_routes.dart';

void main() {
  runApp(const GearGuardApp());
}

class GearGuardApp extends StatelessWidget {
  const GearGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GearGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.primary,
          surface: AppColors.surface,
          onPrimary: Colors.white,
          onSurface: Colors.white,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.softBorder),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputFill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.surface,
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      initialRoute: AppRoutes.home,
      getPages: AppPages.routes,
    );
  }
}
