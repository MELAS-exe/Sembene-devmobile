import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tera/core/utils/app_colors.dart';

class TeraTopBar extends StatelessWidget {
  const TeraTopBar({
    required this.title,
    super.key,
    this.leading,
    this.trailing,
    this.dark = false,
  });

  final String title;
  final Widget? leading;
  final Widget? trailing;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: leading,
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: dark ? Colors.white : AppColors.ink,
                  letterSpacing: -0.005 * 15,
                ),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 36),
              child: trailing != null
                  ? Align(
                      alignment: Alignment.centerRight,
                      child: trailing,
                    )
                  : const SizedBox(width: 36),
            ),
          ],
        ),
      ),
    );
  }
}
