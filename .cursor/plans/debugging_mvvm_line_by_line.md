---
name: Debugging MVVM - Chi tiết từng dòng code
overview: Bản đồ chi tiết: file nào, dòng nào, xảy ra hiện tượng gì trong luồng MVVM của ShopCartDemo.
---

# Debugging MVVM - Chi tiết theo file và dòng code

Tài liệu này chỉ rõ **file → dòng → hiện tượng** để đặt breakpoint và phán đoán điểm gãy.

---

## Phần 1. Luồng Mở Chi Tiết Sản Phẩm (Product Detail)

### 1.1. View: Tap card → truyền productId

| File | Dòng | Hiện tượng | Ghi chú debug |
|------|------|------------|---------------|
| `lib/presentation/widgets/product_card_widget.dart` | 53–59 | User tap vào card | `onTap` gọi `Navigator.push` với `ProductDetailView(productId: product.id)` |
| | 56 | Truyền `productId` | Giá trị `product.id` (vd: `'p001'`). **Breakpoint đây để xem id có đúng không** |

**Lỗi thường gặp**: `productId` rỗng hoặc sai → màn chi tiết sẽ "Không tìm thấy sản phẩm".

---

### 1.2. View: ProductDetailView build và watch ViewModel

| File | Dòng | Hiện tượng | Ghi chú debug |
|------|------|------------|---------------|
| `lib/features/product_detail/views/product_detail_view.dart` | 40 | `productId` nhận từ constructor | Nếu breakpoint tại `build`, xem `productId` có đúng với `ProductCardWidget` truyền không |
| | 41 | `ref.watch(productDetailViewModelProvider(productId))` | View đăng ký lắng nghe ViewModel. Lần đầu vào màn → FutureProvider chạy callback. |
| | 45–53 | `asyncProduct.when(loading, data, error)` | `asyncProduct` là `AsyncValue<ProductModel?>` |

**Chi tiết khi `when` chạy:**

| Dòng | Nhánh | Điều kiện | UI hiển thị |
|------|-------|-----------|-------------|
| 45–50 | `data` | Future resolve, `product != null` | `_buildContent` – nội dung chi tiết |
| 46–48 | `data` + null | Future resolve, `product == null` | `_buildNotFound` – "Không tìm thấy sản phẩm" |
| 51 | `loading` | Future chưa resolve | `_buildLoading` – "Đang tải sản phẩm..." |
| 52 | `error` | Future throw exception | `_buildError` – "Có lỗi xảy ra" + message |

**Lỗi thường gặp**:
- Luôn loading: Future không resolve (breakpoint trong ViewModel/Service).
- Luôn "Không tìm thấy": `productId` sai hoặc Repository trả null (breakpoint trong Repository dòng 40).

---

### 1.3. ViewModel: FutureProvider gọi Service

| File | Dòng | Hiện tượng | Ghi chú debug |
|------|------|------------|---------------|
| `lib/features/product_detail/viewmodels/product_detail_viewmodel.dart` | 37–40 | Callback của `FutureProvider.autoDispose.family` | Chạy khi có widget `watch` lần đầu |
| | 38 | `if (productId.isEmpty) return null` | **Breakpoint**: Xem `productId` có rỗng không |
| | 39 | `ref.read(productDetailServiceProvider).getProductById(productId)` | Gọi Service lấy sản phẩm |

**Lỗi thường gặp**: `productId` rỗng → trả null ngay → View hiện "Không tìm thấy sản phẩm".

---

### 1.4. Service: delay + gọi Repository

| File | Dòng | Hiện tượng | Ghi chú debug |
|------|------|------------|---------------|
| `lib/features/product_detail/services/product_detail_service.dart` | 39–41 | `getProductById(String id)` | **Breakpoint**: Xem `id` nhận được |
| | 39 | `await Future.delayed(300)` | Giả lập mạng, user thấy loading ~300ms |
| | 40 | `return _repository.getProductById(id)` | Gọi Repository (sync trong code hiện tại) |

