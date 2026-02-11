import '../../data/models/product_model.dart';

// CartItem - Entity đại diện cho một item trong giỏ hàng
//
// Entity thuộc Domain Layer trong Clean Architecture
// Chứa business logic liên quan đến item trong giỏ
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
