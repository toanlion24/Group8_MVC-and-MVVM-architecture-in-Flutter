---
name: Debugging MVVM - Hướng dẫn chi tiết
overview: Hướng dẫn sử dụng debugger, đọc log, và phán đoán điểm gãy trong hệ thống MVVM (Model-View-ViewModel) thay vì sửa mò.
---

# Hướng dẫn Debug & Phán đoán điểm gãy trong MVVM

## 1. Nguyên tắc debug theo từng layer MVVM

| Layer | Vai trò | Điểm dễ gãy | Công cụ debug phù hợp |
|-------|---------|-------------|------------------------|
| **Model** | Data, Repository, Service | null, exception khi parse JSON, lỗi API | Breakpoint, Log, try-catch |
| **ViewModel** | Chuyển Data → UI State (Provider/BLoC) | state sai, emit nhầm, provider dispose sớm | DevTools Provider, BLoC Observer, Breakpoint |
| **View** | UI Widgets | build lỗi, không rebuild khi state đổi | Breakpoint trong build(), Flutter Inspector |

**Nguyên tắc vàng**: Khi lỗi, xác định lỗi thuộc layer nào trước (qua log/stack trace), rồi mới đào sâu vào file cụ thể. Không sửa mò nhiều file cùng lúc.

---

## 2. Sử dụng Debugger (Breakpoint, Step, Watch)

### 2.1. Cách đặt Breakpoint

1. Mở file Dart, click vào **lề trái** (cạnh số dòng) để đặt chấm đỏ.
2. Chạy app ở chế độ **Debug**: `flutter run` (không dùng `--release`).
3. Khi chạy đến dòng có breakpoint, app sẽ dừng.

**Gợi ý vị trí đặt breakpoint theo MVVM:**

| Layer | File ví dụ | Vị trí nên breakpoint |
|-------|------------|------------------------|
| Model | `product_repository.dart` | Đầu `getProductById(id)` – xem `id` có đúng không |
| Model | `product_model.dart` | Trong `fromJson` – khi parse lỗi |
| ViewModel | `product_detail_viewmodel.dart` | Trong callback của `FutureProvider` – xem giá trị trả về |
| ViewModel | `cart_notifier.dart` | Đầu `addToCart`, `_loadCart`, `_saveCart` |
| ViewModel | `login_bloc.dart` | Trong `mapEventToState` – xem event và state emit |
| View | `product_detail_view.dart` | Trong `build` hoặc `_buildContent` – xem `asyncProduct`, `product` |

### 2.2. Lệnh Step (F10, F11)

- **Step Over (F10)**: Chạy qua hàm hiện tại, không vào bên trong.
- **Step Into (F11)**: Vào bên trong hàm đang gọi.
- **Step Out (Shift+F11)**: Thoát khỏi hàm hiện tại, về caller.

**Cách dùng khi debug MVVM:**
- Đang ở View gọi `ref.watch(viewModelProvider)` → Step Into để xem ViewModel làm gì.
- Đang ở ViewModel gọi `service.getProductById(id)` → Step Into để xem Service/Repository.

### 2.3. Watch & Evaluate

- **Watch**: Thêm biến hoặc biểu thức để theo dõi giá trị khi step (VD: `productId`, `state`, `product`).
- **Evaluate (Debug Console)**: Trong lúc dừng, gõ `product` hoặc `state.items.length` để xem giá trị tức thời.

**Ví dụ Watch hữu ích:**
- `asyncProduct.value` – khi debug `ProductDetailView`.
- `state.items` – khi debug `CartNotifier`.
- `event` – khi debug `LoginBloc`.

### 2.4. Call Stack

- Khi app dừng ở breakpoint, mở **Call Stack** để xem chuỗi gọi từ đâu.
- Giúp trả lời: "Ai gọi hàm này? Đi qua ViewModel hay trực tiếp từ View?"

---

## 3. Đọc Log và cách in log có hệ thống

### 3.1. debugPrint vs print

```dart
debugPrint('Cart: addToCart ${product.id}');  // Ưu tiên dùng
print('...');  // Có thể bị truncate khi log dài
```

- **debugPrint**: Không bị cắt, không gây overflow trong release.
- **print**: Đơn giản nhưng dễ tràn trên một số thiết bị.

### 3.2. Log có prefix theo layer (để dễ lọc)

```dart
// Trong Repository/Service (Model)
debugPrint('[Model] ProductRepository.getProductById id=$id');

// Trong ViewModel (Provider/BLoC)
debugPrint('[ViewModel] CartNotifier.addToCart productId=${product.id}');
debugPrint('[BLoC] LoginBloc mapEventToState: $event');

// Trong View
debugPrint('[View] ProductDetailView build productId=$productId');
```

