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
import 'package:tera/shared/widgets/tera_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.mustChangePassword) {
            context.go(AppRouter.changePasswordPath);
          } else {
            context.read<ProfileCubit>().loadProfile();
            context.go(AppRouter.marketPath);
          }
        } else if (state is AuthUnauthenticated) {
          // stay on splash — user can tap to go to onboarding/login
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.4,
              colors: [Colors.white, AppColors.bg],
              stops: [0, 0.6],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 52, 28, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const TeraLogo(size: 36),
                      const SizedBox(width: 10),
                      Text(
                        'Tera',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.01 * 17,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    l10n.senegal,
                    style: AppTextStyles.eyebrow(),
                  ),
                  const SizedBox(height: 18),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Le marché\n',
                          style: AppTextStyles.serifHeading(fontSize: 64),
                        ),
                        TextSpan(
                          text: 'le plus juste',
                          style: AppTextStyles.serifItalic(
                            fontSize: 64,
                            color: AppColors.greenDeep,
                          ),
                        ),
                        TextSpan(
                          text: '\ndu pays.',
                          style: AppTextStyles.serifHeading(fontSize: 64),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    l10n.taglineSub,
                    style: AppTextStyles.body(
                      color: AppColors.inkSoft,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: FilledButton(
                      onPressed: () => context.go(AppRouter.onboardingPath),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Text(l10n.start),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: TextButton(
                      onPressed: () => context.go(AppRouter.loginPath),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.haveAccount,
                            style: AppTextStyles.body(color: AppColors.inkSoft),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.loginHere,
                            style: AppTextStyles.body(
                              color: AppColors.terraDeep,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
