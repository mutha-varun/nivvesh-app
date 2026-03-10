class OtpResponseData {
  final String message;
  final String redirectUrl;

  OtpResponseData({
    required this.message,
    required this.redirectUrl,
  });

  factory OtpResponseData.fromJson(Map<String, dynamic> json) {
    return OtpResponseData(
      message: json['message'] as String? ?? '',
      redirectUrl: json['redirect_url'] as String? ?? '',
    );
  }
}