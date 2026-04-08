import 'package:get/get.dart';
import 'package:gearguard/app/data/repositories/warranty_repository.dart';
import 'package:gearguard/app/modules/home/controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WarrantyRepository>(() => WarrantyRepository());
    Get.lazyPut<HomeController>(() => HomeController(Get.find<WarrantyRepository>()));
  }
}
