// =============================================================================
// PHỎNG VẤN KIẾN THỨC - main.dart (Entry point)
// =============================================================================
//
//   Q1. Hàm main() trong Flutter chạy khi nào? Có thể gọi main() nhiều lần không?
//   A1. main() là entry point, chạy đúng một lần khi ứng dụng khởi động (OS gọi).
//       Không gọi main() thủ công nhiều lần; mỗi lần mở app thì process mới chạy main().
//
//   Q2. WidgetsFlutterBinding.ensureInitialized() dùng để làm gì? Bỏ nó có được không?
//   A2. Đảm bảo Flutter binding đã sẵn sàng trước khi dùng native/plugin (SharedPreferences,
//       camera, path_provider...). Nếu có async init trước runApp() thì nên gọi; bỏ đi
//       có thể gây lỗi khi plugin cần channel hoặc platform code.
//
//   Q3. runApp() nhận gì? Widget gốc đặt ở đâu trong cây widget?
//   A3. runApp(Widget) nhận một widget — đó là widget gốc. Flutter vẽ cây từ đây;
//       widget gốc trong project này là ProviderScope(child: MyApp()).
//
//   Q4. ProviderScope là gì? Tại sao Riverpod lại cần bọc cả app bằng ProviderScope?
//   A4. ProviderScope là nơi lưu trữ "container" của Riverpod (override, providers).
//       ref.watch/read cần tìm provider trong cây; nếu không có Scope thì không có chỗ
//       lưu state → cần bọc cả app để mọi màn đều dùng được Riverpod.
//
//   Q5. Nếu đặt Consumer hoặc ref.watch bên ngoài ProviderScope thì chuyện gì xảy ra?
//   A5. Sẽ lỗi (ProviderNotFoundException hoặc tương đương): không tìm thấy ProviderScope
//       trong ancestor, nên không có ref hợp lệ.
//
// =============================================================================
// LOGIC TRONG FILE: main() chạy 1 lần khi mở app
//   1. ensureInitialized() → sẵn sàng cho plugin (SharedPreferences, ...)
//   2. runApp(ProviderScope(MyApp())) → vẽ cây widget gốc, bọc bằng ProviderScope
// -----------------------------------------------------------------------------
// LOGIC TRONG DỰ ÁN: ProviderScope là nơi chứa toàn bộ state Riverpod (cart,
//   product detail...). Mọi Consumer / ref.watch / ref.read phải nằm dưới
//   ProviderScope thì mới hoạt động. MyApp (app.dart) nằm bên trong.
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}
