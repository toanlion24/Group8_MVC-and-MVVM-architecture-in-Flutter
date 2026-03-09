// =============================================================================
// PHỎNG VẤN KIẾN THỨC - validation_mixin.dart (Mixin validate)
// =============================================================================
//
//   Q1. Mixin trong Dart là gì? Khác với kế thừa (extends) thế nào?
//   A1. Mixin: thêm method/property vào class bằng 'with', không dùng extends. Một class
//       có thể with nhiều mixin; tránh đa kế thừa. Khác extends: mixin không phải quan hệ
//       "is-a", chỉ "có thêm hành vi".
//
//   Q2. Tại sao dùng mixin thay vì copy hàm isValidQuantity vào CartNotifier?
//   A2. Tái sử dụng: nếu sau này có chỗ khác cần isValidQuantity (ví dụ OrderNotifier)
//       chỉ cần with ValidationMixin. Tránh duplicate, logic validate nằm một chỗ.
//
//   Q3. ValidationMixin phụ thuộc AppConstants — ai import, thứ tự dependency?
//   A3. File này import app_constants. CartNotifier (with ValidationMixin) không cần
//       import AppConstants — mixin đã import. Thứ tự: AppConstants → ValidationMixin
//       → CartNotifier.
//
// -----------------------------------------------------------------------------
// LOGIC TRONG FILE: mixin ValidationMixin, method isValidQuantity(min..max theo AppConstants).
// -----------------------------------------------------------------------------
// LOGIC TRONG DỰ ÁN: CartNotifier with ValidationMixin gọi isValidQuantity khi
//   addToCart / incrementQuantity để không vượt quá maxQuantityPerItem.
// -----------------------------------------------------------------------------

import '../constants/app_constants.dart';

mixin ValidationMixin {
  // Kiểm tra số lượng có hợp lệ không
  bool isValidQuantity(int quantity) {
    return quantity >= AppConstants.minQuantityPerItem &&
        quantity <= AppConstants.maxQuantityPerItem;
  }
}
