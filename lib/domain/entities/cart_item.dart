// =============================================================================
// PHỎNG VẤN KIẾN THỨC - cart_item.dart (Domain entity / Item giỏ hàng)
// =============================================================================
//
//   Q1. Entity dùng ProductModel (data) — có vi phạm Clean Architecture không?
//   A1. Chuẩn CA: entity không phụ thuộc model; có layer mapping. Dự án đơn giản, domain
//       dùng luôn ProductModel để tránh duplicate; nếu tách hẳn thì có CartItemEntity(productId,
//       quantity) và map ProductModel → Entity ở repository. Chấp nhận dependency domain→data
//       cho demo.
//
//   Q2. toJson/fromJson dùng ở đâu? CartNotifier lưu giỏ thế nào?
//   A2. CartNotifier._saveCart() gọi state.items.map((item) => item.toJson()), jsonEncode
//       rồi prefs.setString. _loadCart() jsonDecode, map CartItem.fromJson. SharedPreferences
//       chỉ lưu string nên cần serialize list CartItem.
//
//   Q3. copyWith dùng khi nào? Immutable có bắt buộc với Riverpod Notifier không?
//   A3. CartNotifier khi tăng số lượng: currentItems[index] = item.copyWith(quantity: item.quantity + 1).
//       Immutable: mỗi lần đổi tạo object mới, state = state.copyWith(items: newList). Riverpod
//       so sánh state cũ/mới để quyết định rebuild; immutable giúp so sánh đúng.
//
// -----------------------------------------------------------------------------
// LOGIC TRONG FILE: CartItem(product, quantity), totalPrice, copyWith, toJson, fromJson.
// -----------------------------------------------------------------------------
// LOGIC TRONG DỰ ÁN: CartState.items là List<CartItem>. CartNotifier load/save qua JSON;
//   CartItemWidget nhận cartItem để hiển thị và gọi notifier increment/decrement/remove.
// -----------------------------------------------------------------------------

import '../../data/models/product_model.dart';

/// CartItem - Entity: một dòng trong giỏ (product + quantity)
class CartItem {
  final ProductModel product;
  final int quantity;

  const CartItem({required this.product, this.quantity = 1});

  // Tính tổng tiền của item này
  double get totalPrice => product.price * quantity;

  // Tạo bản sao mới với các giá trị thay đổi (Immutability)
  CartItem copyWith({ProductModel? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  // ============================================
  // JSON SERIALIZATION - Để lưu vào SharedPreferences
  // ============================================

  // Chuyển đổi thành JSON
  Map<String, dynamic> toJson() {
    return {'product': product.toJson(), 'quantity': quantity};
  }

  // Factory constructor để tạo từ JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }
}
