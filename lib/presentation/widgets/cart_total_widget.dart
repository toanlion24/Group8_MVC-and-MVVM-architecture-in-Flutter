import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/mixins/price_formatter_mixin.dart';
import '../providers/cart_notifier.dart';

// CartTotalWidget - Sử dụng SELECTOR để tối ưu rebuild
//
// SELECTOR vs CONSUMER:
//
// CONSUMER:
// - Rebuild khi BẤT KỲ state nào trong Provider thay đổi
// - Ví dụ: Thêm sản phẩm mới (quantity thay đổi) -> Consumer rebuild
//
// SELECTOR:
// - Chỉ rebuild khi PHẦN STATE ĐƯỢC CHỌN thay đổi
// - Ví dụ: Chỉ rebuild khi totalPrice thay đổi
// - Nếu thêm cùng 1 sản phẩm (quantity tăng nhưng price/item không đổi)
//   -> totalPrice thay đổi -> Selector rebuild
// - Nếu chỉ thay đổi metadata không liên quan đến price
//   -> Selector KHÔNG rebuild
//
// Cú pháp: `Selector<ProviderType, SelectedValueType>`
class CartTotalWidget extends StatelessWidget with PriceFormatterMixin {
  const CartTotalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // SELECTOR OLD -> RIVERPOD SELECT
    // Sử dụng Consumer của Riverpod
    return Consumer(
      builder: (context, ref, child) {
        // Chỉ lắng nghe totalPrice
        final totalPrice = ref.watch(
          cartProvider.select((state) => state.totalPrice),
        );

        debugPrint('CartTotalWidget REBUILD - totalPrice: $totalPrice');

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25), // ~0.1 opacity
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Label
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tổng tiền',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onPrimaryContainer
                            .withAlpha(179), // ~0.7 opacity
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Hiển thị tổng tiền đã format (sử dụng Mixin)
                    Text(
                      formatPrice(totalPrice),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),

                // Nút thanh toán
                ElevatedButton.icon(
                  onPressed: totalPrice > 0
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🎉 Đặt hàng thành công!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // Clear cart after checkout
                          // ref.read(provider.notifier) để gọi method
                          ref.read(cartProvider.notifier).clearCart();
                        }
                      : null,
                  icon: const Icon(Icons.payment),
                  label: const Text('Thanh toán'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
