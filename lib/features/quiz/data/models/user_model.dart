import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.fullName,
    required super.dateOfBirth,
    super.email,
    super. gender,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json['fullName'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      email: json['email'] as String?,
      gender: json['gender'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'email': email,
      'gender': gender,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      fullName: user.fullName,
      dateOfBirth: user.dateOfBirth,
      email: user.email,
      gender: user.gender,
    );
  }
}