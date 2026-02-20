/// AuthRepository - Demo đăng nhập/đăng ký giả lập
class AuthRepository {
  /// Demo login: chấp nhận bất kỳ email/password nào
  /// Thành công nếu email có chứa '@' và password >= 6 ký tự
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return email.contains('@') && password.length >= 6;
  }

  /// Demo register: tương tự login
  Future<bool> register(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return email.contains('@') && password.length >= 6;
  }
}
