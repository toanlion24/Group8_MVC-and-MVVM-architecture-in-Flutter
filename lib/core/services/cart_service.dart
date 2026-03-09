// =============================================================================
// PHỎNG VẤN KIẾN THỨC - cart_service.dart (Service gọi Riverpod ngoài Widget)
// =============================================================================
//
//   Q1. CartService nhận Ref ref — Ref là gì? Tại sao không truyền WidgetRef?
//   A1. Ref (từ Riverpod) là interface để read/watch provider, có trong ProviderScope. WidgetRef
//       chỉ có trong context widget (Consumer, ConsumerWidget). Service/class không có
//       BuildContext nên nhận Ref do Provider cung cấp: cartServiceProvider nhận (ref) => CartService(ref).
//
//   Q2. ref.read(cartProvider) và ref.watch(cartProvider) khác nhau thế nào? Service dùng read vì sao?
//   A2. read: lấy giá trị hiện tại, không subscribe — khi state đổi service không rebuild. watch:
//       subscribe, state đổi thì listener rebuild. Service chỉ cần đọc hoặc gửi lệnh (clearCart)
//       một lần, không cần rebuild → dùng read.
//
//   Q3. Trong dự án CartService được gọi ở đâu? Có bắt buộc phải có không?
//   A3. CartScreen: trong dialog "Xóa tất cả" có nút "Test Service" gọi
//       ref.read(cartServiceProvider).printCartTotal() và clearCartFromService(). Demo để
//       minh họa gọi Riverpod từ layer không phải widget; không bắt buộc cho tính năng chính.
//
// -----------------------------------------------------------------------------
// LOGIC TRONG FILE: CartService(ref): printCartTotal (read cart, in log), clearCartFromService
//   (notifier.clearCart). cartServiceProvider = Provider<CartService>.
// -----------------------------------------------------------------------------
// LOGIC TRONG DỰ ÁN: Dùng trong CartScreen dialog; chứng tỏ có thể thao tác giỏ hàng
//   từ service/lớp bên ngoài nếu có Ref.
// -----------------------------------------------------------------------------

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/cart_notifier.dart';

/// Demo Service: Gọi Provider từ bên ngoài Widget
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
