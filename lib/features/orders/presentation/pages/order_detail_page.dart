import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:tera/core/utils/app_colors.dart';
import 'package:tera/core/utils/app_text_styles.dart';
import 'package:tera/features/market/domain/entities/product.dart';
import 'package:tera/features/market/presentation/blocs/products_cubit.dart';
import 'package:tera/features/orders/domain/entities/order.dart';
import 'package:tera/features/orders/presentation/blocs/order_cubit.dart';

String _fmtFCFA(double n) =>
    '${NumberFormat('#,###', 'fr_FR').format(n.round())} FCFA';

String _fmtNum(double n) => NumberFormat('#,###', 'fr_FR').format(n.round());

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({required this.order, super.key});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final shortId =
        '#${order.id.substring(0, order.id.length.clamp(0, 8)).toUpperCase()}';

    return BlocListener<OrderCubit, OrderState>(
      listener: (context, state) {
        if (state is OrderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Fixed top bar ───────────────────────────────────────
            _TopBar(shortId: shortId, order: order),

            // ── Scrollable content ──────────────────────────────────
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // ── Hero card ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: _HeroCard(order: order),
                  ),

                  // ── Timeline ──────────────────────────────────────
                  if (order.status != OrderStatus.cancelled) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: Text(
                        'Suivi en temps réel',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: _Timeline(status: order.status),
                    ),
                  ],

                  // ── Driver card (shipping / shipped) ──────────────
                  if (order.status == OrderStatus.shipping ||
                      order.status == OrderStatus.shipped) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
                      child: Text(
                        'Livreur',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _DriverCard(delivery: order.delivery),
                    ),
                  ],

                  // ── Order summary ─────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
                    child: Text(
                      'Détails commande',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _OrderSummary(order: order),
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Top bar ───────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.shortId, required this.order});
  final String shortId;
  final Order order;

  void _showOptions(BuildContext context) {
    final cancellable = order.status != OrderStatus.cancelled &&
        order.status != OrderStatus.delivered;
    final cubit = context.read<OrderCubit>();
    final nav = Navigator.of(context);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 20),
              _OptionRow(
                icon: Icons.share_rounded,
                label: 'Partager la commande',
                onTap: () => Navigator.of(sheetCtx).pop(),
              ),
              if (cancellable)
                _OptionRow(
                  icon: Icons.cancel_outlined,
                  label: 'Annuler la commande',
                  color: AppColors.bad,
                  onTap: () async {
                    Navigator.of(sheetCtx).pop();
                    final confirmed = await showDialog<bool>(
                      context: nav.context,
                      builder: (dialogCtx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: Text(
                          'Annuler la commande ?',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        content: Text(
                          'Cette action est irréversible.',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            color: AppColors.inkSoft,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogCtx).pop(false),
                            child: Text(
                              'Non',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: AppColors.inkSoft,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogCtx).pop(true),
                            child: Text(
                              'Oui, annuler',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: AppColors.bad,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirmed ?? false) {
                      await cubit.cancelOrder(order.id);
                      if (cubit.state is! OrderError) nav.pop();
                    }
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.line),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: AppColors.ink,
                ),
              ),
            ),
            Expanded(
              child: Text(
                shortId,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.5,
                  color: AppColors.ink,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _showOptions(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.line),
                ),
                child: const Icon(
                  Icons.more_horiz_rounded,
                  size: 20,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.ink,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 14),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      );
}

