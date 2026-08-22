import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tera/app/router/app_router.dart';
import 'package:tera/core/utils/app_colors.dart';
import 'package:tera/core/utils/app_text_styles.dart';
import 'package:tera/features/auth/presentation/blocs/auth_cubit.dart';
import 'package:tera/features/profile/presentation/blocs/profile_cubit.dart';
import 'package:tera/l10n/l10n.dart';
import 'package:tera/shared/widgets/tera_top_bar.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _obscure = true;
  bool _tosAccepted = true;

  int get _strength {
    final p = _pwdCtrl.text;
    if (p.isEmpty) return 0;
    if (p.length < 6) return 1;
    if (p.length < 8) return 2;
    final hasLetter = p.contains(RegExp(r'[a-zA-Z]'));
    final hasDigit = p.contains(RegExp(r'[0-9]'));
    if (hasLetter && hasDigit && p.length >= 10) return 4;
    if (hasLetter && hasDigit) return 3;
    return 2;
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _phoneCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_tosAccepted) return;
    context.read<AuthCubit>().register(
          firstName: _firstCtrl.text,
          lastName: _lastCtrl.text,
          phoneNumber: '221${_phoneCtrl.text.replaceAll(' ', '')}',
          password: _pwdCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocListener<AuthCubit, AuthState>(
      listener: (ctx, state) {
        if (state is AuthAuthenticated) {
          if (state.mustChangePassword) {
            ctx.go(AppRouter.changePasswordPath);
          } else {
            ctx.read<ProfileCubit>().loadProfile();
            ctx.go(AppRouter.marketPath);
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Column(
          children: [
            TeraTopBar(
              title: l10n.signup,
              leading: IconButton(
                onPressed: () => context.go(AppRouter.loginPath),
                icon: const Icon(Icons.chevron_left, size: 26),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.paper,
                  side: const BorderSide(color: AppColors.line),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Le marché juste du ',
                            style: AppTextStyles.serifHeading(fontSize: 38),
                          ),
                          TextSpan(
                            text: 'Sénégal.',
                            style: AppTextStyles.serifItalic(
                                fontSize: 38,
                                color: AppColors.greenDeep),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Quelques informations et vous voilà sur le marché.',
                      style: AppTextStyles.body(
                          color: AppColors.inkSoft, fontSize: 14),
                    ),
                    const SizedBox(height: 22),
                    // First + last name row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.firstName,
                                  style: AppTextStyles.label()),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _firstCtrl,
                                textCapitalization:
                                    TextCapitalization.words,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.lastName,
                                  style: AppTextStyles.label()),
                              const SizedBox(height: 6),
                              TextField(controller: _lastCtrl),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Phone
                    Text(l10n.phone, style: AppTextStyles.label()),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 90,
                          height: 52,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.terra, width: 1.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🇸🇳',
                                  style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 4),
                              Text('+221',
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Password
                    Text(l10n.password, style: AppTextStyles.label()),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _pwdCtrl,
                      obscureText: _obscure,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.inkMute,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Strength bar
                    Row(
                      children: List.generate(4, (i) {
                        final filled = i < _strength;
                        return Expanded(
                          child: Container(
                            height: 4,
                            margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                            decoration: BoxDecoration(
                              color: filled
                                  ? AppColors.green
                                  : AppColors.line,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                    if (_strength >= 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Solide — 8 caractères minimum ✓',
                          style: AppTextStyles.label(
                              fontSize: 11.5,
                              color: AppColors.greenDeep),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // ToS
                    GestureDetector(
                      onTap: () =>
                          setState(() => _tosAccepted = !_tosAccepted),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: _tosAccepted
                                  ? AppColors.green
                                  : Colors.transparent,
                              border: Border.all(
                                color: _tosAccepted
                                    ? AppColors.green
                                    : AppColors.terra,
                                width: 1.4,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: _tosAccepted
                                ? const Icon(Icons.check,
                                    size: 12, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        'En créant un compte vous acceptez nos ',
                                    style: AppTextStyles.label(
                                        fontSize: 12.5),
                                  ),
                                  TextSpan(
                                    text: "conditions d'utilisation.",
                                    style: AppTextStyles.label(
                                      fontSize: 12.5,
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
                    ),
                    const SizedBox(height: 20),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (ctx, state) {
                        return SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: FilledButton(
                            onPressed: (state is AuthLoading || !_tosAccepted)
                                ? null
                                : _submit,
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(16)),
                            ),
                            child: state is AuthLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2),
                                  )
                                : Text(l10n.createAccount),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l10n.haveAccount,
                            style: AppTextStyles.body(
                                fontSize: 13.5,
                                color: AppColors.inkSoft)),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => context.go(AppRouter.loginPath),
                          child: Text(
                            l10n.loginHere,
                            style: AppTextStyles.body(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.terraDeep,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
