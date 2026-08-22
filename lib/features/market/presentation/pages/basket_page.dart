import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tera/app/router/app_router.dart';
import 'package:tera/core/utils/app_colors.dart';
import 'package:tera/core/utils/app_text_styles.dart';
import 'package:tera/features/market/presentation/blocs/basket_cubit.dart';
import 'package:tera/features/orders/presentation/blocs/order_cubit.dart';
import 'package:tera/features/payment/domain/entities/payment_reference_type.dart';
import 'package:tera/features/payment/presentation/pages/payment_page.dart';
import 'package:tera/features/profile/domain/entities/address.dart';
import 'package:tera/features/profile/presentation/blocs/address_cubit.dart';
import 'package:tera/l10n/l10n.dart';
import 'package:tera/shared/widgets/tera_top_bar.dart';

String _fmtFCFA(double n) =>
    '${NumberFormat('#,###', 'fr_FR').format(n.round())} FCFA';

const double _kDeliveryFee = 5000;

class _DeliveryAddress {
  const _DeliveryAddress({required this.name, required this.subtitle});
  final String name;
  final String subtitle;
}

class BasketPage extends StatefulWidget {
  const BasketPage({super.key});

  @override
  State<BasketPage> createState() => _BasketPageState();
}

class _BasketPageState extends State<BasketPage> {
  _DeliveryAddress _address = const _DeliveryAddress(
    name: 'Marché Mermoz, allée 4',
    subtitle: 'Dakar · livraison demain matin',
  );

