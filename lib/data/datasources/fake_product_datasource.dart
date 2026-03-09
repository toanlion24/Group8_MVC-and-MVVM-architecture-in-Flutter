// =============================================================================
// PHỎNG VẤN KIẾN THỨC - fake_product_datasource.dart (Data source giả lập)
// =============================================================================
//
//   Q1. Data source trong Clean Architecture nằm ở đâu? Repository gọi DataSource thế nào?
//   A1. Data source thuộc data layer (datasources/). Repository (ProductRepository) gọi
//       FakeProductDataSource.getProducts() và getProductById; không gọi từ presentation.
//       UI chỉ gọi Repository hoặc Service/ViewModel.
//
//   Q2. getProducts() là static — có thể đổi thành instance method + inject không?
//   A2. Có: class FakeProductDataSource { List<ProductModel> getProducts() => [...]; }
//       rồi Provider/Repository tạo instance. Static đơn giản khi không cần state/config;
//       instance dễ test và thay bằng RemoteProductDataSource(inject http client).
//
//   Q3. Khi đổi sang API thật, cần sửa những file nào?
//   A3. Tạo RemoteProductDataSource (API call), ProductRepository nhận DataSource (interface)
//       và gọi getProducts/getProductById từ đó. Có thể giữ Fake cho dev, đổi inject ở
//       môi trường. ProductListScreen và ProductDetailService vẫn dùng Repository, không đổi.
//
// -----------------------------------------------------------------------------
// LOGIC TRONG FILE: FakeProductDataSource.getProducts() trả về list ProductModel cố định (8 SP).
// -----------------------------------------------------------------------------
// LOGIC TRONG DỰ ÁN: ProductRepository.getAllProducts/getProductById gọi từ đây.
//   ProductListScreen và ProductDetailService dùng Repository, không trực tiếp DataSource.
// -----------------------------------------------------------------------------

import '../models/product_model.dart';