Khi đọc log, search `[Model]`, `[ViewModel]`, `[View]` để biết lỗi xuất phát từ layer nào.

### 3.3. Xem log ở đâu

- **VS Code / Cursor**: Panel **Debug Console** khi chạy `flutter run`.
- **Chrome (web)**: F12 → tab **Console**.
- **Flutter DevTools**: Mở từ terminal (`d` sau khi `flutter run`) → có thể xem log tích hợp.

### 3.4. Try-catch và log lỗi

```dart
try {
  final product = _repository.getProductById(id);
  return product;
} catch (e, stack) {
  debugPrint('[Model] getProductById error: $e');
  debugPrint(stack.toString());  // Stack trace giúp tìm file/dòng lỗi
  rethrow;
}
```

Stack trace cho biết **chính xác file và dòng** gây exception.

---

## 4. Phán đoán điểm gãy theo triệu chứng

### 4.1. Triệu chứng: Màn hình trắng / crash khi mở app

| Triệu chứng | Hướng điều tra | File/layer cần kiểm tra |
|-------------|----------------|--------------------------|
| Crash ngay khi mở app | Xem stack trace trong log | `main.dart`, `app.dart`, Provider scope |
| Lỗi "Provider not found" | Kiểm tra `ProviderScope` bọc `MyApp` | `main.dart` |
| Lỗi "No MaterialLocalizations" | Kiểm tra `MaterialApp` và locale | `app.dart` |

### 4.2. Triệu chứng: Màn chi tiết sản phẩm không hiện / "Không tìm thấy sản phẩm"

| Triệu chứng | Hướng điều tra | Điểm cần breakpoint/log |
|-------------|----------------|--------------------------|
| Luôn "Không tìm thấy sản phẩm" | `productId` có đúng không? Repository có trả null? | `ProductDetailView` build, `productDetailViewModelProvider` callback |
| Luôn loading | Future không resolve? Service/Repository throw? | `ProductDetailService.getProductById`, `ProductRepository.getProductById` |
| Hiện error thay vì data | Xem `AsyncValue.error` – exception là gì | `product_detail_viewmodel.dart`, `product_detail_service.dart` |

**Flow kiểm tra:**
1. Breakpoint trong `ProductDetailView` → xem `productId` khi mở màn.
2. Breakpoint trong `productDetailViewModelProvider` → xem giá trị trả về (null / ProductModel / Exception).
3. Breakpoint trong `ProductRepository.getProductById` → xem `FakeProductDataSource.getProducts()` có chứa id đó không.

### 4.3. Triệu chứng: Giỏ hàng không cập nhật / số lượng sai

| Triệu chứng | Hướng điều tra | Điểm cần kiểm tra |
|-------------|----------------|--------------------|
| Thêm vào giỏ nhưng UI không đổi | View có `watch` cartProvider không? | `CartScreen`, `ProductCardWidget`, `CartIconWidget` |
| Số lượng hiển thị sai | State trong CartNotifier có đúng không? | `cart_notifier.dart` – `addToCart`, `incrementQuantity` |
| Mất giỏ sau khi restart app | SharedPreferences có lưu/load đúng không? | `_loadCart`, `_saveCart` trong `cart_notifier.dart` |

**Flow kiểm tra:**
1. Breakpoint trong `addToCart` → xem `state` trước và sau khi thêm.
2. Log `state.items` sau mỗi thao tác.
3. Kiểm tra `ref.watch(cartProvider)` hoặc `ref.watch(cartProvider.select(...))` có được gọi trong widget không.

### 4.4. Triệu chứng: Đăng nhập không thành công / form validate sai

| Triệu chứng | Hướng điều tra | File/layer |
|-------------|----------------|------------|
| Bấm đăng nhập không phản hồi | LoginBloc có nhận event không? | `login_bloc.dart` – `mapEventToState` |
| Luôn "LoginFailure" | AuthRepository trả false? Email/password sai? | `auth_repository.dart` |
| Nút bấm disabled | FormCubit state `isValid` | `auth_form_state.dart`, `form_cubit.dart` |

**Flow kiểm tra:**
1. Breakpoint trong `LoginBloc` – xem `event` (email, password).
2. Breakpoint trong `AuthRepository.login` – xem điều kiện trả true/false.
3. Breakpoint trong `FormCubit` – xem `emailError`, `passwordError`, `isValid`.

---

## 5. Flutter DevTools – Công cụ mạnh cho MVVM

