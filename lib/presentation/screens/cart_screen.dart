// =============================================================================
// PHỎNG VẤN KIẾN THỨC - cart_screen.dart (Màn hình giỏ hàng)
// =============================================================================
//
//   Q1. ConsumerWidget và Consumer — khi nào dùng từng loại? CartScreen dùng cả ref trong method (_showClearCartDialog).
//   A1. ConsumerWidget: widget có ref trong build. Khi cần ref trong callback (dialog, onPressed)
//       vẫn dùng ref từ parameter build(context, ref). _showClearCartDialog(context, ref) nhận ref
//       để đọc cartProvider.notifier và cartServiceProvider bên trong dialog.
//
//   Q2. ref.watch(cartProvider.select((state) => state.items)) — tại sao dùng nhiều Consumer với select khác nhau?
//   A2. Một Consumer watch items (list), một watch itemCount/totalQuantity/isEmpty cho header.
//       Tách để chỉ phần cần thay đổi mới rebuild: header chỉ rebuild khi count/empty đổi;
//       list chỉ rebuild khi items đổi. Select giảm rebuild không cần thiết.
//
//   Q3. CartTotalWidget cố định ở dưới; list có padding bottom 120 — vì sao?
//   A3. CartTotalWidget có chiều cao cố định (footer). ListView cần padding bottom để nội dung
//       không bị footer che (cuộn đến item cuối vẫn thấy). 120px xấp xỉ chiều cao footer + SafeArea.
//
// -----------------------------------------------------------------------------
// LOGIC TRONG FILE: ConsumerWidget. Column: header (số loại + tổng số, nút Xóa tất cả),
//   Expanded(ListView CartItemWidget), CartTotalWidget. Dialog clear cart có nút Test Service.
// -----------------------------------------------------------------------------
// LOGIC TRONG DỰ ÁN: Tab thứ hai của HomeScreen. Hiển thị giỏ từ cartProvider; thao tác
//   qua CartItemWidget và footer thanh toán / xóa tất cả.
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/cart_service.dart';
import '../providers/cart_notifier.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/cart_total_widget.dart';

/// CartScreen - Màn hình giỏ hàng
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Consumer(
          builder: (context, ref, child) {
            final itemCount = ref.watch(
              cartProvider.select((state) => state.itemCount),
            );
            final totalQuantity = ref.watch(
              cartProvider.select((state) => state.totalQuantity),
            );
            final isEmpty = ref.watch(
              cartProvider.select((state) => state.isEmpty),
            );

            if (isEmpty) {
              return const SizedBox.shrink();
            }

            return Container(
              margin: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$itemCount loại • $totalQuantity sản phẩm',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showClearCartDialog(context, ref),
                    icon: Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    label: Text(
                      'Xóa tất cả',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final items = ref.watch(
                cartProvider.select((state) => state.items),
              );
              if (items.isEmpty) {
                return _buildEmptyCart(context);
              }
              final listContent = ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return CartItemWidget(cartItem: items[index]);
                },
              );
              if (kIsWeb && MediaQuery.of(context).size.width > 800) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: listContent,
                  ),
                );
              }
              return listContent;
            },
          ),
        ),
        const CartTotalWidget(),
      ],
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 80,
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Giỏ hàng trống',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thêm sản phẩm để bắt đầu mua sắm',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Xóa giỏ hàng?'),
        content: const Text(
          'Bạn có chắc muốn xóa tất cả sản phẩm trong giỏ hàng?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(cartProvider.notifier).clearCart();
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Xóa tất cả'),
          ),
          TextButton(
            onPressed: () {
              final service = ref.read(cartServiceProvider);
              service.printCartTotal();
              service.clearCartFromService();
              Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Test CartService')),
                );
              }
            },
            child: const Text('Test Service'),
          ),
        ],
      ),
    );
  }
}
