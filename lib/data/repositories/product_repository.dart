import '../datasources/fake_product_datasource.dart';
import '../models/product_model.dart';

// ProductRepository - Repository Pattern
//
// Repository đóng vai trò trung gian giữa Data Source và Domain Layer
// Giúp tách biệt logic lấy dữ liệu với business logic
class ProductRepository {
  // Lấy tất cả sản phẩm
  List<ProductModel> getAllProducts() {
    return FakeProductDataSource.getProducts();
  }

  // Lấy chi tiết sản phẩm theo ID
  ProductModel? getProductById(String id) {
    final products = FakeProductDataSource.getProducts();
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
