/// Domain model representing the authenticated user.
class UserModel {
  final String? phone;
  final String? fcmToken;

  const UserModel({this.phone, this.fcmToken});

  UserModel copyWith({String? phone, String? fcmToken}) {
    return UserModel(
      phone: phone ?? this.phone,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
