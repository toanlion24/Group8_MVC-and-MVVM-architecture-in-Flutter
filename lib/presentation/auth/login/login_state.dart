/// LoginState - Các trạng thái của luồng đăng nhập
/// Initial, Loading, Success, Failure
sealed class LoginState {}

/// Trạng thái ban đầu
class LoginInitial extends LoginState {}

/// Đang xử lý đăng nhập
class LoginLoading extends LoginState {}

/// Đăng nhập thành công
class LoginSuccess extends LoginState {}

/// Đăng nhập thất bại
class LoginFailure extends LoginState {
  final String message;

  LoginFailure({required this.message});
}
