import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tera/app/router/app_router.dart';
import 'package:tera/core/utils/app_colors.dart';
import 'package:tera/core/utils/app_text_styles.dart';
import 'package:tera/features/market/domain/entities/product.dart';
import 'package:tera/features/market/presentation/blocs/basket_cubit.dart';
import 'package:tera/features/market/presentation/blocs/product_stock_cubit.dart';
import 'package:tera/l10n/l10n.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({required this.product, super.key});
  final Product product;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  double _quantity = 50;

  static const _quickQty = [10.0, 25.0, 50.0, 100.0];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = widget.product;
    final subtotal = p.price * _quantity;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 420,
                  child: Stack(
                    children: [
                      // Tinted gradient background
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [p.tint, p.tint, AppColors.bg],
                              stops: const [0, 0.7, 1],
                            ),
                          ),
                        ),
                      ),
                      // Emoji hero
                      Positioned(
                        top: 100,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Center(
                          child: Transform.rotate(
                            angle: -0.14,
                            child: Text(
                              p.emoji,
                              style: const TextStyle(
                                fontFamily: 'Segoe UI Emoji',
                                fontFamilyFallback: [
                                  'Apple Color Emoji',
                                  'Noto Color Emoji',
                                ],
                                fontSize: 160,
                                shadows: [
                                  Shadow(
                                    color: Color(0x2E000000),
                                    offset: Offset(0, 20),
                                    blurRadius: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Bottom badges
                      Positioned(
                        bottom: 18,
                        left: 18,
                        child: Row(
                          children: [
                            _Pill(
                              label: l10n.inSeason,
                              bg: Colors.white.withValues(alpha: 0.7),
                              fg: AppColors.greenDeep,
                              dot: true,
                            ),
                            const SizedBox(width: 6),
                            _Pill(
                              label: 'Niayes',
                              bg: Colors.white.withValues(alpha: 0.7),
                              fg: AppColors.ink,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 220),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${p.category.toUpperCase()} · CALIBRE A',
                        style: AppTextStyles.eyebrow(),
                      ),
                      const SizedBox(height: 8),
                      // Product name with serif italic on last word
                      _buildProductName(p.name),
                      const SizedBox(height: 14),
                      // Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            NumberFormat('#,###', 'fr_FR')
                                .format(p.price.round()),
                            style: AppTextStyles.serifHeading(fontSize: 34),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'FCFA / ${l10n.perKg}',
                            style: AppTextStyles.label(fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Description
                      Text(
                        p.description,
                        style: AppTextStyles.body(
                            fontSize: 14.5, color: AppColors.inkSoft),
                      ),
                      const SizedBox(height: 18),
                      // Info row
                      Row(
                        children: [
                          Expanded(
                            child: BlocBuilder<ProductStockCubit,
                                ProductStockState>(
                              builder: (context, state) {
                                final value = state is ProductStockLoaded
                                    ? NumberFormat('#,###', 'fr_FR')
                                        .format(state.totalQuantity.round())
                                    : '—';
                                return _InfoCard(
                                  label: l10n.available,
                                  value: value,
                                  suffix: 'kg en stock',
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _InfoCard(
                              label: l10n.estDelivery,
                              value: '2 – 5',
                              suffix: 'jours',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      // Quantity
                      Text(
                        l10n.quantity,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _QtyBtn(
                            icon: Icons.remove_rounded,
                            dark: false,
                            onTap: () => setState(() {
                              if (_quantity > 1) _quantity -= 1;
                            }),
                          ),
                          Expanded(
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment:
                                    CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    _quantity.round().toString(),
                                    style: AppTextStyles.serifHeading(
                                        fontSize: 36),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    p.unit,
                                    style: AppTextStyles.label(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          _QtyBtn(
                            icon: Icons.add_rounded,
                            dark: true,
                            onTap: () =>
                                setState(() => _quantity += 1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Quick qty chips
                      Row(
                        children: _quickQty
                            .map((q) => Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: _Chip(
                                    label: '${q.round()} ${p.unit}',
                                    active: _quantity == q,
                                    onTap: () =>
                                        setState(() => _quantity = q),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Sticky top bar
          Positioned(
            top: 52,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _IconBtn(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => context.pop(),
                ),
                Row(
                  children: [
                    _IconBtn(
                        icon: Icons.favorite_border_rounded, onTap: () {}),
                    const SizedBox(width: 8),
                    BlocBuilder<BasketCubit, BasketState>(
                      builder: (context, basket) => GestureDetector(
                        onTap: () => context.push(AppRouter.basketPath),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.paper,
                                borderRadius:
                                    BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppColors.line),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.shopping_basket_outlined,
                                  size: 18,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                            if (basket.count > 0)
                              Positioned(
                                top: 2,
                                right: 2,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: AppColors.forest,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.bg,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${basket.count}',
                                      style: GoogleFonts.inter(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Sticky bottom CTA
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xF2F7F2E6),
                border: Border(
                    top: BorderSide(color: AppColors.line)),
              ),
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 36),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.subtotal,
                            style: AppTextStyles.eyebrow()),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              NumberFormat('#,###', 'fr_FR')
                                  .format(subtotal.round()),
                              style:
                                  AppTextStyles.serifHeading(fontSize: 28),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'FCFA',
                              style: AppTextStyles.label(fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  FilledButton.icon(
                    onPressed: () {
                      context.read<BasketCubit>().add(
                            p,
                            quantity: _quantity,
                          );
                      context.pop();
                    },
                    icon: const Icon(Icons.shopping_basket_outlined,
                        size: 18),
                    label: Text(l10n.addToBasket),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.forest,
                      minimumSize: const Size(152, 54),
                      textStyle: GoogleFonts.inter(
                          fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductName(String name) {
    final words = name.trim().split(' ');
    if (words.length <= 1) {
      return Text(name,
          style: AppTextStyles.serifHeading(fontSize: 44)
              .copyWith(height: 1));
    }
    final first = words.sublist(0, words.length - 1).join(' ');
    final last = words.last;
    return Text.rich(
      TextSpan(children: [
        TextSpan(
            text: '$first ',
            style: AppTextStyles.serifHeading(fontSize: 44)
                .copyWith(height: 1)),
        TextSpan(
            text: last,
            style: AppTextStyles.serifItalic(fontSize: 44)
                .copyWith(height: 1)),
      ]),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.line),
          ),
          child: Center(child: Icon(icon, size: 18, color: AppColors.ink)),
        ),
      );
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.bg,
    required this.fg,
    this.dot = false,
  });
  final String label;
  final Color bg;
  final Color fg;
  final bool dot;

  @override
  Widget build(BuildContext context) => Container(
        height: 26,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dot) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: fg,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
            ],
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: fg)),
          ],
        ),
      );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard(
      {required this.label, required this.value, required this.suffix});
  final String label;
  final String value;
  final String suffix;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          color: AppColors.paper2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTextStyles.label(fontSize: 11)),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(width: 4),
                Text(suffix,
                    style: AppTextStyles.label(fontSize: 12)),
              ],
            ),
          ],
        ),
      );
}

class _QtyBtn extends StatelessWidget {
  const _QtyBtn(
      {required this.icon, required this.dark, required this.onTap});
  final IconData icon;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: dark ? AppColors.forest : AppColors.paper,
            borderRadius: BorderRadius.circular(14),
            border: dark ? null : Border.all(color: AppColors.line),
          ),
          child: Icon(icon,
              size: 18, color: dark ? Colors.white : AppColors.ink),
        ),
      );
}

class _Chip extends StatelessWidget {
  const _Chip(
      {required this.label, required this.active, required this.onTap});
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
                color: active ? AppColors.forest : AppColors.line),
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
