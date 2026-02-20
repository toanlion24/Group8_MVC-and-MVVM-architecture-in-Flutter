import 'package:flutter_application_2/data/models/product_model.dart';
import 'package:flutter_application_2/data/repositories/product_repository.dart';

/// ProductDetailService - Service layer cho Product Detail
///
/// ViewModel gọi Service để lấy dữ liệu.
/// Service sử dụng Repository để truy xuất data.
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
