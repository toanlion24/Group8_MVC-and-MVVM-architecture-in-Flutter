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
