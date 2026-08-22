import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tera/app/router/app_router.dart';
import 'package:tera/core/utils/app_colors.dart';
import 'package:tera/core/utils/app_text_styles.dart';
import 'package:tera/l10n/l10n.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _idx = 0;

  static const _scenes = [
    _SceneData(
      photo:
          'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=900&q=80&auto=format&fit=crop',
      baseGradient: [Color(0xFFC9D6B8), Color(0xFF8AA874), Color(0xFF4D6638), Color(0xFF2A3A1F)],
      veil: [Color(0x14141E0F), Color(0x38141E0F), Color(0x8C141E0F)],
    ),
    _SceneData(
      photo:
          'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?w=900&q=80&auto=format&fit=crop',
      baseGradient: [Color(0xFFE8D8B0), Color(0xFFC69A55), Color(0xFF6E4520), Color(0xFF2B1A0E)],
      veil: [Color(0x1A28190A), Color(0x4D28190A), Color(0x9428190A)],
    ),
    _SceneData(
      photo:
          'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=900&q=80&auto=format&fit=crop',
      baseGradient: [Color(0xFFF6C45F), Color(0xFFD97B3C), Color(0xFF8C3D20), Color(0xFF2C1410)],
      veil: [Color(0x1A1E0F08), Color(0x471E0F08), Color(0x8C1E0F08)],
    ),
  ];

  List<String> _titles(AppLocalizations l10n) =>
      [l10n.ob1Title, l10n.ob2Title, l10n.ob3Title];
  List<String> _bodies(AppLocalizations l10n) =>
      [l10n.ob1Body, l10n.ob2Body, l10n.ob3Body];

  void _advance(BuildContext ctx) {
    if (_idx < 2) {
      setState(() => _idx++);
    } else {
      ctx.go(AppRouter.loginPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scene = _scenes[_idx];
    final title = _titles(l10n)[_idx];
    final body = _bodies(l10n)[_idx];
    final words = title.split(' ');

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: scene.baseGradient,
              ),
            ),
          ),
          // Photo
          Image.network(
            scene.photo,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          // Veil
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: scene.veil,
                stops: const [0, 0.55, 1],
              ),
            ),
          ),
          // Dots top
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final active = i == _idx;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: active ? 22 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.green
                        : Colors.white.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
          // Skip
          Positioned(
            top: 60,
            right: 20,
            child: TextButton(
              onPressed: () => context.go(AppRouter.loginPath),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.18),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: const StadiumBorder(),
              ),
              child: Text(
                l10n.skip,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Caption block
          Positioned(
            left: 18,
            right: 18,
            bottom: 110,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Container(
                color: const Color(0xD1141A12),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${(_idx + 1).toString().padLeft(2, '0')} / 03',
                      style: AppTextStyles.eyebrow(
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(
                        children: words.asMap().entries.map((e) {
                          final isLast = e.key == words.length - 1;
                          return TextSpan(
                            text: isLast ? e.value : '${e.value} ',
                            style: isLast
                                ? AppTextStyles.serifItalic(
                                    fontSize: 34,
                                    color: const Color(0xFFCFE0B9),
                                  )
                                : AppTextStyles.serifHeading(
                                    fontSize: 34,
                                    color: Colors.white,
                                  ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      body,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.78),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // CTA
          Positioned(
            left: 18,
            right: 18,
            bottom: 44,
            child: SizedBox(
              height: 58,
              child: FilledButton(
                onPressed: () => _advance(context),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_idx < 2 ? l10n.next : l10n.start),
                    const SizedBox(width: 6),
                    const Text('→'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SceneData {
  const _SceneData({
    required this.photo,
    required this.baseGradient,
    required this.veil,
  });
  final String photo;
  final List<Color> baseGradient;
  final List<Color> veil;
}
