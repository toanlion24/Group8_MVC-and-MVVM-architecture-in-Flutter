import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/mixins/price_formatter_mixin.dart';
import '../../data/models/product_model.dart';
import '../providers/cart_notifier.dart';

// ProductCardWidget - Card hiển thị sản phẩm
//
// Sử dụng ConsumerWidget để tương tác với Riverpod
class ProductCardWidget extends ConsumerWidget with PriceFormatterMixin {
  final ProductModel product;

  const ProductCardWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch: Lắng nghe thay đổi để cập nhật UI (nút đã thêm/chưa)
    // Tối ưu: Chỉ rebuild khi trạng thái "có trong giỏ" hoặc "số lượng" thay đổi
    final isInCart = ref.watch(
      cartProvider.select((state) => state.isInCart(product.id)),
    );
    final quantityInCart = ref.watch(
      cartProvider.select((state) => state.getQuantity(product.id)),
    );

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hình ảnh sản phẩm
          AspectRatio(
            aspectRatio: 1.25,
            child: Container(
              color: Colors.grey.shade200,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Hiển thị ảnh sản phẩm từ assets
                  ClipRRect(
                    child: Image.asset(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image,
                          size: 48,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),

                  // Badge số lượng trong giỏ
                  if (isInCart)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'x$quantityInCart',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Thông tin sản phẩm
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên sản phẩm
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Danh mục
                Text(
                  product.category,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),

                // Giá tiền (sử dụng PriceFormatterMixin)
                Text(
                  formatPrice(product.price),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),

                // Nút thêm vào giỏ
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // ref.read: Chỉ gọi method, không lắng nghe thay đổi
                      ref.read(cartProvider.notifier).addToCart(product);
                    },
                    icon: Icon(isInCart ? Icons.add : Icons.add_shopping_cart),
                    label: Text(isInCart ? 'Thêm nữa' : 'Thêm'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isInCart
                          ? Colors.green
                          : Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
