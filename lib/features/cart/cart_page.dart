// lib/features/cart/cart_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../core/utils/theme.dart';
import 'cart_provider.dart';

class CartPage extends StatefulWidget {
  final String cartId;
  const CartPage({super.key, required this.cartId});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _scannerOpen = false;
  bool _manualMode = false;
  bool _codeScanned = false;
  final TextEditingController _manualCtrl = TextEditingController();
  MobileScannerController? _scanCtrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCart(widget.cartId);
    });
  }

  @override
  void dispose() {
    _scanCtrl?.dispose();
    _manualCtrl.dispose();
    super.dispose();
  }

  void _openScanner() {
    setState(() {
      _scannerOpen = true;
      _codeScanned = false;
      _manualMode = false;
      _scanCtrl = MobileScannerController();
    });
  }

  void _closeScanner() {
    _scanCtrl?.dispose();
    setState(() {
      _scannerOpen = false;
      _scanCtrl = null;
    });
  }

  Future<void> _handleBarcode(String barcode) async {
    if (_codeScanned) return;
    setState(() => _codeScanned = true);
    HapticFeedback.mediumImpact();
    _closeScanner();
    final ok = await context.read<CartProvider>().addItem(widget.cartId, barcode);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<CartProvider>().error ?? 'Product not found',
            style: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary),
          ),
        ),
      );
    } else if (ok && mounted) {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _addManual() async {
    final code = _manualCtrl.text.trim();
    if (code.isEmpty) return;
    setState(() => _manualMode = false);
    _manualCtrl.clear();
    await _handleBarcode(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Your Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (_, cart, __) => cart.cart != null && cart.cart!.items.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.error),
                    onPressed: () => _confirmClear(context),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Consumer<CartProvider>(
            builder: (_, cartProvider, __) {
              if (cartProvider.loading && cartProvider.cart == null) {
                return const Center(
                    child: CircularProgressIndicator(color: AppColors.accent));
              }
              final cart = cartProvider.cart;
              if (cart == null) {
                return _buildError(cartProvider.error ?? 'Cart not found');
              }
              return _buildCart(context, cart, cartProvider);
            },
          ),
          if (_scannerOpen) _buildScannerOverlay(),
          if (_manualMode) _buildManualOverlay(),
        ],
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (_, cartProvider, __) {
          final cart = cartProvider.cart;
          if (cart == null || cart.items.isEmpty) return const SizedBox.shrink();
          return _buildBottomBar(context, cart);
        },
      ),
    );
  }

  Widget _buildCart(
      BuildContext context, CartResponse cart, CartProvider cartProvider) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildCartHeader(cart)),
        if (cart.items.isEmpty)
          SliverFillRemaining(child: _buildEmptyCart())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _CartItemCard(
                  item: cart.items[i],
                  onDecrease: () => cartProvider.decreaseItem(
                      widget.cartId, cart.items[i].productId),
                  onIncrease: () => _handleBarcode(cart.items[i].barcode),
                  index: i,
                ),
                childCount: cart.items.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCartHeader(CartResponse cart) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${cart.items.length} item${cart.items.length == 1 ? '' : 's'}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Cart · ${widget.cartId.substring(0, 8)}',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          _ScanButton(
            onScan: _openScanner,
            onManual: () => setState(() => _manualMode = true),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.shopping_basket_outlined,
                color: AppColors.accent, size: 40),
          ).animate().scale(begin: const Offset(0.8, 0.8)).fadeIn(),
          const SizedBox(height: 20),
          Text('Cart is empty',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              )).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text('Scan a product barcode to start shopping',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: AppColors.textSecondary,
              )).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: _openScanner,
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
            label: const Text('Scan Product'),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => setState(() => _manualMode = true),
            child: const Text('Enter Barcode'),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, CartResponse cart) {
    final total = cart.totalAmount;
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border:
            const Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 13, color: AppColors.textSecondary)),
              Text(
                '₹${total.toStringAsFixed(2)}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => context.push('/cart/${widget.cartId}/bill'),
            child: const Text('View Bill'),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            if (_scanCtrl != null)
              MobileScanner(
                controller: _scanCtrl!,
                onDetect: (capture) {
                  final code = capture.barcodes.firstOrNull?.rawValue;
                  if (code != null) _handleBarcode(code);
                },
              ),
            // Top bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                    16, MediaQuery.of(context).padding.top + 8, 16, 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 28),
                      onPressed: _closeScanner,
                    ),
                    Expanded(
                      child: Text('Scan Product Barcode',
                          style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ),
                    TextButton(
                      onPressed: () {
                        _closeScanner();
                        setState(() => _manualMode = true);
                      },
                      child: Text('Manual',
                          style: GoogleFonts.spaceGrotesk(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
            // Scan guide
            Center(
              child: Container(
                width: 260,
                height: 140,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.accent, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
                  .custom(
                    duration: 1200.ms,
                    builder: (_, value, child) => Container(
                      width: 260,
                      height: 140,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.accent.withOpacity(0.5 + 0.5 * value),
                            width: 2),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.1 * value),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: child,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _manualMode = false),
        child: Container(
          color: Colors.black.withOpacity(0.6),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.fromLTRB(
                    24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Enter Barcode',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            )),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: AppColors.textSecondary),
                          onPressed: () =>
                              setState(() => _manualMode = false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _manualCtrl,
                      autofocus: true,
                      style: GoogleFonts.spaceGrotesk(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Barcode Number',
                        prefixIcon: Icon(Icons.barcode_reader,
                            color: AppColors.textSecondary, size: 20),
                      ),
                      onSubmitted: (_) => _addManual(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addManual,
                        child: const Text('Add to Cart'),
                      ),
                    ),
                  ],
                ),
              ).animate().slideY(begin: 0.3, end: 0, duration: 300.ms),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 48),
          const SizedBox(height: 16),
          Text(msg,
              style: GoogleFonts.spaceGrotesk(
                  color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () =>
                context.read<CartProvider>().loadCart(widget.cartId),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear cart?',
            style: GoogleFonts.spaceGrotesk(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: Text(
          'This will remove all items from your cart.',
          style: GoogleFonts.spaceGrotesk(
              color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.spaceGrotesk(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Clear',
                style: GoogleFonts.spaceGrotesk(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      context.read<CartProvider>().clearCart(widget.cartId);
    }
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItemResponse item;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final int index;

  const _CartItemCard({
    required this.item,
    required this.onDecrease,
    required this.onIncrease,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.inventory_2_outlined,
                color: AppColors.textSecondary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  '₹${item.price.toStringAsFixed(2)} each',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 8),
              _QtyControl(
                  qty: item.quantity,
                  onDecrease: onDecrease,
                  onIncrease: onIncrease),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (index * 50).ms)
        .slideX(begin: 0.05, end: 0);
  }
}

class _QtyControl extends StatelessWidget {
  final int qty;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _QtyControl(
      {required this.qty, required this.onDecrease, required this.onIncrease});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _QtyBtn(
          icon: qty == 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
          onTap: onDecrease,
          isDelete: qty == 1,
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 32),
          alignment: Alignment.center,
          child: Text('$qty',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              )),
        ),
        _QtyBtn(icon: Icons.add_rounded, onTap: onIncrease),
      ],
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDelete;

  const _QtyBtn(
      {required this.icon, required this.onTap, this.isDelete = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isDelete
              ? AppColors.error.withOpacity(0.15)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            size: 16, color: isDelete ? AppColors.error : AppColors.textPrimary),
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  final VoidCallback onScan;
  final VoidCallback onManual;

  const _ScanButton({required this.onScan, required this.onManual});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onManual,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Icon(Icons.keyboard_outlined,
                color: AppColors.textSecondary, size: 20),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onScan,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.accent, AppColors.accentDark]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.qr_code_scanner_rounded,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 6),
                Text('Scan',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
