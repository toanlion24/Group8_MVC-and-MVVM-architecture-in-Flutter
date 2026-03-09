// =============================================================================
// PHỎNG VẤN KIẾN THỨC - product_model.dart (Data layer / Model sản phẩm)
// =============================================================================
//
//   Q1. Model trong Data layer khác Entity trong Domain thế nào? ProductModel đặt ở data vì sao?
//   A1. Model (data): cấu trúc sát với nguồn (JSON, DB). Entity (domain): nghiệp vụ thuần.
//       ProductModel ở data vì map trực tiếp từ FakeProductDataSource/API; CartItem là entity
//       (product + quantity, totalPrice). Dự án đơn giản nên CartItem dùng luôn ProductModel.
//
//   Q2. fromJson / toJson dùng khi nào trong dự án? API có trả JSON không?
//   A2. FakeProductDataSource dùng constructor, không từ JSON. toJson/fromJson dùng khi
//       CartItem lưu SharedPreferences (product nằm trong CartItem.toJson). API thật sẽ
//       dùng fromJson từ response.
//
//   Q3. fullDescription nullable — dùng ở đâu, có bắt buộc không?
//   A3. fullDescription dùng ở ProductDetailView (mô tả chi tiết). Nullable vì có thể API
//       không trả; UI kiểm tra null/empty trước khi hiển thị block "Thông số chi tiết".
//
// -----------------------------------------------------------------------------
// LOGIC TRONG FILE: Class immutable ProductModel (id, name, description, fullDescription?,
//   price, imageUrl, category), fromJson, toJson.
// -----------------------------------------------------------------------------
// LOGIC TRONG DỰ ÁN: Datasource/Repository trả ProductModel; ProductCardWidget, CartItem,
//   ProductDetailView đều dùng ProductModel. CartItem chứa product: ProductModel.
// -----------------------------------------------------------------------------

/// ProductModel - Data Model cho sản phẩm (Data Layer)
class ProductModel {
  final String id;
  final String name;
  final String description;
  final String? fullDescription; // Mô tả chi tiết khi click vào sản phẩm
  final double price;
  final String imageUrl;
  final String category;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    this.fullDescription,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  // Factory constructor để tạo từ JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      fullDescription: json['fullDescription'] as String?,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
    );
  }

  // Chuyển đổi thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'fullDescription': fullDescription,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
    };
  }
}
