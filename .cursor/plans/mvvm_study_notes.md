---
name: MVVM Study Notes
overview: Ghi chú MVVM (Model-View-ViewModel) dựa trên cấu trúc dự án ShopCartDemo, dùng để trình bày và ôn tập.
---

## 1. Tổng quan MVVM trong dự án

- **Model (Data Layer)**: Chứa dữ liệu và logic truy cập dữ liệu (Model, DataSource, Repository, Service).
- **View (UI – Widgets)**: Màn hình và widget hiển thị, nhận input từ người dùng.
- **ViewModel**: Chứa logic chuyển đổi Data → UI State, không phụ thuộc trực tiếp vào widget; dùng **Riverpod** (FutureProvider/NotifierProvider) và **BLoC/Cubit**.

Trong ShopCartDemo:
- **Auth** dùng BLoC/Cubit.
- **Giỏ hàng** dùng Riverpod Notifier.
- **Chi tiết sản phẩm (product_detail)** là ví dụ MVVM rõ ràng nhất (Model–View–ViewModel).

---

## 2. Model – Data Layer (Repositories, Services, Models)

### 2.1. File quan trọng

- **Model dữ liệu**
  - `lib/data/models/product_model.dart`
    - Đại diện một sản phẩm: id, name, description, fullDescription?, price, imageUrl, category.
    - Có `fromJson` / `toJson` để map với JSON (API, lưu trữ).

- **Entity domain**
  - `lib/domain/entities/cart_item.dart`
    - Đại diện một dòng trong giỏ hàng: `product` (ProductModel) + `quantity`, có `totalPrice`.

- **DataSource**
  - `lib/data/datasources/fake_product_datasource.dart`
    - Cung cấp danh sách sản phẩm giả lập (list cứng), mô phỏng nguồn dữ liệu (sau này có thể thay bằng REST API).

- **Repositories**
  - `lib/data/repositories/product_repository.dart`
    - `getAllProducts()` lấy toàn bộ sản phẩm từ FakeProductDataSource.
    - `getProductById(id)` trả về `ProductModel?` (null nếu không tìm thấy).
  - `lib/data/repositories/auth_repository.dart`
    - Xử lý login/register demo (check email có `@`, password đủ dài, v.v.).

- **Service**
  - `lib/features/product_detail/services/product_detail_service.dart`
    - Dùng `ProductRepository` để lấy chi tiết sản phẩm.
    - `getProductById(String id)` trả `Future<ProductModel?>`, có delay 300ms giả lập network.

### 2.2. Câu hỏi thường gặp (Model)

- **Hỏi**: Model khác Entity thế nào trong dự án này?  
  **Đáp**: `ProductModel` là model dữ liệu (gần với JSON/API), còn `CartItem` là entity nghiệp vụ (product + quantity + totalPrice).

- **Hỏi**: Tại sao cần Repository, không gọi DataSource trực tiếp từ View?  
  **Đáp**: Repository tạo một “lớp trung gian” để sau này có thể thay FakeDataSource bằng API thật mà không phải sửa UI.

- **Hỏi**: Service khác Repository ở chỗ nào?  
  **Đáp**: Repository tập trung vào truy xuất dữ liệu, Service có thể thêm logic (delay, xử lý lỗi, combine nhiều repository) trước khi trả data cho ViewModel.

---

## 3. View – UI (Widgets, Screens)

### 3.1. File quan trọng

- **Màn hình chính và widget:**
  - `lib/presentation/screens/home_screen.dart`
  - `lib/presentation/screens/product_list_screen.dart`
  - `lib/presentation/screens/cart_screen.dart`
  - `lib/presentation/widgets/product_card_widget.dart`
  - `lib/presentation/widgets/cart_item_widget.dart`
  - `lib/presentation/widgets/cart_total_widget.dart`
  - `lib/presentation/widgets/cart_icon_widget.dart`

