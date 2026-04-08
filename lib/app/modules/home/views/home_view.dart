import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gearguard/app/core/theme/app_colors.dart';
import 'package:gearguard/app/data/models/warranty_item.dart';
import 'package:gearguard/app/modules/home/controllers/home_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeController controller = Get.find<HomeController>();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 ? 'GearGuard' : 'Categories',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        onPressed: controller.navigateToCreate,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: kToolbarHeight,
        color: AppColors.grey,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          child: Row(
            children: <Widget>[
              Expanded(
                child: IconButton(
                  onPressed: () => setState(() => _currentIndex = 0),
                  icon: Icon(
                    Icons.home_rounded,
                    color: _currentIndex == 0 ? AppColors.primary : Colors.white70,
                  ),
                  tooltip: 'Home',
                ),
              ),
              const SizedBox(width: 52),
              Expanded(
                child: IconButton(
                  onPressed: () => setState(() => _currentIndex = 1),
                  icon: Icon(
                    Icons.category_rounded,
                    color: _currentIndex == 1 ? AppColors.primary : Colors.white70,
                  ),
                  tooltip: 'Categories',
                ),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: <Widget>[
          _HomeTab(controller: controller),
          _CategoriesTab(controller: controller),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final List<WarrantyItem> items = controller.filteredWarranties;
      return RefreshIndicator(
        onRefresh: controller.loadWarranties,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: <Color>[AppColors.bannerStart, AppColors.bannerEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Your warranties in one place',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Track expiry dates, receipts, and product details.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _StatsRow(controller: controller),
            const SizedBox(height: 12),
            TextField(
              controller: controller.searchController,
              decoration: const InputDecoration(
                hintText: 'Search product, brand, or serial',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 48),
                child: Center(
                  child: Text('No warranties found. Tap "Add" to get started.'),
                ),
              )
            else
              ...items.map((WarrantyItem item) {
                final bool warn = !item.isExpired && item.daysUntilExpiry <= 30;
                final Color color = item.isExpired
                    ? Colors.red
                    : warn
                        ? Colors.orange
                        : Colors.green;
                final String status = item.isExpired
                    ? 'Expired'
                    : warn
                        ? 'Expiring in ${item.daysUntilExpiry} days'
                        : 'Active';
                return Card(
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: _ProductThumb(path: item.productImagePath),
                    title: Text(item.productName),
                    subtitle: Text(
                      '${item.brand} • ${item.shopName}\n'
                      'Expires ${controller.formatDate(item.expiryDate)}\n$status',
                    ),
                    subtitleTextStyle:
                        Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
                    trailing: PopupMenuButton<String>(
                      onSelected: (String value) {
                        if (value == 'edit') {
                          controller.navigateToEdit(item);
                        } else if (value == 'delete') {
                          controller.deleteWarranty(item);
                        }
                      },
                      itemBuilder: (_) => const <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                        PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: () => controller.navigateToEdit(item),
                  ),
                );
              }),
          ],
        ),
      );
    });
  }
}

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final Map<String, int> categories = <String, int>{};
      for (final WarrantyItem item in controller.warranties) {
        final String key = item.brand.trim().isEmpty ? 'Other' : item.brand.trim();
        categories[key] = (categories[key] ?? 0) + 1;
      }
      final List<MapEntry<String, int>> entries = categories.entries.toList()
        ..sort((MapEntry<String, int> a, MapEntry<String, int> b) => b.value - a.value);

      if (entries.isEmpty) {
        return const Center(
          child: Text('No categories yet. Add a product first.'),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        itemBuilder: (_, int index) {
          final MapEntry<String, int> category = entries[index];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.bannerStart,
                child: Icon(Icons.category_rounded, color: AppColors.primary),
              ),
              title: Text(category.key),
              subtitle: Text('${category.value} item(s)'),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: entries.length,
      );
    });
  }
}

class _ProductThumb extends StatelessWidget {
  const _ProductThumb({this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final bool hasImage = path != null && path!.isNotEmpty && File(path!).existsSync();
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 50,
        height: 50,
        color: AppColors.inputFill,
        child: hasImage
            ? Image.file(
                File(path!),
                fit: BoxFit.cover,
              )
            : const Icon(Icons.inventory_2_outlined, color: Colors.white70),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _StatCard(
            title: 'Total',
            value: '${controller.totalCount}',
            color: const Color(0xFFFFB188),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            title: 'Soon',
            value: '${controller.expiringSoonCount}',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            title: 'Expired',
            value: '${controller.expiredCount}',
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final Color textColor = color == Colors.red ? Colors.redAccent : color;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Column(
          children: <Widget>[
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: textColor, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

