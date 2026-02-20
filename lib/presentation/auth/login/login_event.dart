/// LoginEvent - Các sự kiện của Login BLoC
sealed class LoginEvent {}

/// Sự kiện yêu cầu đăng nhập
class LoginRequested extends LoginEvent {
  final String email;
  final String password;

  LoginRequested(this.email, this.password);
}

/// Sự kiện yêu cầu đăng ký
class RegisterRequested extends LoginEvent {
  final String email;
  final String password;

  RegisterRequested(this.email, this.password);
}
