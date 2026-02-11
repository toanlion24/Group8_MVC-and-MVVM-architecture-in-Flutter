import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/cart_service.dart';
import '../providers/cart_notifier.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/cart_total_widget.dart';

// CartScreen - Màn hình giỏ hàng
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header hiển thị số loại sản phẩm (Sử dụng Consumer)
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

            return Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_bag,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEmpty
                        ? 'Giỏ hàng trống'
                        : '$itemCount loại sản phẩm ($totalQuantity items)',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  if (!isEmpty)
                    TextButton.icon(
                      onPressed: () {
                        _showClearCartDialog(context, ref);
                      },
                      icon: const Icon(Icons.delete_sweep, size: 18),
                      label: const Text('Xóa tất cả'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                ],
              ),
            );
          },
        ),

        // Danh sách sản phẩm trong giỏ
        Expanded(
          // Sử dụng Consumer để lắng nghe list items
          child: Consumer(
            builder: (context, ref, child) {
              final items = ref.watch(
                cartProvider.select((state) => state.items),
              );

              if (items.isEmpty) {
                return _buildEmptyCart();
              }

              return ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return CartItemWidget(cartItem: items[index]);
                },
              );
            },
          ),
        ),

        // Footer hiển thị tổng tiền
        const CartTotalWidget(),
      ],
    );
  }

  // Widget hiển thị khi giỏ hàng trống
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Giỏ hàng của bạn đang trống',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thêm sản phẩm vào giỏ hàng',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // Dialog xác nhận xóa tất cả
  void _showClearCartDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa giỏ hàng'),
        content: const Text(
          'Bạn có chắc muốn xóa tất cả sản phẩm trong giỏ hàng?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // Gọi method clearCart
              ref.read(cartProvider.notifier).clearCart();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa tất cả'),
          ),
          // DEMO Service Button
          TextButton(
            onPressed: () {
              // Demo usage of CartService
              // This shows how to access provider logic via a service
              final service = ref.read(cartServiceProvider);
              service.printCartTotal();
              service.clearCartFromService();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Called CartService! Check console.'),
                ),
              );
            },
            child: const Text('Test Service (Logs)'),
          ),
        ],
      ),
    );
  }
}
