// =============================================================================
// PHỎNG VẤN KIẾN THỨC - product_detail_view.dart (Màn chi tiết sản phẩm)
// =============================================================================
//
//   Q1. asyncProduct.when(loading, data, error) — khi nào data nhận null?
//   A1. Khi FutureProvider trả về null: productId không có trong datasource hoặc productId.isEmpty.
//       View kiểm tra data: (product) => product == null ? _buildNotFound(context) : _buildContent(...).
//
//   Q2. ref.watch(cartProvider.select(...)) isInCart, quantity — màn chi tiết cũng cần đồng bộ với giỏ?
//   A2. Có. Nút "Thêm vào giỏ" và text "Đã có x trong giỏ" cần isInCart và quantity từ cartProvider.
//       Watch để khi user thêm từ màn khác hoặc từ chính màn này, UI cập nhật (số lượng, nhãn nút).
//
//   Q3. Hero tag 'product_${product.id}' trùng với ProductCardWidget — transition hoạt động thế nào?
//   A3. Cùng tag trên hai màn: ProductCardWidget (danh sách) và ProductDetailView (chi tiết). Khi
//       push màn chi tiết, Flutter tìm Hero cùng tag ở destination và animate ảnh từ vị trí card
//       sang vị trí app bar. Pop lại cũng có transition ngược.
//
// -----------------------------------------------------------------------------
// LOGIC TRONG FILE: ConsumerWidget + PriceFormatterMixin. watch productDetailViewModelProvider(productId),
//   when(loading/data/error). data: null → notFound; else SliverAppBar + Hero + nội dung + nút Thêm vào giỏ.
// -----------------------------------------------------------------------------
// LOGIC TRONG DỰ ÁN: Mở từ ProductCardWidget (tap card). Hiển thị chi tiết từ Repository qua
//   Service/ViewModel; có thể thêm vào giỏ từ màn này.
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/mixins/price_formatter_mixin.dart';
import '../../../presentation/providers/cart_notifier.dart';
import '../models/product_model.dart';
import '../viewmodels/product_detail_viewmodel.dart';

/// ProductDetailView - Màn hình chi tiết sản phẩm
class ProductDetailView extends ConsumerWidget with PriceFormatterMixin {
  const ProductDetailView({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProduct = ref.watch(productDetailViewModelProvider(productId));

    return Scaffold(
      body: asyncProduct.when(
        data: (product) {
          if (product == null) {
            return _buildNotFound(context);
          }
          return _buildContent(context, ref, product);
        },
        loading: () => _buildLoading(context),
        error: (err, stack) => _buildError(context, err),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Đang tải sản phẩm...',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ProductModel product,
  ) {
    final theme = Theme.of(context);
    final isInCart = ref.watch(
      cartProvider.select((s) => s.isInCart(product.id)),
    );
    final quantity = ref.watch(
      cartProvider.select((s) => s.getQuantity(product.id)),
    );
    final maxWidth = kIsWeb && MediaQuery.of(context).size.width > 800 ? 600.0 : double.infinity;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          backgroundColor: theme.colorScheme.surface,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: theme.colorScheme.onSurface,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Hero(
              tag: 'product_${product.id}',
              child: Container(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                child: Image.asset(
                  product.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 80,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Danh mục
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        product.category,
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tên sản phẩm
                    Text(
                      product.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Giá - nổi bật
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primaryContainer.withOpacity(0.5),
                            theme.colorScheme.primaryContainer.withOpacity(0.2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Giá',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatPrice(product.price),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          if (isInCart)
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 18,
                                      color: Colors.green.shade700,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'Đã có $quantity trong giỏ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green.shade700,
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Mô tả ngắn
                    Text(
                      product.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),

                    // Thông số chi tiết
                    if (product.fullDescription != null &&
                        product.fullDescription!.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Icon(
                            Icons.checklist_rounded,
                            size: 22,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Thông số chi tiết',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant.withOpacity(0.4),
                          ),
                        ),
                        child: _buildDetailText(
                          theme,
                          product.fullDescription!.trim(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),

                    // Nút thêm vào giỏ
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          ref.read(cartProvider.notifier).addToCart(product);
                        },
                        icon: Icon(
                          isInCart ? Icons.add_rounded : Icons.add_shopping_cart_rounded,
                          size: 22,
                        ),
                        label: Text(
                          isInCart
                              ? 'Thêm nữa ($quantity trong giỏ)'
                              : 'Thêm vào giỏ hàng',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailText(ThemeData theme, String text) {
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final isBullet = line.trim().startsWith('•');
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isBullet) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 6, right: 10),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    line.trim().replaceFirst('•', '').trim(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.6,
                      fontSize: 14,
                    ),
                  ),
                ),
              ] else
                Expanded(
                  child: Text(
                    line.trim(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.6,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy sản phẩm',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Quay lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Có lỗi xảy ra',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }
}