/// FakeProductDataSource - Nguồn dữ liệu giả lập (thay bằng API/DB sau)
class FakeProductDataSource {
  static List<ProductModel> getProducts() {
    return [
      const ProductModel(
        id: 'p001',
        name: 'iPhone 15 Pro Max',
        description: 'Điện thoại Apple iPhone 15 Pro Max 256GB',
        fullDescription: '''
• Chất liệu: Khung viền titanium cao cấp, nhẹ bền, chống trầy xước tốt
• Chip: Apple A17 Pro - chip 3nm mạnh nhất trên smartphone, xử lý đồ họa game AAA mượt mà
• Màn hình: Super Retina XDR 6.7 inch, 120Hz ProMotion, Always-On Display, độ sáng đỉnh 2000 nits
• Camera: 48MP chính + 12MP Ultra Wide + 12MP Tele 5x; quay video ProRes, Log; chụp đêm ấn tượng
• Pin: Dùng cả ngày, sạc nhanh 27W, hỗ trợ MagSafe và Qi2
• Kết nối: USB-C, Wi-Fi 6E, 5G, Face ID
• Thiết kế mỏng 8.25mm, chống nước IP68''',
        price: 29990000,
        imageUrl: 'assets/images/iphone-15-pro-max.png',
        category: 'Điện thoại',
      ),
      const ProductModel(
        id: 'p002',
        name: 'Samsung Galaxy S24 Ultra',
        description: 'Điện thoại Samsung Galaxy S24 Ultra 512GB',
        fullDescription: '''
• Thiết kế: Khung titanium phẳng, màn hình Dynamic AMOLED 2X 6.8 inch QHD+ 120Hz
• Chip: Snapdragon 8 Gen 3 for Galaxy - hiệu năng tối ưu, AI tích hợp sâu
• S Pen: Bút cảm ứng tích hợp sẵn - ghi chú, vẽ, điều khiển từ xa
• Camera: 200MP chính + 50MP periscope 5x + 10MP periscope 10x + 12MP Ultra Wide; Zoom Space 100x
• Galaxy AI: Dịch thời gian thực, Circle to Search, Photo Assist, Note Assist
• Pin: 5000mAh, sạc 45W có dây, 15W không dây
• Bảo mật: Knox, kính Gorilla Armor chống trầy''',
        price: 31990000,
        imageUrl: 'assets/images/samsung-galaxy-s24-ultra.png',
        category: 'Điện thoại',
      ),
      const ProductModel(
        id: 'p003',
        name: 'MacBook Pro M3',
        description: 'Laptop Apple MacBook Pro 14 inch M3 Pro',
        fullDescription: '''
• Chip: Apple M3 Pro - 12 lõi CPU, 18 lõi GPU; hiệu năng vượt trội, tiết kiệm pin
• Màn hình: Liquid Retina XDR 14.2 inch, ProMotion 120Hz, độ sáng 1000 nits (đỉnh 1600 nits HDR)
• RAM: 18GB thống nhất - chạy mượt nhiều tác vụ nặng cùng lúc
• SSD: 512GB khởi động - tốc độ đọc/ghi cực nhanh
• Thiết kế: Vỏ nhôm Unibody, bản lề MagSafe 3, cổng HDMI, SDXC, Thunderbolt 4
• Pin: Lên đến 18 giờ xem video, sạc nhanh
• Loa 6 loa, micro 3 mảng - phù hợp làm việc sáng tạo, họp online''',
        price: 49990000,
        imageUrl: 'assets/images/Macbook-pro.png',
        category: 'Laptop',
      ),
      const ProductModel(
        id: 'p004',
        name: 'iPad Pro M2',
        description: 'Máy tính bảng Apple iPad Pro 12.9 inch M2',
        fullDescription: '''
• Chip: Apple M2 - 8 lõi CPU, 10 lõi GPU; hiệu năng máy tính để bàn trên tablet
• Màn hình: Liquid Retina XDR 12.9 inch, mini-LED, ProMotion 120Hz, độ sáng 1600 nits đỉnh
• Hỗ trợ: Apple Pencil 2 (từ tính), Magic Keyboard, Trackpad - biến thành laptop
• Camera: 12MP Wide + 10MP Ultra Wide, LiDAR Scanner - AR chính xác
• Kết nối: USB-C Thunderbolt, Wi-Fi 6E, 5G (tùy chọn), Face ID
• Hệ thống loa 4 loa, micro 5 mảng - âm thanh sống động
• iPadOS 17 - Stage Manager, đa nhiệm mạnh mẽ''',
        price: 28990000,
        imageUrl: 'assets/images/ipad-pro-m2.png',
        category: 'Tablet',
      ),
      const ProductModel(
        id: 'p005',
        name: 'AirPods Pro 2',
        description: 'Tai nghe Apple AirPods Pro thế hệ 2',
        fullDescription: '''
• Chip H2: Chống ồn chủ động gấp đôi thế hệ 1, âm thanh rõ ràng hơn
• Adaptive Audio: Tự động điều chỉnh giữa chế độ Chống ồn và Minh bạch theo môi trường
• Tìm kiếm: Precision Finding với U1 chip - định vị qua âm thanh và haptic
• Thời lượng pin: 6 giờ (có ANC), 30 giờ với hộp sạc; sạc MagSafe, Qi, Lightning
• Chống nước: IP54 (tai nghe và hộp)
• Tính năng: Tailored Listening, Spatial Audio động, Voice Isolation khi gọi
• Hộp sạc có loa - phát âm thanh khi tìm kiếm''',
        price: 5990000,
        imageUrl: 'assets/images/airpods-pro-2.png',
        category: 'Phụ kiện',
      ),
      const ProductModel(
        id: 'p006',
        name: 'Apple Watch Ultra 2',
        description: 'Đồng hồ thông minh Apple Watch Ultra 2',
        fullDescription: '''
• Màn hình: Retina 49mm, Always-On, độ sáng 3000 nits - nhìn rõ dưới nắng
• Chip S9 SiP: xử lý nhanh hơn, Siri on-device, Double Tap mới
• GPS: Dual-frequency (L1 + L5) - độ chính xác cao cho chạy bộ, leo núi
• Chống nước: 100m WR, phù hợp lặn biển; titanium Grade 4 bền bỉ
• Pin: 36 giờ thường, 72 giờ Low Power - dùng nhiều ngày
• Tính năng: Đo độ cao, la bàn, sự cố, hành trình; tối ưu cho thể thao mạo hiểm
• Dây đeo: Ocean, Alpine, Trail - đa dạng phong cách''',
        price: 21990000,
        imageUrl: 'assets/images/apple-watch.png',
        category: 'Đồng hồ',
      ),
      const ProductModel(
        id: 'p007',
        name: 'Sony WH-1000XM5',
        description: 'Tai nghe chống ồn Sony WH-1000XM5',
        fullDescription: '''
• Chống ồn: Processor V1 - chống ồn hàng đầu thế giới, 8 micro thu âm
• Âm thanh: Driver 30mm, LDAC - chất lượng cao, bass sâu, chi tiết tốt
• Thoải mái: Đệm da mềm, trọng lượng nhẹ ~250g, gấp gọn dễ mang
• Thời lượng pin: 30 giờ (ANC bật), sạc 3 phút dùng 3 giờ
• Tính năng: Speak-to-Chat (nói chuyện tạm tắt nhạc), Ambient Sound, multipoint
• Kết nối: Bluetooth 5.2, NFC, 3.5mm có dây
• Ứng dụng Headphones Connect - tùy chỉnh EQ, chế độ''',
        price: 7990000,
        imageUrl: 'assets/images/Tai-nghe-chong-on.png',
        category: 'Phụ kiện',
      ),
      const ProductModel(
        id: 'p008',
        name: 'Dell XPS 15',
        description: 'Laptop Dell XPS 15 Core i7 Gen 13',
        fullDescription: '''
• CPU: Intel Core i7-13700H Gen 13 - 14 lõi, hiệu năng đa nhiệm mạnh
• GPU: NVIDIA GeForce RTX 4050 - đồ họa, render, chơi game mượt
• Màn hình: 15.6 inch FHD+ 60Hz hoặc 3.5K OLED tùy cấu hình; InfinityEdge
• RAM: 16GB/32GB DDR5, SSD 512GB/1TB NVMe
• Thiết kế: Vỏ nhôm CNC, bàn phím carbon, trackpad kính - cao cấp
• Pin: 86Wh, dùng cả ngày làm việc
• Cổng: 2x Thunderbolt 4, USB-C, HDMI 2.1, jack 3.5mm''',
        price: 42990000,
        imageUrl: 'assets/images/Laptop-Dell-XPS.png',
        category: 'Laptop',
      ),
    ];
  }
}
