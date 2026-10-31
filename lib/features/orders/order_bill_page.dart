// lib/features/orders/order_bill_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_service.dart';
import '../../core/models/models.dart';
import '../../core/utils/theme.dart';

class OrderBillPage extends StatefulWidget {
  final String orderId;
  const OrderBillPage({super.key, required this.orderId});

  @override
  State<OrderBillPage> createState() => _OrderBillPageState();
}

class _OrderBillPageState extends State<OrderBillPage> {
  final ApiService _api = ApiService();
  OrderBillResponse? _bill;
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
      _bill = await _api.getOrderBill(widget.orderId);
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
        title: const Text('Order Receipt'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent))
          : _error != null
              ? _buildError()
              : _buildReceipt(),
    );
  }

  Widget _buildReceipt() {
    final bill = _bill!;
    final fmt = DateFormat('dd MMM yyyy, hh:mm a');
    final date = bill.createdAt != null
        ? fmt.format(bill.createdAt!.toLocal())
        : '—';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Receipt header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.check_circle_outline_rounded,
                      color: AppColors.success, size: 28),
                ).animate().scale(begin: const Offset(0.7, 0.7)),
                const SizedBox(height: 12),
                Text('Order Confirmed',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    )).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 4),
                Text(date,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 13, color: AppColors.textSecondary))
                    .animate()
                    .fadeIn(delay: 200.ms),
                const SizedBox(height: 16),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ReceiptMeta(
                        label: 'Store', value: bill.storeName ?? '—'),
                    _ReceiptMeta(
                        label: 'Brand', value: bill.tenantName ?? '—'),
                  ],
                ).animate().fadeIn(delay: 300.ms),
                if (bill.storeAddress != null) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(bill.storeAddress!,
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ),
                ],
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.05, end: 0),
          const SizedBox(height: 20),
          Text('Items',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              )),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: bill.items.asMap().entries.map((e) {
                final last = e.key == bill.items.length - 1;
                return _OrderItemRow(
                  item: e.value,
                  index: e.key,
                  isLast: last,
                )
                    .animate()
                    .fadeIn(delay: (e.key * 50 + 200).ms)
                    .slideX(begin: 0.05, end: 0);
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.surface, AppColors.cardBg],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Text('Total Amount',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    )),
                const Spacer(),
                Text('₹${bill.totalAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent,
                    )),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),
          // Order ID
          Center(
            child: Text(
              'Order ID: ${widget.orderId}',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  color: AppColors.textSecondary.withOpacity(0.5),
                  letterSpacing: 0.3),
            ),
          ).animate().fadeIn(delay: 500.ms),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Text(
                  'Scan to look up this order',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: QrImageView(
                    data: Uri.parse(ApiClient.baseUrl)
                        .resolve(
                          '/api/v1/orders/${Uri.encodeComponent(widget.orderId)}/bill',
                        )
                        .toString(),
                    version: QrVersions.auto,
                    size: 180,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    semanticsLabel: 'QR code for order ${widget.orderId}',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Order lookup · ${Uri.parse(ApiClient.baseUrl).host}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 550.ms),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_rounded,
              color: AppColors.textSecondary, size: 48),
          const SizedBox(height: 16),
          Text('Could not load receipt',
              style: GoogleFonts.spaceGrotesk(
                  color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _load, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _ReceiptMeta extends StatelessWidget {
  final String label;
  final String value;
  const _ReceiptMeta({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            )),
      ],
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final OrderItemSnapshot item;
  final int index;
  final bool isLast;

  const _OrderItemRow(
      {required this.item, required this.index, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text('${item.quantity}×',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                )),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(item.name,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          Text(
            '₹${item.total.toStringAsFixed(2)}',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