- **Màn hình chi tiết sản phẩm (MVVM rõ nhất):**
  - `lib/features/product_detail/views/product_detail_view.dart`
    - Là `ConsumerWidget` (Riverpod).
    - `build()`:
      - `final asyncProduct = ref.watch(productDetailViewModelProvider(productId));`
      - `asyncProduct.when(loading: ..., data: ..., error: ...)` để hiển thị 3 trạng thái.
    - Khi `data`:
      - Nếu `product == null` → hiển thị màn “Không tìm thấy sản phẩm”.
      - Nếu có `product` → hiển thị chi tiết: ảnh (Hero), tên, giá, mô tả, fullDescription, nút “Thêm vào giỏ”.
    - Đồng thời:
      - Watch `cartProvider.select(...)` để biết sản phẩm đã có trong giỏ chưa và số lượng hiện tại.

### 3.2. Câu hỏi thường gặp (View)

- **Hỏi**: `ConsumerWidget` là gì?  
  **Đáp**: Widget của Riverpod cho phép dùng `WidgetRef` để `watch`/`read` provider. Khi state của provider thay đổi, widget tự rebuild.

- **Hỏi**: `asyncProduct.when(loading, data, error)` hoạt động thế nào?  
  **Đáp**: `asyncProduct` là `AsyncValue<ProductModel?>`. Hàm `when` giúp tách UI cho ba trạng thái: đang load, thành công (data), lỗi.

- **Hỏi**: Tại sao View không gọi trực tiếp `ProductRepository` hoặc `Service`?  
  **Đáp**: Để tuân thủ MVVM – View chỉ quan tâm đến state (từ ViewModel), không biết chi tiết data đến từ đâu.

---

## 4. ViewModel – Logic chuyển đổi Data → UI State

### 4.1. Product Detail ViewModel (MVVM với Riverpod)

**File**: `lib/features/product_detail/viewmodels/product_detail_viewmodel.dart`

- Provider Service:
  - `productDetailServiceProvider = Provider<ProductDetailService>((ref) { ... });`
- ViewModel:
  - `productDetailViewModelProvider = FutureProvider.autoDispose.family<ProductModel?, String>((ref, productId) async { ... });`

**Ý nghĩa:**
- `FutureProvider`:
  - Trả về state bất đồng bộ `AsyncValue<ProductModel?>` cho View.
  - Tự quản lý loading / data / error.
- `family<String>`:
  - Provider nhận tham số `productId`, mỗi ID có một future/state riêng.
- `autoDispose`:
  - Khi người dùng rời màn chi tiết và không còn widget nào `watch`, provider sẽ tự huỷ, giải phóng bộ nhớ.

**Flow:**
1. View gọi: `ref.watch(productDetailViewModelProvider(productId))`.
2. Provider dùng `ref.read(productDetailServiceProvider)` để gọi `getProductById(productId)`.
3. Service dùng `ProductRepository` để lấy `ProductModel?`.
4. Provider phát ra `AsyncValue`:
   - Ban đầu: `loading`.
   - Sau khi xong: `data(product)` hoặc `error`.
5. View dựa trên `when(...)` để hiển thị UI phù hợp.

### 4.2. Cart ViewModel (Riverpod Notifier)

**File**: `lib/presentation/providers/cart_notifier.dart`

- `CartState`:
  - `items` (List<CartItem>), `selectedProductIds` (Set<String>), `isLoading` (bool).
  - Getter: `totalQuantity`, `totalPrice`, `itemCount`, `isEmpty`, `isInCart(productId)`, `getQuantity(productId)`.
- `CartNotifier extends Notifier<CartState>`:
  - `build()`:
    - Set state ban đầu (`isLoading: true`), gọi `_loadCart()` từ SharedPreferences.
  - Hàm thao tác:
    - `addToCart(product)`, `removeFromCart(productId)`.
    - `incrementQuantity(productId)`, `decrementQuantity(productId)`.
    - `toggleSelectProduct(productId)`, `clearCart()`.
