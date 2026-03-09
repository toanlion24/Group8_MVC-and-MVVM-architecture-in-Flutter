// =============================================================================
// PHỎNG VẤN KIẾN THỨC - product_card_widget.dart (Card một sản phẩm trong list)
// =============================================================================
//
//   Q1. onTap mở ProductDetailView(productId) — truyền id thay vì ProductModel vì sao?
//   A1. Truyền id: màn chi tiết tự load (FutureProvider.family(productId)), có loading/error.
//       Nếu truyền ProductModel thì không cần load nhưng không có fullDescription từ "server"
//       và không thống nhất với luồng async. Chi tiết cần id để ref.watch(productDetailViewModelProvider(productId)).
//
//   Q2. Hero(tag: 'product_${product.id}') — Hero dùng để làm gì khi chuyển màn?
//   A2. Hero dùng cho transition: ảnh từ card "bay" sang ảnh trên màn chi tiết (cùng tag).
//       Flutter tự animate vị trí/kích thước. Tag phải unique (product.id).
//
//   Q3. ref.read(cartProvider.notifier).addToCart(product) — read không watch, có rebuild khi giỏ đổi không?
//   A3. addToCart chỉ gọi action, không subscribe. Widget đã ref.watch(cartProvider.select(...))
//       isInCart và quantityInCart — khi notifier thay đổi state, những watch đó rebuild
//       widget. read chỉ để gọi notifier.addToCart; rebuild do watch đảm nhiệm.
//
// -----------------------------------------------------------------------------
// LOGIC TRONG FILE: ConsumerWidget + PriceFormatterMixin. Watch isInCart, quantityInCart.
//   Card: ảnh Hero, tên, category, giá, nút Thêm vào giỏ. onTap → ProductDetailView(product.id).
// -----------------------------------------------------------------------------
// LOGIC TRONG DỰ ÁN: Dùng trong ProductListScreen SliverGrid. Mỗi card một ProductModel từ Repository.
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/mixins/price_formatter_mixin.dart';
import '../../data/models/product_model.dart';
import '../../features/product_detail/views/product_detail_view.dart';
import '../providers/cart_notifier.dart';

/// ProductCardWidget - Card hiển thị một sản phẩm trong danh sách
class ProductCardWidget extends ConsumerWidget with PriceFormatterMixin {
  final ProductModel product;

  const ProductCardWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInCart = ref.watch(
      cartProvider.select((state) => state.isInCart(product.id)),
    );
    final quantityInCart = ref.watch(
      cartProvider.select((state) => state.getQuantity(product.id)),
    );
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailView(productId: product.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Container(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'product_${product.id}',
                      child: Image.asset(
                        product.imageUrl,
                        fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 48,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      ),
                    ),
                    if (isInCart)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            'x$quantityInCart',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
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
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            product.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.category,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatPrice(product.price),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          ref.read(cartProvider.notifier).addToCart(product);
                        },
                        icon: Icon(
                          isInCart ? Icons.add : Icons.add_shopping_cart_rounded,
                          size: 18,
                        ),
                        label: Text(isInCart ? 'Thêm nữa' : 'Thêm vào giỏ'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
