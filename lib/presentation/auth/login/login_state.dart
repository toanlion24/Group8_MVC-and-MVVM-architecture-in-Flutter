// =============================================================================
// PHỎNG VẤN KIẾN THỨC - login_state.dart (State của luồng đăng nhập)
// =============================================================================
//
//   Q1. Tại sao có LoginInitial, LoginLoading, LoginSuccess, LoginFailure? Thiếu một cái thì sao?
//   A1. Mô hình state rõ ràng cho luồng async: Initial (chưa gửi), Loading (đang gọi),
//       Success/Failure (xong). Thiếu Loading thì UI không biết lúc nào hiện spinner;
//       thiếu Initial có thể dùng Loading làm mặc định nhưng khó phân biệt "chưa gửi" vs "đang gửi".
//
//   Q2. LoginFailure có message còn LoginSuccess không có data — có nên thêm user/token vào Success không?
//   A2. Có thể: LoginSuccess(user) hoặc LoginSuccess(token) để lưu thông tin đăng nhập.
//       Dự án demo chỉ cần biết "thành công" để pushReplacement(HomeScreen); không lưu user.
//       Production thường emit Success kèm model User hoặc token.
//
//   Q3. AuthScreen dùng BlocConsumer<LoginBloc, LoginState> — listener và builder khác nhau thế nào?
//   A3. listener: chạy khi state thay đổi (side effect), không return widget — dùng để
//       Navigator.pushReplacement khi LoginSuccess, hoặc showDialog khi Failure. builder:
//       return widget theo state (hiện form, hiện loading, hiện nút). listener 1 lần khi
//       state đổi; builder rebuild mỗi khi state đổi.
//
// -----------------------------------------------------------------------------
// LOGIC TRONG FILE: sealed LoginState; 4 subclass: Initial, Loading, Success, Failure(message).
// -----------------------------------------------------------------------------
// LOGIC TRONG DỰ ÁN: LoginBloc emit Initial → (add event) → Loading → Success hoặc Failure.
//   AuthScreen listener: if (state is LoginSuccess) pushReplacement(HomeScreen). builder: hiện form/loading.
// -----------------------------------------------------------------------------

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