// ─── Hero card ─────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.order});
  final Order order;

  // Eyebrow: "STATUS · Livraison estimée" (no estimate for cancelled)
  String get _eyebrow {
    final status = switch (order.status) {
      OrderStatus.pending || OrderStatus.created => 'EN ATTENTE',
      OrderStatus.confirmed => 'CONFIRMÉE',
      OrderStatus.shipping => 'EN PRÉPARATION',
      OrderStatus.shipped => 'EN ROUTE',
      OrderStatus.delivered => 'LIVRÉE',
      OrderStatus.cancelled => 'ANNULÉE',
    };
    if (order.status == OrderStatus.cancelled ||
        order.status == OrderStatus.delivered) {
      return status;
    }
    return '$status · Livraison estimée';
  }

  // Heading line 1: the delivery estimate (what the eyebrow labels)
  String get _title => switch (order.status) {
        OrderStatus.pending || OrderStatus.created => 'En attente',
        OrderStatus.confirmed => 'Sous peu',
        OrderStatus.shipping => 'Demain',
        OrderStatus.shipped => 'En route',
        OrderStatus.delivered => 'Livrée',
        OrderStatus.cancelled => 'Annulée',
      };

  // Heading line 2: italic accent
  String get _subtitle => switch (order.status) {
        OrderStatus.pending || OrderStatus.created => 'de confirmation',
        OrderStatus.confirmed => 'en préparation',
        OrderStatus.shipping => 'au matin',
        OrderStatus.shipped => 'vers vous',
        OrderStatus.delivered => 'avec succès',
        OrderStatus.cancelled => 'commande annulée',
      };

  String get _itemsSummary {
    if (order.items.isEmpty) return '—';
    final totalQty =
        order.items.fold<double>(0, (sum, i) => sum + i.quantity);
    final count = order.items.length;
    return '${_fmtNum(totalQty)} kg · $count article${count > 1 ? 's' : ''}';
  }

  String get _routeLabel => switch (order.status) {
        OrderStatus.pending || OrderStatus.created => 'Commande enregistrée',
        OrderStatus.confirmed => 'Prise en charge confirmée',
        OrderStatus.shipping => 'En cours de préparation',
        OrderStatus.shipped => 'Livraison en cours',
        OrderStatus.delivered => 'Commande livrée',
        OrderStatus.cancelled => 'Commande annulée',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.forest, Color(0xFF0f1a0c)],
        ),
      ),
      child: Stack(
        children: [
          // Watermark emoji (fontSize: 200, as in design)
          Positioned(
            right: -20,
            bottom: -30,
            child: Opacity(
              opacity: 0.18,
              child: Transform.rotate(
                angle: -0.209,
                child: const Text(
                  '🛍️',
                  style: TextStyle(
                    fontFamily: 'Segoe UI Emoji',
                    fontFamilyFallback: [
                      'Apple Color Emoji',
                      'Noto Color Emoji',
                    ],
                    fontSize: 200,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Eyebrow: status · Livraison estimée
              Text(
                _eyebrow,
                style: AppTextStyles.eyebrow(
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 8),
              // Heading: delivery estimate (serif + italic)
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$_title\n',
                      style: AppTextStyles.serifHeading(
                        fontSize: 36,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: _subtitle,
                      style: AppTextStyles.serifItalic(
                        fontSize: 36,
                        color: const Color(0xFFcfe0b9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Product row — flat, no background container (matches design)
              Row(
                children: [
                  // ProductChip: tinted circle + bag emoji (size 36)
                  Container(
                    width: 36,
                    height: 36,
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
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _itemsSummary,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _routeLabel,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Timeline ──────────────────────────────────────────────────

class _Timeline extends StatelessWidget {
  const _Timeline({required this.status});
  final OrderStatus status;

  static const _stages = [
    (label: 'Reçue', sub: 'Commande enregistrée'),
    (label: 'Confirmée', sub: 'Prise en charge'),
    (label: 'Préparation', sub: 'En cours de préparation'),
    (label: 'En route', sub: 'En cours de livraison'),
    (label: 'Livrée', sub: 'Commande livrée'),
  ];

  int get _currentIndex => switch (status) {
        OrderStatus.pending || OrderStatus.created => 0,
        OrderStatus.confirmed => 1,
        OrderStatus.shipping => 2,
        OrderStatus.shipped => 3,
        OrderStatus.delivered => 4,
        _ => 0,
      };

  @override
  Widget build(BuildContext context) {
    final current = _currentIndex;
    return Column(
      children: List.generate(_stages.length, (i) {
        return _StageRow(
          label: _stages[i].label,
          sub: _stages[i].sub,
          done: i <= current,
          active: i == current,
          topColor: i == 0
              ? Colors.transparent
              : (i <= current ? AppColors.green : AppColors.line),
          bottomColor: i == _stages.length - 1
              ? Colors.transparent
              : (i < current ? AppColors.green : AppColors.line),
          isLast: i == _stages.length - 1,
        );
      }),
    );
  }
}

class _StageRow extends StatelessWidget {
  const _StageRow({
    required this.label,
    required this.sub,
    required this.done,
    required this.active,
    required this.topColor,
    required this.bottomColor,
    required this.isLast,
  });

  final String label;
  final String sub;
  final bool done;
  final bool active;
  final Color topColor;
  final Color bottomColor;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: connector lines + dot
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Container(width: 2, color: topColor),
                  ),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: done ? AppColors.green : AppColors.paper,
                    shape: BoxShape.circle,
                    border: done
                        ? null
                        : Border.all(color: AppColors.line, width: 2),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: AppColors.green.withValues(alpha: 0.18),
                              spreadRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                  child: done
                      ? const Icon(
                          Icons.check_rounded,
                          size: 13,
                          color: Colors.white,
                        )
                      : null,
                ),
                Expanded(
                  child: Center(
                    child: Container(width: 2, color: bottomColor),
                  ),
                ),
              ],
            ),
          ),
          // Right: stage content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: 14,
                top: 2,
                bottom: isLast ? 4 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: done ? AppColors.ink : AppColors.inkMute,
                          ),
                        ),
                      ),
                      if (active)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.greenPale,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'En cours',
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.greenDeep,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    active
                        ? 'En cours · ${sub.toLowerCase()}'
                        : (done ? sub : 'À venir'),
                    style: AppTextStyles.label(fontSize: 11.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Driver card ───────────────────────────────────────────────

class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.delivery});
  final Delivery? delivery;

  String get _initials {
    if (delivery == null || !delivery!.hasDriver) return '?';
    final first = delivery!.driverFirstName?.isNotEmpty == true
        ? delivery!.driverFirstName![0].toUpperCase()
        : '';
    final last = delivery!.driverLastName?.isNotEmpty == true
        ? delivery!.driverLastName![0].toUpperCase()
        : '';
    return '$first$last'.isEmpty ? '?' : '$first$last';
  }

  void _copyPhone(BuildContext context, String phone) {
    Clipboard.setData(ClipboardData(text: phone));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Numéro copié : $phone')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasDriver = delivery?.hasDriver ?? false;
    final name = hasDriver ? delivery!.driverFullName : 'En attente d\'un chauffeur';
    final phone = delivery?.driverPhoneNumber;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.greenPale,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                hasDriver ? _initials : '—',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.greenDeep,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chauffeur', style: AppTextStyles.label(fontSize: 11)),
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: hasDriver ? AppColors.ink : AppColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: (hasDriver && phone != null) ? () => _copyPhone(context, phone) : null,
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: (hasDriver && phone != null)
                    ? AppColors.greenPale
                    : AppColors.inkMute.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Appeler',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: (hasDriver && phone != null)
                        ? AppColors.greenDeep
                        : AppColors.inkSoft,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Order summary ─────────────────────────────────────────────

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, productsState) {
        final products = productsState is ProductsLoaded
            ? productsState.products
            : <Product>[];

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.line),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F1A1F17),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              ...order.items.map((item) {
                final product = products
                    .where((p) => p.id == item.productId)
                    .firstOrNull;
                final name = product?.name ?? '—';
                final emoji = product?.emoji ?? '🛍️';
                final tint = product?.tint ?? AppColors.greenPale;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      // tinted circle + emoji at size * 0.55
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: tint,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(
                              fontFamily: 'Segoe UI Emoji',
                              fontFamilyFallback: [
                                'Apple Color Emoji',
                                'Noto Color Emoji',
                              ],
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: AppColors.ink,
                              ),
                            ),
                            Text(
                              '${item.quantity.round()} kg × '
                              '${_fmtNum(item.unitPrice)} FCFA',
                              style: AppTextStyles.label(fontSize: 11.5),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _fmtFCFA(item.lineTotal),
                        style: AppTextStyles.tabularNum(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              // Divider: margin 10px top, 8px bottom (design div-line)
              const Padding(
                padding: EdgeInsets.only(top: 10, bottom: 8),
                child: Divider(height: 1, color: AppColors.line),
              ),
              // Total row: space-between + baseline alignment
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text('Total', style: AppTextStyles.label()),
                  ),
                  Text(
                    _fmtFCFA(order.totalAmount),
                    style: AppTextStyles.serifHeading(fontSize: 22),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
