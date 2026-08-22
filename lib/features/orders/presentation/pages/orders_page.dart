import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tera/app/router/app_router.dart';
import 'package:tera/core/utils/app_colors.dart';
import 'package:tera/core/utils/app_text_styles.dart';
import 'package:tera/features/orders/domain/entities/order.dart';
import 'package:tera/features/orders/presentation/blocs/order_cubit.dart';
import 'package:tera/l10n/l10n.dart';
import 'package:tera/shared/widgets/tera_icons.dart';

String _fmtFCFA(double n) =>
    '${NumberFormat('#,###', 'fr_FR').format(n.round())} FCFA';

String _fmtDate(DateTime dt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(dt.year, dt.month, dt.day);
  if (date == today) return "Aujourd'hui";
  if (date == today.subtract(const Duration(days: 1))) return 'Hier';
  return DateFormat('d MMM yyyy', 'fr_FR').format(dt);
}

({Color bg, Color fg}) _statusColors(OrderStatus status) => switch (status) {
      OrderStatus.pending =>
        (bg: AppColors.pillPendingBg, fg: AppColors.pillPendingFg),
      OrderStatus.created =>
        (bg: AppColors.pillCreatedBg, fg: AppColors.pillCreatedFg),
      OrderStatus.confirmed =>
        (bg: AppColors.pillConfirmedBg, fg: AppColors.pillConfirmedFg),
      OrderStatus.shipping =>
        (bg: AppColors.pillShippingBg, fg: AppColors.pillShippingFg),
      OrderStatus.shipped =>
        (bg: AppColors.pillShippedBg, fg: AppColors.pillShippedFg),
      OrderStatus.delivered =>
        (bg: AppColors.pillDeliveredBg, fg: AppColors.pillDeliveredFg),
      OrderStatus.cancelled =>
        (bg: AppColors.pillCancelledBg, fg: AppColors.pillCancelledFg),
    };

String _statusLabel(BuildContext context, OrderStatus status) {
  final l10n = context.l10n;
  return switch (status) {
    OrderStatus.pending => l10n.statusPENDING,
    OrderStatus.created => l10n.statusCREATED,
    OrderStatus.confirmed => l10n.statusCONFIRMED,
    OrderStatus.shipping => l10n.statusSHIPPING,
    OrderStatus.shipped => l10n.statusSHIPPED,
    OrderStatus.delivered => l10n.statusDELIVERED,
    OrderStatus.cancelled => l10n.statusCANCELLED,
  };
}

