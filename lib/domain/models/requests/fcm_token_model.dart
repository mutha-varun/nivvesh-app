class FcmTokenRequest {
  final String phone;
  final String fcmToken;
  final String platform;

  FcmTokenRequest({
    required this.phone,
    required this.fcmToken,
    required this.platform,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'fcmToken': fcmToken,
      'platform': platform,
    };
  }
}
