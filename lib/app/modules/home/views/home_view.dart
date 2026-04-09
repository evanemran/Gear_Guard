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
          _currentIndex == 0 ? 'Gear Guard' : 'My Items',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu_rounded),
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.backgroundRaised.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.softBorder),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x52000000),
                blurRadius: 28,
                offset: Offset(0, 18),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: _ModernNavItem(
                  label: 'Home',
                  icon: Icons.grid_view_rounded,
                  isActive: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _AddNavButton(
                  onTap: controller.navigateToCreate,
                ),
              ),
              Expanded(
                child: _ModernNavItem(
                  label: 'Items',
                  icon: Icons.widgets_rounded,
                  isActive: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
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
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
          children: <Widget>[
            _HeroPanel(
              controller: controller,
              focusItem: controller.nextExpiringItem,
            ),
            const SizedBox(height: 16),
            _StatsRow(controller: controller),
            const SizedBox(height: 16),
            TextField(
              controller: controller.searchController,
              decoration: const InputDecoration(
                hintText: 'Search product, brand, or serial number',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 18),
            _SectionHeader(
              title: 'Tracked Products',
              subtitle: '${items.length} visible item${items.length == 1 ? '' : 's'}',
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              _EmptyState(query: controller.query.value)
            else
              ...items.map((WarrantyItem item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _WarrantyCard(item: item, controller: controller),
                );
              }),
          ],
        ),
      );
    });
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.controller,
    required this.focusItem,
  });

  final HomeController controller;
  final WarrantyItem? focusItem;

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0x24FFFFFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Smart Warranty Tracking',
              style: TextStyle(
                color: AppColors.primarySoft,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Stay ahead of every expiry window.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.portfolioHealthLabel,
            style: const TextStyle(
              color: AppColors.textMuted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          LinearProgressIndicator(
            value: controller.activeCoverageRatio,
            minHeight: 10,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: const Color(0x26FFFFFF),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 10),
          Text(
            '${(controller.activeCoverageRatio * 100).round()}% of saved products are still covered',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (focusItem != null) ...<Widget>[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0x16000000),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.softBorder),
              ),
              child: Row(
                children: <Widget>[
                  _ProductThumb(path: focusItem!.productImagePath, size: 62),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Next to expire',
                          style: TextStyle(
                            color: AppColors.primarySoft,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          focusItem!.productName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Expires ${controller.formatDate(focusItem!.expiryDate)}',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StatusPill(item: focusItem!, controller: controller, isLinear: false,),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
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
          style: const TextStyle(color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final bool isSearching = query.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.softBorder),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'No matching warranties' : 'No warranties yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            isSearching
                ? 'Try a different keyword for product, brand, or serial number.'
                : 'Add your first product and GearGuard will keep watch on the remaining coverage for you.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _WarrantyCard extends StatelessWidget {
  const _WarrantyCard({
    required this.item,
    required this.controller,
  });

  final WarrantyItem item;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final Color progressColor = item.isExpired
        ? AppColors.danger
        : item.daysUntilExpiry <= 30
            ? AppColors.warning
            : AppColors.success;

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () => controller.navigateToEdit(item),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.softBorder),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _ProductThumb(path: item.productImagePath, size: 62),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.productName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.brand} • ${item.shopName}',
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 10),
                      _StatusPill(item: item, controller: controller, isLinear: true,),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  color: AppColors.surfaceAlt,
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
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: _InfoBlock(
                    label: 'Expires',
                    value: controller.formatDate(item.expiryDate),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InfoBlock(
                    label: 'Price',
                    value: controller.formatCurrency(item.price),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InfoBlock(
                    label: 'Receipt',
                    value: item.hasReceipt ? 'Saved' : 'Missing',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  item.isExpired
                      ? 'Coverage ended'
                      : '${item.remainingWarrantyDays} days remaining',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${(item.warrantyProgress * 100).round()}%',
                  style: TextStyle(
                    color: progressColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: item.warrantyProgress,
                minHeight: 8,
                backgroundColor: AppColors.surfaceAlt,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            /*if (item.serialNumber.trim().isNotEmpty || item.notes.trim().isNotEmpty) ...<Widget>[
              const SizedBox(height: 14),
              const Divider(),
              const SizedBox(height: 14),
              if (item.serialNumber.trim().isNotEmpty)
                _MetaLine(label: 'Serial', value: item.serialNumber),
              if (item.notes.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _MetaLine(label: 'Notes', value: item.notes),
                ),
            ],*/
          ],
        ),
      ),
    );
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
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No collections yet. Add a product first to build brand-based groups.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
        );
      }

      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
        children: <Widget>[
          const _SectionHeader(
            title: 'Brand Collections',
            subtitle: 'See how your products are distributed across makers',
          ),
          const SizedBox(height: 14),
          ...entries.map((MapEntry<String, int> category) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppColors.softBorder),
                  boxShadow: AppColors.softShadow,
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          colors: <Color>[
                            AppColors.primaryDeep,
                            AppColors.primary,
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.category_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            category.key,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${category.value} tracked item${category.value == 1 ? '' : 's'}',
                            style: const TextStyle(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${category.value}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.primarySoft,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      );
    });
  }
}

class _ProductThumb extends StatelessWidget {
  const _ProductThumb({
    this.path,
    this.size = 50,
  });

  final String? path;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bool hasImage = path != null && path!.isNotEmpty && File(path!).existsSync();
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: size,
        height: size,
        color: AppColors.surfaceAlt,
        child: hasImage
            ? Image.file(
                File(path!),
                fit: BoxFit.cover,
              )
            : const Icon(Icons.inventory_2_outlined, color: AppColors.textMuted),
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
            title: 'Tracked',
            value: '${controller.totalCount}',
            color: AppColors.primarySoft,
            icon: Icons.inventory_2_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            title: 'Expiring',
            value: '${controller.expiringSoonCount}',
            color: AppColors.warning,
            icon: Icons.schedule_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            title: 'Expired',
            value: '${controller.expiredCount}',
            color: AppColors.danger,
            icon: Icons.gpp_bad_rounded,
          ),
        ),
      ],
    );
  }
}

class _ModernNavItem extends StatelessWidget {
  const _ModernNavItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isActive
              ? const LinearGradient(
                  colors: <Color>[
                    AppColors.primaryDeep,
                    AppColors.primary,
                  ],
                )
              : null,
          color: isActive ? null : Colors.transparent,
          boxShadow: isActive ? AppColors.primaryGlow : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 20,
              color: isActive ? Colors.white : AppColors.textMuted,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: isActive
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddNavButton extends StatelessWidget {
  const _AddNavButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: <Color>[
              AppColors.primary,
              AppColors.primaryDeep,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: const Color(0x26FFFFFF)),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x55FF6B1A),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.softBorder),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.item,
    required this.controller,
    required this.isLinear,
  });

  final WarrantyItem item;
  final HomeController controller;
  final bool isLinear;

  @override
  Widget build(BuildContext context) {
    final Color color = item.isExpired
        ? AppColors.danger
        : item.daysUntilExpiry <= 30
            ? AppColors.warning
            : AppColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        controller.warrantyStatusLabel(item, isLinear: isLinear),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: <InlineSpan>[
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              color: AppColors.primarySoft,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: AppColors.textMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
