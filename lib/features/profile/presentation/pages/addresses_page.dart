import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tera/core/utils/app_colors.dart';
import 'package:tera/features/profile/domain/entities/address.dart';
import 'package:tera/features/profile/presentation/blocs/address_cubit.dart';
import 'package:tera/shared/widgets/tera_top_bar.dart';

class AddressesPage extends StatelessWidget {
  const AddressesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BlocBuilder<AddressCubit, AddressState>(
        builder: (context, state) {
          final addresses =
              state is AddressLoaded ? state.addresses : <Address>[];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TeraTopBar(
                title: 'Mes adresses',
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
                child: addresses.isEmpty
                    ? const _EmptyState()
                    : ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(20, 16, 20, 120),
                        itemCount: addresses.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final address = addresses[i];
                          return Dismissible(
                            key: ValueKey(address.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => context
                                .read<AddressCubit>()
                                .removeAddress(address.id),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: AppColors.bad,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            child: _AddressCard(
                              address: address,
                              onDelete: () => context
                                  .read<AddressCubit>()
                                  .removeAddress(address.id),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 4, 4),
        child: GestureDetector(
          onTap: () => _showAddSheet(context),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              color: AppColors.forest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.forest.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Ajouter une adresse',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AddressCubit>(),
        child: const _AddAddressSheet(),
      ),
    );
  }
}

// ─── Empty state ───────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.paper,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.line),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              size: 28,
              color: AppColors.inkMute,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Aucune adresse enregistrée.',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.inkSoft,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ajoutez vos adresses de livraison.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.inkMute,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Address card ──────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address, required this.onDelete});
  final Address address;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                Icons.location_on_outlined,
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
                  address.label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  address.street,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: AppColors.inkSoft,
                  ),
                ),
                Text(
                  address.city,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.inkMute,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFF5DAD6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                size: 16,
                color: AppColors.bad,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Add address bottom sheet ──────────────────────────────────

class _AddAddressSheet extends StatefulWidget {
  const _AddAddressSheet();

  @override
  State<_AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends State<_AddAddressSheet> {
  final _labelCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _labelCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _labelCtrl.text.trim().isNotEmpty &&
      _streetCtrl.text.trim().isNotEmpty &&
      _cityCtrl.text.trim().isNotEmpty;

  Future<void> _save() async {
    if (!_canSave || _saving) return;
    setState(() => _saving = true);
    await context.read<AddressCubit>().addAddress(
          label: _labelCtrl.text.trim(),
          street: _streetCtrl.text.trim(),
          city: _cityCtrl.text.trim(),
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'NOUVELLE ADRESSE',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 11 * 0.08,
              color: AppColors.inkSoft,
            ),
          ),
          const SizedBox(height: 16),
          _SheetField(
            label: 'NOM',
            controller: _labelCtrl,
            hint: 'ex : Maison, Ferme, Bureau…',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          _SheetField(
            label: 'RUE / LIEU-DIT',
            controller: _streetCtrl,
            hint: 'ex : Rue 12, Médina',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          _SheetField(
            label: 'VILLE',
            controller: _cityCtrl,
            hint: 'ex : Dakar',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _canSave ? _save : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: 52,
              decoration: BoxDecoration(
                color: _canSave ? AppColors.forest : AppColors.line,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Enregistrer',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _canSave ? Colors.white : AppColors.inkSoft,
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

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.ink,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.inkMute,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
