import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gearguard/app/data/models/warranty_item.dart';
import 'package:gearguard/app/data/repositories/warranty_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class WarrantyFormController extends GetxController {
  WarrantyFormController(this._repository);

  final WarrantyRepository _repository;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController productController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController shopController = TextEditingController();
  final TextEditingController serialController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final Rx<DateTime> purchaseDate = DateTime.now().obs;
  final Rx<DateTime> expiryDate = DateTime.now().add(const Duration(days: 365)).obs;
  final RxBool hasReceipt = false.obs;
  final RxnString productImagePath = RxnString();
  final RxnString invoiceImagePath = RxnString();

  final ImagePicker _imagePicker = ImagePicker();

  WarrantyItem? editingItem;

  bool get isEditing => editingItem != null;

  @override
  void onInit() {
    super.onInit();
    final Object? argument = Get.arguments;
    if (argument is WarrantyItem) {
      editingItem = argument;
      productController.text = argument.productName;
      brandController.text = argument.brand;
      shopController.text = argument.shopName;
      serialController.text = argument.serialNumber;
      priceController.text = argument.price.toStringAsFixed(2);
      notesController.text = argument.notes;
      purchaseDate.value = argument.purchaseDate;
      expiryDate.value = argument.expiryDate;
      hasReceipt.value = argument.hasReceipt;
      productImagePath.value = argument.productImagePath;
      invoiceImagePath.value = argument.invoiceImagePath;
    }
  }

  @override
  void onClose() {
    productController.dispose();
    brandController.dispose();
    shopController.dispose();
    serialController.dispose();
    priceController.dispose();
    notesController.dispose();
    super.onClose();
  }

  Future<void> pickDate({
    required BuildContext context,
    required bool isPurchaseDate,
  }) async {
    final DateTime initialDate = isPurchaseDate ? purchaseDate.value : expiryDate.value;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      if (isPurchaseDate) {
        purchaseDate.value = picked;
      } else {
        expiryDate.value = picked;
      }
    }
  }

  String formatDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> pickProductImage() async {
    final XFile? file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) {
      return;
    }
    productImagePath.value = await _persistImage(file, 'product');
  }

  Future<void> pickInvoiceImage() async {
    final XFile? file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) {
      return;
    }
    invoiceImagePath.value = await _persistImage(file, 'invoice');
    hasReceipt.value = true;
  }

  void removeProductImage() {
    productImagePath.value = null;
  }

  void removeInvoiceImage() {
    invoiceImagePath.value = null;
    hasReceipt.value = false;
  }

  Future<String> _persistImage(XFile file, String prefix) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory imageDir = Directory(p.join(appDir.path, 'warranty_images'));
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    final String extension = p.extension(file.path).toLowerCase();
    final String fileName =
        '${prefix}_${DateTime.now().microsecondsSinceEpoch}${extension.isEmpty ? '.jpg' : extension}';
    final String destinationPath = p.join(imageDir.path, fileName);
    final File copied = await File(file.path).copy(destinationPath);
    return copied.path;
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    if (expiryDate.value.isBefore(purchaseDate.value)) {
      Get.snackbar('Invalid date', 'Expiry date must be after purchase date.');
      return;
    }

    final WarrantyItem item = WarrantyItem(
      id: editingItem?.id,
      productName: productController.text.trim(),
      brand: brandController.text.trim(),
      shopName: shopController.text.trim(),
      serialNumber: serialController.text.trim(),
      purchaseDate: purchaseDate.value,
      expiryDate: expiryDate.value,
      price: double.parse(priceController.text.trim()),
      notes: notesController.text.trim(),
      hasReceipt: hasReceipt.value,
      productImagePath: productImagePath.value,
      invoiceImagePath: invoiceImagePath.value,
    );

    if (isEditing) {
      await _repository.updateWarranty(item);
    } else {
      await _repository.insertWarranty(item);
    }
    Get.back<bool>(result: true);
  }
}