- Provider:
  - `final cartProvider = NotifierProvider<CartNotifier, CartState>(() => CartNotifier());`

**Flow:**
1. UI (View) `watch`:
   - `ref.watch(cartProvider)` hoặc `ref.watch(cartProvider.select(...))`.
2. Khi người dùng thao tác:
   - Gọi `ref.read(cartProvider.notifier).addToCart(product);` (hoặc các hàm khác).
3. Notifier cập nhật `state`, Riverpod tự động rebuild các widget đang `watch`.

### 4.3. Auth ViewModel (BLoC + Cubit)

- **Form (Cubit)**:
  - `lib/presentation/auth/form/auth_form_state.dart`
  - `lib/presentation/auth/form/form_cubit.dart`
    - Nhận event nhập email/password, validate, emit state mới.
- **Login BLoC**:
  - `lib/presentation/auth/login/login_event.dart`
  - `lib/presentation/auth/login/login_state.dart`
  - `lib/presentation/auth/login/login_bloc.dart`
    - Nhận event `LoginRequested` / `RegisterRequested`, gọi `AuthRepository`, emit `Loading`, `Success`, `Failure`.

---

## 5. Hệ thống câu hỏi phỏng vấn / thuyết trình MVVM

### 5.1. Câu hỏi chung về kiến trúc

1. **MVVM là gì? Trong dự án này, 3 phần Model–View–ViewModel tương ứng với thư mục nào?**
2. **Tại sao nên tách Model/View/ViewModel thay vì để logic hết trong widget?**
3. **So sánh nhanh BLoC và Riverpod khi dùng làm ViewModel trong dự án này.**

### 5.2. Câu hỏi về Model/Data Layer

1. **`ProductModel` khác `CartItem` như thế nào về mặt vai trò?**
2. **Repository pattern giúp gì nếu sau này chuyển từ FakeDataSource sang API thật?**
3. **Vì sao `getProductById` trả về `ProductModel?` chứ không phải non-null?**

### 5.3. Câu hỏi về View

1. **`ProductDetailView` làm những việc chính gì trong build()?**
2. **Tại sao dùng `asyncProduct.when(...)` thay vì if-else thông thường?**
3. **View lấy thông tin “sản phẩm đã có trong giỏ bao nhiêu cái” bằng cách nào?**

### 5.4. Câu hỏi về ViewModel

1. **Giải thích `FutureProvider.autoDispose.family<ProductModel?, String>`.**
2. **Sự khác nhau giữa `ref.watch` và `ref.read` khi dùng trong View.**
3. **Vì sao giỏ hàng dùng `NotifierProvider` còn chi tiết sản phẩm dùng `FutureProvider`?**
4. **Nếu cần thêm logic “chỉ tính tổng tiền cho sản phẩm đang được chọn” thì nên đặt ở đâu?**

---

## 6. Cách trình bày trong buổi thuyết trình

- **Bước 1 – Giới thiệu tổng quan**:  
  - Nêu lại 3 layer MVVM và thư mục tương ứng trong dự án.

- **Bước 2 – Đi sâu vào feature Product Detail**:  
  - Mở lần lượt các file:
    1. `product_model.dart` (Model)
    2. `product_repository.dart` + `product_detail_service.dart` (Data/Service)
    3. `product_detail_viewmodel.dart` (ViewModel – FutureProvider)
    4. `product_detail_view.dart` (View – ConsumerWidget)
  - Vẽ (hoặc chỉ) sơ đồ luồng: **User tap → View → ViewModel (Provider) → Service → Repository → DataSource**.

- **Bước 3 – So sánh với một ViewModel khác (CartNotifier)**:  
  - Chỉ ra rằng giỏ hàng là một ViewModel khác dùng Riverpod Notifier (state nhiều thao tác, không chỉ load một lần).

- **Bước 4 – Q&A**:  
  - Sử dụng danh sách câu hỏi ở mục 5 để luyện tập trước.