  void _pickAddress() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AddressCubit>(),
        child: _AddressSheet(
          current: _address,
          onSelect: (addr) => setState(() => _address = addr),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocListener<OrderCubit, OrderState>(
      listener: (context, state) {
        if (state is OrderSuccess) {
          final order = state.order;
          context.read<BasketCubit>().clear();
          // Land on the orders list, then open the NabooPay checkout that the
          // backend auto-created for this order on top of it.
          context.go(AppRouter.ordersPath);
          appRouter.push(
            AppRouter.paymentPath,
            extra: PaymentRouteArgs(
              referenceId: order.id,
              referenceType: PaymentReferenceType.order,
              amount: order.totalAmount,
              description: 'Commande Tera',
            ),
          );
        } else if (state is OrderError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: BlocBuilder<BasketCubit, BasketState>(
          builder: (context, basket) {
            return Column(
              children: [
                TeraTopBar(
                  title: l10n.basket,
                  leading: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.paper,
                        borderRadius: BorderRadius.circular(18),
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
                  trailing: Text(
                    '${basket.count} articles',
                    style: AppTextStyles.label(fontSize: 12),
                  ),
                ),
                Expanded(
                  child: basket.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🛒', style: TextStyle(fontSize: 48)),
                              const SizedBox(height: 12),
                              Text(
                                l10n.emptyBasket,
                                style: AppTextStyles.body(
                                  color: AppColors.inkSoft,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                          itemCount: basket.items.length,
                          itemBuilder: (ctx, i) {
                            final item = basket.items[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Dismissible(
                                key: ValueKey(item.product.id),
                                direction: DismissDirection.endToStart,
                                onDismissed: (_) => context
                                    .read<BasketCubit>()
                                    .remove(item.product.id),
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: AppColors.terra,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                child: _BasketItemCard(item: item),
                              ),
                            );
                          },
                        ),
                ),
                if (!basket.isEmpty)
                  _BottomSection(
                    basket: basket,
                    address: _address,
                    onAddressTap: _pickAddress,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BottomSection extends StatelessWidget {
  const _BottomSection({
    required this.basket,
    required this.address,
    required this.onAddressTap,
  });

  final BasketState basket;
  final _DeliveryAddress address;
  final VoidCallback onAddressTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final total = basket.subtotal + _kDeliveryFee;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Delivery address
          GestureDetector(
            onTap: onAddressTap,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.paper,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.greenPale,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.local_shipping_outlined,
                        color: AppColors.greenDeep,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address.name,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          address.subtitle,
                          style: AppTextStyles.label(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.inkSoft,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _TotalRow(label: l10n.subtotal, value: _fmtFCFA(basket.subtotal)),
          const SizedBox(height: 4),
          _TotalRow(label: l10n.delivery, value: _fmtFCFA(_kDeliveryFee)),
          const SizedBox(height: 6),
          const Divider(color: AppColors.line),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                l10n.total,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                _fmtFCFA(total),
                style: AppTextStyles.serifHeading(fontSize: 26),
              ),
            ],
          ),
          const SizedBox(height: 14),
          BlocBuilder<OrderCubit, OrderState>(
            builder: (context, orderState) {
              final loading = orderState is OrderLoading;
              return FilledButton(
                onPressed: loading
                    ? null
                    : () => context.read<OrderCubit>().placeOrder(
                        basket.items,
                        destinationAddress: address.name,
                      ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forest,
                  minimumSize: const Size(double.infinity, 54),
                  textStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                child: loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : Text(l10n.placeOrder),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AddressSheet extends StatefulWidget {
  const _AddressSheet({required this.current, required this.onSelect});

  final _DeliveryAddress current;
  final void Function(_DeliveryAddress) onSelect;

  @override
  State<_AddressSheet> createState() => _AddressSheetState();
}

class _AddressSheetState extends State<_AddressSheet> {
  final _ctrl = TextEditingController();
  Address? _selected;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _canConfirm => _selected != null || _ctrl.text.trim().isNotEmpty;

  void _confirm() {
    if (!_canConfirm) return;
    if (_selected != null) {
      widget.onSelect(
        _DeliveryAddress(
          name: '${_selected!.street}, ${_selected!.city}',
          subtitle: _selected!.label,
        ),
      );
    } else {
      widget.onSelect(
        _DeliveryAddress(
          name: _ctrl.text.trim(),
          subtitle: 'Adresse personnalisée',
        ),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<AddressCubit>().state is AddressLoaded
        ? (context.watch<AddressCubit>().state as AddressLoaded).addresses
        : <Address>[];
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'ADRESSE DE LIVRAISON',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 11 * 0.08,
              color: AppColors.inkSoft,
            ),
          ),
          // ── Saved addresses ──────────────────────────────────
          if (saved.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...saved.map((addr) {
              final isSelected = _selected?.id == addr.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => setState(() {
                    _selected = isSelected ? null : addr;
                    if (!isSelected) _ctrl.clear();
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.greenPale : AppColors.paper,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.green : AppColors.line,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.greenDeep
                                : AppColors.paper2,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: isSelected
                                ? Colors.white
                                : AppColors.inkSoft,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                addr.label,
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              Text(
                                '${addr.street}, ${addr.city}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.inkSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: AppColors.greenDeep,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            // ── Divider ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.line)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'ou saisissez une adresse',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: AppColors.inkMute,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.line)),
                ],
              ),
            ),
          ] else
            const SizedBox(height: 14),
          // ── Custom text field ─────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: AppColors.paper,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _selected == null && _ctrl.text.isNotEmpty
                    ? AppColors.green
                    : AppColors.line,
              ),
            ),
            child: TextField(
              controller: _ctrl,
              textCapitalization: TextCapitalization.sentences,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.ink),
              onChanged: (_) => setState(() => _selected = null),
              decoration: InputDecoration(
                hintText: 'Ex: Marché Mermoz, allée 4, Dakar',
                hintStyle: AppTextStyles.label(fontSize: 13),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
                prefixIcon: const Icon(
                  Icons.edit_location_alt_outlined,
                  size: 18,
                  color: AppColors.inkSoft,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _canConfirm ? _confirm : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: 52,
              decoration: BoxDecoration(
                color: _canConfirm ? AppColors.forest : AppColors.line,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  'Confirmer',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _canConfirm ? Colors.white : AppColors.inkSoft,
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

class _BasketItemCard extends StatelessWidget {
  const _BasketItemCard({required this.item});
  final BasketItem item;

  @override
  Widget build(BuildContext context) {
    final p = item.product;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.paper2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: p.tint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                p.emoji,
                style: const TextStyle(
                  fontFamily: 'Segoe UI Emoji',
                  fontFamilyFallback: ['Apple Color Emoji', 'Noto Color Emoji'],
                  fontSize: 28,
                ),
              ),
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
                      child: Text(
                        p.name,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.read<BasketCubit>().remove(p.id),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  // ignore: lines_longer_than_80_chars
                  '${NumberFormat('#,###', 'fr_FR').format(p.price.round())} FCFA · le ${p.unit}',
                  style: AppTextStyles.label(fontSize: 12),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _SmallQtyBtn(
                      icon: Icons.remove_rounded,
                      dark: false,
                      onTap: () => context.read<BasketCubit>().updateQuantity(
                        p.id,
                        item.quantity - 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${item.quantity.round()} ${p.unit}',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _SmallQtyBtn(
                      icon: Icons.add_rounded,
                      dark: true,
                      onTap: () => context.read<BasketCubit>().updateQuantity(
                        p.id,
                        item.quantity + 1,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _fmtFCFA(item.lineTotal),
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
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

class _SmallQtyBtn extends StatelessWidget {
  const _SmallQtyBtn({
    required this.icon,
    required this.dark,
    required this.onTap,
  });
  final IconData icon;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: dark ? AppColors.forest : AppColors.paper,
        borderRadius: BorderRadius.circular(8),
        border: dark ? null : Border.all(color: AppColors.line),
      ),
      child: Center(
        child: Icon(icon, size: 14, color: dark ? Colors.white : AppColors.ink),
      ),
    ),
  );
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: AppTextStyles.label(fontSize: 13)),
      Text(
        value,
        style: AppTextStyles.tabularNum(fontSize: 13, color: AppColors.inkSoft),
      ),
    ],
  );
}
