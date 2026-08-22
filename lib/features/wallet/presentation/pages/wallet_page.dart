import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tera/core/utils/app_colors.dart';
import 'package:tera/core/utils/app_text_styles.dart';
import 'package:tera/features/profile/presentation/blocs/profile_cubit.dart';
import 'package:tera/features/wallet/domain/entities/balance_source.dart';
import 'package:tera/features/wallet/domain/entities/payout.dart';
import 'package:tera/features/wallet/domain/entities/payout_method.dart';
import 'package:tera/features/wallet/domain/entities/payout_status.dart';
import 'package:tera/features/wallet/domain/entities/wallet_balance.dart';
import 'package:tera/features/wallet/presentation/blocs/wallet_cubit.dart';

String _fmtFCFA(double n) =>
    '${NumberFormat('#,###', 'fr_FR').format(n.round())} FCFA';

String _fmtDate(DateTime dt) => DateFormat('d MMM yyyy', 'fr_FR').format(dt);

({Color bg, Color fg}) _statusColors(PayoutStatus status) => switch (status) {
  PayoutStatus.completed => (
    bg: AppColors.pillApprovedBg,
    fg: AppColors.pillApprovedFg,
  ),
  PayoutStatus.pending => (
    bg: AppColors.pillPendingBg,
    fg: AppColors.pillPendingFg,
  ),
  PayoutStatus.failed => (
    bg: AppColors.pillRejectedBg,
    fg: AppColors.pillRejectedFg,
  ),
};

String _statusLabel(PayoutStatus status) => switch (status) {
  PayoutStatus.completed => 'Effectué',
  PayoutStatus.pending => 'En cours',
  PayoutStatus.failed => 'Échoué',
};

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  void initState() {
    super.initState();
    context.read<WalletCubit>().loadWallet();
  }

  void _openWithdrawSheet(WalletBalance balance) {
    final profileState = context.read<ProfileCubit>().state;
    final profile = profileState is ProfileLoaded ? profileState.profile : null;
    final phone = profileState is ProfileLoaded ? profileState.phone : null;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<WalletCubit>(),
        child: _WithdrawSheet(
          balance: balance,
          defaultFirstName: profile?.firstName ?? '',
          defaultLastName: profile?.lastName ?? '',
          defaultPhone: phone ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _TopBar(title: 'Portefeuille'),
          Expanded(
            child: BlocBuilder<WalletCubit, WalletState>(
              builder: (context, state) => switch (state) {
                WalletInitial() || WalletLoading() => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.green,
                    strokeWidth: 2.5,
                  ),
                ),
                WalletError(:final message) => _ErrorView(
                  message: message,
                  onRetry: () => context.read<WalletCubit>().loadWallet(),
                ),
                WalletLoaded(:final balance, :final payouts) => _WalletBody(
                  balance: balance,
                  payouts: payouts,
                  onRefresh: () async =>
                      context.read<WalletCubit>().loadWallet(),
                  onWithdraw: () => _openWithdrawSheet(balance),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Top bar ───────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});
  final String title;

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
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.4,
                  color: AppColors.ink,
                ),
              ),
            ),
            const SizedBox(width: 36),
          ],
        ),
      ),
    );
  }
}

// ─── Body ──────────────────────────────────────────────────────

class _WalletBody extends StatelessWidget {
  const _WalletBody({
    required this.balance,
    required this.payouts,
    required this.onRefresh,
    required this.onWithdraw,
  });

  final WalletBalance balance;
  final List<Payout> payouts;
  final Future<void> Function() onRefresh;
  final VoidCallback onWithdraw;

  String get _sourceLabel => switch (balance.source) {
    BalanceSource.sellerEarnings => 'Vos revenus de ventes',
    BalanceSource.platformProfit => 'Profit de la plateforme',
    BalanceSource.unavailable => 'Indisponible',
  };

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.forest,
      backgroundColor: AppColors.paper,
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          // ── Balance hero card ────────────────────────────────
          Container(
            padding: const EdgeInsets.all(22),
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
                const Positioned(
                  right: -18,
                  bottom: -28,
                  child: Opacity(
                    opacity: 0.12,
                    child: Text(
                      '💰',
                      style: TextStyle(
                        fontFamily: 'Segoe UI Emoji',
                        fontFamilyFallback: [
                          'Apple Color Emoji',
                          'Noto Color Emoji',
                        ],
                        fontSize: 150,
                        height: 1,
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SOLDE DISPONIBLE',
                      style: AppTextStyles.eyebrow(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _fmtFCFA(balance.available),
                      style: AppTextStyles.serifHeading(color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _sourceLabel,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ── Withdraw CTA / unavailable note ──────────────────
          if (balance.source == BalanceSource.unavailable)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.paper,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: AppColors.inkSoft,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Aucun retrait disponible pour votre compte.',
                      style: AppTextStyles.label(fontSize: 13),
                    ),
                  ),
                ],
              ),
            )
          else
            GestureDetector(
              onTap: balance.canWithdraw ? onWithdraw : null,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: balance.canWithdraw ? AppColors.green : AppColors.line,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 18,
                      color: balance.canWithdraw
                          ? Colors.white
                          : AppColors.inkSoft,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Retirer mes fonds',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: balance.canWithdraw
                            ? Colors.white
                            : AppColors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 28),

          // ── History ──────────────────────────────────────────
          Text('HISTORIQUE DES RETRAITS', style: AppTextStyles.eyebrow()),
          const SizedBox(height: 12),
          if (payouts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  'Aucun retrait pour le moment.',
                  style: AppTextStyles.label(fontSize: 13),
                ),
              ),
            )
          else
            ...payouts.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PayoutCard(payout: p),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Payout card ───────────────────────────────────────────────

class _PayoutCard extends StatelessWidget {
  const _PayoutCard({required this.payout});
  final Payout payout;

