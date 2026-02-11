import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/cart_notifier.dart';

// Demo Service: Gọi Provider từ bên ngoài Widget
class CartService {
  final Ref ref;

  CartService(this.ref);

  // Method demo: In ra tổng tiền hiện tại trong console
  void printCartTotal() {
    // ref.read() để lấy giá trị hiện tại (không lắng nghe thay đổi)
    final cartState = ref.read(cartProvider);
    debugPrint('Service Log: Current Total Price is \$${cartState.totalPrice}');
  }

  // Method demo: Clear giỏ hàng từ Service
  void clearCartFromService() {
    // ref.read(provider.notifier) để lấy Notifier và gọi hàm
    ref.read(cartProvider.notifier).clearCart();
    debugPrint('Service Log: Cart cleared via Service!');
  }
}

// Provider cho Service này (để dễ dàng inject vào nơi khác nếu cần)
final cartServiceProvider = Provider<CartService>((ref) {
  return CartService(ref);
});
