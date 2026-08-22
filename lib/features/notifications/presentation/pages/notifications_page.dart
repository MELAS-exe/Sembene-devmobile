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
import 'package:tera/features/notifications/domain/entities/notification_item.dart';
import 'package:tera/features/notifications/presentation/blocs/notification_cubit.dart';
import 'package:tera/features/orders/domain/repositories/i_order_repository.dart';
import 'package:tera/injector.dart';
import 'package:tera/shared/widgets/tera_icons.dart';

String _fmtTime(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 1) return 'À l\'instant';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min';
  if (diff.inHours < 24) return '${diff.inHours} h';
  return DateFormat('d MMM', 'fr_FR').format(dt);
}

bool _isToday(DateTime dt) {
  final now = DateTime.now();
  return dt.year == now.year &&
      dt.month == now.month &&
      dt.day == now.day;
}

({Color bg, Color fg, Widget icon}) _kindStyle(NotificationKind kind) =>
    switch (kind) {
      NotificationKind.order => (
          bg: AppColors.goldPale,
          fg: const Color(0xFF8A6B1F),
          icon: const Icon(Icons.local_shipping_outlined,
              size: 18, color: Color(0xFF8A6B1F)),
        ),
      NotificationKind.storage => (
          bg: AppColors.greenPale,
          fg: AppColors.greenDeep,
          icon: const TeraWarehouseIcon(size: 18, color: AppColors.greenDeep),
        ),
      NotificationKind.payment => (
          bg: AppColors.terraPale,
          fg: AppColors.terraDeep,
          icon: const Icon(Icons.auto_awesome_outlined,
              size: 18, color: AppColors.terraDeep),
        ),
      NotificationKind.general => (
          bg: AppColors.skyPale,
          fg: const Color(0xFF3A5670),
          icon: const TeraBellIcon(size: 18, color: Color(0xFF3A5670)),
        ),
    };

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  NotificationKind? _filter;

  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().loadNotifications();
  }

  Future<void> _navigateForItem(NotificationItem item) async {
    final route = item.targetRoute;
    final entityId = item.targetEntityId;
    if (route == null || !mounted) return;

    switch (route) {
      case '/orders/detail':
        if (entityId == null) return;
        final result =
            await getIt<IOrderRepository>().getOrderById(entityId);
        if (!mounted) return;
        result.fold((_) {}, (order) {
          context.push(AppRouter.orderDetailPath, extra: order);
        });
      case '/storage-requests/detail':
        context.go(AppRouter.storagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          final notifications = state is NotificationsLoaded
              ? state.notifications
              : <NotificationItem>[];
          final unreadCount =
              notifications.where((n) => !n.isRead).length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Fixed header ─────────────────────────────────────
              SafeArea(
                bottom: false,
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back button
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.paper,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: AppColors.line),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 16,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CENTRE D\'ALERTES',
                                  style: AppTextStyles.eyebrow(),
                                ),
                                const SizedBox(height: 4),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Notifications ',
                                        style:
                                            AppTextStyles.serifHeading(
                                                fontSize: 32),
                                      ),
                                      TextSpan(
                                        text: 'fraîches',
                                        style:
                                            AppTextStyles.serifItalic(
                                          fontSize: 32,
                                          color: AppColors.greenDeep,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (unreadCount > 0)
                            GestureDetector(
                              onTap: () => context
                                  .read<NotificationCubit>()
                                  .markAllAsRead(),
                              child: Container(
                                height: 34,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.paper,
                                  borderRadius:
                                      BorderRadius.circular(999),
                                  border: Border.all(
                                      color: AppColors.line),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_rounded,
                                      size: 14,
                                      color: AppColors.terraDeep,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Tout marquer',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.terraDeep,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),

                      // ── Filter chips ────────────────────────────
                      const SizedBox(height: 14),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FilterChip(
                              label: 'Tout',
                              count: notifications.length,
                              active: _filter == null,
                              onTap: () =>
                                  setState(() => _filter = null),
                            ),
                            const SizedBox(width: 6),
                            _FilterChip(
                              label: 'Commandes',
                              count: notifications
                                  .where((n) =>
                                      n.kind == NotificationKind.order)
                                  .length,
                              active:
                                  _filter == NotificationKind.order,
                              onTap: () => setState(
                                  () => _filter = NotificationKind.order),
                            ),
                            const SizedBox(width: 6),
                            _FilterChip(
                              label: 'Stock',
                              count: notifications
                                  .where((n) =>
                                      n.kind ==
                                      NotificationKind.storage)
                                  .length,
                              active:
                                  _filter == NotificationKind.storage,
                              onTap: () => setState(() =>
                                  _filter = NotificationKind.storage),
                            ),
                            const SizedBox(width: 6),
                            _FilterChip(
                              label: 'Paiements',
                              count: notifications
                                  .where((n) =>
                                      n.kind ==
                                      NotificationKind.payment)
                                  .length,
                              active:
                                  _filter == NotificationKind.payment,
                              onTap: () => setState(() =>
                                  _filter = NotificationKind.payment),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),

              // ── Scrollable list ───────────────────────────────────
              Expanded(
                child: _buildContent(context, state, notifications),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    NotificationState state,
    List<NotificationItem> notifications,
  ) {
    if (state is NotificationLoading) {
      return const _NotificationsShimmer();
    }
    if (state is NotificationError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 36, color: AppColors.inkSoft),
              const SizedBox(height: 12),
              Text(state.message,
                  style:
                      AppTextStyles.body(color: AppColors.inkSoft),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => context
                    .read<NotificationCubit>()
                    .loadNotifications(),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.forest),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    final filtered = _filter == null
        ? notifications
        : notifications
            .where((n) => n.kind == _filter)
            .toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TeraBellIcon(size: 40, color: AppColors.inkMute),
            const SizedBox(height: 12),
            Text('Aucune notification ici.',
                style: AppTextStyles.label(fontSize: 13)),
          ],
        ),
      );
    }

    final today =
        filtered.where((n) => _isToday(n.createdAt)).toList();
    final earlier =
        filtered.where((n) => !_isToday(n.createdAt)).toList();

    return RefreshIndicator(
      color: AppColors.forest,
      backgroundColor: AppColors.paper,
      onRefresh: () =>
          context.read<NotificationCubit>().loadNotifications(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 60),
        children: [
          if (today.isNotEmpty) ...[
            Text("AUJOURD'HUI", style: AppTextStyles.eyebrow()),
            const SizedBox(height: 8),
            ...today.map((n) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _NotificationCard(
                    item: n,
                    onTap: () {
                      context.read<NotificationCubit>().markAsRead(n.id);
                      unawaited(_navigateForItem(n));
                    },
                  ),
                )),
          ],
          if (earlier.isNotEmpty) ...[
            if (today.isNotEmpty) const SizedBox(height: 10),
            Text('PRÉCÉDEMMENT', style: AppTextStyles.eyebrow()),
            const SizedBox(height: 8),
            ...earlier.map((n) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _NotificationCard(
                    item: n,
                    onTap: () {
                      context.read<NotificationCubit>().markAsRead(n.id);
                      unawaited(_navigateForItem(n));
                    },
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

// ─── Shimmer skeleton ─────────────────────────────────────────

class _NotificationsShimmer extends StatelessWidget {
  const _NotificationsShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.line,
      highlightColor: AppColors.paper2,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 60),
        children: [
          for (int i = 0; i < 6; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            const _NotificationCardShimmer(),
          ],
        ],
      ),
    );
  }
}

class _NotificationCardShimmer extends StatelessWidget {
  const _NotificationCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 13,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                    Container(
                      width: 28,
                      height: 11,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Container(
                  height: 11,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 5),
                FractionallySizedBox(
                  widthFactor: 0.6,
                  child: Container(
                    height: 11,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Notification card ────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.onTap});
  final NotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ks = _kindStyle(item.kind);
    return GestureDetector(
      onTap: item.isRead ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.isRead ? AppColors.paper : const Color(0xFFFBFBF2),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: item.isRead ? AppColors.line : AppColors.greenPale,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kind icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ks.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: ks.icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!item.isRead) ...[
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: AppColors.terra,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.terra
                                    .withValues(alpha: 0.18),
                                blurRadius: 0,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 7),
                      ],
                      Expanded(
                        child: Text(
                          item.displayTitle,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontWeight: item.isRead
                                ? FontWeight.w600
                                : FontWeight.w700,
                            fontSize: 14,
                            color: item.isRead
                                ? AppColors.ink2
                                : AppColors.ink,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _fmtTime(item.createdAt),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.inkMute,
                        ),
                      ),
                    ],
                  ),
                  if (item.displayBody.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.displayBody,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: AppColors.inkSoft,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (!item.isRead && item.channel.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.channel.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppColors.inkMute,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 10 * 0.08,
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

// ─── Filter chip ──────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });
  final String label;
  final int count;
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : AppColors.ink,
                ),
              ),
              Text(
                ' $count',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: active
                      ? Colors.white.withValues(alpha: 0.55)
                      : AppColors.inkSoft,
                ),
              ),
            ],
          ),
        ),
      );
}
