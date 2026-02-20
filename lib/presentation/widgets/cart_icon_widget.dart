import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_notifier.dart';

// CartIconWidget - Sử dụng CONSUMER để hiển thị số lượng
//
// CONSUMER:
// - Lắng nghe MỌI thay đổi từ CartProvider
// - Rebuild TOÀN BỘ widget bên trong builder mỗi khi notifyListeners() được gọi
// - Phù hợp khi widget cần nhiều thông tin từ Provider
//
// Trong ví dụ này:
// - Consumer rebuild mỗi khi giỏ hàng thay đổi (thêm/xóa/cập nhật)
// - Hiển thị badge với tổng số lượng sản phẩm
class CartIconWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const CartIconWidget({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    // CONSUMER: Lắng nghe CartProvider và rebuild khi có thay đổi
    // Sử dụng Consumer của Riverpod
    return Consumer(
      builder: (context, ref, child) {
        // Sử dụng ref.watch với select để chỉ lắng nghe totalQuantity (giống Selector)
        final totalQuantity = ref.watch(
          cartProvider.select((state) => state.totalQuantity),
        );

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: totalQuantity > 0
                  ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.6)
                  : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 24,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                if (totalQuantity > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        totalQuantity > 99 ? '99+' : '$totalQuantity',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onError,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
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
