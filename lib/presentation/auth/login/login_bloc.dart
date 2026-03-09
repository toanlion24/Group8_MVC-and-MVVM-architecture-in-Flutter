// =============================================================================
// PHỎNG VẤN KIẾN THỨC - login_bloc.dart (BLoC xử lý đăng nhập/đăng ký)
// =============================================================================
//
//   Q1. Bloc nhận event từ đâu? Luồng từ UI đến emit state diễn ra thế nào?
//   A1. UI gọi context.read<LoginBloc>().add(LoginRequested(email, password)). Bloc nhận event,
//       gọi handler đã đăng ký (on<LoginRequested>) → handler emit Loading → await repository
//       → emit Success hoặc Failure. BlocConsumer/BlocBuilder rebuild theo state.
//
//   Q2. on<LoginRequested>(_onLoginRequested) nghĩa là gì? Có thể đăng ký nhiều handler cho cùng event không?
//   A2. on<Event>(handler): khi add(Event), Bloc gọi handler(event, emit). Một event type chỉ
//       nên map một handler; nhiều handler cho cùng event thì chỉ handler đăng ký sau được gọi (override).
//
//   Q3. Tại sao emit(LoginLoading()) ngay đầu handler, rồi mới await repository?
//   A3. Để UI biết đang xử lý: builder thấy state is LoginLoading thì hiện CircularProgressIndicator.
//       Nếu không emit Loading trước await thì user không thấy feedback trong lúc chờ.
//
//   Q4. LoginBloc cần AuthRepository — ai tạo và inject (app.dart hay AuthScreen)?
//   A4. app.dart tạo: BlocProvider(create: (_) => LoginBloc(AuthRepository())). Repository
//       inject vào Bloc tại nơi provide (dependency injection tại root).
//
// -----------------------------------------------------------------------------
// LOGIC TRONG FILE: LoginBloc(Repository), on<LoginRequested> và on<RegisterRequested>.
//   Mỗi handler: emit Loading → await repository → Success hoặc Failure (try/catch).
// -----------------------------------------------------------------------------
// LOGIC TRONG DỰ ÁN: AuthScreen add(event) với email/password từ FormCubit state.
//   Bloc emit Success → listener trong AuthScreen pushReplacement(HomeScreen).
// -----------------------------------------------------------------------------

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

/// LoginBloc - Xử lý luồng đăng nhập
/// Nhận LoginRequested -> emit Loading -> Success hoặc Failure
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._authRepository) : super(LoginInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
  }

  final AuthRepository _authRepository;

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      final success =
          await _authRepository.login(event.email, event.password);
      if (success) {
        emit(LoginSuccess());
      } else {
        emit(LoginFailure(message: 'Email hoặc mật khẩu không đúng'));
      }
    } catch (e) {
      emit(LoginFailure(message: e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      final success =
          await _authRepository.register(event.email, event.password);
      if (success) {
        emit(LoginSuccess());
      } else {
        emit(LoginFailure(
            message: 'Đăng ký thất bại. Email hợp lệ, mật khẩu >= 6 ký tự'));
      }
    } catch (e) {
      emit(LoginFailure(message: e.toString()));
    }
  }
}