**Lỗi thường gặp**: Nếu Repository throw (vd: lỗi trong tương lai khi gọi API) → exception lan lên ViewModel → View nhận `AsyncValue.error`.

---

### 1.5. Model: Repository lấy từ DataSource

| File | Dòng | Hiện tượng | Ghi chú debug |
|------|------|------------|---------------|
| `lib/data/repositories/product_repository.dart` | 37–44 | `getProductById(String id)` | **Breakpoint**: Xem `id` |
| | 38 | `FakeProductDataSource.getProducts()` | Lấy toàn bộ danh sách |
| | 40 | `products.firstWhere((p) => p.id == id)` | Tìm sản phẩm theo id. **Nếu không tìm thấy**: throw `StateError` |
| | 41–43 | `catch (_)` | Bắt lỗi → trả `null` |

**Lỗi thường gặp**:
- `id` không có trong FakeProductDataSource (p001–p008) → `firstWhere` throw → catch → return null.
- **Breakpoint dòng 40**: Kiểm tra `id` và `products.map((p) => p.id)` để đối chiếu.

---

### 1.6. Model: DataSource – danh sách ID có sẵn

| File | Dòng | Hiện tượng | Ghi chú debug |
|------|------|------------|---------------|
| `lib/data/datasources/fake_product_datasource.dart` | 31–32 | `getProducts()` | Trả list 8 sản phẩm với id: `p001`, `p002`, …, `p008` |

**ID hợp lệ**: `p001` … `p008`. Nếu `productId` khác → Repository trả null.

---

## Phần 2. Luồng Thêm Vào Giỏ Hàng (Add to Cart)

### 2.1. View: Bấm "Thêm vào giỏ"

| File | Dòng | Hiện tượng | Ghi chú debug |
|------|------|------------|---------------|
| `lib/presentation/widgets/product_card_widget.dart` | 163–164 | `onPressed` của FilledButton | `ref.read(cartProvider.notifier).addToCart(product)` |
| `lib/features/product_detail/views/product_detail_view.dart` | 321–322 | `onPressed` nút "Thêm vào giỏ" | `ref.read(cartProvider.notifier).addToCart(product)` |

**Lưu ý**: `ref.read` chỉ gọi action, không subscribe. Rebuild nhờ `ref.watch(cartProvider.select(...))` ở dòng 40–45 (product_card) và 104–108 (product_detail_view).

---

### 2.2. ViewModel: CartNotifier.addToCart

| File | Dòng | Hiện tượng | Ghi chú debug |
|------|------|------------|---------------|
| `lib/presentation/providers/cart_notifier.dart` | 146–166 | `addToCart(ProductModel product)` | **Breakpoint đầu hàm** để xem `product` |
| | 147–150 | Clone `state.items`, tìm index theo `product.id` | |
| | 153–158 | Nếu đã có: tăng quantity (nếu `isValidQuantity`) | `ValidationMixin` – max 99 |
| | 160–162 | Nếu chưa có: thêm `CartItem(product)` | |
| | 164 | `state = state.copyWith(items: currentItems)` | Cập nhật state → Riverpod rebuild các widget `watch` |
| | 165 | `_saveCart()` | Lưu SharedPreferences |

**Lỗi thường gặp**:
- Số lượng không tăng: `isValidQuantity` false (đạt max 99) – xem `lib/core/mixins/validation_mixin.dart`.
- UI không đổi: Widget không `watch` cartProvider hoặc `select` sai.

---

### 2.3. View: Watch cart state để cập nhật UI

| File | Dòng | Hiện tượng | Ghi chú debug |
|------|------|------------|---------------|
| `lib/presentation/widgets/product_card_widget.dart` | 40–45 | `ref.watch(cartProvider.select(...))` | Chỉ rebuild khi `isInCart` hoặc `getQuantity` thay đổi |
| `lib/features/product_detail/views/product_detail_view.dart` | 104–108 | `ref.watch(cartProvider.select(...))` | `isInCart`, `getQuantity` cho màn chi tiết |

