import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/mixins/price_formatter_mixin.dart';
import '../providers/cart_notifier.dart';

// CartTotalWidget - Footer hiển thị tổng tiền và nút thanh toán
class CartTotalWidget extends ConsumerWidget with PriceFormatterMixin {
  const CartTotalWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalPrice = ref.watch(
      cartProvider.select((state) => state.totalPrice),
    );
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tổng tiền',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatPrice(totalPrice),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            FilledButton.icon(
              onPressed: totalPrice > 0
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('🎉 Đặt hàng thành công!'),
                          backgroundColor: Colors.green.shade700,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                      ref.read(cartProvider.notifier).clearCart();
                    }
                  : null,
              icon: const Icon(Icons.payment_rounded),
              label: const Text('Thanh toán'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