String _itemsLine(Order order) => order.items
    .map(
      (i) =>
          '${i.quantity.round()} kg × '
          '${NumberFormat('#,###', 'fr_FR').format(i.unitPrice.round())} FCFA',
    )
    .join(' · ');

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String _tab = 'active';
  bool _showSearch = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<OrderCubit>().loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BlocConsumer<OrderCubit, OrderState>(
        listener: (context, state) {
          if (state is OrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is OrderLoading) {
            return const _OrdersShimmer();
          }
          if (state is OrderError) {
            return _ErrorState(
              message: state.message,
              onRetry: () => context.read<OrderCubit>().loadOrders(),
            );
          }
          if (state is OrdersLoaded) {
            return _OrdersBody(
              orders: state.orders,
              tab: _tab,
              onTabChanged: (t) => setState(() => _tab = t),
              onRefresh: () async => context.read<OrderCubit>().loadOrders(),
              showSearch: _showSearch,
              searchQuery: _searchQuery,
              searchController: _searchController,
              onSearchToggle: () => setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              }),
              onSearchChanged: (q) => setState(() => _searchQuery = q),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─── Shimmer skeleton ─────────────────────────────────────────

class _OrdersShimmer extends StatelessWidget {
  const _OrdersShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.line,
      highlightColor: AppColors.paper2,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 11,
                    width: 110,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 38,
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Row(
              children: [50.0, 80.0, 96.0].map((w) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Container(
                  height: 30,
                  width: w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              )).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
            child: Column(
              children: List.generate(5, (_) => const _OrderCardShimmer()),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCardShimmer extends StatelessWidget {
  const _OrderCardShimmer();

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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        width: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 24,
                        width: 72,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 12,
                    width: 130,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        height: 11,
                        width: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 11,
                        width: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
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

// ─── Body (scrollable) ────────────────────────────────────────

class _OrdersBody extends StatelessWidget {
  const _OrdersBody({
    required this.orders,
    required this.tab,
    required this.onTabChanged,
    required this.onRefresh,
    required this.showSearch,
    required this.searchQuery,
    required this.searchController,
    required this.onSearchToggle,
    required this.onSearchChanged,
  });

  final List<Order> orders;
  final String tab;
  final void Function(String) onTabChanged;
  final Future<void> Function() onRefresh;
  final bool showSearch;
  final String searchQuery;
  final TextEditingController searchController;
  final VoidCallback onSearchToggle;
  final void Function(String) onSearchChanged;

  List<Order> get _filtered {
    final sorted = [...orders]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final tabFiltered = switch (tab) {
      'active' => sorted.where((o) => o.isActive).toList(),
      'past' => sorted.where((o) => !o.isActive).toList(),
      _ => sorted,
    };
    if (searchQuery.isEmpty) return tabFiltered;
    final q = searchQuery.toLowerCase();
    return tabFiltered
        .where((o) => o.id.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = orders.where((o) => o.isActive).length;
    final filtered = _filtered;
    final tabs = [
      ('all', 'Tout', orders.length),
      ('active', 'En cours', orders.where((o) => o.isActive).length),
      ('past', 'Historique', orders.where((o) => !o.isActive).length),
    ];

    return RefreshIndicator(
      color: AppColors.forest,
      backgroundColor: AppColors.paper,
      onRefresh: onRefresh,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Hero header ──────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VOS COMMANDES',
                              style: AppTextStyles.eyebrow(),
                            ),
                            const SizedBox(height: 6),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '$activeCount ',
                                    style: AppTextStyles.serifHeading(
                                        fontSize: 36),
                                  ),
                                  TextSpan(
                                    text: 'en cours',
                                    style: AppTextStyles.serifItalic(
                                        fontSize: 36),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: onSearchToggle,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: showSearch
                                ? AppColors.forest
                                : AppColors.paper,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: showSearch
                                  ? AppColors.forest
                                  : AppColors.line,
                            ),
                          ),
                          child: Icon(
                            showSearch
                                ? Icons.close_rounded
                                : Icons.search_rounded,
                            size: 18,
                            color: showSearch ? Colors.white : AppColors.ink,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () =>
                            context.push(AppRouter.notificationsPath),
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
                    ],
                  ),
                  if (showSearch) ...[
                    const SizedBox(height: 12),
                    Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.paper,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: TextField(
                        controller: searchController,
                        autofocus: true,
                        onChanged: onSearchChanged,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          color: AppColors.ink,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Rechercher par numéro…',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 13.5,
                            color: AppColors.inkMute,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: AppColors.inkMute,
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Filter chips ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Row(
              children: tabs.map((tb) {
                final isActive = tab == tb.$1;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => onTabChanged(tb.$1),
                    child: Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color:
                            isActive ? AppColors.forest : AppColors.paper,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isActive
                              ? AppColors.forest
                              : AppColors.line,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tb.$2,
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: isActive ? Colors.white : AppColors.ink,
                            ),
                          ),
                          Text(
                            ' ${tb.$3}',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? Colors.white.withValues(alpha: 0.55)
                                  : AppColors.inkSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // ── Order cards or empty ──────────────────────────────
          if (filtered.isEmpty)
            SizedBox(
              height: 300,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '📦',
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
                      'Aucune commande ici.',
                      style: AppTextStyles.label(fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
              child: Column(
                children: filtered
                    .map(
                      (o) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () async {
                            await context.push(
                              AppRouter.orderDetailPath,
                              extra: o,
                            );
                            if (context.mounted) {
                              unawaited(
                                context.read<OrderCubit>().loadOrders(),
                              );
                            }
                          },
                          child: _OrderCard(order: o),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Order card ───────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final colors = _statusColors(order.status);
    final label = _statusLabel(context, order.status);
    final shortId =
        '#${order.id.substring(0, order.id.length.clamp(0, 8)).toUpperCase()}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.paper2,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular chip
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.greenPale,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '🛍️',
                style: TextStyle(
                  fontFamily: 'Segoe UI Emoji',
                  fontFamilyFallback: [
                    'Apple Color Emoji',
                    'Noto Color Emoji',
                  ],
                  fontSize: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order ID + status pill
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        shortId,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusPill(colors: colors, label: label),
                  ],
                ),
                const SizedBox(height: 2),
                // Items line
                Text(
                  _itemsLine(order),
                  style: AppTextStyles.label(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Date + total
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _fmtDate(order.createdAt),
                        style: AppTextStyles.label(fontSize: 11.5),
                      ),
                    ),
                    Text(
                      _fmtFCFA(order.totalAmount),
                      style: AppTextStyles.tabularNum(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Status pill ──────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.colors, required this.label});
  final ({Color bg, Color fg}) colors;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        height: 24,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: colors.bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: colors.fg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: colors.fg,
                letterSpacing: 0.01 * 11.5,
              ),
            ),
          ],
        ),
      );
}

// ─── Error state ──────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 36,
                color: AppColors.inkSoft,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: AppTextStyles.body(color: AppColors.inkSoft),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forest,
                ),
                child: Text(context.l10n.retry),
              ),
            ],
          ),
        ),
      );
}
