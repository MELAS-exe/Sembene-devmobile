import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tera/core/extensions/context_extensions.dart';
import 'package:tera/core/utils/app_colors.dart';
import 'package:tera/core/utils/app_text_styles.dart';
import 'package:tera/features/market/domain/entities/product.dart';
import 'package:tera/features/market/presentation/blocs/products_cubit.dart';
import 'package:tera/features/storage/domain/entities/warehouse.dart';
import 'package:tera/features/storage/presentation/blocs/new_storage_request_cubit.dart';
import 'package:tera/features/storage/presentation/blocs/warehouse_cubit.dart';
import 'package:tera/l10n/l10n.dart';
import 'package:tera/shared/widgets/tera_icons.dart';
import 'package:tera/shared/widgets/tera_top_bar.dart';

String _fmtFCFA(double n) =>
    '${NumberFormat('#,###', 'fr_FR').format(n.round())} FCFA';

String _fmtNum(double n) => NumberFormat('#,###', 'fr_FR').format(n.round());

class NewStorageRequestPage extends StatefulWidget {
  const NewStorageRequestPage({super.key});

  @override
  State<NewStorageRequestPage> createState() => _NewStorageRequestPageState();
}

class _NewStorageRequestPageState extends State<NewStorageRequestPage> {
  Product? _product;
  Warehouse? _warehouse;
  double _quantity = 500;
  int _duration = 21;
  bool _delegatedSale = false;

  late final TextEditingController _qtyCtrl;
  late final TextEditingController _durCtrl;

  @override
  void initState() {
    super.initState();
    _qtyCtrl = TextEditingController(text: '500');
    _durCtrl = TextEditingController(text: '21');
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _durCtrl.dispose();
    super.dispose();
  }

  double get _conservationCost =>
      _product != null ? _product!.perKgRate * _quantity * _duration : 0;

  bool get _canSubmit => _product != null && _warehouse != null;

  void _submit() {
    if (!_canSubmit) return;
    final start = DateTime.now();
    final end = start.add(Duration(days: _duration));
    final fmt = (DateTime d) => d.toLocal().toIso8601String().split('.').first;
    context.read<NewStorageRequestCubit>().submit(
          productId: _product!.id,
          type: 'INBOUND',
          destinationWarehouseId: _warehouse!.id,
          quantity: _quantity,
          startDate: fmt(start),
          endDate: fmt(end),
          delegatedSale: _delegatedSale,
        );
  }

  Future<void> _pickProduct(List<Product> products) async {
    final picked = await showModalBottomSheet<Product>(
      context: context,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ProductPickerSheet(products: products),
    );
    if (picked != null) setState(() => _product = picked);
  }

