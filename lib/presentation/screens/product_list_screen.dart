import 'package:flutter/material.dart';
import '../../data/repositories/product_repository.dart';
import '../widgets/product_card_widget.dart';

// ProductListScreen - Màn hình danh sách sản phẩm
//
// Hiển thị danh sách sản phẩm từ ProductRepository
// Mỗi sản phẩm được hiển thị bằng ProductCardWidget
class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy danh sách sản phẩm từ repository
    final productRepository = ProductRepository();
    final products = productRepository.getAllProducts();

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              Icon(
                Icons.local_offer,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Có ${products.length} sản phẩm',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),

        // Danh sách sản phẩm dạng Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.55, // Taller card to fit content
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCardWidget(product: products[index]);
            },
          ),
        ),
      ],
    );
  }
}
