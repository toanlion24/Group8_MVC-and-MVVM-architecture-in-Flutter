// =============================================================================
// PHỎNG VẤN KIẾN THỨC - auth_screen.dart (Màn hình đăng nhập/đăng ký)
// =============================================================================
//
//   Q1. AuthScreen là StatefulWidget — state nội bộ (_isLogin) dùng để làm gì? Có conflict với FormCubit/LoginBloc không?
//   A1. _isLogin chỉ đổi tab "Đăng nhập" / "Đăng ký" và nhãn nút (không gửi lên server).
//       FormCubit giữ giá trị form + validate; LoginBloc giữ luồng login/register. Không conflict:
//       local UI state (tab) tách với form state và auth state.
//
//   Q2. BlocConsumer<LoginBloc, LoginState>: listener vs builder dùng thế nào trong màn này?
//   A2. listener: khi state is LoginSuccess → pushReplacement(HomeScreen) (side effect, không build widget).
//       builder: nhận loginState để hiện UI — ví dụ state is LoginLoading thì hiện loading, state is
//       LoginFailure thì hiện error card; form và nút lấy từ BlocBuilder<FormCubit, AuthFormState>.
//
//   Q3. Khi bấm "Đăng nhập", email/password lấy từ đâu? FormCubit và LoginBloc kết hợp thế nào?
//   A3. BlocBuilder<FormCubit, AuthFormState> cho formState; khi bấm nút dùng formState.email,
//       formState.password. context.read<LoginBloc>().add(LoginRequested(formState.email, formState.password))
//       (hoặc RegisterRequested nếu _isLogin == false). FormCubit = nguồn dữ liệu form, LoginBloc = thực thi đăng nhập.
//
//   Q4. pushReplacement(HomeScreen()) khác push() thế nào? Sau khi replace, AuthScreen còn trong stack không?
//   A4. push: thêm HomeScreen lên stack, Back quay lại AuthScreen. pushReplacement: thay AuthScreen
//       bằng HomeScreen, stack chỉ còn HomeScreen, Back sẽ thoát app. Sau replace, AuthScreen không còn trong stack.
//
// -----------------------------------------------------------------------------
// LOGIC TRONG FILE: StatefulWidget (_isLogin). BlocConsumer LoginBloc (listener: Success→replace;
//   builder: form + nút). BlocBuilder FormCubit cho TextField và isValid. Nút gửi add(LoginRequested|RegisterRequested).
// -----------------------------------------------------------------------------
// LOGIC TRONG DỰ ÁN: Là home của MaterialApp. Cung cấp FormCubit/LoginBloc từ app.dart;
//   đăng nhập thành công → chuyển sang HomeScreen (danh sách sản phẩm + giỏ hàng).
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../screens/home_screen.dart';
import 'form/form_cubit.dart';
import 'form/auth_form_state.dart';
import 'login/login_bloc.dart';
import 'login/login_event.dart';
import 'login/login_state.dart';

