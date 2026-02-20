import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../data/repositories/product_repository.dart';
import '../widgets/product_card_widget.dart';

// ProductListScreen - Màn hình danh sách sản phẩm
class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  int _crossAxisCount(double width) {
    if (width >= 1200 || (kIsWeb && width >= 900)) return 4;
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final productRepository = ProductRepository();
    final products = productRepository.getAllProducts();
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = _crossAxisCount(width);
    final padding = width >= 600 ? 24.0 : 16.0;

    // Giới hạn max width trên màn hình rộng (web) để dễ đọc
    final maxWidth = kIsWeb && width > 1400 ? 1200.0 : double.infinity;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: CustomScrollView(
          slivers: [
        SliverToBoxAdapter(
          child: Container(
            margin: EdgeInsets.fromLTRB(padding, 20, padding, 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer.withOpacity(0.6),
                  Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Khám phá sản phẩm',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${products.length} sản phẩm có sẵn',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.52,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => ProductCardWidget(product: products[index]),
              childCount: products.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
        ),
      ),
    );
  }
}
