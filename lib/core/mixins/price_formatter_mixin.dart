// =============================================================================
// PHỎNG VẤN KIẾN THỨC - price_formatter_mixin.dart (Mixin format giá)
// =============================================================================
//
//   Q1. Tại sao format giá bằng mixin thay vì hàm top-level (formatPrice(double))?
//   A1. Cả hai đều được. Mixin gom vào class để widget/notifier gọi this.formatPrice;
//       hàm top-level thì formatPrice(price). Dự án chọn mixin để nhất quán với
//       ValidationMixin và gắn format với UI (widget with mixin).
//
//   Q2. Những widget nào trong dự án dùng PriceFormatterMixin?
//   A2. ProductCardWidget, CartItemWidget, CartTotalWidget, ProductDetailView — tất cả
//       with PriceFormatterMixin và gọi formatPrice(price) / formatPrice(totalPrice).
//
//   Q3. Có thể thay bằng extension (extension on double) không? Ưu/nhược?
//   A3. Có: extension on double { String get formattedPrice => ... }. Gọi: price.formattedPrice.
//       Extension gọn cho type cụ thể; mixin có thể thêm nhiều method và dùng chung với
//       ConsumerWidget. Tùy style dự án.
//
// -----------------------------------------------------------------------------
// LOGIC TRONG FILE: mixin PriceFormatterMixin, formatPrice(double) → "1.000.000 VNĐ".
// -----------------------------------------------------------------------------
// LOGIC TRONG DỰ ÁN: Các widget hiển thị giá (card, giỏ hàng, footer, chi tiết SP) dùng
//   chung format để đồng nhất hiển thị tiền tệ.
// -----------------------------------------------------------------------------

mixin PriceFormatterMixin {
  // Format số tiền thành chuỗi có dấu phân cách hàng nghìn
  // Ví dụ: 1000000 -> "1.000.000 VNĐ"
  String formatPrice(double price) {
    // Làm tròn và chuyển thành int
    final intPrice = price.round();

    // Chuyển thành chuỗi và thêm dấu chấm phân cách
    final priceString = intPrice.toString();
    final buffer = StringBuffer();

    int count = 0;
    for (int i = priceString.length - 1; i >= 0; i--) {
      buffer.write(priceString[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }

    return '${buffer.toString().split('').reversed.join()} VNĐ';
  }
}
