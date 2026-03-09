// =============================================================================
// PHỎNG VẤN KIẾN THỨC - auth_repository.dart (Data / Auth)
// =============================================================================
//
//   Q1. Repository pattern là gì? Tại sao không gọi API trực tiếp từ BLoC/UI?
//   A1. Repository là lớp trung gian giữa data source (API, DB) và domain/presentation.
//       Tách logic lấy dữ liệu khỏi BLoC/UI: đổi API hoặc nguồn data chỉ sửa Repository,
//       BLoC/UI giữ nguyên. Dễ test (mock Repository).
//
//   Q2. AuthRepository trả về Future<bool> — trong dự án ai gọi và dùng kết quả thế nào?
//   A2. LoginBloc gọi (trong app.dart: LoginBloc(AuthRepository())). Khi nhận event
//       LoginRequested/RegisterRequested, Bloc gọi _authRepository.login/register,
//       await kết quả rồi emit LoginSuccess() hoặc LoginFailure(message).
//
//   Q3. Future.delayed(1500) dùng để làm gì? Có ảnh hưởng đến UX không?
//   A3. Giả lập độ trễ mạng; user thấy loading 1.5s. Có ảnh hưởng UX (cảm giác chờ),
//       nhưng giúp test loading state. Production thay bằng call API thật.
//
// -----------------------------------------------------------------------------
// LOGIC TRONG FILE: Class AuthRepository, 2 method async login/register.
//   Cùng logic: delay 1.5s → return true nếu email chứa '@' và password.length >= 6.
// -----------------------------------------------------------------------------
// LOGIC TRONG DỰ ÁN: LoginBloc nhận event → gọi repository → emit state. UI không
//   gọi Repository trực tiếp; AuthScreen chỉ dispatch event và listen LoginBloc.
// -----------------------------------------------------------------------------

/// AuthRepository - Demo đăng nhập/đăng ký giả lập
class AuthRepository {
  /// Demo login: chấp nhận bất kỳ email/password nào
  /// Thành công nếu email có chứa '@' và password >= 6 ký tự
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return email.contains('@') && password.length >= 6;
  }

  /// Demo register: tương tự login
  Future<bool> register(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return email.contains('@') && password.length >= 6;
  }
}