### 5.1. Mở DevTools

- Chạy `flutter run`, nhấn `d` trong terminal để mở trong trình duyệt.
- Hoặc: Run → Start Debugging, sau đó mở link DevTools từ Debug Console.

### 5.2. Các tab hữu ích theo layer

| Tab | Dùng để | Liên quan MVVM |
|-----|---------|----------------|
| **Inspector** | Xem cây widget, tìm widget bị overflow/sai layout | View – xem widget tree, constraints |
| **Performance** | Đo FPS, jank | View – tối ưu rebuild |
| **Network** | Xem HTTP request (khi dùng API thật) | Model – API call |
| **Provider** (nếu cài extension) | Xem giá trị provider, rebuild | ViewModel – Riverpod state |
| **Logging** | Xem log có cấu trúc | Tất cả – log với prefix [Model], [ViewModel], [View] |

### 5.3. Provider / Riverpod DevTools

- Riverpod có DevTools: xem provider nào đang active, giá trị, rebuild.
- Giúp phát hiện: provider bị dispose sớm, watch sai provider, state không đổi nhưng UI không rebuild.

---

## 6. BLoC / Cubit – Debug riêng

### 6.1. BlocObserver

Thêm `BlocObserver` để log mọi event và state transition:

```dart
// Trong main.dart hoặc chỗ khởi tạo app
class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    debugPrint('[BLoC] ${bloc.runtimeType} onEvent: $event');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint('[BLoC] ${bloc.runtimeType} ${transition.currentState} -> ${transition.nextState}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('[BLoC] ${bloc.runtimeType} ERROR: $error');
    debugPrint(stackTrace.toString());
    super.onError(bloc, error, stackTrace);
  }
}

void main() {
  Bloc.observer = AppBlocObserver();
  runApp(ProviderScope(child: MyApp()));
}
```

Khi đăng nhập lỗi, log sẽ cho biết event gì được gửi, state chuyển như thế nào, và lỗi (nếu có).

---

## 7. Quy trình debug có hệ thống (tránh sửa mò)

```
1. Ghi lại triệu chứng
   - Màn nào? Thao tác gì? Kết quả mong đợi vs thực tế?

2. Đọc stack trace / log
   - Có exception không? File và dòng nào?
   - Log [Model]/[ViewModel]/[View] có gì bất thường?

3. Xác định layer nghi ngờ
   - Crash trong Repository/Service → Model
   - State sai, provider null → ViewModel
   - UI không cập nhật, overflow → View

4. Đặt 1–2 breakpoint ở layer đó
   - Đầu hàm được gọi khi lỗi xảy ra.
   - Step qua, xem giá trị biến (Watch / Evaluate).

5. Thu hẹp phạm vi
   - Nếu Model đúng (data đúng) → lỗi ở ViewModel hoặc View.
   - Nếu ViewModel state đúng → lỗi ở View (không watch, không rebuild).

6. Sửa và kiểm tra lại
   - Sửa 1 chỗ, chạy lại, xác nhận lỗi đã hết.
```

---

## 8. Bảng tra nhanh – File cần debug theo layer

| Layer | Thư mục/File | Khi nào nghĩ tới |
|-------|--------------|------------------|
| **Model** | `lib/data/models/`, `lib/data/repositories/`, `lib/data/datasources/`, `lib/features/*/services/` | Dữ liệu sai, null, parse lỗi, API lỗi |
| **ViewModel** | `lib/features/product_detail/viewmodels/`, `lib/presentation/providers/`, `lib/presentation/auth/login/`, `lib/presentation/auth/form/` | State sai, không emit, provider dispose, event không xử lý |
| **View** | `lib/presentation/screens/`, `lib/presentation/widgets/`, `lib/features/*/views/` | UI không hiện, không rebuild, layout lỗi |

---

## 9. Tóm tắt

- **Debugger**: Đặt breakpoint ở đầu hàm nghi ngờ (theo bảng mục 2.1), dùng Step/Watch/Call Stack.
- **Log**: Dùng `debugPrint` với prefix `[Model]`, `[ViewModel]`, `[View]` và bật BlocObserver cho BLoC.
- **Phán đoán**: Dựa vào triệu chứng → xác định layer (Model/ViewModel/View) → debug trong layer đó trước.
- **Quy trình**: Ghi triệu chứng → đọc stack/log → xác định layer → breakpoint → thu hẹp → sửa một chỗ rồi test lại.

Chuẩn hóa cách debug theo MVVM giúp tìm lỗi nhanh và tránh sửa mò nhiều file.
