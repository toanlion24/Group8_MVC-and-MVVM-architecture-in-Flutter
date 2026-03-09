// =============================================================================
// PHỎNG VẤN KIẾN THỨC - auth_form_state.dart (State cho Form Cubit)
// =============================================================================
//
//   Q1. Tại sao không dùng tên FormState? Immutable state là gì, lợi ích thế nào?
//   A1. FormState trùng tên với Flutter (FormState của Form widget). Immutable state:
//       không sửa field sau khi tạo; mỗi lần đổi thì tạo instance mới (copyWith).
//       Lợi ích: dễ so sánh, debug, tránh side effect, phù hợp Bloc/Cubit (emit bản mới).
//
//   Q2. copyWith dùng để làm gì? Tại sao không gán trực tiếp state.email = value?
//   A2. copyWith tạo bản sao với một vài field thay đổi; field không truyền giữ nguyên.
//       Cubit/Bloc emit state mới thay vì sửa state cũ (immutability). Nếu gán trực tiếp
//       state.email = value thì vi phạm immutable và Bloc có thể không nhận ra thay đổi.
//
//   Q3. isValid là getter — khi nào nó được tính? BlocBuilder rebuild có tính lại không?
//   A3. Mỗi lần truy cập state.isValid (ví dụ trong BlocBuilder) thì getter được tính.
//       BlocBuilder rebuild khi Cubit emit state mới; lúc đó state thay đổi nên isValid
//       tính lại theo state mới (email, password, emailError, passwordError).
//
// -----------------------------------------------------------------------------
// LOGIC TRONG FILE: Class immutable AuthFormState (email, password, lỗi). copyWith
//   để tạo bản mới; isValid = form đủ và không còn lỗi validate.
// -----------------------------------------------------------------------------
// LOGIC TRONG DỰ ÁN: FormCubit emit AuthFormState. AuthScreen BlocBuilder lấy state
//   để hiển thị TextField (value/error) và bật/tắt nút (isValid). Mỗi onChanged gọi
//   Cubit → emit state mới → rebuild.
// -----------------------------------------------------------------------------

/// AuthFormState - State cho Cubit quản lý Form đăng nhập/đăng ký
/// (Đặt tên AuthFormState để tránh xung đột với FormState của Flutter)
class AuthFormState {
  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;

  const AuthFormState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
  });

  AuthFormState copyWith({
    String? email,
    String? password,
    String? emailError,
    String? passwordError,
  }) {
    return AuthFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: emailError,
      passwordError: passwordError,
    );
  }

  bool get isValid =>
      email.isNotEmpty &&
      password.isNotEmpty &&
      (emailError == null || emailError!.isEmpty) &&
      (passwordError == null || passwordError!.isEmpty);
}
