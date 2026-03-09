// =============================================================================
// PHỎNG VẤN KIẾN THỨC - cart_total_widget.dart (Footer tổng tiền + thanh toán)
// =============================================================================
//
//   Q1. onPressed: totalPrice > 0 ? () { SnackBar + clearCart } : null — thanh toán thật không?
//   A1. Không: chỉ demo. SnackBar "Đặt hàng thành công!" rồi clearCart. Production sẽ gọi
//       API đặt hàng, nhận success rồi mới clear hoặc chuyển màn xác nhận.
//
//   Q2. ref.read(cartProvider.notifier).clearCart() — sau clear widget có tự cập nhật không?
//   A2. Có. clearCart() trong notifier set state mới (items: []); cartProvider notify listener.
//       CartTotalWidget ref.watch(cartProvider.select((state) => state.totalPrice)) nên
//       rebuild, totalPrice = 0, nút disabled. List và header cũng rebuild vì watch items.
//
//   Q3. SafeArea(top: false) — vì sao chỉ bảo vệ bottom?
//   A3. Footer nằm dưới cùng; trên có thể là AppBar/safe. SafeArea(top: false) tránh padding
//       phía trên (không cần), chỉ cần padding bottom cho notch/home indicator.
//
// -----------------------------------------------------------------------------
// LOGIC TRONG FILE: ConsumerWidget + PriceFormatterMixin. Watch totalPrice. Hiển thị
//   "Tổng tiền" + formatPrice; nút Thanh toán (SnackBar + clearCart khi totalPrice > 0).
// -----------------------------------------------------------------------------
// LOGIC TRONG DỰ ÁN: Nằm dưới cùng CartScreen (Column). Cố định, list có padding bottom.
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/mixins/price_formatter_mixin.dart';
import '../providers/cart_notifier.dart';

/// CartTotalWidget - Footer tổng tiền và nút thanh toán
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
