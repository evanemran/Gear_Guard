import 'package:get/get.dart';
import 'package:gearguard/app/data/repositories/warranty_repository.dart';
import 'package:gearguard/app/modules/warranty_form/controllers/warranty_form_controller.dart';

class WarrantyFormBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<WarrantyRepository>()) {
      Get.lazyPut<WarrantyRepository>(() => WarrantyRepository());
    }
    Get.lazyPut<WarrantyFormController>(
      () => WarrantyFormController(Get.find<WarrantyRepository>()),
    );
  }
}
