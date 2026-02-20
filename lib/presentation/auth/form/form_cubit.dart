import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_form_state.dart';

/// FormCubit - Quản lý state đơn giản của Form (Cubit)
class FormCubit extends Cubit<AuthFormState> {
  FormCubit() : super(const AuthFormState());

  void emailChanged(String value) {
    final emailError = value.isEmpty
        ? 'Email không được để trống'
        : (!value.contains('@') ? 'Email không hợp lệ' : null);
    emit(state.copyWith(email: value, emailError: emailError));
  }

  void passwordChanged(String value) {
    final passwordError = value.isEmpty
        ? 'Mật khẩu không được để trống'
        : (value.length < 6 ? 'Mật khẩu tối thiểu 6 ký tự' : null);
    emit(state.copyWith(password: value, passwordError: passwordError));
  }

  void reset() {
    emit(const AuthFormState());
  }
}