**Lỗi thường gặp**: Thiếu `watch` hoặc dùng `ref.read` thay vì `ref.watch` → UI không rebuild khi giỏ thay đổi.

---

## Phần 3. Luồng Load/Save Giỏ Từ SharedPreferences

### 3.1. CartNotifier build và _loadCart

| File | Dòng | Hiện tượng | Ghi chú debug |
|------|------|------------|---------------|
| `lib/presentation/providers/cart_notifier.dart` | 106–111 | `build()` | Trả `CartState(isLoading: true)`, gọi `_loadCart()` |
| | 115–132 | `_loadCart()` | Async: đọc SharedPreferences key `'cart_items'` |
| | 121–124 | `jsonDecode` → `CartItem.fromJson` | **Breakpoint**: Nếu JSON lỗi format → `CartItem.fromJson` throw |
| | 126 | `state = state.copyWith(items: items, isLoading: false)` | Cập nhật state sau khi load xong |
| | 128–130 | `catch` | Log `'Error loading cart'`, set `isLoading: false` |

**Lỗi thường gặp**:
- JSON trong SharedPreferences sai format → `CartItem.fromJson` throw (dòng 59–63 `lib/domain/entities/cart_item.dart`).
- `ProductModel.fromJson` throw nếu key thiếu (dòng 47–56 `lib/data/models/product_model.dart`).

---

### 3.2. CartItem.fromJson và ProductModel.fromJson

| File | Dòng | Hiện tượng | Ghi chú debug |
|------|------|------------|---------------|
| `lib/domain/entities/cart_item.dart` | 59–64 | `CartItem.fromJson` | Gọi `ProductModel.fromJson(json['product'])`, `quantity` từ json |
| `lib/data/models/product_model.dart` | 47–56 | `ProductModel.fromJson` | Cast từng field. **Nếu thiếu key hoặc type sai** → throw |

**Lỗi thường gặp**: Dữ liệu SharedPreferences bị sửa tay hoặc schema cũ → `fromJson` throw khi load giỏ.

---

## Phần 4. Luồng Đăng Nhập (Auth – BLoC)

### 4.1. View: Bấm nút Đăng nhập / Đăng ký

| File | Dòng | Hiện tượng | Ghi chú debug |
|------|------|------------|---------------|
| `lib/presentation/auth/auth_screen.dart` | 244–258 | `onPressed` FilledButton | `context.read<LoginBloc>().add(LoginRequested(...))` hoặc `RegisterRequested(...)` |
| | 245 | `formState.isValid` | Nếu false → `onPressed: null` (nút disabled) |
| | 247–256 | `LoginRequested(formState.email, formState.password)` | Email/password lấy từ FormCubit |

---

### 4.2. ViewModel: LoginBloc xử lý event

| File | Dòng | Hiện tượng | Ghi chú debug |
|------|------|------------|---------------|
| `lib/presentation/auth/login/login_bloc.dart` | 45–60 | `_onLoginRequested` | Handler cho `LoginRequested` |
| | 48 | `emit(LoginLoading())` | UI hiện loading |
| | 50–51 | `_authRepository.login(event.email, event.password)` | Gọi Model layer |
| | 52–56 | Nếu success → `emit(LoginSuccess())`, else `emit(LoginFailure(...))` | |
| | 57–59 | `catch` → `emit(LoginFailure(message: e.toString()))` | Nếu repository throw |

**Breakpoint dòng 50**: Xem `event.email`, `event.password` có đúng không.

---

### 4.3. View: Listener khi LoginSuccess

| File | Dòng | Hiện tượng | Ghi chú debug |
|------|------|------------|---------------|
| `lib/presentation/auth/auth_screen.dart` | 78–85 | `BlocConsumer` listener | Khi `state is LoginSuccess` → `pushReplacement(HomeScreen())` |

