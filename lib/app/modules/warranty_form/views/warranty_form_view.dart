import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gearguard/app/core/theme/app_colors.dart';
import 'package:gearguard/app/modules/warranty_form/controllers/warranty_form_controller.dart';

class WarrantyFormView extends GetView<WarrantyFormController> {
  const WarrantyFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.isEditing ? 'Edit Warranty' : 'Add Warranty',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.softBorder),
                ),
                child: Text(
                  controller.isEditing
                      ? 'Update your warranty information.'
                      : 'Add product details to start tracking coverage.',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: controller.productController,
                decoration: const InputDecoration(labelText: 'Product name'),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Product name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Brand is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.shopController,
                decoration: const InputDecoration(labelText: 'Shop name'),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Shop name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.serialController,
                decoration: const InputDecoration(labelText: 'Serial number'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Price'),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Price is required';
                  }
                  final double? parsed = double.tryParse(value.trim());
                  if (parsed == null || parsed < 0) {
                    return 'Enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Obx(
                () => Card(
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    title: const Text('Purchase date'),
                    subtitle: Text(controller.formatDate(controller.purchaseDate.value)),
                    trailing:
                        const Icon(Icons.calendar_today, color: AppColors.primary),
                    onTap: () => controller.pickDate(
                      context: context,
                      isPurchaseDate: true,
                    ),
                  ),
                ),
              ),
              Obx(
                () => Card(
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    title: const Text('Expiry date'),
                    subtitle: Text(controller.formatDate(controller.expiryDate.value)),
                    trailing:
                        const Icon(Icons.event_available, color: AppColors.primary),
                    onTap: () => controller.pickDate(
                      context: context,
                      isPurchaseDate: false,
                    ),
                  ),
                ),
              ),
              Obx(
                () => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: controller.hasReceipt.value,
                  title: const Text('Receipt available'),
                  onChanged: (bool value) => controller.hasReceipt.value = value,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => _ImagePickerCard(
                  title: 'Product image',
                  imagePath: controller.productImagePath.value,
                  onPick: controller.pickProductImage,
                  onRemove: controller.removeProductImage,
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => _ImagePickerCard(
                  title: 'Invoice image',
                  imagePath: controller.invoiceImagePath.value,
                  onPick: controller.pickInvoiceImage,
                  onRemove: controller.removeInvoiceImage,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.notesController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: controller.submit,
                  child: Text(
                    controller.isEditing ? 'Update Warranty' : 'Save Warranty',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePickerCard extends StatelessWidget {
  const _ImagePickerCard({
    required this.title,
    required this.imagePath,
    required this.onPick,
    required this.onRemove,
  });

  final String title;
  final String? imagePath;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imagePath != null && imagePath!.isNotEmpty;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(imagePath!),
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.inputFill,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text(
                    'No image selected',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPick,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Choose Image'),
                  ),
                ),
                if (hasImage) ...<Widget>[
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
