import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tera/app/router/app_router.dart';
import 'package:tera/core/utils/app_colors.dart';
import 'package:tera/core/utils/app_text_styles.dart';
import 'package:tera/features/auth/presentation/blocs/auth_cubit.dart';
import 'package:tera/features/profile/domain/entities/user_profile.dart';
import 'package:tera/features/profile/presentation/blocs/profile_cubit.dart';
import 'package:tera/l10n/l10n.dart';
import 'package:tera/shared/locale/locale_cubit.dart';
import 'package:tera/shared/widgets/tera_icons.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final profile = state is ProfileLoaded ? state.profile : null;
          final phone = state is ProfileLoaded ? state.phone : null;
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // ── Header ────────────────────────────────────────
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Text('VOTRE COMPTE', style: AppTextStyles.eyebrow()),
                ),
              ),

              // ── Dark profile card ──────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: _ProfileCard(profile: profile, phone: phone, l10n: l10n),
              ),

              // ── Profile section ────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
                child: Text(
                  l10n.profileSection,
                  style: AppTextStyles.eyebrow(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _SettingsGroup(
                  rows: [
                    _SettingsRow(
                      icon: const TeraUserIcon(size: 18, color: AppColors.ink2),
                      label: l10n.editProfile,
                      hint: profile != null
                          ? '${profile.firstName} ${profile.lastName}'
                          : '—',
                      onTap: () => context.push(AppRouter.editProfilePath),
                    ),
                    _SettingsRow(
                      icon: const TeraBagIcon(size: 18, color: AppColors.ink2),
                      label: l10n.addresses,
                      hint: '',
                      onTap: () => context.push(AppRouter.addressesPath),
                    ),
                    _SettingsRow(
                      icon: const Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 18,
                        color: AppColors.ink2,
                      ),
                      label: 'Portefeuille',
                      hint: '',
                      onTap: () => context.push(AppRouter.walletPath),
                    ),
                    _SettingsRow(
                      icon: const Icon(
                        Icons.auto_awesome_outlined,
                        size: 18,
                        color: AppColors.ink2,
                      ),
                      label: l10n.delegatedSalesMenu,
                      hint: '',
                    ),
                  ],
                ),
              ),

              // ── Preferences section ────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
                child: Text(
                  l10n.preferencesSection,
                  style: AppTextStyles.eyebrow(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _SettingsGroup(
                  rows: [
                    _SettingsRow(
                      icon: const TeraGlobeIcon(
                        size: 18,
                        color: AppColors.ink2,
                      ),
                      label: l10n.language,
                      trailing: _LanguageToggle(),
                    ),
                    _SettingsRow(
                      icon: const TeraLockIcon(size: 18, color: AppColors.ink2),
                      label: l10n.changePassword,
                      hint: '',
                      onTap: () => context.push(AppRouter.changePasswordPath),
                    ),
                    _SettingsRow(
                      icon: const TeraBellIcon(size: 16, color: AppColors.ink2),
                      label: l10n.notifications,
                      onTap: () => context.push(AppRouter.notificationsPath),
                    ),
                  ],
                ),
              ),

              // ── Logout ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 48),
                child: OutlinedButton(
                  onPressed: () async {
                    await context.read<AuthCubit>().logout();
                    if (context.mounted) context.go(AppRouter.loginPath);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.bad,
                    side: const BorderSide(color: Color(0xFFf0d3cd)),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  child: Text(l10n.logout),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Dark profile card ─────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile, required this.l10n, this.phone});
  final UserProfile? profile;
  final String? phone;
  final dynamic l10n;

  String get _initials {
    if (profile == null) return '··';
    final f = profile!.firstName.isNotEmpty ? profile!.firstName[0] : '';
    final l = profile!.lastName.isNotEmpty ? profile!.lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Serif backdrop watermark
          Positioned(
            right: -10,
            top: -22,
            child: Text(
              'Tera',
              style: AppTextStyles.serifItalic(
                fontSize: 110,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar + name row
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.goldPale,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.12),
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _initials,
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forest,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (profile != null) ...[
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${profile!.firstName} ',
                                  style: AppTextStyles.serifHeading(
                                    fontSize: 26,
                                    color: Colors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: profile!.lastName,
                                  style: AppTextStyles.serifItalic(
                                    fontSize: 26,
                                    color: const Color(0xFFcfe0b9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (profile!.bio != null && profile!.bio!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                profile!.bio!,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (phone != null && phone!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                phone!,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                        ] else
                          Container(
                            width: 120,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _Pill(
                              label: 'Producteur',
                              bg: Colors.white.withValues(alpha: 0.12),
                              fg: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            const _Pill(
                              label: 'Vérifié',
                              bg: AppColors.green,
                              fg: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Mini stats row
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const _StatCell(value: '—', label: 'Commandes'),
                    const _StatCell(value: '—', label: 'Entrepôts'),
                    _StatCell(
                      value: profile != null
                          ? NumberFormat(
                              '#,###',
                              'fr_FR',
                            ).format(profile!.totalRevenue.round())
                          : '—',
                      label: 'FCFA solde',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.bg, required this.fg});
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Container(
    height: 22,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Center(
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    ),
  );
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: AppTextStyles.serifHeading(fontSize: 22, color: Colors.white),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.5,
            color: Colors.white.withValues(alpha: 0.55),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

// ─── Settings group ────────────────────────────────────────────

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.rows});
  final List<_SettingsRow> rows;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.paper,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.line),
    ),
    child: Column(
      children: rows.asMap().entries.map((e) {
        final isLast = e.key == rows.length - 1;
        return Column(
          children: [
            e.value,
            if (!isLast)
              const Divider(height: 1, color: AppColors.lineSoft, indent: 60),
          ],
        );
      }).toList(),
    ),
  );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    this.hint,
    this.trailing,
    this.onTap,
  });
  final Widget icon;
  final String label;
  final String? hint;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.paper2,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(child: icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (hint != null && hint!.isNotEmpty)
                  Text(hint!, style: AppTextStyles.label(fontSize: 11.5)),
              ],
            ),
          ),
          trailing ??
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: AppColors.inkMute,
              ),
        ],
      ),
    ),
  );
}

// ─── Language toggle ───────────────────────────────────────────

class _LanguageToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        final currentLang = locale.languageCode;
        return Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.paper2,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: ['fr', 'en'].map((l) {
              final active = currentLang == l;
              return GestureDetector(
                onTap: () => context.read<LocaleCubit>().setLocale(l),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: active ? AppColors.forest : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : AppColors.inkSoft,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