---

### 4.4. Model: AuthRepository

| File | Dòng | Hiện tượng | Ghi chú debug |
|------|------|------------|---------------|
| `lib/data/repositories/auth_repository.dart` | 31–34 | `login` | `email.contains('@') && password.length >= 6` → true/false |
| | 32 | `Future.delayed(1500)` | Giả lập mạng |

**Lỗi thường gặp**: Email không có `@` hoặc password < 6 ký tự → return false → LoginBloc emit `LoginFailure`.

---

## Phần 5. Điểm Khởi Động App (Entry)

| File | Dòng | Hiện tượng | Ghi chú debug |
|------|------|------------|---------------|
| `lib/main.dart` | 41–42 | `WidgetsFlutterBinding.ensureInitialized()` | Cần cho SharedPreferences, plugins |
| | 42 | `runApp(ProviderScope(child: MyApp()))` | **ProviderScope** bắt buộc – không có sẽ lỗi khi `ref.watch`/`ref.read` |
| `lib/app.dart` | 59–63 | `MultiBlocProvider` | Cung cấp `FormCubit`, `LoginBloc` cho AuthScreen |
| | 95 | `home: AuthScreen()` | Màn đầu tiên |

**Lỗi thường gặp**: Thiếu `ProviderScope` → `ProviderNotFoundException` khi bất kỳ widget nào dùng Riverpod.

---

## Phần 6. Bảng Tóm Tắt – Nên Breakpoint Khi Gặp Lỗi Gì

| Triệu chứng | File + dòng nên breakpoint |
|-------------|----------------------------|
| "Không tìm thấy sản phẩm" | `product_detail_view.dart` 41 (xem productId), `product_repository.dart` 37 (xem id + products), `product_detail_viewmodel.dart` 38 (productId rỗng?) |
| Màn chi tiết luôn loading | `product_detail_service.dart` 39, `product_repository.dart` 40 (có throw/block không?) |
| Màn chi tiết hiện error | Stack trace → tìm file+dòng throw; thường Service/Repository hoặc `fromJson` |
| Thêm vào giỏ nhưng UI không đổi | `product_card_widget.dart` 40–45, `product_detail_view.dart` 104–108 (có watch không?), `cart_notifier.dart` 164 (state có đổi không?) |
| Số lượng không tăng khi bấm Thêm nữa | `cart_notifier.dart` 155 (isValidQuantity), `validation_mixin.dart` |
| Giỏ mất sau restart app | `cart_notifier.dart` 115–132 (_loadCart), 136–142 (_saveCart), `cart_item.dart` 59 (fromJson) |
| Đăng nhập luôn thất bại | `auth_repository.dart` 31–33 (email, password), `auth_screen.dart` 245 (formState.isValid), `form_cubit.dart` |
| App crash khi mở | `main.dart` 42 (ProviderScope), stack trace |

---

## Phần 7. Log Gợi Ý Theo Dòng (Copy-Paste)

Có thể thêm tạm để trace:

```dart
// product_detail_view.dart dòng 41 (sau ref.watch)
debugPrint('[View] ProductDetailView build productId=$productId, asyncProduct=${asyncProduct.runtimeType}');

// product_detail_viewmodel.dart dòng 38
debugPrint('[ViewModel] productDetailViewModelProvider productId=$productId');

// product_repository.dart dòng 37
debugPrint('[Model] getProductById id=$id, ids=${products.map((p) => p.id).toList()}');

// cart_notifier.dart dòng 146
debugPrint('[ViewModel] addToCart productId=${product.id}, currentCount=${state.items.length}');

// auth_repository.dart dòng 31
debugPrint('[Model] login email=$email, passLen=${password.length}, valid=${email.contains('@') && password.length >= 6}');
```

Sau khi xác định được layer và file lỗi, dùng breakpoint thay log để debug sâu hơn.
