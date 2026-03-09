// =============================================================================
// PHỎNG VẤN KIẾN THỨC - product_detail_service.dart (Service chi tiết sản phẩm)
// =============================================================================
//
//   Q1. ProductDetailService nhận ProductRepository? optional — khi nào inject, khi nào dùng mặc định?
//   A1. Constructor: ProductDetailService({ProductRepository? repository}) : _repository = repository ?? ProductRepository().
//       Test có thể truyền mock repository. Production (ref đọc serviceProvider) không truyền
//       → dùng ProductRepository() mặc định. Inject khi cần (test, nhiều nguồn).
//
//   Q2. Future.delayed(300) — mục đích? Có ảnh hưởng test không?
//   A2. Giả lập độ trễ mạng; user thấy loading ngắn. Test có thể mock service hoặc dùng Fake
//       không delay. Ảnh hưởng test nếu test chờ kết quả thật — nên mock hoặc inject repo trả ngay.
//
//   Q3. Service không dùng Riverpod ref — ViewModel mới ref.read(serviceProvider). Đúng kiến trúc không?
//   A3. Đúng. Service là plain class; Riverpod Provider tạo instance (productDetailServiceProvider).
//       ViewModel (FutureProvider) ref.read(serviceProvider).getProductById(productId). Service
//       không cần ref; chỉ Repository/DataSource.
//
// -----------------------------------------------------------------------------
// LOGIC TRONG FILE: ProductDetailService(repository?). getProductById(id): delay 300ms,
//   return _repository.getProductById(id).
// -----------------------------------------------------------------------------
// LOGIC TRONG DỰ ÁN: productDetailViewModelProvider gọi service.getProductById; View
//   watch viewModelProvider(productId) → AsyncValue<ProductModel?>.
// -----------------------------------------------------------------------------

import 'package:flutter_application_2/data/models/product_model.dart';
import 'package:flutter_application_2/data/repositories/product_repository.dart';

/// ProductDetailService - Service lấy chi tiết sản phẩm (dùng Repository)
class ProductDetailService {
  ProductDetailService({ProductRepository? repository})
      : _repository = repository ?? ProductRepository();

  final ProductRepository _repository;

  /// Lấy chi tiết sản phẩm theo ID
  /// Trả về null nếu không tìm thấy
  Future<ProductModel?> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Giả lập network
    return _repository.getProductById(id);
  }
}
