// =============================================================================
// PHỎNG VẤN KIẾN THỨC - form_cubit.dart (Cubit quản lý form)
// =============================================================================
//
//   Q1. Cubit khác Bloc thế nào? Khi nào dùng Cubit, khi nào dùng Bloc?
//   A1. Cubit: UI gọi method trực tiếp (emailChanged, passwordChanged). Bloc: UI dispatch
//       event (LoginRequested), Bloc map event → state. Cubit đơn giản cho form/local state;
//       Bloc khi có nhiều event hoặc cần trace event rõ ràng.
//
//   Q2. super(const AuthFormState()) nghĩa là gì? emit() làm gì với BlocBuilder?
//   A2. super(initialState): state ban đầu của Cubit. emit(newState) cập nhật state và
//       thông báo cho listener (BlocBuilder/BlocConsumer) → rebuild với state mới.
//
//   Q3. FormCubit không nhận event từ bên ngoài — UI gọi Cubit thế nào?
//   A3. UI lấy Cubit bằng context.read<FormCubit>() (trong app.dart đã provide). Mỗi lần
//       TextField onChanged, gọi context.read<FormCubit>().emailChanged(value). Cubit
//       validate và emit state mới; BlocBuilder nhận state và cập nhật errorText, isValid.
//
// -----------------------------------------------------------------------------
// LOGIC TRONG FILE: FormCubit extends Cubit<AuthFormState>. emailChanged/passwordChanged
//   validate → copyWith → emit. reset() emit state rỗng.
// -----------------------------------------------------------------------------
// LOGIC TRONG DỰ ÁN: AuthScreen có BlocBuilder<FormCubit, AuthFormState>; TextField
//   onChanged gọi FormCubit; nút Đăng nhập/Đăng ký bật khi formState.isValid.
// -----------------------------------------------------------------------------

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
