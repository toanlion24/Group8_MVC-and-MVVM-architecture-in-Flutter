// =============================================================================
// PHỎNG VẤN KIẾN THỨC - app_constants.dart (Hằng số dùng chung)
// =============================================================================
//
//   Q1. Tại sao dùng class + static const thay vì file toàn hằng số (const int x = 1)?
//   A1. Gom hằng số vào một class giúp namespace (AppConstants.maxQuantityPerItem), dễ tìm
//       và refactor. Có thể dùng file chỉ toàn const; class + static phù hợp khi muốn nhóm
//       nhiều constant và tránh tạo instance.
//
//   Q2. AppConstants._() private constructor — mục đích là gì?
//   A2. Constructor private (_()) để không ai gọi AppConstants() — class chỉ dùng như container
//       cho static members (utility/constants only). Nếu không private thì có thể vô tình tạo
//       instance vô nghĩa.
//
//   Q3. maxQuantityPerItem / minQuantityPerItem được dùng ở đâu trong dự án?
//   A3. ValidationMixin dùng: isValidQuantity(quantity) so sánh với AppConstants.minQuantityPerItem
//       và maxQuantityPerItem. CartNotifier (with ValidationMixin) gọi isValidQuantity khi
//       addToCart / incrementQuantity để giới hạn số lượng mỗi sản phẩm trong giỏ.
//
// -----------------------------------------------------------------------------
// LOGIC TRONG FILE: Class chỉ chứa static const (max 99, min 1 cho số lượng item).
// -----------------------------------------------------------------------------
// LOGIC TRONG DỰ ÁN: Core/constants — được import bởi ValidationMixin → CartNotifier
//   dùng khi tăng số lượng trong giỏ (không vượt 99, không dưới 1).
// -----------------------------------------------------------------------------

class AppConstants {
  // Ngăn không cho tạo instance
  AppConstants._();

  static const int maxQuantityPerItem = 99;
  static const int minQuantityPerItem = 1;
}
