# 🛍️ ShopCart - Ứng dụng Giỏ hàng Demo

Ứng dụng mua sắm minh họa kiến trúc **MVC** và **MVVM** trong Flutter, kết hợp **BLoC**, **Cubit** và **Riverpod** để quản lý state.

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart)](https://dart.dev)

---

## 📱 Tính năng

- **Đăng nhập / Đăng ký** – Giao diện hiện đại với validation
- **Danh sách sản phẩm** – Grid responsive (2–4 cột theo màn hình)
- **Chi tiết sản phẩm** – Mô tả chi tiết, thông số kỹ thuật
- **Giỏ hàng** – Thêm/xóa/sửa số lượng, lưu trữ với SharedPreferences
- **Thanh toán** – Flow mô phỏng đặt hàng thành công
- **Responsive** – Hỗ trợ mobile, tablet và web (sidebar trên màn hình rộng)

---

## 🏗️ Kiến trúc

Dự án kết hợp nhiều pattern để minh họa cách triển khai trong Flutter:

### 1. MVVM – Product Detail

```
┌─────────────┐    ┌─────────────────┐    ┌──────────────────┐
│    View     │ ←→ │   ViewModel     │ ←→ │     Service      │
│ (UI Widget) │    │ (Riverpod)      │    │ (Data fetching)  │
└─────────────┘    └─────────────────┘    └──────────────────┘
                            ↓
                   ┌──────────────────┐
                   │     Model        │
                   │ (ProductModel)   │
                   └──────────────────┘
```

- **views/** – `ProductDetailView` – Hiển thị UI
- **viewmodels/** – `productDetailViewModelProvider` – Cung cấp state (Riverpod)
- **services/** – `ProductDetailService` – Lấy dữ liệu từ Repository
- **models/** – `ProductModel` – Dữ liệu sản phẩm

### 2. BLoC & Cubit – Auth (Đăng nhập / Đăng ký)

| Thành phần | Công nghệ | Vai trò |
|------------|-----------|---------|
| Form state | **Cubit** | Quản lý form: email, password, validation |
| Login flow | **BLoC** | Xử lý events: `LoginRequested`, `RegisterRequested` |
| States | — | `Initial`, `Loading`, `Success`, `Failure` |
| UI | **BlocBuilder** | Render theo từng state |

### 3. Riverpod – Giỏ hàng & Product Detail

- **CartNotifier** – State giỏ hàng (items, quantity, tổng tiền)
- **Consumer / ref.watch** – Lắng nghe thay đổi và rebuild UI
- **Selector** – Chỉ rebuild khi cần (tối ưu hiệu năng)

### 4. Repository Pattern

- **ProductRepository** – Truy xuất danh sách và chi tiết sản phẩm
- **AuthRepository** – Xử lý login/register (fake API)
- **FakeProductDataSource** – Nguồn dữ liệu mẫu

---

## 🔁 Quy trình hoạt động chi tiết của dự án

### Tổng quan luồng ứng dụng

```
┌──────────────┐     Đăng nhập thành công      ┌──────────────┐     Click sản phẩm     ┌──────────────────┐
│  main.dart   │ ──────────────────────────▶   │  app.dart    │ ───────────────────▶   │  HomeScreen      │
│  Khởi động   │                               │  AuthScreen  │                        │  ProductList     │
└──────────────┘                               └──────────────┘                        │  CartScreen      │
        │                                               │                              └──────────────────┘
        │                                               │                                        │
        ▼                                               ▼                                        ▼
┌──────────────┐                               ┌──────────────┐                        ┌──────────────────┐
│ ProviderScope│                               │ LoginBloc    │                        │ ProductDetailView│
│ MultiBlocProv│                               │ FormCubit    │                        │ (MVVM)           │
└──────────────┘                               └──────────────┘                        └──────────────────┘
```

---

### 1. Khởi động ứng dụng

| File | Vai trò |
|------|---------|
| **main.dart** | Điểm vào: `runApp()` bọc `ProviderScope` (Riverpod) → `MyApp` |
| **app.dart** | `MultiBlocProvider` cung cấp `FormCubit`, `LoginBloc` → `MaterialApp` có `home: AuthScreen` |

**Luồng:** `main` → `ProviderScope` (cho Riverpod) → `MyApp` → `MultiBlocProvider` (cho BLoC) → `MaterialApp` → màn hình đầu tiên là **AuthScreen**.

---

### 2. Luồng Đăng nhập / Đăng ký (BLoC + Cubit)

#### 2.1 Các file tham gia

| File | Loại | Chức năng |
|------|------|-----------|
| `auth_screen.dart` | View | Form email/password, tab Đăng nhập–Đăng ký |
| `form_cubit.dart` | Cubit | State form: email, password, `emailError`, `passwordError`, `isValid` |
| `auth_form_state.dart` | State | `AuthFormState`: email, password, errors |
| `login_bloc.dart` | BLoC | Xử lý `LoginRequested`, `RegisterRequested` |
| `login_event.dart` | Event | `LoginRequested`, `RegisterRequested` |
| `login_state.dart` | State | `LoginInitial`, `LoginLoading`, `LoginSuccess`, `LoginFailure` |
| `auth_repository.dart` | Repository | Gọi logic login/register (fake) |

#### 2.2 Luồng xử lý khi bấm "Đăng nhập"

```
User nhập email, password
        │
        ▼
┌─────────────────────┐
│ FormCubit           │  emailChanged(), passwordChanged() → cập nhật AuthFormState
│ (Form State)        │  isValid = email có @, password >= 6
└─────────────────────┘
        │
        │  User bấm "Đăng nhập"
        ▼
┌─────────────────────┐
│ AuthScreen          │  context.read<LoginBloc>().add(LoginRequested(email, password))
└─────────────────────┘
        │
        ▼
┌─────────────────────┐
│ LoginBloc           │  on<LoginRequested>: emit(LoginLoading)
│                     │  → _authRepository.login(email, password)
│                     │  → emit(LoginSuccess) hoặc emit(LoginFailure)
└─────────────────────┘
        │
        ▼
┌─────────────────────┐
│ AuthRepository      │  login() → Future.delayed → return email.contains('@') && password.length >= 6
└─────────────────────┘
        │
        ▼
┌─────────────────────┐
│ AuthScreen          │  BlocConsumer listener: nếu LoginSuccess → pushReplacement(HomeScreen)
└─────────────────────┘
```

---

### 3. Luồng Màn hình chính (Home, Sản phẩm, Giỏ hàng)

#### 3.1 Các file tham gia

| File | Chức năng |
|------|-----------|
| `home_screen.dart` | Scaffold + Sidebar (web) hoặc BottomNav (mobile), chứa `ProductListScreen` và `CartScreen` |
| `product_list_screen.dart` | Gọi `ProductRepository.getAllProducts()`, render `GridView` với `ProductCardWidget` |
| `product_card_widget.dart` | Card sản phẩm, `ref.watch(cartProvider)` để biết đã thêm chưa, `InkWell` mở `ProductDetailView` |
| `cart_screen.dart` | `ref.watch(cartProvider)`, hiển thị `CartItemWidget`, `CartTotalWidget` |
| `cart_item_widget.dart` | Một item giỏ: ảnh, tên, giá, nút +/- xóa |
| `cart_total_widget.dart` | Footer: tổng tiền, nút Thanh toán |
| `cart_icon_widget.dart` | Icon giỏ + badge số lượng |

#### 3.2 Luồng dữ liệu giỏ hàng

```
ProductCardWidget "Thêm vào giỏ"
        │
        ▼
┌─────────────────────┐
│ CartNotifier        │  ref.read(cartProvider.notifier).addToCart(product)
│ (cart_notifier.dart)│  → state.copyWith(items) → _saveCart() (SharedPreferences)
└─────────────────────┘
        │
        ▼
┌─────────────────────┐
│ CartIconWidget      │  ref.watch(cartProvider.select((s) => s.totalQuantity))
│ CartTotalWidget     │  → rebuild khi totalQuantity / totalPrice thay đổi
│ CartItemWidget      │  ref.watch(cartProvider.select(...))
└─────────────────────┘
```

**CartNotifier** khởi tạo với `_loadCart()` từ SharedPreferences; mỗi lần thêm/xóa/cập nhật đều gọi `_saveCart()`.

---

### 4. Luồng Chi tiết sản phẩm (MVVM)

#### 4.1 Các file tham gia

| File | Layer | Chức năng |
|------|-------|-----------|
| `product_detail_view.dart` | View | `ref.watch(productDetailViewModelProvider(productId))`, render theo `AsyncValue` |
| `product_detail_viewmodel.dart` | ViewModel | `FutureProvider.family` gọi Service, trả `AsyncValue<ProductModel?>` |
| `product_detail_service.dart` | Service | `getProductById(id)` → gọi Repository |
| `product_repository.dart` | Repository | `getProductById(id)` → `FakeProductDataSource` |
| `product_model.dart` | Model | id, name, description, price, imageUrl, category, fullDescription |

#### 4.2 Luồng khi mở màn hình chi tiết

```
ProductCardWidget: InkWell onTap
        │
        ▼
Navigator.push(ProductDetailView(productId: product.id))
        │
        ▼
┌─────────────────────────────┐
│ ProductDetailView           │  ref.watch(productDetailViewModelProvider(productId))
│                             │  → asyncProduct = AsyncValue<ProductModel?>
└─────────────────────────────┘
        │
        ▼
┌─────────────────────────────┐
│ product_detail_viewmodel    │  FutureProvider gọi getProductById(productId)
│                             │  → ProductDetailService.getProductById()
└─────────────────────────────┘
        │
        ▼
┌─────────────────────────────┐
│ ProductDetailService        │  await Future.delayed(300ms)  // giả lập network
│                             │  → ProductRepository.getProductById(id)
└─────────────────────────────┘
        │
        ▼
┌─────────────────────────────┐
│ ProductRepository           │  FakeProductDataSource.getProducts().firstWhere(id)
└─────────────────────────────┘
        │
        ▼
┌─────────────────────────────┐
│ ProductDetailView           │  asyncProduct.when(
│                             │    loading: () => CircularProgressIndicator,
│                             │    data: (product) => _buildContent(product),
│                             │    error: (e) => _buildError(e),
│                             │  )
└─────────────────────────────┘
```

---

### 5. Bảng tổng hợp: File – Vai trò – Phụ thuộc

| File | Vai trò | Phụ thuộc |
|------|---------|-----------|
| **main.dart** | Entry point, ProviderScope | app.dart |
| **app.dart** | MultiBlocProvider, MaterialApp, theme | auth_screen, form_cubit, login_bloc, auth_repository |
| **auth_screen.dart** | Form đăng nhập/đăng ký | FormCubit, LoginBloc, HomeScreen |
| **form_cubit.dart** | Form state | auth_form_state |
| **login_bloc.dart** | Login flow | auth_repository, login_event, login_state |
| **auth_repository.dart** | Logic login/register | (không) |
| **home_screen.dart** | Layout chính, tab | ProductListScreen, CartScreen, CartIconWidget |
| **product_list_screen.dart** | Danh sách sản phẩm | ProductRepository, ProductCardWidget |
| **product_card_widget.dart** | Card sản phẩm | cartProvider, ProductDetailView |
| **cart_screen.dart** | Màn hình giỏ hàng | cartProvider, CartItemWidget, CartTotalWidget |
| **cart_notifier.dart** | State giỏ hàng | ProductModel, CartItem, SharedPreferences |
| **product_detail_view.dart** | Màn chi tiết | productDetailViewModelProvider, cartProvider |
| **product_detail_viewmodel.dart** | ViewModel chi tiết | ProductDetailService |
| **product_detail_service.dart** | Service chi tiết | ProductRepository |
| **product_repository.dart** | Truy xuất sản phẩm | FakeProductDataSource |
| **fake_product_datasource.dart** | Dữ liệu mẫu | ProductModel |

---

### 6. Sơ đồ phụ thuộc (Dependency flow)

```
                    ┌─────────────┐
                    │  main.dart  │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │  app.dart   │
                    └──────┬──────┘
                           │
         ┌─────────────────┼─────────────────┐
         │                 │                 │
    ┌────▼────┐      ┌─────▼─────┐     ┌────▼─────┐
    │AuthScreen│      │FormCubit  │     │LoginBloc │
    └────┬────┘      └─────┬─────┘     └────┬─────┘
         │                 │                │
         │            AuthFormState    AuthRepository
         │
    ┌────▼────┐
    │HomeScreen│
    └────┬────┘
         │
    ┌────┴────┐
    │         │
┌───▼───┐ ┌──▼────┐
│Product│ │ Cart  │
│ List  │ │ Screen│
└───┬───┘ └──┬────┘
    │        │
    │   ┌────▼────┐
    │   │cartProv.│
    │   └─────────┘
    │
┌───▼──────────┐
│ProductCard   │───► ProductDetailView
└──────────────┘           │
                    ┌──────▼──────┐
                    │productDetail│
                    │ViewModelProv│
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │ProductDetail│
                    │  Service    │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │  Product    │
                    │ Repository  │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │FakeProduct  │
                    │  DataSource │
                    └─────────────┘
```

---

## ⚖️ Phân tích ưu nhược điểm của MVC và MVVM

### MVC (Model-View-Controller)

| Ưu điểm | Nhược điểm |
|---------|------------|
| **Đơn giản, dễ hiểu** – 3 thành phần rõ ràng, phù hợp dự án nhỏ | **View và Model liên kết chặt** – khó thay đổi một bên mà không ảnh hưởng bên kia |
| **Tái sử dụng logic** – Controller có thể dùng cho nhiều View | **Controller dễ phình to** – logic nghiệp vụ và UI dồn vào một nơi |
| **Phát triển song song** – Model/View/Controller có thể code độc lập | **Test khó** – logic trộn trong Controller, khó unit test thuần |
| **Phổ biến** – nhiều tài liệu, framework hỗ trợ | **Sự kiện phức tạp** – nhiều View/Controller dẫn đến event khó quản lý |

**Khi nào nên dùng MVC:** Dự án nhỏ, ít màn hình, team mới làm quen với clean architecture.

---

### MVVM (Model-View-ViewModel)

| Ưu điểm | Nhược điểm |
|---------|------------|
| **Tách biệt UI và logic** – View chỉ render, ViewModel xử lý data | **Độ phức tạp ban đầu** – cần hiểu rõ Data Binding, Stream/Observable |
| **Dễ test** – ViewModel không phụ thuộc UI, test đơn vị dễ dàng | **Overhead** – nhiều lớp, nhiều file cho màn hình đơn giản |
| **Dễ bảo trì** – thay View không ảnh hưởng ViewModel | **Học curve** – cần nắm reactive, state management |
| **Tái sử dụng ViewModel** – một ViewModel có thể dùng cho nhiều View | **Debug phức tạp hơn** – data flow qua nhiều layer |
| **Phù hợp UI phức tạp** – form, list, validation rõ ràng | — |

**Khi nào nên dùng MVVM:** Dự án trung–lớn, UI phức tạp, cần test cao, nhiều người cùng làm.

---

### So sánh nhanh

| Tiêu chí | MVC | MVVM |
|----------|-----|------|
| Liên kết View – Data | View đọc trực tiếp Model | View bind qua ViewModel |
| Test | Khó (logic trong Controller) | Dễ (ViewModel độc lập) |
| Phù hợp | Dự án nhỏ, prototype | Dự án lớn, maintain lâu dài |
| Flutter thực tế | Ít dùng thuần | Thường kết hợp với BLoC, Riverpod làm ViewModel |

---

## 🔄 Demo: ViewModel chuyển đổi Raw Data thành UI State

Trong dự án, **Product Detail** minh họa rõ cách ViewModel biến dữ liệu thô thành UI State.

### Luồng dữ liệu

```
Raw Data (Repository)  →  Service  →  ViewModel  →  UI State  →  View
     ProductModel           ↓            ↓            ↓
   (JSON, API response)  getById()   AsyncValue<T>   Loading /
                                                  Success /
                                                  Error
```

### 1. Raw Data (từ Repository)

```dart
// ProductRepository trả về dữ liệu thô
ProductModel? product = repository.getProductById(id);
// ProductModel: id, name, description, price, imageUrl, category, fullDescription
```

### 2. Service – Lấy và xử lý bước đầu

```dart
// ProductDetailService
Future<ProductModel?> getProductById(String id) async {
  await Future.delayed(Duration(milliseconds: 300)); // Giả lập network
  return _repository.getProductById(id);
}
```

### 3. ViewModel – Chuyển Raw Data thành UI State

```dart
// product_detail_viewmodel.dart
final productDetailViewModelProvider =
    FutureProvider.autoDispose.family<ProductModel?, String>((ref, productId) async {
  if (productId.isEmpty) return null;
  // ViewModel gọi Service → nhận raw ProductModel
  return ref.read(productDetailServiceProvider).getProductById(productId);
});
```

**UI State:** Riverpod `FutureProvider` tạo ra `AsyncValue<ProductModel?>`:
- `AsyncValue.loading` – đang tải
- `AsyncValue.data(product)` – thành công
- `AsyncValue.error(err, stack)` – lỗi

### 4. View – Render theo UI State

```dart
// ProductDetailView
final asyncProduct = ref.watch(productDetailViewModelProvider(productId));

asyncProduct.when(
  data: (product) => product != null ? _buildContent(product) : _buildNotFound(),
  loading: () => _buildLoading(),
  error: (err, _) => _buildError(err),
);
```

### Tóm tắt chuyển đổi

| Bước | Input | Output |
|------|-------|--------|
| Repository | `getProductById(id)` | `ProductModel?` (raw) |
| Service | `ProductModel?` | `Future<ProductModel?>` (có thể thêm xử lý) |
| ViewModel | `Future<ProductModel?>` | `AsyncValue<ProductModel?>` (Loading/Success/Error) |
| View | `AsyncValue` | UI: spinner, content, hoặc error message |

ViewModel không chỉ “chuyển tay” data mà **chuyển dữ liệu thô thành trạng thái phù hợp với UI** (loading, success, error), giúp View chỉ cần render theo state.

---

## 📚 Tư duy tự học: Đặt tên và tổ chức file theo MVVM

### 1. Đặt tên file và thư mục

| Thành phần | Quy ước | Ví dụ |
|------------|---------|-------|
| **View** | `[feature]_view.dart` hoặc `[feature]_screen.dart` | `product_detail_view.dart` |
| **ViewModel** | `[feature]_viewmodel.dart` hoặc `[feature]_notifier.dart` | `product_detail_viewmodel.dart` |
| **Model** | `[entity]_model.dart` | `product_model.dart` |
| **Service** | `[feature]_service.dart` | `product_detail_service.dart` |
| **State** | `[feature]_state.dart` | `login_state.dart` |
| **Event** | `[feature]_event.dart` | `login_event.dart` |

**Lưu ý:**
- Tránh trùng tên với Flutter (ví dụ `FormState` → dùng `AuthFormState`).
- Dùng snake_case cho file: `product_detail_view.dart`, không `ProductDetailView.dart`.

### 2. Tổ chức theo feature

```
features/
└── product_detail/
    ├── models/       # Model dùng trong feature
    ├── services/     # Logic lấy/xử lý data
    ├── viewmodels/   # State, transformation
    └── views/        # UI
```

**Lợi ích:**
- Mở feature nào đọc đủ logic của feature đó.
- Dễ thêm/xóa feature mà ít ảnh hưởng chỗ khác.
- Có thể tách package/package riêng nếu cần.

### 3. Quy ước đặt tên trong code

| Loại | Quy ước | Ví dụ |
|------|---------|-------|
| Provider | `[feature]Provider` hoặc `[feature]ViewModelProvider` | `productDetailViewModelProvider` |
| State class | `[Feature]State` | `LoginState`, `AuthFormState` |
| Event class | `[Action]Event` hoặc verb | `LoginRequested`, `RegisterRequested` |
| Service | `[Feature]Service` | `ProductDetailService` |

### 4. Imports – tránh đan chéo

- **ViewModel** chỉ import: Model, Service (không import View).
- **View** import ViewModel và Model (không import Service trực tiếp).
- Dùng `package:` thay vì `../` khi import xuyên package.

### 5. Kinh nghiệm đọc dự án MVVM

1. Bắt đầu từ **View** → xem UI dùng state/event gì.
2. Đọc **ViewModel** → xem logic và chuyển đổi data.
3. Xem **Service/Repository** → hiểu nguồn dữ liệu.
4. Đọc **Model** để hiểu cấu trúc dữ liệu.

### 6. Checklist tổ chức MVVM

- [ ] Mỗi feature có thư mục riêng (models, views, viewmodels, services).
- [ ] Tên file nhất quán (snake_case, hậu tố _view, _viewmodel, …).
- [ ] View không gọi Service/Repository trực tiếp.
- [ ] ViewModel không import Widget/View.
- [ ] UI State rõ ràng (Loading, Success, Error).

---

## 📁 Cấu trúc thư mục

```
lib/
├── main.dart
├── app.dart
│
├── core/                      # Core chung
│   ├── constants/
│   ├── mixins/
│   └── services/
│
├── data/                      # Data layer
│   ├── datasources/
│   ├── models/
│   └── repositories/
│
├── domain/                    # Domain entities
│   └── entities/
│
├── features/                  # Feature theo MVVM
│   └── product_detail/
│       ├── models/
│       ├── services/
│       ├── viewmodels/
│       └── views/
│
└── presentation/
    ├── auth/                  # Auth (BLoC + Cubit)
    │   ├── form/
    │   └── login/
    ├── screens/
    ├── providers/
    └── widgets/
```

---

## 🛠️ Công nghệ

| Package | Mục đích |
|---------|----------|
| `flutter_bloc` | BLoC, Cubit – state management Auth |
| `flutter_riverpod` | Provider – state management giỏ hàng, product detail |
| `google_fonts` | Font Inter – hỗ trợ tiếng Việt |
| `shared_preferences` | Lưu giỏ hàng offline |

---

## 🚀 Cài đặt và chạy

### Yêu cầu

- Flutter SDK: **3.10+**
- Dart: **3.10+**

### Các bước

```bash
# 1. Clone repo
git clone https://github.com/toanlion24/Group8_MVC-and-MVVM-architecture-in-Flutter.git
cd Group8_MVC-and-MVVM-architecture-in-Flutter

# 2. Cài dependencies
flutter pub get

# 3. Chạy ứng dụng
flutter run
```

### Chạy theo nền tảng

```bash
# Web (Chrome)
flutter run -d chrome

# Android
flutter run -d android

# iOS (macOS)
flutter run -d ios

# Windows
flutter run -d windows
```

---

## 📸 Demo đăng nhập

**Credential demo:**
- Email: bất kỳ có `@` (vd: `test@demo.com`)
- Mật khẩu: tối thiểu 6 ký tự (vd: `123456`)

---

## 👥 Thành viên

**Nhóm 8** – Kiến trúc MVC và MVVM trong Flutter

---

## 📄 License

Dự án dùng cho mục đích học tập và demo.
