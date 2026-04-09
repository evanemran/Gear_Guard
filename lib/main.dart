import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gearguard/app/core/theme/app_theme.dart';
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
      title: 'Gear Guard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.home,
      getPages: AppPages.routes,
    );
  }
}
