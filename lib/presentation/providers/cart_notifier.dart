// =============================================================================
// PHỎNG VẤN KIẾN THỨC - cart_notifier.dart (Riverpod state giỏ hàng)
// =============================================================================
//
//   Q1. Notifier<CartState> khác ChangeNotifier thế nào? Tại sao dùng Notifier?
//   A1. Notifier là API Riverpod 2.x: build() trả state khởi tạo, methods đổi state trực tiếp.
//       ChangeNotifier là từ Flutter, phải notifyListeners(). Notifier gọn, tích hợp ref,
//       autoDispose, test dễ hơn.
//
//   Q2. build() return state ban đầu và gọi _loadCart() — _loadCart async, state có kịp cập nhật không?
//   A2. build() return state isLoading: true; _loadCart() chạy async, khi xong set state =
//       copyWith(items: loaded, isLoading: false). Widget watch cartProvider sẽ rebuild khi
//       state đổi, nên lúc load xong UI nhận items. Đúng thứ tự.
//
//   Q3. ref.watch(cartProvider.select((s) => s.totalQuantity)) — select có tác dụng gì?
//   A3. select: chỉ rebuild khi phần được chọn thay đổi. totalQuantity thay đổi khi items/quantity
//       đổi; nếu chỉ watch totalQuantity thì không rebuild khi selectedProductIds đổi. Giảm rebuild.
//
//   Q4. CartState có selectedProductIds — trong UI có dùng cho thanh toán từng phần không?
//   A4. CartItemWidget dùng isProductSelected để tô nền; toggleSelectProduct có. Hiện thanh toán
//       dùng totalPrice toàn giỏ (fold tất cả items). Có thể mở rộng: chỉ tính totalPrice cho
//       item có id trong selectedProductIds.
//
// -----------------------------------------------------------------------------
// LOGIC TRONG FILE: CartState (items, selectedProductIds, isLoading, getters). CartNotifier
//   with ValidationMixin: build, _loadCart, _saveCart, add/remove/increment/decrement/toggle/clear.
//   cartProvider = NotifierProvider<CartNotifier, CartState>.
// -----------------------------------------------------------------------------
// LOGIC TRONG DỰ ÁN: Toàn app giỏ hàng dùng cartProvider. Widgets watch/read; CartNotifier
//   persist qua SharedPreferences, load lúc khởi tạo.
// -----------------------------------------------------------------------------

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/mixins/validation_mixin.dart';
import '../../data/models/product_model.dart';
import '../../domain/entities/cart_item.dart';

// ============================================
// STATE
// ============================================

class CartState {
  final List<CartItem> items;
  final Set<String> selectedProductIds;
  final bool isLoading;

  const CartState({
    this.items = const [],
    this.selectedProductIds = const {},
    this.isLoading = true,
  });

  CartState copyWith({
    List<CartItem>? items,
    Set<String>? selectedProductIds,
    bool? isLoading,
  }) {
    return CartState(
      items: items ?? this.items,
      selectedProductIds: selectedProductIds ?? this.selectedProductIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  // Getters cho UI
  int get totalQuantity {
    if (items.isEmpty) return 0;
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalPrice {
    if (items.isEmpty) return 0;
    // Tính tổng tiền của TẤT CẢ item trong giỏ (giống logic cũ Consumer)
    // Nếu muốn tính chỉ những item ĐƯỢC CHỌN, thì filter trước.
    // Logic cũ: totalPrice là tổng tất cả.
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get itemCount => items.length;

  bool get isEmpty => items.isEmpty;

  bool isProductSelected(String productId) =>
      selectedProductIds.contains(productId);

  bool isInCart(String productId) {
    return items.any((item) => item.product.id == productId);
  }

  int getQuantity(String productId) {
    var item = items.where((item) => item.product.id == productId).firstOrNull;
    return item?.quantity ?? 0;
  }
}

// ============================================
// NOTIFIER
// ============================================

class CartNotifier extends Notifier<CartState> with ValidationMixin {
  static const String _cartKey = 'cart_items';

  @override
  CartState build() {
    // Khởi tạo state ban đầu
    // Load data async sau khi build xong
    _loadCart();
    return const CartState(isLoading: true);
  }

  // Load từ Storage
  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);

      List<CartItem> items = [];
      if (cartJson != null && cartJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(cartJson);
        items = decoded
            .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      debugPrint('Error loading cart: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  // Lưu vào Storage
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = state.items.map((item) => item.toJson()).toList();
      await prefs.setString(_cartKey, jsonEncode(itemsJson));
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  // Thêm sản phẩm
  void addToCart(ProductModel product) {
    // Clone list để đảm bảo immutability tuyệt đối
    final currentItems = List<CartItem>.from(state.items);
    final index = currentItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (index != -1) {
      // Tăng số lượng
      final item = currentItems[index];
      if (isValidQuantity(item.quantity + 1)) {
        currentItems[index] = item.copyWith(quantity: item.quantity + 1);
      }
    } else {
      // Thêm mới
      currentItems.add(CartItem(product: product));
    }

    state = state.copyWith(items: currentItems);
    _saveCart();
  }

  // Xóa sản phẩm
  void removeFromCart(String productId) {
    final currentItems = List<CartItem>.from(state.items);
    currentItems.removeWhere((item) => item.product.id == productId);

    final currentSelected = Set<String>.from(state.selectedProductIds);
    currentSelected.remove(productId);

    state = state.copyWith(
      items: currentItems,
      selectedProductIds: currentSelected,
    );
    _saveCart();
  }

  // Tăng/Giảm số lượng
  void incrementQuantity(String productId) {
    final currentItems = List<CartItem>.from(state.items);
    final index = currentItems.indexWhere(
      (item) => item.product.id == productId,
    );

    if (index != -1) {
      final item = currentItems[index];
      if (isValidQuantity(item.quantity + 1)) {
        currentItems[index] = item.copyWith(quantity: item.quantity + 1);
        state = state.copyWith(items: currentItems);
        _saveCart();
      }
    }
  }

  void decrementQuantity(String productId) {
    final currentItems = List<CartItem>.from(state.items);
    final index = currentItems.indexWhere(
      (item) => item.product.id == productId,
    );

    if (index != -1) {
      final item = currentItems[index];
      if (item.quantity > 1) {
        currentItems[index] = item.copyWith(quantity: item.quantity - 1);
        state = state.copyWith(items: currentItems);
        _saveCart();
      } else {
        removeFromCart(productId);
      }
    }
  }

  // Toggle select
  void toggleSelectProduct(String productId) {
    final currentSelected = Set<String>.from(state.selectedProductIds);
    if (currentSelected.contains(productId)) {
      currentSelected.remove(productId);
    } else {
      currentSelected.add(productId);
    }
    state = state.copyWith(selectedProductIds: currentSelected);
  }

  void clearCart() {
    state = state.copyWith(items: [], selectedProductIds: {});
    _saveCart();
  }
}

// ============================================
// PROVIDER
// ============================================

final cartProvider = NotifierProvider<CartNotifier, CartState>(() {
  return CartNotifier();
});
