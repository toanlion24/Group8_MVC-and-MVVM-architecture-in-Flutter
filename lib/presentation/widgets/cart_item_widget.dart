import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/mixins/price_formatter_mixin.dart';
import '../../domain/entities/cart_item.dart';
import '../providers/cart_notifier.dart';

// CartItemWidget - Widget hiển thị một item trong giỏ hàng
// Sử dụng ConsumerWidget để tương tác với Riverpod
class CartItemWidget extends ConsumerWidget with PriceFormatterMixin {
  final CartItem cartItem;

  const CartItemWidget({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Kiểm tra sản phẩm có đang được chọn không
    // Sử dụng ref.watch với select để chỉ rebuild khi trạng thái select của item này thay đổi
    final isSelected = ref.watch(
      cartProvider.select(
        (state) => state.isProductSelected(cartItem.product.id),
      ),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      // Highlight khi được chọn
      color: isSelected ? Colors.blue.shade50 : null,
      child: InkWell(
        // Tap để chọn/bỏ chọn
        onTap: () {
          ref
              .read(cartProvider.notifier)
              .toggleSelectProduct(cartItem.product.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Checkbox chọn sản phẩm
              Checkbox(
                value: isSelected,
                onChanged: (_) {
                  ref
                      .read(cartProvider.notifier)
                      .toggleSelectProduct(cartItem.product.id);
                },
              ),

              // Hình ảnh sản phẩm
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    cartItem.product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image, color: Colors.grey);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Thông tin sản phẩm
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên sản phẩm
                    Text(
                      cartItem.product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Giá đơn vị
                    Text(
                      formatPrice(cartItem.product.price),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Tổng tiền item
                    Text(
                      formatPrice(cartItem.totalPrice),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Điều chỉnh số lượng
              Column(
                children: [
                  // Nút xóa
                  IconButton(
                    onPressed: () {
                      ref
                          .read(cartProvider.notifier)
                          .removeFromCart(cartItem.product.id);
                    },
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                    iconSize: 20,
                  ),

                  // Điều chỉnh số lượng
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Nút giảm
                        IconButton(
                          onPressed: () {
                            ref
                                .read(cartProvider.notifier)
                                .decrementQuantity(cartItem.product.id);
                          },
                          icon: const Icon(Icons.remove),
                          iconSize: 18,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),

                        // Số lượng
                        Container(
                          constraints: const BoxConstraints(minWidth: 32),
                          child: Text(
                            '${cartItem.quantity}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),

                        // Nút tăng
                        IconButton(
                          onPressed: () {
                            ref
                                .read(cartProvider.notifier)
                                .incrementQuantity(cartItem.product.id);
                          },
                          icon: const Icon(Icons.add),
                          iconSize: 18,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
