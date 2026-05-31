// lib/features/auth/profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/utils/theme.dart';
import 'auth_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.accent, AppColors.accentDark],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  user?.email?.substring(0, 1).toUpperCase() ?? 'G',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ).animate().scale(begin: const Offset(0.7, 0.7)).fadeIn(),
            const SizedBox(height: 16),
            Text(
              user?.email ?? 'Guest User',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: auth.isAnonymous
                    ? AppColors.accent.withOpacity(0.1)
                    : AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                auth.isAnonymous ? 'Guest Account' : 'Registered',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color:
                      auth.isAnonymous ? AppColors.accent : AppColors.success,
                ),
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 32),
            // Info tiles
            if (user?.mobile != null)
              _InfoTile(
                icon: Icons.phone_outlined,
                label: 'Mobile',
                value: user!.mobile!,
              ).animate().fadeIn(delay: 300.ms),
            if (!auth.isAnonymous)
              _InfoTile(
                icon: Icons.verified_outlined,
                label: 'Account',
                value: 'Verified',
                valueColor: AppColors.success,
              ).animate().fadeIn(delay: 350.ms),
            const SizedBox(height: 24),
            // Actions
            if (auth.isAnonymous) ...[
              _ActionTile(
                icon: Icons.person_add_alt_1_rounded,
                label: 'Register Account',
                subtitle: 'Link your guest session to an account',
                color: AppColors.accent,
                onTap: () => context.push('/register'),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 12),
              _ActionTile(
                icon: Icons.login_rounded,
                label: 'Sign In',
                subtitle: 'Already have an account?',
                color: const Color(0xFF7C9EFF),
                onTap: () => context.go('/login'),
              ).animate().fadeIn(delay: 450.ms),
              const SizedBox(height: 12),
            ],
            _ActionTile(
              icon: Icons.receipt_long_rounded,
              label: 'My Orders',
              subtitle: 'View order history',
              color: const Color(0xFF7C9EFF),
              onTap: () => context.go('/orders'),
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.shopping_bag_outlined,
              label: 'My Carts',
              subtitle: 'View active and past carts',
              color: AppColors.success,
              onTap: () => context.go('/carts'),
            ).animate().fadeIn(delay: 550.ms),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) context.go('/');
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(
                      color: AppColors.error.withOpacity(0.5), width: 1.5),
                ),
              ),
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 12),
          Text(label,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 14, color: AppColors.textSecondary)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              )),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      )),
                  Text(subtitle,
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}