  Future<void> _pickWarehouse(List<Warehouse> warehouses) async {
    final picked = await showModalBottomSheet<Warehouse>(
      context: context,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _WarehousePickerSheet(warehouses: warehouses),
    );
    if (picked != null) setState(() => _warehouse = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<NewStorageRequestCubit, NewStorageRequestState>(
      listener: (context, state) {
        if (state is NewStorageSuccess) {
          context.pop();
          context.displayFlash(l10n.newStorage);
        } else if (state is NewStorageError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TeraTopBar(
                  title: l10n.newStorage,
                  leading: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.paper,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.line),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 10, 22, 280),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Product picker ────────────────────────
                        Text(
                          l10n.product,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        BlocBuilder<ProductsCubit, ProductsState>(
                          builder: (context, state) {
                            final products = state is ProductsLoaded
                                ? state.products
                                : <Product>[];
                            return _ProductPickerCard(
                              product: _product,
                              onTap: () => _pickProduct(products),
                            );
                          },
                        ),

                        // ── Warehouse picker ──────────────────────
                        const SizedBox(height: 18),
                        Text(
                          l10n.warehouse,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        BlocBuilder<WarehouseCubit, WarehouseState>(
                          builder: (context, state) {
                            final warehouses = state is WarehousesLoaded
                                ? state.warehouses
                                : <Warehouse>[];
                            return _WarehousePickerCard(
                              warehouse: _warehouse,
                              isSource: false,
                              onTap: () => _pickWarehouse(warehouses),
                            );
                          },
                        ),

                        // ── Quantity + Duration ───────────────────
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _InputField(
                                label: l10n.quantity,
                                suffix: 'kg',
                                controller: _qtyCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[\d.]')),
                                ],
                                onChanged: (v) {
                                  final parsed = double.tryParse(v);
                                  if (parsed != null) {
                                    setState(() => _quantity = parsed);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _InputField(
                                label: l10n.duration,
                                suffix: l10n.days,
                                controller: _durCtrl,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (v) {
                                  final parsed = int.tryParse(v);
                                  if (parsed != null) {
                                    setState(() => _duration = parsed);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),

                        // ── Delegated sale toggle ─────────────────
                        const SizedBox(height: 18),
                        _DelegatedSaleCard(
                          value: _delegatedSale,
                          onToggle: () =>
                              setState(() => _delegatedSale = !_delegatedSale),
                          l10n: l10n,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Bottom sticky CTA ─────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BlocBuilder<NewStorageRequestCubit,
                  NewStorageRequestState>(
                builder: (context, state) {
                  final isSubmitting = state is NewStorageSubmitting;
                  return _BottomBar(
                    onPressed: (_canSubmit && !isSubmitting) ? _submit : null,
                    isSubmitting: isSubmitting,
                    conservationCost: _conservationCost,
                    l10n: l10n,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Product picker card ────────────────────────────────────────

class _ProductPickerCard extends StatelessWidget {
  const _ProductPickerCard({required this.product, required this.onTap});
  final Product? product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            if (product != null) ...[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: product!.tint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    product!.emoji,
                    style: const TextStyle(
                      fontFamily: 'Segoe UI Emoji',
                      fontFamilyFallback: ['Apple Color Emoji', 'Noto Color Emoji'],
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
                    Text(
                      product!.name,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_fmtNum(product!.price)} FCFA/kg',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.paper2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.line),
                ),
                child: const Center(
                  child: Icon(
                    Icons.eco_outlined,
                    size: 22,
                    color: AppColors.inkMute,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sélectionner un produit',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.inkMute,
                  ),
                ),
              ),
            ],
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.inkSoft,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Warehouse picker card ──────────────────────────────────────

class _WarehousePickerCard extends StatelessWidget {
  const _WarehousePickerCard({
    required this.warehouse,
    required this.isSource,
    required this.onTap,
  });
  final Warehouse? warehouse;
  final bool isSource;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = isSource ? AppColors.skyPale : AppColors.greenPale;
    final iconColor = isSource
        ? const Color(0xFF3a5670)
        : AppColors.greenDeep;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: TeraWarehouseIcon(size: 18, color: iconColor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: warehouse != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          warehouse!.name,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (warehouse!.city.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            warehouse!.city,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: AppColors.inkSoft,
                            ),
                          ),
                        ],
                      ],
                    )
                  : Text(
                      'Sélectionner un entrepôt',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.inkMute,
                      ),
                    ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.inkSoft,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Input field ────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.suffix,
    required this.controller,
    required this.onChanged,
    this.keyboardType,
    this.inputFormatters,
  });

  final String label;
  final String suffix;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 11 * 0.08,
            color: AppColors.inkSoft,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  onChanged: onChanged,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Text(
                  suffix,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.inkSoft,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Delegated sale toggle card ─────────────────────────────────

class _DelegatedSaleCard extends StatelessWidget {
  const _DelegatedSaleCard({
    required this.value,
    required this.onToggle,
    required this.l10n,
  });
  final bool value;
  final VoidCallback onToggle;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.greenPale,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x1F324028)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0x1F324028),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 20,
                  color: AppColors.greenDeep,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.delegatedSale,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: AppColors.greenDeep,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.delegatedSaleSub,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.greenDeep.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _Toggle(value: value),
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.value});
  final bool value;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 48,
      height: 28,
      decoration: BoxDecoration(
        color: value ? AppColors.green : AppColors.line,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 180),
            top: 2,
            left: value ? null : 2,
            right: value ? 2 : null,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x28000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
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

// ─── Cost summary ───────────────────────────────────────────────

class _CostSummary extends StatelessWidget {
  const _CostSummary({required this.conservationCost, required this.l10n});
  final double conservationCost;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CostRow(
          label: l10n.conservation,
          value: conservationCost > 0
              ? _fmtFCFA(conservationCost)
              : '–',
        ),
        _CostRow(label: l10n.transportCost, value: 'Inclus'),
        const Divider(color: AppColors.line, height: 24, thickness: 1),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                l10n.estTotal,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.ink,
                ),
              ),
            ),
            Text(
              conservationCost > 0 ? _fmtFCFA(conservationCost) : '–',
              style: AppTextStyles.serifHeading(fontSize: 28),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _CostRow extends StatelessWidget {
  const _CostRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.inkSoft,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom bar ─────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.onPressed,
    required this.isSubmitting,
    required this.conservationCost,
    required this.l10n,
  });
  final VoidCallback? onPressed;
  final bool isSubmitting;
  final double conservationCost;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg.withValues(alpha: 0.95),
        border: const Border(top: BorderSide(color: AppColors.line)),
      ),
      padding: EdgeInsets.fromLTRB(
        18,
        14,
        18,
        MediaQuery.paddingOf(context).bottom + 14,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CostSummary(conservationCost: conservationCost, l10n: l10n),
          const SizedBox(height: 10),
          SizedBox(
            height: 52,
            child: GestureDetector(
              onTap: onPressed,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                decoration: BoxDecoration(
                  color: onPressed != null ? AppColors.forest : AppColors.line,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          l10n.reserveNow,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: onPressed != null
                                ? Colors.white
                                : AppColors.inkSoft,
                          ),
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

// ─── Product picker sheet ────────────────────────────────────────

class _ProductPickerSheet extends StatelessWidget {
  const _ProductPickerSheet({required this.products});
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.line,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Text(
            'Choisir un produit',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Flexible(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
            shrinkWrap: true,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final p = products[i];
              return GestureDetector(
                onTap: () => Navigator.of(context).pop(p),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: p.tint,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            p.emoji,
                            style: const TextStyle(
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${_fmtNum(p.price)} FCFA/kg',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AppColors.inkSoft,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Warehouse picker sheet ──────────────────────────────────────

class _WarehousePickerSheet extends StatelessWidget {
  const _WarehousePickerSheet({required this.warehouses});
  final List<Warehouse> warehouses;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.line,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Text(
            'Choisir un entrepôt',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Flexible(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
            shrinkWrap: true,
            itemCount: warehouses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final w = warehouses[i];
              return GestureDetector(
                onTap: () => Navigator.of(context).pop(w),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.greenPale,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: TeraWarehouseIcon(
                            size: 18,
                            color: AppColors.greenDeep,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              w.name,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            if (w.city.isNotEmpty)
                              Text(
                                w.city,
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  color: AppColors.inkSoft,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AppColors.inkSoft,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
