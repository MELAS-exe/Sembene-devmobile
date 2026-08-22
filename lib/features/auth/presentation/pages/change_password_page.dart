import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tera/app/router/app_router.dart';
import 'package:tera/core/utils/app_colors.dart';
import 'package:tera/core/utils/app_text_styles.dart';
import 'package:tera/features/auth/presentation/blocs/auth_cubit.dart';
import 'package:tera/features/auth/presentation/blocs/change_password_cubit.dart';
import 'package:tera/features/profile/presentation/blocs/profile_cubit.dart';
import 'package:tera/injector.dart';
import 'package:tera/l10n/l10n.dart';
import 'package:tera/shared/widgets/tera_top_bar.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<ChangePasswordCubit>().submit(
          currentPassword: _currentCtrl.text,
          newPassword: _newCtrl.text,
          confirmPassword: _confirmCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authState = context.read<AuthCubit>().state;
    final isForced = authState is AuthAuthenticated && authState.mustChangePassword;
    return BlocListener<ChangePasswordCubit, ChangePasswordState>(
      listener: (context, state) {
        if (state is ChangePasswordSuccess) {
          getIt<AuthCubit>().onPasswordChanged();
          getIt<ProfileCubit>().loadProfile();
          context.go(AppRouter.marketPath);
        } else if (state is ChangePasswordError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: PopScope(
        canPop: !isForced,
        child: Scaffold(
          backgroundColor: AppColors.bg,
          body: Column(
            children: [
              TeraTopBar(
                title: l10n.changePassword,
                leading: isForced
                    ? null
                    : GestureDetector(
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
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isForced) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.goldPale,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.lock_outline_rounded,
                                size: 18,
                                color: AppColors.ink,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  l10n.changePasswordIntro,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.ink,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                      _PwdField(
                        label: l10n.oldPwd,
                        controller: _currentCtrl,
                        obscure: _obscureCurrent,
                        onToggle: () => setState(
                            () => _obscureCurrent = !_obscureCurrent),
                      ),
                      const SizedBox(height: 16),
                      _PwdField(
                        label: l10n.newPwd,
                        controller: _newCtrl,
                        obscure: _obscureNew,
                        onToggle: () =>
                            setState(() => _obscureNew = !_obscureNew),
                      ),
                      const SizedBox(height: 16),
                      _PwdField(
                        label: l10n.confirmNewPwd,
                        controller: _confirmCtrl,
                        obscure: _obscureConfirm,
                        onToggle: () => setState(
                            () => _obscureConfirm = !_obscureConfirm),
                      ),
                      const SizedBox(height: 32),
                      BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
                        builder: (context, state) {
                          final isLoading = state is ChangePasswordLoading;
                          return SizedBox(
                            height: 52,
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: isLoading ? null : _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.forest,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                textStyle: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(l10n.confirm),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PwdField extends StatelessWidget {
  const _PwdField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });

  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.label(fontSize: 11),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
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
              IconButton(
                onPressed: onToggle,
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: AppColors.inkSoft,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
