import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/mixins/price_formatter_mixin.dart';
import '../../domain/entities/cart_item.dart';
import '../providers/cart_notifier.dart';

// CartItemWidget - Widget hiển thị một item trong giỏ hàng
class CartItemWidget extends ConsumerWidget with PriceFormatterMixin {
  final CartItem cartItem;

  const CartItemWidget({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(
      cartProvider.select(
        (state) => state.isProductSelected(cartItem.product.id),
      ),
    );
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      color: isSelected ? theme.colorScheme.primaryContainer.withOpacity(0.4) : null,
      child: InkWell(
        onTap: () {
          ref.read(cartProvider.notifier).toggleSelectProduct(cartItem.product.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (_) {
                  ref.read(cartProvider.notifier).toggleSelectProduct(cartItem.product.id);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    cartItem.product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.image_outlined,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cartItem.product.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatPrice(cartItem.product.price),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatPrice(cartItem.totalPrice),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    onPressed: () {
                      ref.read(cartProvider.notifier).removeFromCart(cartItem.product.id);
                    },
                    icon: const Icon(Icons.delete_outline),
                    color: theme.colorScheme.error,
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.errorContainer.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            ref.read(cartProvider.notifier).decrementQuantity(cartItem.product.id);
                          },
                          icon: const Icon(Icons.remove, size: 18),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                        SizedBox(
                          width: 32,
                          child: Text(
                            '${cartItem.quantity}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            ref.read(cartProvider.notifier).incrementQuantity(cartItem.product.id);
                          },
                          icon: const Icon(Icons.add, size: 18),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
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
