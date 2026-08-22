import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tera/core/extensions/context_extensions.dart';
import 'package:tera/core/utils/app_colors.dart';
import 'package:tera/features/profile/presentation/blocs/edit_profile_cubit.dart';
import 'package:tera/features/profile/presentation/blocs/profile_cubit.dart';
import 'package:tera/l10n/l10n.dart';
import 'package:tera/shared/widgets/tera_top_bar.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _bioCtrl;

  @override
  void initState() {
    super.initState();
    final profileState = context.read<ProfileCubit>().state;
    final profile =
        profileState is ProfileLoaded ? profileState.profile : null;
    _firstNameCtrl = TextEditingController(text: profile?.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: profile?.lastName ?? '');
    _bioCtrl = TextEditingController(text: profile?.bio ?? '');
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _firstNameCtrl.text.trim().isNotEmpty &&
      _lastNameCtrl.text.trim().isNotEmpty;

  void _save() {
    if (!_canSave) return;
    context.read<EditProfileCubit>().submit(
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          bio: _bioCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<EditProfileCubit, EditProfileState>(
      listener: (context, state) {
        if (state is EditProfileSuccess) {
          context.read<ProfileCubit>().loadProfile();
          context
            ..pop()
            ..displayFlash(l10n.editProfile);
        } else if (state is EditProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TeraTopBar(
              title: l10n.myProfile,
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
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProfileField(
                      label: l10n.firstName,
                      controller: _firstNameCtrl,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 14),
                    _ProfileField(
                      label: l10n.lastName,
                      controller: _lastNameCtrl,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 14),
                    _ProfileField(
                      label: l10n.bio,
                      controller: _bioCtrl,
                      onChanged: (_) => setState(() {}),
                      maxLines: 3,
                      hint: '…',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomSheet: BlocBuilder<EditProfileCubit, EditProfileState>(
          builder: (context, state) {
            final isSubmitting = state is EditProfileSubmitting;
            return Container(
              decoration: BoxDecoration(
                color: AppColors.bg.withValues(alpha: 0.95),
                border: const Border(top: BorderSide(color: AppColors.line)),
              ),
              padding: EdgeInsets.fromLTRB(
                22,
                14,
                22,
                MediaQuery.paddingOf(context).bottom + 14,
              ),
              child: SizedBox(
                height: 52,
                child: GestureDetector(
                  onTap: (_canSave && !isSubmitting) ? _save : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    decoration: BoxDecoration(
                      color: (_canSave && !isSubmitting)
                          ? AppColors.forest
                          : AppColors.line,
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
                              l10n.save,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: (_canSave && !isSubmitting)
                                    ? Colors.white
                                    : AppColors.inkSoft,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.maxLines = 1,
    this.hint,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final String? hint;

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
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: maxLines,
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
                fontSize: 15,
                color: AppColors.inkMute,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
