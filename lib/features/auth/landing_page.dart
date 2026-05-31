// lib/features/auth/landing_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/utils/theme.dart';
import 'auth_provider.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // Background geometric pattern
          Positioned.fill(child: _BackgroundPattern()),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),
                  _buildLogo(),
                  const SizedBox(height: 32),
                  _buildHero(),
                  const Spacer(flex: 3),
                  _buildActions(context),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.qr_code_scanner_rounded,
              color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          'ScanPay',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: -0.2, end: 0, curve: Curves.easeOut);
  }

  Widget _buildHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shop smarter.\nPay faster.',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 44,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.1,
            letterSpacing: -1.5,
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 700.ms)
            .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),
        const SizedBox(height: 16),
        Text(
          'Scan products, build your cart, and checkout in seconds — right from your phone.',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        )
            .animate()
            .fadeIn(delay: 400.ms, duration: 700.ms)
            .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),
        const SizedBox(height: 32),
        // Feature pills
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ['Scan & Shop', 'Instant Bill', 'Order History']
              .asMap()
              .entries
              .map(
                (e) => _FeaturePill(label: e.value)
                    .animate()
                    .fadeIn(delay: (500 + e.key * 100).ms)
                    .scale(begin: const Offset(0.8, 0.8)),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () => context.go('/login'),
          child: const Text('Sign In'),
        )
            .animate()
            .fadeIn(delay: 700.ms, duration: 500.ms)
            .slideY(begin: 0.3, end: 0),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () async {
            final ok = await auth.loginAnonymous();
            if (ok && context.mounted) context.go('/home');
          },
          child: auth.loading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.accent),
                )
              : const Text('Continue as Guest'),
        )
            .animate()
            .fadeIn(delay: 850.ms, duration: 500.ms)
            .slideY(begin: 0.3, end: 0),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'Guest mode lets you shop fully — register anytime to save history.',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ).animate().fadeIn(delay: 1000.ms),
      ],
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final String label;
  const _FeaturePill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        label,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _BackgroundPattern extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PatternPainter(),
    );
  }
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF112240)
      ..style = PaintingStyle.fill;

    // Large circle top right
    canvas.drawCircle(
        Offset(size.width + 80, -60), 220, paint);

    // Small accent circle bottom left
    final accentPaint = Paint()
      ..color = const Color(0xFFFFC947).withOpacity(0.06)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(-40, size.height + 20), 180, accentPaint);

    // Grid dots
    final dotPaint = Paint()
      ..color = const Color(0xFF1E3A55)
      ..style = PaintingStyle.fill;
    for (var x = 0.0; x < size.width; x += 40) {
      for (var y = 0.0; y < size.height; y += 40) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
