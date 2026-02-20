// ProductModel - Data Model cho sản phẩm
//
// Đây là class đại diện cho dữ liệu sản phẩm
// Sử dụng trong Data Layer của Clean Architecture
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
