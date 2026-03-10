class AuthUser {
  final String phone;
  final String otp;

  AuthUser({required this.phone, required this.otp});

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'otp': otp,
    };
  }
}