  @override
  Widget build(BuildContext context) {
    final colors = _statusColors(payout.status);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: AppColors.greenPale,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.north_east_rounded,
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _fmtFCFA(payout.amount),
                        style: AppTextStyles.tabularNum(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _StatusPill(
                      label: _statusLabel(payout.status),
                      colors: colors,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${payout.method.label} · ${payout.recipientPhone}',
                  style: AppTextStyles.label(fontSize: 11.5),
                ),
                const SizedBox(height: 2),
                Text(
                  _fmtDate(payout.createdAt),
                  style: AppTextStyles.label(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.colors});
  final String label;
  final ({Color bg, Color fg}) colors;

  @override
  Widget build(BuildContext context) => Container(
    height: 24,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: colors.bg,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Center(
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: colors.fg,
        ),
      ),
    ),
  );
}

// ─── Withdraw sheet ────────────────────────────────────────────

class _WithdrawSheet extends StatefulWidget {
  const _WithdrawSheet({
    required this.balance,
    required this.defaultFirstName,
    required this.defaultLastName,
    required this.defaultPhone,
  });

  final WalletBalance balance;
  final String defaultFirstName;
  final String defaultLastName;
  final String defaultPhone;

  @override
  State<_WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends State<_WithdrawSheet> {
  late final TextEditingController _amountCtrl;
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _phoneCtrl;

  PayoutMethod _method = PayoutMethod.wave;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController();
    _firstNameCtrl = TextEditingController(text: widget.defaultFirstName);
    _lastNameCtrl = TextEditingController(text: widget.defaultLastName);
    _phoneCtrl = TextEditingController(text: widget.defaultPhone);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  String? _validate() {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      return 'Saisissez un montant valide.';
    }
    if (amount < WalletBalance.minWithdrawal) {
      return 'Le montant minimum est de '
          '${_fmtFCFA(WalletBalance.minWithdrawal)}.';
    }
    if (amount > widget.balance.available) {
      return 'Le montant dépasse votre solde disponible.';
    }
    if (_firstNameCtrl.text.trim().isEmpty ||
        _lastNameCtrl.text.trim().isEmpty) {
      return 'Renseignez le nom du bénéficiaire.';
    }
    if (_phoneCtrl.text.trim().isEmpty) {
      return 'Renseignez le numéro du bénéficiaire.';
    }
    return null;
  }

  Future<void> _submit() async {
    final validationError = _validate();
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final result = await context.read<WalletCubit>().withdraw(
      amount: double.parse(_amountCtrl.text.trim()),
      method: _method,
      recipientFirstName: _firstNameCtrl.text.trim(),
      recipientLastName: _lastNameCtrl.text.trim(),
      recipientPhone: _phoneCtrl.text.trim(),
    );

    if (!mounted) return;
    if (result == null) {
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Demande de retrait envoyée.')),
      );
    } else {
      setState(() {
        _submitting = false;
        _error = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 18, 20, 20 + bottom),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          Text('RETIRER MES FONDS', style: AppTextStyles.eyebrow()),
          const SizedBox(height: 4),
          Text(
            'Disponible : ${_fmtFCFA(widget.balance.available)}',
            style: AppTextStyles.label(),
          ),
          const SizedBox(height: 16),

          // ── Amount ─────────────────────────────────────────
          const _FieldLabel('Montant (FCFA)'),
          const SizedBox(height: 6),
          _SheetField(
            controller: _amountCtrl,
            hint: 'Ex: 10 000',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 14),

          // ── Method ─────────────────────────────────────────
          const _FieldLabel('Méthode'),
          const SizedBox(height: 6),
          Row(
            children: PayoutMethod.values.map((m) {
              final selected = _method == m;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: m == PayoutMethod.values.first ? 8 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => setState(() => _method = m),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.greenPale : AppColors.paper,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? AppColors.green : AppColors.line,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          m.label,
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? AppColors.greenDeep
                                : AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // ── Recipient ──────────────────────────────────────
          const _FieldLabel('Bénéficiaire'),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _SheetField(controller: _firstNameCtrl, hint: 'Prénom'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SheetField(controller: _lastNameCtrl, hint: 'Nom'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _SheetField(
            controller: _phoneCtrl,
            hint: '+221 77 000 00 00',
            keyboardType: TextInputType.phone,
          ),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: AppTextStyles.label(color: AppColors.bad)),
          ],

          const SizedBox(height: 18),
          GestureDetector(
            onTap: _submitting ? null : _submit,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: _submitting ? AppColors.line : AppColors.forest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Confirmer le retrait',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: GoogleFonts.inter(
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
  );
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: GoogleFonts.inter(fontSize: 14, color: AppColors.ink),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.label(fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
        ),
      ),
    );
  }
}

// ─── Error view ────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
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
            style: FilledButton.styleFrom(backgroundColor: AppColors.forest),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    ),
  );
}
