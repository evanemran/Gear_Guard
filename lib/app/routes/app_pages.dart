import 'package:get/get.dart';
import 'package:gearguard/app/modules/home/bindings/home_binding.dart';
import 'package:gearguard/app/modules/home/views/home_view.dart';
import 'package:gearguard/app/modules/warranty_form/bindings/warranty_form_binding.dart';
import 'package:gearguard/app/modules/warranty_form/views/warranty_form_view.dart';
import 'package:gearguard/app/routes/app_routes.dart';

class AppPages {
  static final List<GetPage<dynamic>> routes = <GetPage<dynamic>>[
    GetPage<HomeView>(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage<WarrantyFormView>(
      name: AppRoutes.warrantyForm,
      page: () => const WarrantyFormView(),
      binding: WarrantyFormBinding(),
    ),
  ];
}
