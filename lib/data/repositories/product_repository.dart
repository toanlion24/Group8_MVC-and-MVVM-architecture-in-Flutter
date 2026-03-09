// =============================================================================
// PHỎNG VẤN KIẾN THỨC - product_repository.dart (Repository sản phẩm)
// =============================================================================
//
//   Q1. ProductListScreen tạo ProductRepository() trực tiếp — có nên inject từ Riverpod không?
//   A1. Nên: Provider<ProductRepository>((ref) => ProductRepository()) rồi ref.read trong
//       screen hoặc trong ProductDetailService. Inject giúp test (mock repo) và đổi nguồn
//       một chỗ. Hiện tại new ProductRepository() vẫn được vì repo không giữ state.
//
//   Q2. getProductById trả ProductModel? — ai xử lý null?
//   A2. ProductDetailService.getProductById gọi repository, trả Future<ProductModel?>. View
//       (ProductDetailView) asyncProduct.when(data: (product) => product == null ? notFound : content).
//
//   Q3. Repository có async không? ProductDetailService lại gọi async getProductById?
//   A3. Repository hiện tại sync (getProducts, getProductById gọi list trực tiếp). Service
//       bọc trong Future + delay để giả lập mạng; nếu sau này Repository gọi API thì
//       getProductById sẽ async và Service chỉ await.
//
// -----------------------------------------------------------------------------
// LOGIC TRONG FILE: getAllProducts() → FakeProductDataSource.getProducts();
//   getProductById(id) → firstWhere hoặc null.
// -----------------------------------------------------------------------------
// LOGIC TRONG DỰ ÁN: ProductListScreen gọi getAllProducts; ProductDetailService gọi
//   getProductById. Một nguồn duy nhất cho dữ liệu sản phẩm.
// -----------------------------------------------------------------------------

import '../datasources/fake_product_datasource.dart';
import '../models/product_model.dart';

/// ProductRepository - Trung gian giữa Data Source và UI/Service
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
