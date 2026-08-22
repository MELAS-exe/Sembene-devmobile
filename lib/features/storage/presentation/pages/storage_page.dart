import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tera/app/router/app_router.dart';
import 'package:tera/core/utils/app_colors.dart';
import 'package:tera/core/utils/app_text_styles.dart';
import 'package:tera/features/market/domain/entities/product.dart';
import 'package:tera/features/market/presentation/blocs/products_cubit.dart';
import 'package:tera/features/storage/domain/entities/storage_request.dart';
import 'package:tera/features/storage/domain/entities/warehouse.dart';
import 'package:tera/features/storage/presentation/blocs/storage_requests_cubit.dart';
import 'package:tera/features/storage/presentation/blocs/warehouse_cubit.dart';
import 'package:tera/l10n/l10n.dart';
import 'package:tera/shared/widgets/tera_icons.dart';

String _fmtNum(double n) => NumberFormat('#,###', 'fr_FR').format(n.round());

class StoragePage extends StatefulWidget {
  const StoragePage({super.key});

  @override
  State<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  String _tab = 'all';

  @override
  void initState() {
    super.initState();
    context.read<WarehouseCubit>().loadWarehouses();
    context.read<StorageRequestsCubit>().loadRequests();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.bg,
      floatingActionButton: _Fab(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Fixed header ──────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => context.push(AppRouter.notificationsPath),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.paper,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.line),
                    ),
                    child: const Center(
                      child: TeraBellIcon(size: 18, color: AppColors.ink),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Scrollable content ────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              color: AppColors.forest,
              backgroundColor: AppColors.paper,
              onRefresh: () async {
                await Future.wait([
                  context.read<WarehouseCubit>().loadWarehouses(),
                  context.read<StorageRequestsCubit>().loadRequests(),
                ]);
              },
              child: BlocBuilder<WarehouseCubit, WarehouseState>(
                builder: (context, state) {
                  final warehouses = state is WarehousesLoaded
                      ? state.warehouses
                      : <Warehouse>[];

                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                        // ── Hero CTA card ─────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: _HeroCard(l10n: l10n),
                      ),

                      // ── Nos entrepôts ─────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Nos entrepôts',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Text(
                              l10n.seeAll,
                              style: AppTextStyles.label(fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      if (state is WarehouseLoading)
                        SizedBox(
                          height: 136,
                          child: Shimmer.fromColors(
                            baseColor: AppColors.line,
                            highlightColor: AppColors.paper2,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20),
                              itemCount: 3,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (_, __) =>
                                  const _WarehouseCardShimmer(),
                            ),
                          ),
                        )
                      else
                        _WarehouseStrip(warehouses: warehouses),

                      // ── Tabs ──────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 26, 20, 14),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _Chip(
                                label: 'Tout',
                                active: _tab == 'all',
                                onTap: () => setState(() => _tab = 'all'),
                              ),
                              const SizedBox(width: 6),
                              _Chip(
                                label: l10n.storageActive,
                                active: _tab == 'active',
                                onTap: () =>
                                    setState(() => _tab = 'active'),
                              ),
                              const SizedBox(width: 6),
                              _Chip(
                                label: 'En attente',
                                active: _tab == 'pending',
                                onTap: () =>
                                    setState(() => _tab = 'pending'),
                              ),
                              const SizedBox(width: 6),
                              _Chip(
                                label: l10n.storageHistory,
                                active: _tab == 'past',
                                onTap: () => setState(() => _tab = 'past'),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Reservations list ─────────────────────
                      BlocBuilder<ProductsCubit, ProductsState>(
                        builder: (context, prodState) {
                          final products = prodState is ProductsLoaded
                              ? prodState.products
                              : <Product>[];

                          return BlocBuilder<StorageRequestsCubit,
                              StorageRequestsState>(
                            builder: (context, reqState) {
                              if (reqState is StorageRequestsLoading) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Shimmer.fromColors(
                                    baseColor: AppColors.line,
                                    highlightColor: AppColors.paper2,
                                    child: Column(
                                      children: List.generate(
                                        3,
                                        (_) =>
                                            const _StorageRequestCardShimmer(),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              final all = reqState is StorageRequestsLoaded
                                  ? reqState.requests
                                  : <StorageRequest>[];

                              Widget cardFor(StorageRequest r) {
                                final whId = r.destinationWarehouseId ??
                                    r.sourceWarehouseId;
                                final whName = warehouses
                                    .where((w) => w.id == whId)
                                    .map((w) => w.name)
                                    .firstOrNull;
                                final product = products
                                    .where((p) => p.id == r.productId)
                                    .firstOrNull;
                                return _StorageRequestCard(
                                  request: r,
                                  warehouseName: whName,
                                  product: product,
                                );
                              }

                              Widget emptyState() => SizedBox(
                                    height: 200,
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            '🏭',
                                            style: TextStyle(
                                              fontFamily: 'Segoe UI Emoji',
                                              fontFamilyFallback: [
                                                'Apple Color Emoji',
                                                'Noto Color Emoji',
                                              ],
                                              fontSize: 40,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Aucune réservation ici.',
                                            style: AppTextStyles.label(
                                                fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );

                              if (_tab == 'all') {
                                final pending = all
                                    .where((r) =>
                                        r.status ==
                                        StorageRequestStatus.pending)
                                    .toList();
                                final active = all
                                    .where((r) =>
                                        r.status ==
                                        StorageRequestStatus.approved)
                                    .toList();
                                final past = all
                                    .where((r) =>
                                        r.status ==
                                            StorageRequestStatus.rejected ||
                                        r.status ==
                                            StorageRequestStatus.completed)
                                    .toList();

                                if (all.isEmpty) return emptyState();

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (pending.isNotEmpty) ...[
                                        _SectionLabel(label: 'En attente'),
                                        ...pending.map(cardFor),
                                      ],
                                      if (active.isNotEmpty) ...[
                                        _SectionLabel(label: 'Actives'),
                                        ...active.map(cardFor),
                                      ],
                                      if (past.isNotEmpty) ...[
                                        _SectionLabel(label: 'Terminées'),
                                        ...past.map(cardFor),
                                      ],
                                    ],
                                  ),
                                );
                              }

                              final filtered = switch (_tab) {
                                'pending' => all
                                    .where((r) =>
                                        r.status ==
                                        StorageRequestStatus.pending)
                                    .toList(),
                                'past' => all
                                    .where((r) =>
                                        r.status ==
                                            StorageRequestStatus.rejected ||
                                        r.status ==
                                            StorageRequestStatus.completed)
                                    .toList(),
                                _ => all
                                    .where((r) =>
                                        r.status ==
                                        StorageRequestStatus.approved)
                                    .toList(),
                              };

                              if (filtered.isEmpty) return emptyState();

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20),
                                child: Column(
                                  children: filtered.map(cardFor).toList(),
                                ),
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 60),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shimmer skeletons ──────────────────────────────────────────

class _WarehouseCardShimmer extends StatelessWidget {
  const _WarehouseCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 156,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 12,
                width: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            height: 26,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _StorageRequestCardShimmer extends StatelessWidget {
  const _StorageRequestCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F0F0),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 14,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        height: 20,
                        width: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 20,
                        width: 64,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Container(
                    height: 12,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hero card ─────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.l10n});
  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.terra, Color(0xFFa85a26)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFa85a26).withValues(alpha: 0.45),
            blurRadius: 36,
            offset: const Offset(0, 18),
            spreadRadius: -14,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient fallback background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF6C45F),
                    Color(0xFFD97B3C),
                    Color(0xFF7E3A1A),
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
            ),
            // Background photo
            Image.network(
              'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?w=900&q=80&auto=format&fit=crop',
              fit: BoxFit.cover,
              color: const Color(0x1A000000),
              colorBlendMode: BlendMode.darken,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
            // Warm colour wash
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xC7C97C3E),
                    Color(0x9E783212),
                    Color(0xD93C1606),
                  ],
                ),
              ),
            ),
            // Bottom veil for readability
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x59000000)],
                  stops: [0.3, 1.0],
                ),
              ),
            ),
            // Decorative sparkle dots (top-right)
            Positioned(
              top: 18,
              right: 18,
              child: Row(
                children: [
                  Container(
                    width: 4, height: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFFfde6b8),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 2.8, height: 2.8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFfde6b8).withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 2, height: 2,
                    decoration: BoxDecoration(
                      color: const Color(0xFFfde6b8).withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFfde6b8),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Conservation Tera',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 10 * 0.12,
                            color: const Color(0xFFfde6b8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Nos entrepôts,\n',
                          style: AppTextStyles.serifHeading(
                            fontSize: 34,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: 'à votre service.',
                          style: AppTextStyles.serifItalic(
                            fontSize: 34,
                            color: const Color(0xFFfde6b8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                            spreadRadius: -6,
                          ),
                        ],
                      ),
                      child: Text(
                        '${context.l10n.reserveNow} →',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.terraDeep,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Warehouse strip ────────────────────────────────────────────

class _WarehouseStrip extends StatelessWidget {
  const _WarehouseStrip({required this.warehouses});
  final List<Warehouse> warehouses;

  @override
  Widget build(BuildContext context) {
    if (warehouses.isEmpty) {
      return const SizedBox(height: 120);
    }
    return SizedBox(
      height: 136,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: warehouses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => _WarehouseCard(warehouse: warehouses[i]),
      ),
    );
  }
}

class _WarehouseCard extends StatelessWidget {
  const _WarehouseCard({required this.warehouse});
  final Warehouse warehouse;

  @override
  Widget build(BuildContext context) {
    final pct = (warehouse.usedPercent * 100).round();
    final isNearFull = warehouse.usedPercent > 0.8;

    return Container(
      width: 156,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.paper2,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.greenPale,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: TeraWarehouseIcon(
                    size: 16,
                    color: AppColors.greenDeep,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  warehouse.name,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$pct',
                  style: AppTextStyles.serifHeading(fontSize: 26),
                ),
                TextSpan(
                  text: '%',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: warehouse.usedPercent,
              child: Container(
                decoration: BoxDecoration(
                  color: isNearFull ? AppColors.terra : AppColors.green,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter chip ───────────────────────────────────────────────

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.forest : AppColors.paper,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: active ? AppColors.forest : AppColors.line,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : AppColors.ink,
              ),
            ),
          ),
        ),
      );
}

// ─── Storage request card ──────────────────────────────────────

class _StorageRequestCard extends StatelessWidget {
  const _StorageRequestCard({
    required this.request,
    this.warehouseName,
    this.product,
  });
  final StorageRequest request;
  final String? warehouseName;
  final Product? product;

  ({Color bg, Color fg, String label}) get _typeStyle =>
      switch (request.type.toUpperCase()) {
        'INBOUND' => (
            bg: AppColors.greenPale,
            fg: AppColors.greenDeep,
            label: 'Dépôt',
          ),
        'OUTBOUND' => (
            bg: AppColors.skyPale,
            fg: const Color(0xFF3A5670),
            label: 'Retrait',
          ),
        _ => (
            bg: AppColors.terraPale,
            fg: AppColors.terraDeep,
            label: 'Transfert',
          ),
      };

  ({Color bg, Color fg, String label}) get _statusStyle =>
      switch (request.status) {
        StorageRequestStatus.approved => (
            bg: AppColors.greenPale,
            fg: AppColors.greenDeep,
            label: 'Approuvée',
          ),
        StorageRequestStatus.pending => (
            bg: AppColors.terraPale,
            fg: AppColors.terraDeep,
            label: 'En attente',
          ),
        StorageRequestStatus.rejected => (
            bg: const Color(0xFFF4CDCA),
            fg: AppColors.bad,
            label: 'Rejetée',
          ),
        StorageRequestStatus.completed => (
            bg: AppColors.paper2,
            fg: AppColors.inkSoft,
            label: 'Terminée',
          ),
      };

  String? get _daysRemaining {
    final end = request.endDate;
    if (end == null) return null;
    final days = end.difference(DateTime.now()).inDays;
    if (days <= 0) return null;
    return '$days j. restants';
  }

  @override
  Widget build(BuildContext context) {
    final ts = _typeStyle;
    final ss = _statusStyle;
    final days = _daysRemaining;
    final p = product;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.paper2,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Product emoji chip ───────────────────────────────
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: p?.tint ?? ts.bg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  p?.emoji ?? '🌿',
                  style: const TextStyle(
                    fontSize: 26,
                    fontFamily: 'Segoe UI Emoji',
                    fontFamilyFallback: ['Apple Color Emoji', 'Noto Color Emoji'],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // ── Content ─────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: quantity + type pill | status pill
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${_fmtNum(request.quantity)} kg',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        height: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        decoration: BoxDecoration(
                          color: ts.bg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Center(
                          child: Text(
                            ts.label,
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: ts.fg,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Status pill — top right
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: ss.bg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          ss.label,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: ss.fg,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Subtitle: warehouse name
                  if (warehouseName != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      warehouseName!,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: AppColors.inkSoft,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  // Bottom row: days remaining — right-aligned
                  if (days != null) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        days,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.greenDeep,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section label ─────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 10),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppColors.inkMute,
          ),
        ),
      );
}

// ─── FAB ───────────────────────────────────────────────────────

class _Fab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => FloatingActionButton(
        onPressed: () => context.push(AppRouter.newStoragePath),
        backgroundColor: AppColors.green,
        elevation: 8,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
      );
}
