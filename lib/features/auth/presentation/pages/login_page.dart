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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<AuthCubit>().login(
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
              title: l10n.signin,
              leading: IconButton(
                onPressed: () => context.go(AppRouter.splashPath),
                icon: const Icon(Icons.chevron_left, size: 26),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.paper,
                  side: const BorderSide(color: AppColors.line),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Bon retour',
                            style:
                                AppTextStyles.serifHeading(fontSize: 44),
                          ),
                          TextSpan(
                            text: '.',
                            style: AppTextStyles.serifItalic(
                                fontSize: 44,
                                color: AppColors.greenDeep),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Connectez-vous pour suivre vos commandes, gérer votre stock et accéder au marché.',
                      style: AppTextStyles.body(
                          color: AppColors.inkSoft, fontSize: 14.5),
                    ),
                    const SizedBox(height: 28),
                    // Phone field
                    Text(l10n.phone,
                        style: AppTextStyles.label()),
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
                              const Text('🇸🇳', style: TextStyle(fontSize: 16)),
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
                            decoration: const InputDecoration(
                              hintText: '77 100 22 33',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Password field
                    Text(l10n.password,
                        style: AppTextStyles.label()),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _pwdCtrl,
                      obscureText: _obscure,
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
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.pwdHint,
                            style: AppTextStyles.label(fontSize: 11.5)),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            l10n.forgot,
                            style: AppTextStyles.label(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.terraDeep,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (ctx, state) {
                        return SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: FilledButton(
                            onPressed: state is AuthLoading ? null : _submit,
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: state is AuthLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(l10n.signin),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l10n.noAccount,
                            style: AppTextStyles.body(
                                fontSize: 14, color: AppColors.inkSoft)),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => context.go(AppRouter.registerPath),
                          child: Text(
                            l10n.registerHere,
                            style: AppTextStyles.body(
                              fontSize: 14,
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
