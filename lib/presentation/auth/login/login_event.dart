// =============================================================================
// PHỎNG VẤN KIẾN THỨC - login_event.dart (Event cho Login BLoC)
// =============================================================================
//
//   Q1. sealed class LoginEvent là gì? Lợi ích so với abstract class hoặc enum?
//   A1. sealed class: chỉ các subclass trong cùng file mới được kế thừa; khi switch/if
//       trên LoginEvent, compiler biết đủ các trường hợp nên bắt exhaustiveness. abstract
//       class cho phép subclass ở file khác; enum không mang data (email, password) tiện.
//
//   Q2. LoginRequested và RegisterRequested đều có email, password — tại sao không dùng 1 event + enum type?
//   A2. Có thể dùng 1 event (LoginAction type: login | register) nhưng tách 2 class giúp
//       Bloc map rõ: on<LoginRequested> và on<RegisterRequested> gọi _onLogin / _onRegister.
//       Mỗi event tự mang data, đọc code dễ hơn.
//
//   Q3. Trong dự án ai tạo và dispatch LoginRequested? Bloc nhận event ở đâu?
//   A3. AuthScreen: khi bấm "Đăng nhập" gọi context.read<LoginBloc>().add(LoginRequested(
//       formState.email, formState.password)). Bloc đăng ký trong constructor: on<LoginRequested>
//       (_onLoginRequested), on<RegisterRequested>(_onRegisterRequested).
//
// -----------------------------------------------------------------------------
// LOGIC TRONG FILE: sealed LoginEvent; 2 subclass LoginRequested và RegisterRequested,
//   mỗi cái giữ email + password.
// -----------------------------------------------------------------------------
// LOGIC TRONG DỰ ÁN: AuthScreen add(LoginRequested | RegisterRequested) → LoginBloc
//   xử lý → gọi AuthRepository → emit LoginSuccess / LoginFailure.
// -----------------------------------------------------------------------------

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
