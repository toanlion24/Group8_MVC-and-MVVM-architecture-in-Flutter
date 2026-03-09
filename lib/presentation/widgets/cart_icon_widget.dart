// =============================================================================
// PHỎNG VẤN KIẾN THỨC - cart_icon_widget.dart (Icon giỏ hàng + badge)
// =============================================================================
//
//   Q1. Consumer vs ConsumerWidget — CartIconWidget dùng Consumer bên trong build. Có thể đổi thành ConsumerWidget không?
//   A1. Có: class CartIconWidget extends ConsumerWidget, build(context, ref) { ... ref.watch(...) }.
//       Consumer dùng khi widget cha không có ref (ví dụ StatelessWidget bọc Consumer). Cả hai
//       đều rebuild khi provider thay đổi; ConsumerWidget gọn hơn khi cả widget đều cần ref.
//
//   Q2. ref.watch(cartProvider.select((state) => state.totalQuantity)) — chỉ totalQuantity thay đổi mới rebuild đúng không?
//   A2. Đúng. select so sánh (state) => state.totalQuantity; chỉ khi totalQuantity đổi thì
//       selector mới coi là thay đổi và rebuild. Các thay đổi khác (ví dụ selectedProductIds)
//       không làm widget này rebuild.
//
//   Q3. onTap chuyển sang tab Giỏ hàng — ai truyền callback, HomeScreen xử lý thế nào?
//   A3. HomeScreen truyền onTap: () => setState(() => _currentIndex = 1). CartIconWidget nhận
//       VoidCallback? onTap; khi tap gọi onTap?.call() → đổi tab sang CartScreen.
//
// -----------------------------------------------------------------------------
// LOGIC TRONG FILE: StatelessWidget, Consumer watch totalQuantity. Icon + badge (99+ nếu > 99).
// -----------------------------------------------------------------------------
// LOGIC TRONG DỰ ÁN: Nằm trên AppBar của HomeScreen; tap chuyển sang tab Giỏ hàng.
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_notifier.dart';

/// CartIconWidget - Icon giỏ hàng + badge tổng số lượng
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
