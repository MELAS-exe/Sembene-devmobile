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
import 'package:tera/features/market/presentation/blocs/basket_cubit.dart';
import 'package:tera/features/market/presentation/blocs/products_cubit.dart';
import 'package:tera/features/profile/presentation/blocs/profile_cubit.dart';
import 'package:tera/l10n/l10n.dart';
import 'package:tera/shared/widgets/tera_icons.dart';
import 'package:tera/shared/widgets/tera_logo.dart';

// Category chip label → entity category value mapping
const _categories = [
  (label: 'Tous', value: null),
  (label: 'Légumes', value: 'Légume'),
  (label: 'Céréales', value: 'Céréale'),
  (label: 'Tubercules', value: 'Tubercule'),
  (label: 'Fruits', value: 'Fruit'),
  (label: 'Légumineuses', value: 'Légumineuse'),
];

class MarketHomePage extends StatefulWidget {
  const MarketHomePage({super.key});

  @override
  State<MarketHomePage> createState() => _MarketHomePageState();
}

class _MarketHomePageState extends State<MarketHomePage> {
  String? _selectedCategory;
  bool _searching = false;
  String _searchQuery = '';
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    context.read<ProductsCubit>().loadProducts();
    if (context.read<ProfileCubit>().state is ProfileInitial) {
      context.read<ProfileCubit>().loadProfile();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (!_searching) {
        _searchQuery = '';
        _searchCtrl.clear();
      }
    });
  }

  List<Product> _filtered(List<Product> all) {
    var list = all;
    if (_selectedCategory != null) {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hour = DateTime.now().hour;
    final greetingWord = hour < 17 ? 'Bonjour' : 'Bonsoir';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Fixed header ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 14),
            child: Row(
              children: [
                const TeraLogo(),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tera',
                        style: GoogleFonts.inter(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    Text('Marché · Dakar',
                        style: AppTextStyles.label(fontSize: 11)),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _toggleSearch,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _searching ? AppColors.forest : AppColors.paper,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _searching ? AppColors.forest : AppColors.line,
                      ),
                    ),
                    child: Center(
                      child: _searching
                          ? const Icon(Icons.close_rounded,
                              size: 18, color: Colors.white)
                          : const TeraSearchIcon(
                              color: AppColors.ink, size: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                BlocBuilder<BasketCubit, BasketState>(
                  builder: (context, basketState) => Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _IconBtn(
                        child: const Icon(
                            Icons.shopping_basket_outlined,
                            size: 18,
                            color: AppColors.ink),
                        onTap: () => context.push(AppRouter.basketPath),
                      ),
                      if (basketState.count > 0)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppColors.forest,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: AppColors.bg, width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                '${basketState.count}',
                                style: GoogleFonts.inter(
                                  fontSize: 8,
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
                const SizedBox(width: 8),
                Stack(
                  children: [
                    _IconBtn(
                      child: const TeraBellIcon(color: AppColors.ink, size: 18),
                      onTap: () =>
                          context.push(AppRouter.notificationsPath),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.terra,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.bg, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_searching)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.line),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  onChanged: (q) => setState(() => _searchQuery = q),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un produit...',
                    hintStyle: AppTextStyles.label(fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded,
                        size: 18, color: AppColors.inkMute),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          // ── Scrollable content ─────────────────────────────────
          Expanded(
            child: BlocBuilder<ProductsCubit, ProductsState>(
              builder: (context, state) {
                final allProducts =
                    state is ProductsLoaded ? state.products : <Product>[];
                final products = _filtered(allProducts);
                final featured =
                    allProducts.isNotEmpty ? allProducts.first : null;

                return RefreshIndicator(
                  onRefresh: () => context.read<ProductsCubit>().loadProducts(),
                  color: AppColors.forest,
                  backgroundColor: AppColors.paper,
                  child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Greeting
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(20, 14, 20, 10),
                            child: BlocBuilder<ProfileCubit, ProfileState>(
                              builder: (context, profileState) {
                                final name = profileState is ProfileLoaded
                                    ? profileState.profile.firstName
                                        .toUpperCase()
                                    : null;
                                final eyebrow = name != null
                                    ? '$greetingWord · $name'.toUpperCase()
                                    : greetingWord.toUpperCase();
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(eyebrow,
                                        style: AppTextStyles.eyebrow()),
                                    const SizedBox(height: 6),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Que cherchez-vous\n',
                                            style:
                                                AppTextStyles.serifHeading(
                                                    fontSize: 38),
                                          ),
                                          TextSpan(
                                            text: "aujourd'hui ?",
                                            style:
                                                AppTextStyles.serifItalic(
                                                    fontSize: 38),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          // Featured product hero card
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(20, 14, 20, 0),
                            child: _FeaturedCard(product: featured),
                          ),
                          // Category chips
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(20, 18, 0, 6),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _categories.map((cat) {
                                  final active =
                                      _selectedCategory == cat.value;
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(right: 8),
                                    child: _CategoryChip(
                                      label: cat.label,
                                      active: active,
                                      onTap: () => setState(() =>
                                          _selectedCategory = cat.value),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          // Section header
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(20, 18, 20, 10),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              crossAxisAlignment:
                                  CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(l10n.allProducts,
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16)),
                                Text('${products.length} produits',
                                    style:
                                        AppTextStyles.label(fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (state is ProductsLoading)
                      SliverToBoxAdapter(
                        child: Shimmer.fromColors(
                          baseColor: AppColors.line,
                          highlightColor: AppColors.paper2,
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 110),
                            child: Column(
                              children: [
                                for (int r = 0; r < 3; r++) ...[
                                  if (r > 0) const SizedBox(height: 12),
                                  const Row(
                                    children: [
                                      Expanded(
                                          child: _ProductCardShimmer()),
                                      SizedBox(width: 12),
                                      Expanded(
                                          child: _ProductCardShimmer()),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      )
                    else if (state is ProductsError)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(state.message,
                                  style: AppTextStyles.body(
                                      color: AppColors.inkSoft)),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: () => context
                                    .read<ProductsCubit>()
                                    .loadProducts(),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(120, 40),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('Réessayer'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (products.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'Aucun produit dans cette catégorie.',
                            style: AppTextStyles.body(
                                color: AppColors.inkSoft),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                        sliver: SliverGrid.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.64,
                          ),
                          itemCount: products.length,
                          itemBuilder: (ctx, i) =>
                              _ProductCardGrid(product: products[i]),
                        ),
                      ),
                  ],
                ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.product});
  final Product? product;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (product == null) {
      return Shimmer.fromColors(
        baseColor: AppColors.line,
        highlightColor: AppColors.paper2,
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => context.push(AppRouter.productDetailPath, extra: product),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD97B3C), Color(0xFFC25A26)],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _HeroBackdropPainter()),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.inSeason.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.7),
                            letterSpacing: 0.1 * 10.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text.rich(
                          TextSpan(children: [
                            TextSpan(
                              text: '${_buildFirstLine(product!.name)}\n',
                              style: AppTextStyles.serifHeading(
                                      fontSize: 28, color: Colors.white)
                                  .copyWith(height: 1),
                            ),
                            TextSpan(
                              text: _buildLastWord(product!.name),
                              style: AppTextStyles.serifItalic(
                                      fontSize: 28,
                                      color: const Color(0xFFFDE6B8))
                                  .copyWith(height: 1),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          // ignore: lines_longer_than_80_chars
                          '${NumberFormat('#,###', 'fr_FR').format(product!.price.round())} FCFA · le ${product!.unit}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Découvrir →',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.terraDeep,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Emoji
                  Transform.rotate(
                    angle: -0.209,
                    child: Transform.translate(
                      offset: const Offset(0, 8),
                      child: Text(
                        product!.emoji,
                        style: const TextStyle(
                          fontFamily: 'Segoe UI Emoji',
                          fontFamilyFallback: [
                            'Apple Color Emoji',
                            'Noto Color Emoji',
                          ],
                          fontSize: 88,
                          height: 1,
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

  String _buildFirstLine(String name) {
    final words = name.trim().split(' ');
    if (words.length <= 1) return name;
    return words.sublist(0, words.length - 1).join(' ');
  }

  String _buildLastWord(String name) {
    final words = name.trim().split(' ');
    if (words.length <= 1) return '';
    return words.last;
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.child, required this.onTap});
  final Widget child;
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
          child: Center(child: child),
        ),
      );
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
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
          padding: const EdgeInsets.symmetric(horizontal: 14),
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

class _ProductCardGrid extends StatelessWidget {
  const _ProductCardGrid({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Card + card-level tap (navigate to detail)
        GestureDetector(
          onTap: () => context.push(
            AppRouter.productDetailPath,
            extra: product,
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.paper2,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: product.tint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        product.emoji,
                        style: const TextStyle(
                          fontFamily: 'Segoe UI Emoji',
                          fontFamilyFallback: [
                            'Apple Color Emoji',
                            'Noto Color Emoji',
                          ],
                          fontSize: 64,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  product.category,
                  style: AppTextStyles.label(fontSize: 11),
                ),
                Text(
                  product.name,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: -0.005 * 15,
                    height: 1.15,
                  ),
                  maxLines: 2,
                ),
                const Spacer(),
                // Right side reserved for the stacked + button
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 40),
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: NumberFormat('#,###', 'fr_FR')
                              .format(product.price.round()),
                          style: AppTextStyles.tabularNum(fontSize: 13),
                        ),
                        TextSpan(
                          text: ' FCFA/${product.unit}',
                          style: AppTextStyles.tabularNum(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.inkSoft,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // + button sits outside the card GestureDetector — no arena conflict
        Positioned(
          right: 14,
          bottom: 14,
          child: GestureDetector(
            onTap: () => context.read<BasketCubit>().add(product),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.forest,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Shimmer skeleton for a product grid card ────────────────────

class _ProductCardShimmer extends StatelessWidget {
  const _ProductCardShimmer();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.64,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 10,
              width: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 14,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Spacer(),
            Container(
              height: 13,
              width: 96,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 360;
    final sy = size.height / 200;

    // Soft swoop — dark tone at bottom of card
    final swoopPaint = Paint()
      ..color = const Color(0x387A2B10)
      ..style = PaintingStyle.fill;
    final swoopPath = Path()
      ..moveTo(-20 * sx, 170 * sy)
      ..quadraticBezierTo(120 * sx, 130 * sy, 260 * sx, 175 * sy)
      // T command: reflected control point of previous Q
      ..quadraticBezierTo(400 * sx, 220 * sy, 400 * sx, 165 * sy)
      ..lineTo(400 * sx, 200 * sy)
      ..lineTo(-20 * sx, 200 * sy)
      ..close();
    canvas.drawPath(swoopPath, swoopPaint);

    // Halftone dot grid — top-left ornament
    final dotPaint = Paint()
      ..color = const Color(0x38FFE7A8)
      ..style = PaintingStyle.fill;
    for (var r = 0; r < 5; r++) {
      for (var c = 0; c < 6; c++) {
        final cx = (14 + c * 10) * sx;
        final cy = (14 + r * 10) * sy;
        final radius = (r < 3 && c < 4) ? 1.3 * sx : 0.8 * sx;
        canvas.drawCircle(Offset(cx, cy), radius, dotPaint);
      }
    }

    // Sparkle motes — right-center accent
    final sparklePaint = Paint()
      ..color = const Color(0xA6FDE6B8)
      ..style = PaintingStyle.fill;
    canvas
      ..drawCircle(Offset(200 * sx, 36 * sy), 1.2 * sx, sparklePaint)
      ..drawCircle(Offset(225 * sx, 56 * sy), 0.9 * sx, sparklePaint)
      ..drawCircle(Offset(246 * sx, 28 * sy), 0.7 * sx, sparklePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
