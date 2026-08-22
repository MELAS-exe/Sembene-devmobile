import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tera/core/utils/app_colors.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status, required this.label});

  final String status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors(status);
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: fg,
              letterSpacing: 0.01 * 11.5,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _colors(String status) => switch (status.toUpperCase()) {
        'PENDING' => (AppColors.pillPendingBg, AppColors.pillPendingFg),
        'CREATED' => (AppColors.pillCreatedBg, AppColors.pillCreatedFg),
        'CONFIRMED' => (AppColors.pillConfirmedBg, AppColors.pillConfirmedFg),
        'SHIPPING' => (AppColors.pillShippingBg, AppColors.pillShippingFg),
        'SHIPPED' => (AppColors.pillShippedBg, AppColors.pillShippedFg),
        'DELIVERED' => (AppColors.pillDeliveredBg, AppColors.pillDeliveredFg),
        'CANCELLED' => (AppColors.pillCancelledBg, AppColors.pillCancelledFg),
        'APPROVED' => (AppColors.pillApprovedBg, AppColors.pillApprovedFg),
        'REJECTED' => (AppColors.pillRejectedBg, AppColors.pillRejectedFg),
        _ => (AppColors.line, AppColors.inkSoft),
      };
}
