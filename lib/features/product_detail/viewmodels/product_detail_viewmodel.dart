// =============================================================================
// PHỎNG VẤN KIẾN THỨC - product_detail_viewmodel.dart (ViewModel = FutureProvider)
// =============================================================================
//
// CÂU HỎI:
//   Q1. FutureProvider.autoDispose.family<ProductModel?, String> — autoDispose và family nghĩa là gì?
//   A1. family: provider nhận tham số (productId); mỗi productId một cache riêng.
//       ref.watch(productDetailViewModelProvider('p001')) và provider('p002') là hai future khác nhau.
//       autoDispose: khi không còn listener (rời màn chi tiết), provider dispose và lần vào lại
//       sẽ fetch lại. Tiết kiệm bộ nhớ.
//
//   Q2. ViewModel trong MVVM thường là class — ở đây chỉ là provider. Có coi là ViewModel không?
//   A2. Có. ViewModel = nguồn state cho View. Ở đây state là AsyncValue<ProductModel?> từ
//       FutureProvider; "logic" là gọi service.getProductById. Không cần class riêng vì
//       Riverpod đã đóng vai trò holder state + trigger fetch.
//
//   Q3. productId.isEmpty return null — View xử lý null thế nào?
//   A3. ProductDetailView: asyncProduct.when(data: (product) => product == null ? _buildNotFound : _buildContent).
//       null khi id không tồn tại hoặc id empty; hiển thị màn "Không tìm thấy sản phẩm".
//
// -----------------------------------------------------------------------------
// LOGIC TRONG FILE: productDetailServiceProvider = Provider<ProductDetailService>.
//   productDetailViewModelProvider = FutureProvider.autoDispose.family: (productId) => service.getProductById(productId).
// -----------------------------------------------------------------------------
// LOGIC TRONG DỰ ÁN: ProductDetailView watch productDetailViewModelProvider(productId);
//   when(loading/data/error) để hiển thị loading, nội dung, hoặc lỗi.
// -----------------------------------------------------------------------------

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../services/product_detail_service.dart';

final productDetailServiceProvider = Provider<ProductDetailService>((ref) {
  return ProductDetailService();
});

final productDetailViewModelProvider =
    FutureProvider.autoDispose.family<ProductModel?, String>((ref, productId) async {
  if (productId.isEmpty) return null;
  return ref.read(productDetailServiceProvider).getProductById(productId);
});
