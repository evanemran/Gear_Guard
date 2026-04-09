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
          controller.isEditing ? 'Update Coverage' : 'Add New Warranty',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: <Widget>[
              _IntroCard(controller: controller),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Product Details',
                subtitle: 'Add the product and purchase details you want to protect.',
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: controller.productController,
                      decoration: const InputDecoration(
                        labelText: 'Product name',
                        prefixIcon: Icon(Icons.devices_rounded),
                      ),
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
                      decoration: const InputDecoration(
                        labelText: 'Brand',
                        prefixIcon: Icon(Icons.workspace_premium_rounded),
                      ),
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
                      decoration: const InputDecoration(
                        labelText: 'Shop name',
                        prefixIcon: Icon(Icons.storefront_rounded),
                      ),
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
                      decoration: const InputDecoration(
                        labelText: 'Serial number',
                        prefixIcon: Icon(Icons.qr_code_2_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: controller.priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        prefixIcon: Icon(Icons.attach_money_rounded),
                      ),
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
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => _SectionCard(
                  title: 'Coverage Timeline',
                  subtitle: 'Choose dates and preview how much warranty is left.',
                  child: Column(
                    children: <Widget>[
                      _DateTile(
                        title: 'Purchase date',
                        value: controller.formatDate(controller.purchaseDate.value),
                        icon: Icons.calendar_month_rounded,
                        onTap: () => controller.pickDate(
                          context: context,
                          isPurchaseDate: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _DateTile(
                        title: 'Expiry date',
                        value: controller.formatDate(controller.expiryDate.value),
                        icon: Icons.event_available_rounded,
                        onTap: () => controller.pickDate(
                          context: context,
                          isPurchaseDate: false,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _CoveragePreview(controller: controller),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => _SectionCard(
                  title: 'Proof & Attachments',
                  subtitle: 'Save receipt and product images so claims are easier later.',
                  child: Column(
                    children: <Widget>[
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: controller.hasReceipt.value,
                        activeColor: AppColors.primary,
                        title: const Text('Receipt available'),
                        subtitle: const Text(
                          'Turn this on when you have a proof of purchase.',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                        onChanged: (bool value) => controller.hasReceipt.value = value,
                      ),
                      const SizedBox(height: 8),
                      _ImagePickerCard(
                        title: 'Product image',
                        subtitle: 'Helps you visually identify the item later.',
                        imagePath: controller.productImagePath.value,
                        onPick: controller.pickProductImage,
                        onRemove: controller.removeProductImage,
                      ),
                      const SizedBox(height: 12),
                      _ImagePickerCard(
                        title: 'Invoice image',
                        subtitle: 'Store the invoice, receipt, or warranty card.',
                        imagePath: controller.invoiceImagePath.value,
                        onPick: controller.pickInvoiceImage,
                        onRemove: controller.removeInvoiceImage,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Notes',
                subtitle: 'Keep reminders like service center, model, or claim instructions.',
                child: TextFormField(
                  controller: controller.notesController,
                  minLines: 4,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Add notes',
                    alignLabelWithHint: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 64),
                      child: Icon(Icons.notes_rounded),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: controller.submit,
                  icon: const Icon(Icons.check_circle_rounded),
                  label: Text(
                    controller.isEditing ? 'Update Warranty' : 'Save Warranty',
                    style: const TextStyle(fontWeight: FontWeight.w700),
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

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.controller});

  final WarrantyFormController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: <Color>[
            AppColors.heroStart,
            AppColors.heroMiddle,
            AppColors.heroEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppColors.primaryGlow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Coverage Entry',
            style: TextStyle(
              color: AppColors.primarySoft,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            controller.isEditing
                ? 'Refresh your warranty details and keep the countdown accurate.'
                : 'Capture product, receipt, and warranty dates once so the app can monitor the rest.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.softBorder),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.softBorder),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0x22FF6B1A),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: const TextStyle(color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _CoveragePreview extends StatelessWidget {
  const _CoveragePreview({required this.controller});

  final WarrantyFormController controller;

  @override
  Widget build(BuildContext context) {
    final Color accent = controller.isExpired ? AppColors.danger : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.backgroundRaised,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  controller.remainingCoverageLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  controller.warrantyLengthLabel,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: controller.coverageProgress,
              minHeight: 9,
              backgroundColor: AppColors.surfaceAlt,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: _MiniMetric(
                  label: 'Purchase',
                  value: controller.formatDate(controller.purchaseDate.value),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniMetric(
                  label: 'Expiry',
                  value: controller.formatDate(controller.expiryDate.value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ImagePickerCard extends StatelessWidget {
  const _ImagePickerCard({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.onPick,
    required this.onRemove,
  });

  final String title;
  final String subtitle;
  final String? imagePath;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imagePath != null && imagePath!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          if (hasImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(imagePath!),
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 86,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.backgroundRaised,
              ),
              child: const Center(
                child: Text(
                  'No image selected',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: onPick,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Choose image'),
                ),
              ),
              if (hasImage) ...<Widget>[
                const SizedBox(width: 10),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
