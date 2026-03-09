// =============================================================================
// PHỎNG VẤN KIẾN THỨC - product_detail/models/product_model.dart (Barrel)
// =============================================================================
//
//   Q1. File chỉ export ProductModel — không định nghĩa class. Lợi ích?
//   A1. Barrel file: feature import từ '../models/product_model.dart' thay vì đường dẫn dài
//       tới data layer. Giữ cấu trúc feature (models/, services/, views/) và che dependency
//       thực sự (data). Đổi nguồn ProductModel chỉ sửa file barrel.
//
//   Q2. show ProductModel — nếu data layer export thêm class khác, feature có nhận không?
//   A2. Không. show ProductModel chỉ re-export đúng class đó. Các class khác của data/models
//       không lộ ra qua file này. hide/show kiểm soát API public của barrel.
//
//   Q3. Import từ package:flutter_application_2 — tên package từ đâu?
//   A3. Từ pubspec.yaml: name: flutter_application_2. Import package giống import lib từ
//       package khác. Trong cùng project thường dùng relative import (../../data/...); dùng
//       package name vẫn đúng và tránh path sâu.
//
// -----------------------------------------------------------------------------
// LOGIC TRONG FILE: Chỉ export ProductModel từ data layer.
// -----------------------------------------------------------------------------
// LOGIC TRONG DỰ ÁN: ProductDetailView và ViewModel import ProductModel từ feature/models.
// -----------------------------------------------------------------------------

/// ProductDetail - Models (re-export)
export 'package:flutter_application_2/data/models/product_model.dart'
    show ProductModel;
