// lib/features/scan/scan_store_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/api/api_service.dart';
import '../../core/utils/theme.dart';

class ScanStorePage extends StatefulWidget {
  const ScanStorePage({super.key});

  @override
  State<ScanStorePage> createState() => _ScanStorePageState();
}

class _ScanStorePageState extends State<ScanStorePage>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  final TextEditingController _manualCtrl = TextEditingController();
  final MobileScannerController _scannerCtrl = MobileScannerController();

  bool _manualMode = false;
  bool _loading = false;
  bool _scanned = false;

  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scannerCtrl.dispose();
    _manualCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleCode(String code) async {
    if (_loading || _scanned) return;
    setState(() {
      _scanned = true;
      _loading = true;
    });
    HapticFeedback.mediumImpact();
    try {
      final cart = await _api.getOrCreateCart(code);
      if (mounted) {
        context.go('/cart/${cart.cartId}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _scanned = false;
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Store not found: $code',
                style: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Enter Store'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() => _manualMode = !_manualMode),
            child: Text(
              _manualMode ? 'Scan QR' : 'Manual',
              style: GoogleFonts.spaceGrotesk(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _manualMode ? _buildManual() : _buildScanner(),
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        // Camera
        MobileScanner(
          controller: _scannerCtrl,
          onDetect: (capture) {
            final code = capture.barcodes.firstOrNull?.rawValue;
            if (code != null) _handleCode(code);
          },
        ),
        // Overlay
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        // Viewport cutout — simulated with overlay
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Point at the store QR code',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 32),
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, __) {
                  final glow = _pulseCtrl.value;
                  return Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.accent
                            .withOpacity(0.6 + 0.4 * glow),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.15 * glow),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: _loading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.accent))
                        : Stack(
                            children: [
                              // Corner accents
                              ..._cornerAccents(),
                            ],
                          ),
                  );
                },
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'Scanning automatically...',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _cornerAccents() {
    const size = 20.0;
    const thickness = 3.0;
    const color = AppColors.accent;
    final r = BorderRadius.circular(4);

    Widget corner({required AlignmentGeometry align, required double rx, required double ry}) {
      return Positioned.fill(
        child: Align(
          alignment: align,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              border: Border(
                top: rx < 0 ? BorderSide.none : const BorderSide(color: color, width: thickness),
                bottom: rx > 0 ? BorderSide.none : const BorderSide(color: color, width: thickness),
                left: ry < 0 ? BorderSide.none : const BorderSide(color: color, width: thickness),
                right: ry > 0 ? BorderSide.none : const BorderSide(color: color, width: thickness),
              ),
              borderRadius: r,
            ),
          ),
        ),
      );
    }

    return [
      corner(align: Alignment.topLeft, rx: 1, ry: 1),
      corner(align: Alignment.topRight, rx: 1, ry: -1),
      corner(align: Alignment.bottomLeft, rx: -1, ry: 1),
      corner(align: Alignment.bottomRight, rx: -1, ry: -1),
    ];
  }

  Widget _buildManual() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.store_rounded,
                color: AppColors.accent, size: 32),
          ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
          const SizedBox(height: 24),
          Text(
            'Enter Store Code',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1, end: 0),
          const SizedBox(height: 8),
          Text(
            'Find the code displayed at the store entrance or checkout.',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 14, color: AppColors.textSecondary, height: 1.5),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 32),
          TextField(
            controller: _manualCtrl,
            style: GoogleFonts.spaceGrotesk(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Store Code',
              prefixIcon: Icon(Icons.tag_rounded,
                  color: AppColors.textSecondary, size: 20),
              hintText: 'e.g. STORE001',
            ),
            onSubmitted: (v) {
              if (v.isNotEmpty) _handleCode(v.trim().toUpperCase());
            },
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading
                  ? null
                  : () {
                      final code = _manualCtrl.text.trim().toUpperCase();
                      if (code.isNotEmpty) _handleCode(code);
                    },
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary),
                    )
                  : const Text('Enter Store'),
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}
