import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gearguard/app/data/models/warranty_item.dart';
import 'package:gearguard/app/data/repositories/warranty_repository.dart';
import 'package:gearguard/app/routes/app_routes.dart';

class HomeController extends GetxController {
  HomeController(this._repository);

  final WarrantyRepository _repository;

  final RxList<WarrantyItem> warranties = <WarrantyItem>[].obs;
  final RxBool isLoading = true.obs;
  final RxString query = ''.obs;

  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      query.value = searchController.text.trim().toLowerCase();
    });
    loadWarranties();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadWarranties() async {
    isLoading.value = true;
    warranties.assignAll(await _repository.getAllWarranties());
    isLoading.value = false;
  }

  List<WarrantyItem> get filteredWarranties {
    if (query.value.isEmpty) {
      return warranties;
    }
    return warranties.where((WarrantyItem item) {
      return item.productName.toLowerCase().contains(query.value) ||
          item.brand.toLowerCase().contains(query.value) ||
          item.serialNumber.toLowerCase().contains(query.value);
    }).toList();
  }

  int get totalCount => warranties.length;

  int get expiredCount => warranties.where((WarrantyItem item) => item.isExpired).length;

  int get expiringSoonCount => warranties
      .where((WarrantyItem item) => !item.isExpired && item.daysUntilExpiry <= 30)
      .length;

  List<WarrantyItem> get activeWarranties =>
      warranties.where((WarrantyItem item) => !item.isExpired).toList()
        ..sort((WarrantyItem a, WarrantyItem b) => a.daysUntilExpiry - b.daysUntilExpiry);

  WarrantyItem? get nextExpiringItem =>
      activeWarranties.isEmpty ? null : activeWarranties.first;

  String get portfolioHealthLabel {
    if (warranties.isEmpty) {
      return 'Start adding products to track every warranty in one place.';
    }
    if (expiredCount == warranties.length) {
      return 'Every saved warranty has expired. Refresh your list with new purchases.';
    }
    if (expiringSoonCount > 0) {
      return '$expiringSoonCount item${expiringSoonCount == 1 ? '' : 's'} need attention soon.';
    }
    return 'Your warranty portfolio looks healthy right now.';
  }

  double get activeCoverageRatio {
    if (warranties.isEmpty) {
      return 0;
    }
    return (warranties.length - expiredCount) / warranties.length;
  }

  Future<void> navigateToCreate() async {
    final dynamic changed = await Get.toNamed(AppRoutes.warrantyForm);
    if (changed == true) {
      await loadWarranties();
    }
  }

  Future<void> navigateToEdit(WarrantyItem item) async {
    final dynamic changed = await Get.toNamed(
      AppRoutes.warrantyForm,
      arguments: item,
    );
    if (changed == true) {
      await loadWarranties();
    }
  }

  Future<void> deleteWarranty(WarrantyItem item) async {
    if (item.id == null) {
      return;
    }
    await _repository.deleteWarranty(item.id!);
    await loadWarranties();
  }

  String formatDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String formatCurrency(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  String warrantyStatusLabel(WarrantyItem item, {bool isLinear = false}) {
    if (item.isExpired) {
      return 'Expired';
    }
    if (item.daysUntilExpiry <= 30) {
      return isLinear ? '${item.daysUntilExpiry} days left' : '${item.daysUntilExpiry}\ndays left';
    }
    return 'Protected';
  }
}
