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
