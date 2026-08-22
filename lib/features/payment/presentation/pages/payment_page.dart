import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tera/core/utils/app_colors.dart';
import 'package:tera/core/utils/app_text_styles.dart';
import 'package:tera/features/payment/domain/entities/payment.dart';
import 'package:tera/features/payment/domain/entities/payment_reference_type.dart';
import 'package:tera/features/payment/presentation/blocs/payment_cubit.dart';

String _fmtFCFA(double n) =>
    '${NumberFormat('#,###', 'fr_FR').format(n.round())} FCFA';

class PaymentRouteArgs {
  const PaymentRouteArgs({
    required this.referenceId,
    required this.referenceType,
    required this.amount,
    required this.description,
  });

  final String referenceId;
  final PaymentReferenceType referenceType;
  final double amount;
  final String description;
}

class PaymentPage extends StatefulWidget {
  const PaymentPage({required this.args, super.key});
  final PaymentRouteArgs args;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  void _fetch() {
    final a = widget.args;
    context.read<PaymentCubit>().fetchCheckout(
      referenceId: a.referenceId,
      referenceType: a.referenceType,
      amount: a.amount,
      description: a.description,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BlocBuilder<PaymentCubit, PaymentState>(
        builder: (context, state) => switch (state) {
          PaymentInitial() || PaymentLoading() => const _LoadingView(),
          PaymentCheckout(:final payment) => _CheckoutView(payment: payment),
          PaymentPolling(:final payment) => _PollingView(payment: payment),
          PaymentSuccess(:final payment) => _SuccessView(payment: payment),
          PaymentFailed(:final payment) => _FailedView(
            payment: payment,
            onRetry: _fetch,
          ),
          PaymentError(:final message) => _ErrorView(
            message: message,
            onRetry: _fetch,
          ),
        },
      ),
    );
  }
}

// ─── Top bar ───────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, this.showBack = true});
  final String title;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Row(
          children: [
            if (showBack)
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
              )
            else
              const SizedBox(width: 36),
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

// ─── Primary button ────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.color = AppColors.green,
    this.textColor = Colors.white,
  });
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: textColor),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Loading view ──────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _TopBar(title: 'Paiement'),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: AppColors.green,
                strokeWidth: 2.5,
              ),
              const SizedBox(height: 18),
              Text(
                'Préparation du paiement…',
                style: AppTextStyles.label(fontSize: 13.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Checkout view ─────────────────────────────────────────────

class _CheckoutView extends StatelessWidget {
  const _CheckoutView({required this.payment});
  final Payment payment;

  String get _refLabel => switch (payment.referenceType) {
    PaymentReferenceType.order => 'Commande',
    PaymentReferenceType.storageRequest => 'Réservation',
  };

  @override
  Widget build(BuildContext context) {
    final ref = payment.referenceId;
    final shortRef =
        '#${ref.substring(0, ref.length.clamp(0, 8)).toUpperCase()}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _TopBar(title: 'Paiement'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            children: [
              // ── Hero card ──────────────────────────────────────
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
                    // Watermark
                    const Positioned(
                      right: -18,
                      bottom: -28,
                      child: Opacity(
                        opacity: 0.14,
                        child: Text(
                          '💳',
                          style: TextStyle(
                            fontFamily: 'Segoe UI Emoji',
                            fontFamilyFallback: [
                              'Apple Color Emoji',
                              'Noto Color Emoji',
                            ],
                            fontSize: 160,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MONTANT À PAYER',
                          style: AppTextStyles.eyebrow(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _fmtFCFA(payment.amount),
                          style: AppTextStyles.serifHeading(
                            fontSize: 38,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: AppColors.greenPale,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.receipt_long_rounded,
                                  size: 16,
                                  color: AppColors.greenDeep,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _refLabel,
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                                Text(
                                  shortRef,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Instructions ───────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.line),
                ),
                child: const Column(
                  children: [
                    _InstructionRow(
                      number: '1',
                      text: 'Appuyez sur « Payer avec NabooPay ».',
                    ),
                    SizedBox(height: 10),
                    _InstructionRow(
                      number: '2',
                      text:
                          'Payez avec Wave ou Orange Money sur la page '
                          'sécurisée NabooPay.',
                    ),
                    SizedBox(height: 10),
                    _InstructionRow(
                      number: '3',
                      text:
                          'Revenez ici — le statut se met à jour '
                          'automatiquement.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── CTA ────────────────────────────────────────────
              _PrimaryButton(
                label: 'Payer avec NabooPay',
                icon: Icons.open_in_new_rounded,
                onTap: () =>
                    context.read<PaymentCubit>().openCheckoutUrl(payment),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }
}

class _InstructionRow extends StatelessWidget {
  const _InstructionRow({required this.number, required this.text});
  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppColors.greenPale,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.greenDeep,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: AppTextStyles.label(fontSize: 13))),
      ],
    );
  }
}

// ─── Polling view ──────────────────────────────────────────────

class _PollingView extends StatelessWidget {
  const _PollingView({required this.payment});
  final Payment payment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _TopBar(title: 'Paiement'),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  color: AppColors.green,
                  strokeWidth: 2.5,
                ),
                const SizedBox(height: 20),
                Text(
                  'Vérification en cours…',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Nous confirmons votre paiement de '
                  '${_fmtFCFA(payment.amount)}.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label(fontSize: 13),
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () =>
                      context.read<PaymentCubit>().checkStatus(payment.id),
                  child: Text(
                    'Actualiser maintenant',
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.greenDeep,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (payment.hasCheckoutUrl)
                  GestureDetector(
                    onTap: () =>
                        context.read<PaymentCubit>().openCheckoutUrl(payment),
                    child: Text(
                      'Rouvrir la page de paiement',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Success view ──────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.payment});
  final Payment payment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _TopBar(title: 'Paiement', showBack: false),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.greenPale,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 40,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Paiement confirmé',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _fmtFCFA(payment.amount),
                  style: AppTextStyles.serifHeading(
                    fontSize: 32,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Votre paiement a bien été reçu.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label(fontSize: 13.5),
                ),
                const SizedBox(height: 36),
                _PrimaryButton(
                  label: 'Retour',
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Failed view ───────────────────────────────────────────────

class _FailedView extends StatelessWidget {
  const _FailedView({required this.payment, required this.onRetry});
  final Payment payment;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _TopBar(title: 'Paiement'),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.bad.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cancel_rounded,
                    size: 40,
                    color: AppColors.bad,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Paiement non abouti',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Le paiement de ${_fmtFCFA(payment.amount)} '
                  "n'a pas abouti.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label(fontSize: 13.5),
                ),
                const SizedBox(height: 36),
                _PrimaryButton(
                  label: 'Réessayer',
                  onTap: onRetry,
                  icon: Icons.refresh_rounded,
                ),
                const SizedBox(height: 12),
                _PrimaryButton(
                  label: 'Retour',
                  onTap: () => Navigator.of(context).pop(),
                  color: AppColors.paper,
                  textColor: AppColors.ink,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Error view ────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _TopBar(title: 'Paiement'),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  size: 48,
                  color: AppColors.inkMute,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label(fontSize: 13.5),
                ),
                const SizedBox(height: 28),
                _PrimaryButton(
                  label: 'Réessayer',
                  onTap: onRetry,
                  icon: Icons.refresh_rounded,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