/// AuthScreen - Giao diện Đăng nhập/Đăng ký hiện đại
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    colorScheme.surface,
                    colorScheme.surface.withOpacity(0.95),
                  ]
                : [
                    colorScheme.primaryContainer.withOpacity(0.4),
                    colorScheme.secondaryContainer.withOpacity(0.3),
                  ],
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state is LoginSuccess) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const HomeScreen(),
                  ),
                );
              }
            },
            builder: (context, loginState) {
              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        // Logo & Brand
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.15),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.2),
                                blurRadius: 24,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.shopping_bag_rounded,
                            size: 56,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Shopping Cart',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Mua sắm tiện lợi mọi lúc mọi nơi',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Card chứa form
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: isDark
                                ? colorScheme.surfaceContainerHighest
                                : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.05),
                                blurRadius: 40,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Tab Đăng nhập / Đăng ký
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest
                                      .withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    _buildTab(
                                      label: 'Đăng nhập',
                                      selected: _isLogin,
                                      onTap: () =>
                                          setState(() => _isLogin = true),
                                      colorScheme: colorScheme,
                                    ),
                                    _buildTab(
                                      label: 'Đăng ký',
                                      selected: !_isLogin,
                                      onTap: () =>
                                          setState(() => _isLogin = false),
                                      colorScheme: colorScheme,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Form fields
                              BlocBuilder<FormCubit, AuthFormState>(
                                builder: (context, formState) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _buildTextField(
                                        context: context,
                                        label: 'Email',
                                        hint: 'email@example.com',
                                        icon: Icons.email_outlined,
                                        errorText: formState.emailError,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        onChanged: context
                                            .read<FormCubit>()
                                            .emailChanged,
                                      ),
                                      const SizedBox(height: 20),
                                      _buildTextField(
                                        context: context,
                                        label: 'Mật khẩu',
                                        hint: 'Tối thiểu 6 ký tự',
                                        icon: Icons.lock_outline_rounded,
                                        errorText: formState.passwordError,
                                        obscureText: true,
                                        onChanged: context
                                            .read<FormCubit>()
                                            .passwordChanged,
                                      ),
                                      const SizedBox(height: 28),

                                      // Error message
                                      if (loginState is LoginFailure) ...[
                                        _buildErrorCard(
                                          context: context,
                                          message: loginState.message,
                                        ),
                                        const SizedBox(height: 20),
                                      ],

                                      // Buttons
                                      BlocBuilder<LoginBloc, LoginState>(
                                        builder: (context, state) {
                                          if (state is LoginLoading) {
                                            return const SizedBox(
                                              height: 56,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            );
                                          }
                                          return Column(
                                            children: [
                                              FilledButton(
                                                onPressed: formState.isValid
                                                    ? () => context
                                                            .read<LoginBloc>()
                                                            .add(_isLogin
                                                                ? LoginRequested(
                                                                    formState
                                                                        .email,
                                                                    formState
                                                                        .password,
                                                                  )
                                                                : RegisterRequested(
                                                                    formState
                                                                        .email,
                                                                    formState
                                                                        .password,
                                                                  ))
                                                    : null,
                                                style: FilledButton.styleFrom(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 18,
                                                  ),
                                                  shape:
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            14),
                                                  ),
                                                  elevation: 0,
                                                ),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children: [
                                                      Icon(
                                                        _isLogin
                                                            ? Icons.login_rounded
                                                            : Icons
                                                                .person_add_rounded,
                                                        size: 22,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        _isLogin
                                                            ? 'Đăng nhập'
                                                            : 'Tạo tài khoản',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                        overflow:
                                                            TextOverflow.ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                formState.isValid
                                                    ? 'Hoặc thử cách khác'
                                                    : 'Vui lòng nhập đầy đủ thông tin',
                                                style: theme
                                                    .textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: colorScheme
                                                      .onSurfaceVariant
                                                      .withOpacity(0.7),
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              if (formState.isValid)
                                                const SizedBox(height: 12),
                                              if (formState.isValid)
                                                OutlinedButton(
                                                  onPressed: () => context
                                                      .read<LoginBloc>()
                                                      .add(_isLogin
                                                          ? RegisterRequested(
                                                              formState.email,
                                                              formState
                                                                  .password,
                                                            )
                                                          : LoginRequested(
                                                              formState.email,
                                                              formState
                                                                  .password,
                                                            )),
                                                  style: OutlinedButton.styleFrom(
                                                    padding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                      vertical: 16,
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(14),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    _isLogin
                                                        ? 'Chưa có tài khoản? Đăng ký'
                                                        : 'Đã có tài khoản? Đăng nhập',
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: selected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required String hint,
    required IconData icon,
    required void Function(String) onChanged,
    String? errorText,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasError = errorText != null && errorText.isNotEmpty;

    return TextField(
      onChanged: onChanged,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        prefixIcon: Icon(
          icon,
          size: 22,
          color: hasError
              ? colorScheme.error
              : colorScheme.onSurfaceVariant.withOpacity(0.7),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: hasError
                ? colorScheme.error.withOpacity(0.5)
                : colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: hasError ? colorScheme.error : colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
    );
  }

  Widget _buildErrorCard({
    required BuildContext context,
    required String message,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: colorScheme.onErrorContainer,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colorScheme.onErrorContainer,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
