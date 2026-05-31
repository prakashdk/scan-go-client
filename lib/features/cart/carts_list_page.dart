// lib/features/cart/carts_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api/api_service.dart';
import '../../core/models/models.dart';
import '../../core/utils/theme.dart';

class CartsListPage extends StatefulWidget {
  const CartsListPage({super.key});

  @override
  State<CartsListPage> createState() => _CartsListPageState();
}

class _CartsListPageState extends State<CartsListPage> {
  final ApiService _api = ApiService();
  List<CartSummaryResponse>? _carts;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _carts = await _api.getMyCarts();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('My Carts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent))
          : _error != null
              ? _buildError()
              : _carts == null || _carts!.isEmpty
                  ? _buildEmpty()
                  : _buildList(),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.primary,
        onPressed: () => context.go('/scan-store'),
        icon: const Icon(Icons.add_rounded),
        label: Text('New Cart',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildList() {
    final active = _carts!.where((c) => c.status == 'ACTIVE').toList();
    final others = _carts!.where((c) => c.status != 'ACTIVE').toList();

    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surface,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          if (active.isNotEmpty) ...[
            _sectionLabel('Active'),
            ...active.asMap().entries.map(
                  (e) => _CartCard(cart: e.value, index: e.key).animate().fadeIn(delay: (e.key * 60).ms),
                ),
            const SizedBox(height: 20),
          ],
          if (others.isNotEmpty) ...[
            _sectionLabel('Past'),
            ...others.asMap().entries.map(
                  (e) => _CartCard(cart: e.value, index: e.key, dim: true)
                      .animate()
                      .fadeIn(delay: (e.key * 60).ms),
                ),
          ],
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          )),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.shopping_bag_outlined,
                color: AppColors.accent, size: 36),
          ).animate().scale(begin: const Offset(0.8, 0.8)),
          const SizedBox(height: 20),
          Text('No carts yet',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              )).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text('Scan a store QR code to create one',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 14, color: AppColors.textSecondary))
              .animate()
              .fadeIn(delay: 300.ms),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: () => context.go('/scan-store'),
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
            label: const Text('Enter Store'),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded,
              color: AppColors.error, size: 48),
          const SizedBox(height: 16),
          Text('Failed to load carts',
              style: GoogleFonts.spaceGrotesk(
                  color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _load, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _CartCard extends StatelessWidget {
  final CartSummaryResponse cart;
  final int index;
  final bool dim;

  const _CartCard({required this.cart, required this.index, this.dim = false});

  @override
  Widget build(BuildContext context) {
    final isActive = cart.status == 'ACTIVE';

    return GestureDetector(
      onTap: isActive ? () => context.go('/cart/${cart.cartId}') : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: dim ? AppColors.cardBg.withOpacity(0.6) : AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppColors.accent.withOpacity(0.2) : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.accent.withOpacity(0.15)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isActive
                    ? Icons.shopping_cart_outlined
                    : Icons.shopping_cart_checkout_rounded,
                color: isActive ? AppColors.accent : AppColors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cart.storeName ?? 'Unknown Store',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: dim
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    cart.tenantName ?? cart.storeCode ?? '',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            _StatusBadge(status: cart.status),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'ACTIVE' => ('Active', AppColors.success),
      'CHECKED_OUT' => ('Paid', const Color(0xFF7C9EFF)),
      _ => ('Abandoned', AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          )),
    );
  }
}
